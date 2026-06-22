import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/barber/agenda/data/mappers/agenda_mappers.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';

const List<String> _kVisibleAgendaStatuses = ['pending', 'confirmed', 'completed'];

@LazySingleton(as: AgendaRepository)
class AgendaSupabaseRepository implements AgendaRepository {
  final SupabaseClient _client;

  AgendaSupabaseRepository(this._client);

  @override
  Future<List<AgendaAppointment>> fetchAgendaForDay({
    required String barberId,
    required DateTime day,
  }) async {
    final dayStart = DateTime(day.year, day.month, day.day).toUtc();
    final dayEnd = dayStart.add(const Duration(days: 1));

    final rows = await _client
        .from('reservations')
        .select(
          'id, tenant_id, branch_id, service_id, barber_id, customer_id, '
          'start_time, end_time, status, price_at_booking, notes, '
          'customer:customers!customer_id(id, full_name, whatsapp), '
          'service:services!service_id(id, name, duration_minutes, price_pen), '
          'branch:branches!branch_id(id, name)',
        )
        .eq('barber_id', barberId)
        .inFilter('status', _kVisibleAgendaStatuses)
        .filter('deleted_at', 'is', null)
        .gte('start_time', dayStart.toIso8601String())
        .lt('start_time', dayEnd.toIso8601String())
        .order('start_time', ascending: true);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(AgendaAppointmentMapper.fromRow)
        .whereType<AgendaAppointment>()
        .toList();
  }

  @override
  Future<AgendaLookupRefs> resolveDefaultRefs({
    required String barberId,
    required String tenantId,
  }) async {
    final profile = await _client
        .from('profiles')
        .select('branch_id')
        .eq('id', barberId)
        .maybeSingle();

    final defaultBranchId = profile?['branch_id'] as String?;

    String? defaultServiceId;
    if (tenantId.isNotEmpty) {
      final service = await _client
          .from('services')
          .select('id')
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .filter('deleted_at', 'is', null)
          .order('display_order', ascending: true)
          .limit(1)
          .maybeSingle();
      defaultServiceId = service?['id'] as String?;
    }

    return AgendaLookupRefs(
      defaultBranchId: defaultBranchId,
      defaultServiceId: defaultServiceId,
    );
  }

  @override
  Future<Map<String, dynamic>> registerWalkIn(WalkInRequest request) async {
    final idempotencyKey =
        'walkin_${DateTime.now().millisecondsSinceEpoch}_${request.barberId.substring(0, 8)}';
    final response = await _client.rpc<Map<String, dynamic>>(
      'create_anonymous_booking',
      params: {
        'p_tenant_id': request.tenantId,
        'p_branch_id': request.branchId,
        'p_barber_id': request.barberId,
        'p_service_id': request.serviceId,
        'p_start_time': request.startTime.toUtc().toIso8601String(),
        'p_customer_name': request.customerName,
        'p_customer_phone': request.customerPhone,
        'p_idempotency_key': idempotencyKey,
      },
    );
    return response;
  }

  @override
  Future<void> completeReservation({
    required String reservationId,
    required num amount,
    String? couponCode,
  }) async {
    final key =
        'complete_${reservationId}_${DateTime.now().millisecondsSinceEpoch}';
    await _client.rpc('complete_reservation_atomic', params: {
      'p_reservation_id': reservationId,
      'p_amount_value': amount,
      'p_payment_method': 'cash',
      'p_idempotency_key': key,
      'p_coupon_unique_code': couponCode,
    });
  }

  @override
  Future<List<AgendaCoupon>> fetchUsableCoupons({
    required String customerId,
  }) async {
    final rows = await _client
        .from('customer_coupons')
        .select(
          'unique_code, redeemed_at, valid_until, '
          'promotion:promotions!promotion_id(name, discount_type, discount_value, is_active)',
        )
        .eq('customer_id', customerId)
        .filter('redeemed_at', 'is', null);

    final now = DateTime.now();
    final out = <AgendaCoupon>[];
    for (final r in (rows as List)) {
      if (r is! Map) continue;
      final promo = r['promotion'] as Map<String, dynamic>?;
      if (promo == null || (promo['is_active'] as bool? ?? false) == false) {
        continue;
      }
      final vu = DateTime.tryParse(r['valid_until'] as String? ?? '');
      if (vu == null || vu.toLocal().isBefore(now)) continue;
      out.add(AgendaCoupon(
        code: (r['unique_code'] as String?) ?? '',
        name: (promo['name'] as String?) ?? 'Promoción',
        discountType: (promo['discount_type'] as String?) ?? 'percentage',
        discountValue: (promo['discount_value'] as num?)?.toDouble() ?? 0,
      ));
    }
    return out;
  }

  @override
  Future<void> markNoShow({required String reservationId}) async {
    final key =
        'noshow_${reservationId}_${DateTime.now().millisecondsSinceEpoch}';
    await _client.rpc('mark_no_show_atomic', params: {
      'p_reservation_id': reservationId,
      'p_idempotency_key': key,
    });
  }

  @override
  Future<void> cancelReservation({
    required String reservationId,
    required String reasonCode,
    String? note,
  }) async {
    // p_idempotency_key (uuid) se omite: la RPC ya es idempotente por status y
    // la notificacion se deduplica por reservation_id.
    await _client.rpc('cancel_reservation_blindada', params: {
      'p_reservation_id': reservationId,
      'p_reason_code': reasonCode,
      'p_note': note,
    });
  }

  @override
  Future<AgendaTodaySummary> fetchTodaySummary({required String barberId}) async {
    final now = DateTime.now();
    final startLocal = DateTime(now.year, now.month, now.day);
    final endLocal = startLocal.add(const Duration(days: 1));

    // Las 2 lecturas (cortes de hoy + proxima cita) son independientes: en
    // paralelo responde mas rapido tras cada accion del barbero.
    final results = await Future.wait([
      _client
          .from('reservations')
          .select('price_at_booking')
          .eq('barber_id', barberId)
          .eq('status', 'completed')
          .filter('deleted_at', 'is', null)
          .gte('start_time', startLocal.toUtc().toIso8601String())
          .lt('start_time', endLocal.toUtc().toIso8601String()),
      _client
          .from('reservations')
          .select('start_time')
          .eq('barber_id', barberId)
          .inFilter('status', ['pending', 'confirmed'])
          .filter('deleted_at', 'is', null)
          .gte('start_time', now.toUtc().toIso8601String())
          .order('start_time', ascending: true)
          .limit(1),
    ]);
    final completedRows = results[0];
    final nextRows = results[1];

    var cuts = 0;
    var revenue = 0.0;
    for (final r in (completedRows as List)) {
      if (r is Map) {
        cuts++;
        final p = r['price_at_booking'];
        if (p is num) revenue += p.toDouble();
      }
    }

    DateTime? nextStart;
    final nList = nextRows as List;
    if (nList.isNotEmpty &&
        nList.first is Map &&
        (nList.first as Map)['start_time'] != null) {
      nextStart =
          DateTime.tryParse((nList.first as Map)['start_time'] as String)?.toLocal();
    }

    return AgendaTodaySummary(
      completedCuts: cuts,
      revenue: revenue,
      nextStart: nextStart,
    );
  }

  @override
  Future<List<DateTime>> fetchMarkedDays({
    required String barberId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _client
        .from('reservations')
        .select('start_time')
        .eq('barber_id', barberId)
        .inFilter('status', _kVisibleAgendaStatuses)
        .filter('deleted_at', 'is', null)
        .gte('start_time', from.toUtc().toIso8601String())
        .lt('start_time', to.toUtc().toIso8601String());

    final days = <DateTime>{};
    for (final r in (rows as List)) {
      if (r is Map && r['start_time'] != null) {
        final dt = DateTime.tryParse(r['start_time'] as String)?.toLocal();
        if (dt != null) days.add(DateTime(dt.year, dt.month, dt.day));
      }
    }
    final sorted = days.toList()..sort();
    return sorted;
  }

  @override
  Stream<void> watchChanges({required String barberId}) {
    late RealtimeChannel channel;
    late StreamController<void> controller;

    Future<void> teardown() async {
      try {
        await channel.unsubscribe();
      } catch (_) {}
    }

    controller = StreamController<void>(
      onCancel: () async {
        await teardown();
        if (!controller.isClosed) await controller.close();
      },
    );

    final channelName =
        'agenda_${barberId}_${DateTime.now().microsecondsSinceEpoch}';
    channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reservations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'barber_id',
            value: barberId,
          ),
          callback: (_) {
            if (!controller.isClosed) controller.add(null);
          },
        )
        .subscribe();

    return controller.stream;
  }
}

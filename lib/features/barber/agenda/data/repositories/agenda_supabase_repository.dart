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

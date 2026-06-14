import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/reservations/domain/models/booking_result.dart';
import 'package:trim_flow/features/reservations/domain/repositories/reservation_repository.dart';

@LazySingleton(as: ReservationRepository)
class ReservationSupabaseRepository implements ReservationRepository {
  final SupabaseClient _client;

  ReservationSupabaseRepository(this._client);

  @override
  Future<List<DateTime>> fetchAvailableSlots({
    required String tenantId,
    required String branchId,
    required String barberId,
    required String serviceId,
    required DateTime date,
  }) async {
    final res = await _client.rpc('get_available_slots', params: {
      'p_tenant_id': tenantId,
      'p_branch_id': branchId,
      'p_barber_id': barberId,
      'p_service_id': serviceId,
      'p_date': _dateOnly(date),
    });

    final list = (res is List) ? res : const [];
    final slots = <DateTime>[];
    for (final item in list) {
      if (item is Map && item['start'] != null) {
        final parsed = DateTime.tryParse(item['start'] as String);
        if (parsed != null) slots.add(parsed.toUtc());
      }
    }
    slots.sort();
    return slots;
  }

  @override
  Future<BookingResult> createBooking({
    required String tenantId,
    required String branchId,
    required String barberId,
    required String serviceId,
    required DateTime startUtc,
    required String customerName,
    required String customerPhone,
    required String idempotencyKey,
  }) async {
    final startIso = startUtc.toUtc().toIso8601String();
    final isLoggedIn = _client.auth.currentUser != null;

    // Cliente autenticado -> create_app_booking (vincula identidad y GANA puntos).
    // Anonimo (sin sesion) -> create_anonymous_booking (walk-in por nombre+telefono).
    final res = isLoggedIn
        ? await _client.rpc('create_app_booking', params: {
            'p_tenant_id': tenantId,
            'p_branch_id': branchId,
            'p_barber_id': barberId,
            'p_service_id': serviceId,
            'p_start_time': startIso,
            'p_idempotency_key': idempotencyKey,
          })
        : await _client.rpc('create_anonymous_booking', params: {
            'p_tenant_id': tenantId,
            'p_branch_id': branchId,
            'p_barber_id': barberId,
            'p_service_id': serviceId,
            'p_start_time': startIso,
            'p_customer_name': customerName,
            'p_customer_phone': customerPhone,
            'p_idempotency_key': idempotencyKey,
          });

    final map = (res is Map) ? res.cast<String, dynamic>() : const <String, dynamic>{};
    return BookingResult(
      reservationId: (map['reservationId'] as String?) ?? '',
      confirmationCode: (map['confirmationCode'] as String?) ?? '',
    );
  }

  String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';
import 'package:trim_flow/features/reservations/domain/models/booking_result.dart';

abstract class ReservationRepository {
  /// Horarios libres (en UTC) para un barbero/servicio/dia, via RPC.
  Future<List<DateTime>> fetchAvailableSlots({
    required String tenantId,
    required String branchId,
    required String barberId,
    required String serviceId,
    required DateTime date,
  });

  /// Crea la reserva via RPC SECURITY DEFINER y devuelve el ticket.
  Future<BookingResult> createBooking({
    required String tenantId,
    required String branchId,
    required String barberId,
    required String serviceId,
    required DateTime startUtc,
    required String customerName,
    required String customerPhone,
    required String idempotencyKey,
    String? couponCode,
    List<Map<String, dynamic>> productItems = const [],
  });

  /// Cupones del cliente usables en este tenant (via RPC get_my_coupons).
  Future<List<CustomerCoupon>> fetchUsableCoupons({required String tenantId});
}

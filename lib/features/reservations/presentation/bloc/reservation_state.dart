import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';

part 'reservation_state.freezed.dart';

enum ReservationStatus { initial, loading, success, failure }

enum SlotsStatus { initial, loading, loaded, error }

@freezed
abstract class ReservationState with _$ReservationState {
  const factory ReservationState({
    @Default(ReservationStatus.initial) ReservationStatus status,
    @Default(1) int currentPhase,
    @Default(Reservation(tenantId: '')) Reservation reservation,
    @Default(false) bool professionalSelected,
    @Default(false) bool isDiscountActive,
    @Default(<DateTime>[]) List<DateTime> availableSlots,
    @Default(SlotsStatus.initial) SlotsStatus slotsStatus,
    DateTime? selectedSlotUtc,
    String? effectiveBarberId,
    String? idempotencyKey,
    String? errorMessage,
    @Default(<CustomerCoupon>[]) List<CustomerCoupon> availableCoupons,
    CustomerCoupon? selectedCoupon,
    @Default(0) double couponDiscount,
    double? finalPrice,
  }) = _ReservationState;
}

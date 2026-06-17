import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';

part 'reservation_event.freezed.dart';

@freezed
abstract class ReservationEvent with _$ReservationEvent {
  const factory ReservationEvent.selectCenter(BarberCenter center) = _SelectCenter;
  const factory ReservationEvent.toggleService(Service service) = _ToggleService;
  const factory ReservationEvent.selectProfessional(Professional? professional) = _SelectProfessional;
  const factory ReservationEvent.loadSlots(DateTime date, String barberId) = _LoadSlots;
  const factory ReservationEvent.selectSlot(DateTime startUtc) = _SelectSlot;
  const factory ReservationEvent.goToPhase(int phase) = _GoToPhase;
  const factory ReservationEvent.loadCoupons() = _LoadCoupons;
  const factory ReservationEvent.selectCoupon(CustomerCoupon? coupon) = _SelectCoupon;
  const factory ReservationEvent.confirmReservation({
    required String customerName,
    required String customerPhone,
  }) = _ConfirmReservation;
  const factory ReservationEvent.activateDiscount() = _ActivateDiscount;
  const factory ReservationEvent.deactivateDiscount() = _DeactivateDiscount;
  const factory ReservationEvent.reset() = _Reset;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

part 'reservation_event.freezed.dart';

@freezed
abstract class ReservationEvent with _$ReservationEvent {
  const factory ReservationEvent.selectCenter(BarberCenter center) = _SelectCenter;
  const factory ReservationEvent.toggleService(Service service) = _ToggleService;
  const factory ReservationEvent.selectProfessional(Professional? professional) = _SelectProfessional;
  const factory ReservationEvent.selectDateTime(DateTime date, String time) = _SelectDateTime;
  const factory ReservationEvent.goToPhase(int phase) = _GoToPhase;
  const factory ReservationEvent.confirmReservation() = _ConfirmReservation;
  const factory ReservationEvent.activateDiscount() = _ActivateDiscount;
  const factory ReservationEvent.deactivateDiscount() = _DeactivateDiscount;
  const factory ReservationEvent.reset() = _Reset;
}


import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

part 'reservation_state.freezed.dart';

enum ReservationStatus { initial, loading, success, failure }

@freezed
abstract class ReservationState with _$ReservationState {
  const factory ReservationState({
    @Default(ReservationStatus.initial) ReservationStatus status,
    @Default(1) int currentPhase,
    @Default(Reservation(tenantId: '')) Reservation reservation,
    @Default(false) bool professionalSelected, 
    String? errorMessage,
  }) = _ReservationState;
}

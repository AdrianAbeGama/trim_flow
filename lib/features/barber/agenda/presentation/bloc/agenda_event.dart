import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_state.dart';

part 'agenda_event.freezed.dart';

@freezed
abstract class AgendaEvent with _$AgendaEvent {
  const factory AgendaEvent.started() = AgendaStarted;
  const factory AgendaEvent.refreshRequested() = AgendaRefreshRequested;
  const factory AgendaEvent.daySelected(DateTime day) = AgendaDaySelected;
  const factory AgendaEvent.viewModeChanged(AgendaViewMode mode) =
      AgendaViewModeChanged;
  const factory AgendaEvent.realtimeTicked() = AgendaRealtimeTicked;
  const factory AgendaEvent.walkInRequested(WalkInRequest request) =
      AgendaWalkInRequested;
  const factory AgendaEvent.resolveRefsRequested() = AgendaResolveRefsRequested;
  const factory AgendaEvent.statusChanged(String appointmentId, AgendaStatus newStatus, {String? reason}) = AgendaStatusChanged;
}

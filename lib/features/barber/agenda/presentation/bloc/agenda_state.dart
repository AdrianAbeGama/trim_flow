import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';

part 'agenda_state.freezed.dart';

enum AgendaStatusUi { initial, loading, loaded, error }
enum AgendaViewMode { list, matrix }

@freezed
abstract class AgendaUiState with _$AgendaUiState {
  const factory AgendaUiState({
    @Default(AgendaStatusUi.initial) AgendaStatusUi status,
    @Default(AgendaViewMode.list) AgendaViewMode viewMode,
    required DateTime selectedDay,
    @Default(<AgendaAppointment>[]) List<AgendaAppointment> appointments,
    AgendaLookupRefs? lookupRefs,
    String? errorMessage,
    @Default(false) bool isBusy,
  }) = _AgendaUiState;

  factory AgendaUiState.initial() {
    final now = DateTime.now();
    return AgendaUiState(selectedDay: DateTime(now.year, now.month, now.day));
  }
}

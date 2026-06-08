import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_event.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaUiState> {
  final AgendaRepository _repository;
  final String barberId;
  final String tenantId;

  StreamSubscription<void>? _realtimeSub;

  AgendaBloc({
    required this.barberId,
    required this.tenantId,
    required AgendaRepository repository,
  })  : _repository = repository,
        super(AgendaUiState.initial()) {
    on<AgendaStarted>(_onStarted);
    on<AgendaRefreshRequested>(_onRefresh);
    on<AgendaDaySelected>(_onDaySelected);
    on<AgendaViewModeChanged>(_onViewModeChanged);
    on<AgendaRealtimeTicked>(_onRealtimeTicked);
    on<AgendaWalkInRequested>(_onWalkIn);
    on<AgendaResolveRefsRequested>(_onResolveRefs);
    on<AgendaStatusChanged>(_onStatusChanged);
    on<AgendaCompleteRequested>(_onCompleteRequested);
  }

  Future<void> _onStarted(AgendaStarted event, Emitter<AgendaUiState> emit) async {
    await _fetchAndEmit(emit, isFirstLoad: true);
    await _loadMarkedDays(emit);
    await _loadSummary(emit);
    add(const AgendaResolveRefsRequested());
    _realtimeSub?.cancel();
    _realtimeSub = _repository.watchChanges(barberId: barberId).listen((_) {
      if (!isClosed) add(const AgendaRealtimeTicked());
    });
  }

  Future<void> _onRefresh(
      AgendaRefreshRequested event, Emitter<AgendaUiState> emit) async {
    await _fetchAndEmit(emit, isFirstLoad: false);
  }

  Future<void> _onDaySelected(
      AgendaDaySelected event, Emitter<AgendaUiState> emit) async {
    emit(state.copyWith(
      selectedDay: DateTime(event.day.year, event.day.month, event.day.day),
    ));
    await _fetchAndEmit(emit, isFirstLoad: false);
  }

  void _onViewModeChanged(
      AgendaViewModeChanged event, Emitter<AgendaUiState> emit) {
    emit(state.copyWith(viewMode: event.mode));
  }

  Future<void> _onRealtimeTicked(
      AgendaRealtimeTicked event, Emitter<AgendaUiState> emit) async {
    await _fetchAndEmit(emit, isFirstLoad: false);
    await _loadMarkedDays(emit);
    await _loadSummary(emit);
  }

  Future<void> _onResolveRefs(
      AgendaResolveRefsRequested event, Emitter<AgendaUiState> emit) async {
    try {
      final refs = await _repository.resolveDefaultRefs(
        barberId: barberId,
        tenantId: tenantId,
      );
      emit(state.copyWith(lookupRefs: refs));
    } catch (e, stack) {
      debugPrint('AgendaBloc.resolveRefs error: $e\n$stack');
    }
  }

  Future<void> _onWalkIn(
      AgendaWalkInRequested event, Emitter<AgendaUiState> emit) async {
    emit(state.copyWith(isBusy: true));
    try {
      await _repository.registerWalkIn(event.request);
      await _fetchAndEmit(emit, isFirstLoad: false);
      await _loadMarkedDays(emit);
      await _loadSummary(emit);
    } catch (e, stack) {
      debugPrint('AgendaBloc.walkIn error: $e\n$stack');
      emit(state.copyWith(
        isBusy: false,
        status: AgendaStatusUi.error,
        errorMessage: 'No pudimos registrar el walk-in.',
      ));
      return;
    }
    emit(state.copyWith(isBusy: false));
  }

  Future<void> _fetchAndEmit(Emitter<AgendaUiState> emit,
      {required bool isFirstLoad}) async {
    if (isFirstLoad) {
      emit(state.copyWith(status: AgendaStatusUi.loading, errorMessage: null));
    }
    try {
      final list = await _repository.fetchAgendaForDay(
        barberId: barberId,
        day: state.selectedDay,
      );
      emit(state.copyWith(
        status: AgendaStatusUi.loaded,
        appointments: list,
        errorMessage: null,
      ));
    } catch (e, stack) {
      debugPrint('AgendaBloc.fetch error: $e\n$stack');
      emit(state.copyWith(
        status: AgendaStatusUi.error,
        errorMessage: 'No pudimos cargar la agenda.',
      ));
    }
  }

  Future<void> _loadMarkedDays(Emitter<AgendaUiState> emit) async {
    try {
      final now = DateTime.now();
      final base = DateTime(now.year, now.month, now.day);
      final days = await _repository.fetchMarkedDays(
        barberId: barberId,
        from: base.subtract(const Duration(days: 60)),
        to: base.add(const Duration(days: 180)),
      );
      emit(state.copyWith(markedDays: days));
    } catch (e, stack) {
      debugPrint('AgendaBloc.markedDays error: $e\n$stack');
    }
  }

  Future<void> _loadSummary(Emitter<AgendaUiState> emit) async {
    try {
      final summary = await _repository.fetchTodaySummary(barberId: barberId);
      emit(state.copyWith(
        todayCuts: summary.completedCuts,
        todayRevenue: summary.revenue,
        nextStart: summary.nextStart,
      ));
    } catch (e, stack) {
      debugPrint('AgendaBloc.summary error: $e\n$stack');
    }
  }

  Future<void> _onCompleteRequested(
      AgendaCompleteRequested event, Emitter<AgendaUiState> emit) async {
    emit(state.copyWith(isBusy: true, errorMessage: null));
    try {
      await _repository.completeReservation(
        reservationId: event.appointmentId,
        amount: event.amount,
        couponCode: event.couponCode,
      );
      await _fetchAndEmit(emit, isFirstLoad: false);
      await _loadMarkedDays(emit);
      await _loadSummary(emit);
      emit(state.copyWith(isBusy: false));
    } catch (e, stack) {
      debugPrint('AgendaBloc.complete error: $e\n$stack');
      emit(state.copyWith(
        isBusy: false,
        status: AgendaStatusUi.error,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  Future<void> _onStatusChanged(
      AgendaStatusChanged event, Emitter<AgendaUiState> emit) async {
    // No asistio: se persiste via RPC SECURITY DEFINER (ADR-0015).
    if (event.newStatus == AgendaStatus.noShow) {
      emit(state.copyWith(isBusy: true, errorMessage: null));
      try {
        await _repository.markNoShow(reservationId: event.appointmentId);
        await _fetchAndEmit(emit, isFirstLoad: false);
        await _loadMarkedDays(emit);
        await _loadSummary(emit);
        emit(state.copyWith(isBusy: false));
      } catch (e, stack) {
        debugPrint('AgendaBloc.statusChanged error: $e\n$stack');
        emit(state.copyWith(
          isBusy: false,
          status: AgendaStatusUi.error,
          errorMessage: _friendlyError(e),
        ));
      }
      return;
    }

    // Confirmar / Cancelar: sin RPC dedicada todavia -> actualizacion local.
    final newList = state.appointments.map((a) {
      if (a.id == event.appointmentId) {
        return AgendaAppointment(
          id: a.id,
          tenantId: a.tenantId,
          startTime: a.startTime,
          endTime: a.endTime,
          status: event.newStatus,
          customerName: a.customerName,
          customerWhatsapp: a.customerWhatsapp,
          serviceName: a.serviceName,
          serviceDurationMinutes: a.serviceDurationMinutes,
          priceAtBooking: a.priceAtBooking,
          branchName: a.branchName,
          notes: event.reason ?? a.notes,
        );
      }
      return a;
    }).toList();
    emit(state.copyWith(appointments: newList));
  }

  String _friendlyError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('invalid_transition')) {
      return 'Esta cita ya cambió de estado. Refresca la agenda.';
    }
    if (s.contains('reservation_not_found')) return 'No se encontró la cita.';
    return 'No se pudo guardar el cambio. Intenta de nuevo.';
  }

  @override
  Future<void> close() async {
    await _realtimeSub?.cancel();
    return super.close();
  }
}

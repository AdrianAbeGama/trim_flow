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
  }

  Future<void> _onStarted(AgendaStarted event, Emitter<AgendaUiState> emit) async {
    await _fetchAndEmit(emit, isFirstLoad: true);
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
      var list = await _repository.fetchAgendaForDay(
        barberId: barberId,
        day: state.selectedDay,
      );
      
      // Inject dummy data for UI testing if empty
      if (list.isEmpty) {
        final now = DateTime.now();
        list = [
          AgendaAppointment(
            id: 'mock_1',
            tenantId: tenantId,
            startTime: DateTime(now.year, now.month, now.day, 10, 0),
            endTime: DateTime(now.year, now.month, now.day, 10, 45),
            status: AgendaStatus.confirmed,
            customerName: 'Carlos Ruiz',
            serviceName: 'Corte Clásico + Barba',
            priceAtBooking: 25.0,
          ),
          AgendaAppointment(
            id: 'mock_2',
            tenantId: tenantId,
            startTime: DateTime(now.year, now.month, now.day, 11, 30),
            endTime: DateTime(now.year, now.month, now.day, 12, 15),
            status: AgendaStatus.completed,
            customerName: 'Miguel Soto',
            serviceName: 'Fade & Cejas',
            priceAtBooking: 20.0,
          ),
          AgendaAppointment(
            id: 'mock_3',
            tenantId: tenantId,
            startTime: DateTime(now.year, now.month, now.day, 14, 0),
            endTime: DateTime(now.year, now.month, now.day, 14, 30),
            status: AgendaStatus.pending,
            customerName: 'José Pérez',
            serviceName: 'Solo Corte',
            priceAtBooking: 15.0,
          ),
        ];
      }

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

  void _onStatusChanged(
      AgendaStatusChanged event, Emitter<AgendaUiState> emit) {
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
          notes: a.notes,
        );
      }
      return a;
    }).toList();
    emit(state.copyWith(appointments: newList));
  }

  @override
  Future<void> close() async {
    await _realtimeSub?.cancel();
    return super.close();
  }
}

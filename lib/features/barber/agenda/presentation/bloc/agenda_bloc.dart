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

  // Días con citas demo (hoy, +2, +5). Permite que cada día muestre lo suyo y
  // que el calendario marque los días con citas.
  late final DateTime _refDay = _dayOnly(DateTime.now());
  List<DateTime> get demoDays => [
        _refDay,
        _refDay.add(const Duration(days: 2)),
        _refDay.add(const Duration(days: 5)),
      ];

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

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
      final list = await _repository.fetchAgendaForDay(
        barberId: barberId,
        day: state.selectedDay,
      );

      // Demo: si no hay citas reales para el día, mostramos ejemplos
      // para visualizar la agenda poblada (mock, no persiste).
      final effective = list.isEmpty ? _demoAppointments(state.selectedDay) : list;

      emit(state.copyWith(
        status: AgendaStatusUi.loaded,
        appointments: effective,
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

  List<AgendaAppointment> _demoAppointments(DateTime day) {
    final dd = _dayOnly(day);
    // Solo los días demo tienen citas; el resto queda vacío (cada día su agenda).
    if (!demoDays.any((d) => _isSameDay(d, dd))) return [];
    DateTime at(int h, int m) => DateTime(day.year, day.month, day.day, h, m);
    final all = [
      AgendaAppointment(
        id: 'demo-1', tenantId: tenantId,
        startTime: at(9, 0), endTime: at(9, 45),
        status: AgendaStatus.pending,
        customerName: 'Carlos Ruiz', customerWhatsapp: '+51 999 123 456',
        serviceName: 'Corte + Barba', serviceDurationMinutes: 45,
        priceAtBooking: 55, branchName: 'Local Centro',
        notes: 'Cliente frecuente · fade medio',
      ),
      AgendaAppointment(
        id: 'demo-2', tenantId: tenantId,
        startTime: at(10, 30), endTime: at(11, 0),
        status: AgendaStatus.confirmed,
        customerName: 'Miguel Soto', customerWhatsapp: '+51 988 222 111',
        serviceName: 'Corte Clásico', serviceDurationMinutes: 30,
        priceAtBooking: 35, branchName: 'Local Centro',
      ),
      AgendaAppointment(
        id: 'demo-3', tenantId: tenantId,
        startTime: at(12, 0), endTime: at(13, 0),
        status: AgendaStatus.completed,
        customerName: 'José Pérez', serviceName: 'Platinado Premium',
        serviceDurationMinutes: 60, priceAtBooking: 120, branchName: 'Local Centro',
        notes: 'Decolorado + matiz',
      ),
      AgendaAppointment(
        id: 'demo-4', tenantId: tenantId,
        startTime: at(15, 0), endTime: at(15, 30),
        status: AgendaStatus.cancelled,
        customerName: 'Andrés Vega', serviceName: 'Perfilado de barba',
        serviceDurationMinutes: 30, priceAtBooking: 25, branchName: 'Local Centro',
        notes: 'Imprevisto del cliente',
      ),
      AgendaAppointment(
        id: 'demo-5', tenantId: tenantId,
        startTime: at(17, 30), endTime: at(18, 15),
        status: AgendaStatus.noShow,
        customerName: 'Diego Flores', customerWhatsapp: '+51 977 333 222',
        serviceName: 'Corte + Diseño', serviceDurationMinutes: 45,
        priceAtBooking: 60, branchName: 'Local Centro',
      ),
    ];
    // Variar por día para que se note el cambio: +2 días → 2 citas, +5 → 3.
    if (_isSameDay(dd, demoDays[1])) return all.take(2).toList();
    if (_isSameDay(dd, demoDays[2])) return all.sublist(2);
    return all;
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
          notes: event.reason ?? a.notes,
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

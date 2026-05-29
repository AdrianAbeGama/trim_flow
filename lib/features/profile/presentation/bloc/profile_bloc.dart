import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:trim_flow/core/notifications/notifications.dart';
import 'package:trim_flow/core/services/auth_service.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/features/profile/data/mappers/profile_mappers.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService _authService;
  final ProfileRepository _repository;
  final AppModeBloc _appModeBloc;
  final TenantThemeBloc _tenantThemeBloc;

  StreamSubscription<AppModeState>? _modeSub;
  String? _trackedUserId;

  ProfileBloc(
    this._authService,
    this._repository,
    this._appModeBloc,
    this._tenantThemeBloc,
  ) : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<SaveProfileData>(_onSaveProfileData);
    on<ToggleEditMode>(_onToggleEditMode);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<RequestNotificationPermissionEvent>(_onRequestPermission);
    on<TestNotificationEvent>(_onTestNotification);
    on<ClaimReward>(_onClaimReward);
    on<AddScheduledReservation>(_onAddScheduledReservation);
    on<ClearBadge>(_onClearBadge);
    on<ResetFidelityCount>(_onResetFidelityCount);
    on<CancelAppointment>(_onCancelAppointment);
    on<UpdateBranchId>(_onUpdateBranchId);

    _bootstrapFromAppMode();
    _modeSub = _appModeBloc.stream.listen(_onAppModeChanged);
  }

  void _bootstrapFromAppMode() {
    final current = _appModeBloc.state;
    final userId = _authService.currentUser?.id;
    if (current.isLoggedIn && current.mode != null && userId != null) {
      _trackedUserId = userId;
      add(const ProfileEvent.load());
    }
  }

  void _onAppModeChanged(AppModeState modeState) {
    if (isClosed) return;
    final userId = _authService.currentUser?.id;

    if (!modeState.isLoggedIn || userId == null) {
      if (_trackedUserId != null || state.user != null) {
        _trackedUserId = null;
        add(const ProfileEvent.load());
      }
      return;
    }

    if (modeState.mode == null) return;

    if (userId != _trackedUserId) {
      _trackedUserId = userId;
      add(const ProfileEvent.load());
    }
  }

  AppMode _currentMode() => _appModeBloc.state.mode ?? AppMode.client;
  String _currentTenantId() => _tenantThemeBloc.state.tenantId;

  Future<void> _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    final authUser = _authService.currentUser;
    if (authUser == null) {
      emit(const ProfileState());
      return;
    }

    emit(const ProfileState(status: ProfileStatus.loading));

    final tenantId = _currentTenantId();
    final mode = _currentMode();

    try {
      final result = mode == AppMode.barber
          ? await _repository.loadStaffProfile(
              authUserId: authUser.id,
              fallbackTenantId: tenantId,
            )
          : await _repository.loadCustomerProfile(
              authUserId: authUser.id,
              fallbackTenantId: tenantId,
            );

      if (result == null) {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          user: _fallbackUser(authUser.id, authUser.email, tenantId),
          completedCuts: 0,
          isRewardAvailable: false,
          scheduledAppointments: const [],
          appointmentHistory: const [],
        ));
        return;
      }

      if (mode == AppMode.client && result.user.customerId != null) {
        final appointments = await _safeLoadAppointments(result.user.customerId!);
        final history = await _safeLoadHistory(result.user.customerId!);
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          user: result.user,
          completedCuts: result.loyaltyPoints,
          isRewardAvailable: result.isRewardAvailable,
          scheduledAppointments: appointments,
          appointmentHistory: history,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          user: result.user,
          completedCuts: result.loyaltyPoints,
          isRewardAvailable: result.isRewardAvailable,
          scheduledAppointments: const [],
          appointmentHistory: const [],
        ));
      }
    } catch (e, stack) {
      debugPrint('ProfileBloc.load error: $e\n$stack');
      emit(state.copyWith(
        status: ProfileStatus.error,
        scheduledAppointments: const [],
        appointmentHistory: const [],
      ));
    }
  }

  Future<List<Reservation>> _safeLoadAppointments(String customerId) async {
    try {
      return await _repository.loadActiveReservations(customerId: customerId);
    } catch (e) {
      debugPrint('ProfileBloc.loadActiveReservations error: $e');
      return const [];
    }
  }

  Future<List<PastAppointment>> _safeLoadHistory(String customerId) async {
    try {
      return await _repository.loadAppointmentHistory(customerId: customerId);
    } catch (e) {
      debugPrint('ProfileBloc.loadAppointmentHistory error: $e');
      return const [];
    }
  }

  Future<void> _onSaveProfileData(SaveProfileData event, Emitter<ProfileState> emit) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    emit(state.copyWith(status: ProfileStatus.loading));

    final authUserId = currentUser.id;
    final tenantId = _currentTenantId();
    final resolvedTenant = tenantId == kDefaultTenantId ? null : tenantId;
    final mode = _currentMode();

    final isBarberMode = mode == AppMode.barber;
    final input = ProfileUpdateInput(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      birthDate: isBarberMode ? '' : event.birthDate,
    );

    try {
      if (isBarberMode) {
        await _repository.updateStaffProfile(
          authUserId: authUserId,
          tenantId: resolvedTenant,
          input: input,
        );
      } else {
        await _repository.updateCustomerProfile(
          authUserId: authUserId,
          tenantId: resolvedTenant,
          input: input,
        );
      }

      final updatedUser = currentUser.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        birthDate: isBarberMode ? currentUser.birthDate : event.birthDate,
      );

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: updatedUser,
        isEditing: false,
      ));
    } catch (e, stack) {
      debugPrint('ProfileBloc.save error: $e\n$stack');
      emit(state.copyWith(status: ProfileStatus.error));
    }
  }

  void _onToggleEditMode(ToggleEditMode event, Emitter<ProfileState> emit) {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  void _onClaimReward(ClaimReward event, Emitter<ProfileState> emit) {
    if (state.completedCuts >= kLoyaltyRewardThreshold) {
      emit(state.copyWith(isBenefitActive: true));
    }
  }

  void _onToggleNotifications(ToggleNotificationsEvent event, Emitter<ProfileState> emit) {
    if (state.user != null) {
      emit(state.copyWith(user: state.user!.copyWith(notificationsEnabled: event.enabled)));
    }
  }

  Future<void> _onRequestPermission(RequestNotificationPermissionEvent event, Emitter<ProfileState> emit) async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      add(const ToggleNotificationsEvent(enabled: true));
    }
  }

  Future<void> _onTestNotification(TestNotificationEvent event, Emitter<ProfileState> emit) async {
    final mode = _currentMode();
    final idx = state.notificationIndex;
    final copy = _resolveTestNotificationCopy(mode, idx);

    try {
      const androidDetails = AndroidNotificationDetails(
        'trimflow_test_channel',
        'Trimflow Test',
        importance: Importance.max,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        id: idx,
        title: copy.$1,
        body: copy.$2,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }

    emit(state.copyWith(notificationIndex: (idx + 1) % 3));
  }

  void _onAddScheduledReservation(AddScheduledReservation event, Emitter<ProfileState> emit) {
    final updatedList = List<Reservation>.from(state.scheduledAppointments)..add(event.reservation);

    bool showBadge = false;
    if (event.reservation.date != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final resDate = DateTime(
        event.reservation.date!.year,
        event.reservation.date!.month,
        event.reservation.date!.day,
      );
      if (resDate == today || resDate == tomorrow) {
        showBadge = true;
      }
    }

    emit(state.copyWith(
      scheduledAppointments: updatedList,
      hasPendingBadge: showBadge,
    ));
  }

  void _onClearBadge(ClearBadge event, Emitter<ProfileState> emit) {
    emit(state.copyWith(hasPendingBadge: false));
  }

  void _onResetFidelityCount(ResetFidelityCount event, Emitter<ProfileState> emit) {
    final updatedUser = state.user?.copyWith(completedCuts: 0);
    emit(state.copyWith(
      completedCuts: 0,
      isBenefitActive: false,
      isRewardAvailable: false,
      user: updatedUser,
    ));
  }

  void _onCancelAppointment(CancelAppointment event, Emitter<ProfileState> emit) {
    final reservation = state.scheduledAppointments
        .where((r) => r.id == event.reservationId)
        .firstOrNull;

    final updatedScheduled = state.scheduledAppointments
        .where((r) => r.id != event.reservationId)
        .toList();

    final cancelledEntry = PastAppointment(
      centerName: reservation?.center?.name ?? 'Sede Principal',
      dateStr: reservation?.date != null
          ? '${reservation!.date!.day.toString().padLeft(2, '0')} / '
              '${reservation.date!.month.toString().padLeft(2, '0')} / '
              '${reservation.date!.year}'
          : '—',
      serviceName: reservation?.services.map((s) => s.name).join(', ') ?? 'Servicio',
      professionalName: reservation?.professional?.name ?? 'Barbero',
      status: 'cancelled',
      cancellationReason: event.reason,
      rating: 0,
      paidPrice: null,
      wasDiscounted: false,
    );

    final updatedHistory = List<PastAppointment>.from(state.appointmentHistory)
      ..insert(0, cancelledEntry);

    emit(state.copyWith(
      scheduledAppointments: updatedScheduled,
      appointmentHistory: updatedHistory,
    ));
  }

  void _onUpdateBranchId(UpdateBranchId event, Emitter<ProfileState> emit) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(branchId: event.branchId);
      emit(state.copyWith(user: updatedUser));
    }
  }

  (String, String) _resolveTestNotificationCopy(AppMode mode, int idx) {
    if (mode == AppMode.client) {
      switch (idx) {
        case 0:
          return ('Alerta de Cita', '¡Hola! Recuerda que tienes un corte programado para el día de hoy.');
        case 1:
          return ('Alerta de Cumpleaños', '¡TrimFlow te desea un feliz cumpleaños! Pide tu regalo en tu siguiente visita.');
        default:
          return ('Alerta de Inactividad', '¡Ya pasaron 30 días desde tu último corte! Tus barberos te extrañan, agenda aquí.');
      }
    }
    switch (idx) {
      case 0:
        return ('Alerta de Agenda', '¡Atención! Un cliente ha agendado una cita contigo a las 4:00 PM.');
      case 1:
        return ('Alerta de Almacén', '¡Stock Crítico! Quedan menos de 3 unidades del ítem: Cera Mate en tu almacén.');
      default:
        return ('Alerta de Sistema', '¡Hola! Tu administrador ha actualizado el catálogo de servicios de la sede.');
    }
  }

  UserProfile _fallbackUser(String authUserId, String? email, String tenantId) {
    return UserProfile(
      tenantId: tenantId,
      id: authUserId,
      firstName: 'Usuario',
      lastName: '',
      email: email ?? '',
      photoUrl: '',
      phone: '',
      birthDate: '',
      notificationsEnabled: true,
      completedCuts: 0,
    );
  }

  @override
  Future<void> close() async {
    await _modeSub?.cancel();
    return super.close();
  }
}

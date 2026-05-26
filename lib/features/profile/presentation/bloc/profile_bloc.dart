import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trim_flow/bootstrap.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

import 'package:trim_flow/core/services/auth_service.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService _authService = getIt<AuthService>();

  ProfileBloc() : super(const ProfileState()) {
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
  }

  void _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    // Citas mock iniciales
    final initialScheduled = [
      Reservation(
        tenantId: 'barberia_alpha',
        id: 'mock_active_1',
        center: const BarberCenter(
          tenantId: 'barberia_alpha',
          id: '1',
          name: 'Cercado - Principal',
          location: 'Av. Principal 123',
          imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&q=80',
        ),
        services: [
          const Service(
            tenantId: 'barberia_alpha',
            id: 's1',
            name: 'Corte Clásico',
            price: 35.0,
            durationInMinutes: 30,
            category: 'Cortes',
          )
        ],
        professional: const Professional(
          tenantId: 'barberia_alpha',
          id: 'p1',
          name: 'Juan Pérez',
          specialties: ['Clásicos'],
          yearsOfExperience: 8,
        ),
        date: DateTime.now().add(const Duration(days: 1)),
        time: '16:00 PM',
        totalPrice: 35.0,
      )
    ];

    final initialHistory = [
      const PastAppointment(
        centerName: 'Cercado - Principal',
        dateStr: '05 / 05 / 2026',
        serviceName: 'Corte + Barba',
        professionalName: 'Carlos Díaz',
        status: 'completed',
        rating: 5,
        paidPrice: 55.0,
        wasDiscounted: false,
      ),
      const PastAppointment(
        centerName: 'Cercado - Sucursal',
        dateStr: '20 / 04 / 2026',
        serviceName: 'Perfilado de Cejas',
        professionalName: 'Luis Gómez',
        status: 'cancelled',
        cancellationReason: 'El cliente no pudo asistir por motivos personales',
        rating: 3,
        paidPrice: null,
        wasDiscounted: false,
      ),
    ];

    try {
      final authUser = _authService.currentUser;
      if (authUser == null) {
        emit(state.copyWith(
          status: ProfileStatus.initial, 
          user: null,
          scheduledAppointments: initialScheduled,
          appointmentHistory: initialHistory,
        ));
        return;
      }

      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (response != null) {
        final cuts = response['completed_cuts'] ?? 2;
        final realUser = UserProfile(
          tenantId: 'barberia_alpha',
          id: response['id'] ?? authUser.id,
          firstName: response['full_name']?.split(' ').first ?? authUser.userMetadata?['full_name']?.split(' ').first ?? 'Usuario',
          lastName: (response['full_name'] as String?)?.split(' ').skip(1).join(' ') ?? authUser.userMetadata?['full_name']?.split(' ').last ?? '',
          email: response['email'] ?? authUser.email ?? '',
          photoUrl: response['avatar_url'] ?? authUser.userMetadata?['avatar_url'] ?? 'https://www.w3schools.com/howto/img_avatar.png',
          phone: response['phone'] ?? '',
          birthDate: response['birth_date'] ?? '',
          notificationsEnabled: response['notifications_enabled'] ?? true,
          completedCuts: cuts,
          history: [],
        );
        
        emit(state.copyWith(
          status: ProfileStatus.loaded, 
          user: realUser,
          completedCuts: cuts,
          isRewardAvailable: cuts == 7,
          scheduledAppointments: initialScheduled,
          appointmentHistory: initialHistory,
        ));
      } else {
        final mockUser = UserProfile(
          tenantId: 'barberia_alpha',
          id: authUser.id,
          firstName: authUser.userMetadata?['full_name']?.split(' ').first ?? 'Usuario',
          lastName: authUser.userMetadata?['full_name']?.split(' ').last ?? '',
          email: authUser.email ?? '',
          photoUrl: authUser.userMetadata?['avatar_url'] ?? 'https://www.w3schools.com/howto/img_avatar.png',
          phone: '',
          birthDate: '',
          notificationsEnabled: true,
          completedCuts: 2,
        );
        
        emit(state.copyWith(
          status: ProfileStatus.loaded, 
          user: mockUser,
          completedCuts: 2,
          isRewardAvailable: false,
          scheduledAppointments: initialScheduled,
          appointmentHistory: initialHistory,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        scheduledAppointments: initialScheduled,
        appointmentHistory: initialHistory,
      ));
    }
  }

  void _onSaveProfileData(SaveProfileData event, Emitter<ProfileState> emit) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfileStatus.loading));
    
    try {
      final supabase = Supabase.instance.client;
      final fullName = '${event.firstName} ${event.lastName}'.trim();
      
      final currentMode = getIt<AppModeBloc>().state.mode ?? AppMode.client;
      final currentTenantId = getIt<TenantThemeBloc>().state.tenantId;
      final effectiveTenantId = (currentTenantId == 'default' || currentTenantId == 'barberia_alpha') 
          ? 'bbbbbbbb-2222-4222-8222-222222222222' 
          : currentTenantId;

      if (currentMode == AppMode.barber) {
        final response = await supabase.from('profiles').update({
          'full_name': fullName,
          'phone': event.phone,
          'tenant_id': effectiveTenantId,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', state.user!.id).select();

        if (response.isEmpty) {
          await supabase.from('customers').update({
            'full_name': fullName,
            'whatsapp': '+51${event.phone}',
            'tenant_id': effectiveTenantId,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('auth_user_id', state.user!.id);
        }
      } else {
        await supabase.from('customers').update({
          'full_name': fullName,
          'whatsapp': '+51${event.phone}',
          'birth_date': event.birthDate.isEmpty ? null : event.birthDate,
          'tenant_id': effectiveTenantId,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('auth_user_id', state.user!.id);
      }

      final updatedUser = state.user!.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        birthDate: event.birthDate,
      );

      emit(state.copyWith(status: ProfileStatus.loaded, user: updatedUser, isEditing: false));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error));
    }
  }

  void _onToggleEditMode(ToggleEditMode event, Emitter<ProfileState> emit) {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  void _onClaimReward(ClaimReward event, Emitter<ProfileState> emit) {
    if (state.completedCuts == 7) {
      emit(state.copyWith(
        isBenefitActive: true,
      ));
    }
  }

  void _onToggleNotifications(ToggleNotificationsEvent event, Emitter<ProfileState> emit) {
    if (state.user != null) {
      emit(state.copyWith(user: state.user!.copyWith(notificationsEnabled: event.enabled)));
    }
  }

  void _onRequestPermission(RequestNotificationPermissionEvent event, Emitter<ProfileState> emit) async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      add(const ToggleNotificationsEvent(enabled: true));
    }
  }

  void _onTestNotification(TestNotificationEvent event, Emitter<ProfileState> emit) async {
    final currentMode = getIt<AppModeBloc>().state.mode ?? AppMode.client;
    String title = '';
    String body = '';

    final idx = state.notificationIndex;
    if (currentMode == AppMode.client) {
      if (idx == 0) {
        title = 'Alerta de Cita';
        body = '¡Hola! Recuerda que tienes un corte programado para el día de hoy.';
      } else if (idx == 1) {
        title = 'Alerta de Cumpleaños';
        body = '¡TrimFlow te desea un feliz cumpleaños! Pide tu regalo en tu siguiente visita.';
      } else {
        title = 'Alerta de Inactividad';
        body = '¡Ya pasaron 30 días desde tu último corte! Tus barberos te extrañan, agenda aquí.';
      }
    } else {
      if (idx == 0) {
        title = 'Alerta de Agenda';
        body = '¡Atención! Un cliente ha agendado una cita contigo a las 4:00 PM.';
      } else if (idx == 1) {
        title = 'Alerta de Almacén';
        body = '¡Stock Crítico! Quedan menos de 3 unidades del ítem: Cera Mate en tu almacén.';
      } else {
        title = 'Alerta de Sistema';
        body = '¡Hola! Tu administrador ha actualizado el catálogo de servicios de la sede.';
      }
    }

    final nextIdx = (idx + 1) % 3;

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
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }

    emit(state.copyWith(
      notificationIndex: nextIdx,
    ));
  }

  void _onAddScheduledReservation(AddScheduledReservation event, Emitter<ProfileState> emit) {
    final updatedList = List<Reservation>.from(state.scheduledAppointments)..add(event.reservation);
    
    bool showBadge = false;
    if (event.reservation.date != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      final resDate = DateTime(event.reservation.date!.year, event.reservation.date!.month, event.reservation.date!.day);
      if (resDate == today || resDate == tomorrow) {
        showBadge = true;
      }
    }

    emit(state.copyWith(
      scheduledAppointments: updatedList.toList(),
      hasPendingBadge: showBadge,
    ));
  }

  void _onClearBadge(ClearBadge event, Emitter<ProfileState> emit) {
    emit(state.copyWith(hasPendingBadge: false));
  }

  void _onResetFidelityCount(ResetFidelityCount event, Emitter<ProfileState> emit) async {
    const nextCuts = 1;
    final updatedUser = state.user?.copyWith(completedCuts: nextCuts);
    
    emit(state.copyWith(
      completedCuts: nextCuts,
      isBenefitActive: false,
      isRewardAvailable: false,
      user: updatedUser,
    ));

    try {
      final authUser = _authService.currentUser;
      if (authUser != null) {
        final supabase = Supabase.instance.client;
        await supabase.from('profiles').update({
          'completed_cuts': nextCuts,
        }).eq('id', authUser.id);
      }
    } catch (e) {
      debugPrint('Error resetting Supabase completed cuts: $e');
    }
  }

  void _onCancelAppointment(CancelAppointment event, Emitter<ProfileState> emit) {
    // Buscar la reserva en la lista programada
    final reservation = state.scheduledAppointments
        .where((r) => r.id == event.reservationId)
        .firstOrNull;

    // Quitar de citas activas
    final updatedScheduled = state.scheduledAppointments
        .where((r) => r.id != event.reservationId)
        .toList();

    // Agregar al historial como cancelada
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
      scheduledAppointments: updatedScheduled.toList(),
      appointmentHistory: updatedHistory.toList(),
    ));
  }
}

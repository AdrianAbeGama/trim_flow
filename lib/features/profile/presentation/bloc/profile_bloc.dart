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
  }

  void _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    try {
      final authUser = _authService.currentUser;
      if (authUser == null) {
        emit(state.copyWith(status: ProfileStatus.initial, user: null));
        return;
      }

      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (response != null) {
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
          completedCuts: response['completed_cuts'] ?? 0,
          history: [],
        );
        
        emit(state.copyWith(
          status: ProfileStatus.loaded, 
          user: realUser,
          completedCuts: realUser.completedCuts,
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
        );
        
        emit(state.copyWith(status: ProfileStatus.loaded, user: mockUser));
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error));
    }
  }

  void _onSaveProfileData(SaveProfileData event, Emitter<ProfileState> emit) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfileStatus.loading));
    
    try {
      final supabase = Supabase.instance.client;
      final fullName = '${event.firstName} ${event.lastName}'.trim();
      
      // Obtenemos el modo actual (Barbero o Cliente)
      final currentMode = getIt<AppModeBloc>().state.mode ?? AppMode.client;
      
      // Obtenemos el tenantId actual
      final currentTenantId = getIt<TenantThemeBloc>().state.tenantId;
      final effectiveTenantId = (currentTenantId == 'default' || currentTenantId == 'barberia_alpha') 
          ? 'bbbbbbbb-2222-4222-8222-222222222222' 
          : currentTenantId;

      if (currentMode == AppMode.barber) {
        // Intentar ACTUALIZAR como BARBERO (profiles)
        // No usamos upsert porque el SQL no tiene políticas de INSERT para usuarios
        final response = await supabase.from('profiles').update({
          'full_name': fullName,
          'phone': event.phone,
          'tenant_id': effectiveTenantId,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', state.user!.id).select();

        if (response.isEmpty) {
          debugPrint('DEBUG: El perfil no existe en "profiles". Verificando en "customers"...');
          // Si no existe en profiles, intentamos en customers (algunos usuarios se crean ahí)
          await supabase.from('customers').update({
            'full_name': fullName,
            'whatsapp': '+51${event.phone}',
            'tenant_id': effectiveTenantId,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('auth_user_id', state.user!.id);
        }
      } else {
        // Modo CLIENTE: Solo Update
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
      debugPrint('DEBUG: Error al guardar perfil en modo ${getIt<AppModeBloc>().state.mode}: $e');
      emit(state.copyWith(status: ProfileStatus.error));
    }
  }

  void _onToggleEditMode(ToggleEditMode event, Emitter<ProfileState> emit) {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  void _onClaimReward(ClaimReward event, Emitter<ProfileState> emit) {
    if (state.isRewardAvailable) {
      emit(state.copyWith(
        completedCuts: 0,
        isRewardAvailable: false,
        user: state.user?.copyWith(completedCuts: 0),
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
    String title = '';
    String body = '';

    if (event.mode == AppMode.client) {
      switch (event.type) {
        case ProfileNotificationType.offer:
          title = '¡Día del Hombre!';
          body = 'Tienes un 50% de descuento en tu próximo corte';
          break;
        case ProfileNotificationType.birthday:
          title = '¡Feliz cumpleaños!';
          body = 'Pasa por tu regalo a Trimflow';
          break;
        case ProfileNotificationType.reservation:
          title = 'Tu cita es en 15 minutos';
          body = '¡No llegues tarde!';
          break;
      }
    } else {
      switch (event.type) {
        case ProfileNotificationType.offer:
          title = 'Nuevo Pedido Recibido';
          body = 'Tienes un nuevo servicio pendiente en tu lista';
          break;
        case ProfileNotificationType.birthday:
          title = 'Servicio Finalizado';
          body = 'El cliente ha calificado tu servicio con 5 estrellas';
          break;
        case ProfileNotificationType.reservation:
          title = 'Recordatorio de Turno';
          body = 'Tu siguiente cliente llegará en 10 minutos';
          break;
      }
    }

    const androidDetails = AndroidNotificationDetails(
      'trimflow_test_channel',
      'Trimflow Test',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}

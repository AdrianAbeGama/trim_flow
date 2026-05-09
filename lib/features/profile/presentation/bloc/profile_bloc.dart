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

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService _authService = getIt<AuthService>();

  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<SaveProfileData>(_onSaveProfileData);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<RequestNotificationPermissionEvent>(_onRequestPermission);
    on<TestNotificationEvent>(_onTestNotification);
    on<ClaimReward>(_onClaimReward);
  }

  void _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    final authUser = _authService.currentUser;
    if (authUser == null) {
      emit(state.copyWith(status: ProfileStatus.loaded, user: null));
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      
      // Intentar cargar perfil con joins
      final response = await supabase
          .from('profiles')
          .select('*, customers(customer_id), barbers(barber_id)')
          .eq('id', authUser.id)
          .maybeSingle();

      if (response != null) {
        final customerData = response['customers'] as List?;
        final barberData = response['barbers'] as List?;
        
        final customerId = (customerData != null && customerData.isNotEmpty) 
            ? customerData.first['customer_id']?.toString() 
            : null;
            
        final barberId = (barberData != null && barberData.isNotEmpty) 
            ? barberData.first['barber_id']?.toString() 
            : null;

        final realUser = UserProfile(
          tenantId: 'barberia_alpha',
          id: response['id'] ?? authUser.id,
          firstName: response['first_name'] ?? authUser.userMetadata?['full_name']?.split(' ').first ?? 'Usuario',
          lastName: response['last_name'] ?? authUser.userMetadata?['full_name']?.split(' ').last ?? '',
          email: response['email'] ?? authUser.email ?? '',
          photoUrl: response['avatar_url'] ?? authUser.userMetadata?['avatar_url'] ?? 'https://www.w3schools.com/howto/img_avatar.png',
          phone: response['phone'] ?? '',
          birthDate: response['birth_date'] ?? '',
          notificationsEnabled: response['notifications_enabled'] ?? true,
          customerId: customerId,
          barberId: barberId,
          completedCuts: response['completed_cuts'] ?? 0,
          history: [], // Aquí cargaríamos el historial real después
        );
        
        emit(state.copyWith(
          status: ProfileStatus.loaded, 
          user: realUser,
          completedCuts: realUser.completedCuts,
        ));
      } else {
        // Si no existe el perfil, crear uno básico o manejar error
        // Por ahora cargamos el mock pero avisamos que no hay perfil real
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

    try {
      final supabase = Supabase.instance.client;
      
      await supabase.from('profiles').upsert({
        'id': state.user!.id,
        'first_name': event.firstName,
        'last_name': event.lastName,
        'phone': event.phone,
        'birth_date': event.birthDate,
        'updated_at': DateTime.now().toIso8601String(),
      });

      final updatedUser = state.user!.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        birthDate: event.birthDate,
      );

      emit(state.copyWith(
        status: ProfileStatus.updated, 
        user: updatedUser,
        isEditing: false,
      ));
      
      emit(state.copyWith(status: ProfileStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error));
    }
  }

  void _onClaimReward(ClaimReward event, Emitter<ProfileState> emit) {
    if (state.isRewardAvailable) {
      // Lógica de reclamo de recompensa
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

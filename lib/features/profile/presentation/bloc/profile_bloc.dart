import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trim_flow/bootstrap.dart';
import 'package:trim_flow/features/profile/domain/models/user_profile.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
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
    
    await Future<void>.delayed(const Duration(milliseconds: 800));
    
    const mockUser = UserProfile(
      id: '001',
      firstName: 'Adrian',
      lastName: 'Abe',
      email: 'adrian@example.com',
      photoUrl: 'https://www.w3schools.com/howto/img_avatar.png',
      phone: '987654321',
      birthDate: '04/05/2000',
      notificationsEnabled: false,
      completedCuts: 2,
      history: [
        CuttingRecord(day: '15 May', time: '10:00 AM', price: 'S/ 40.00'),
        CuttingRecord(day: '10 May', time: '02:30 PM', price: 'S/ 35.00'),
        CuttingRecord(day: '01 May', time: '11:00 AM', price: 'S/ 40.00'),
      ],
    );
    
    emit(state.copyWith(
      status: ProfileStatus.loaded, 
      user: mockUser,
      completedCuts: mockUser.completedCuts,
      isRewardAvailable: mockUser.completedCuts >= 7,
    ));
  }

  void _onSaveProfileData(SaveProfileData event, Emitter<ProfileState> emit) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfileStatus.loading));
    
    // Simular guardado
    await Future<void>.delayed(const Duration(seconds: 1));

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
    
    // Volver a estado cargado para habilitar la UI
    emit(state.copyWith(status: ProfileStatus.loaded));
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

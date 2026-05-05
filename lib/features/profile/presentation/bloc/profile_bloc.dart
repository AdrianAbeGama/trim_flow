import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trim_flow/features/profile/domain/models/user_profile.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<ToggleEditModeEvent>(_onToggleEditMode);
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
      birthDate: '04/05/2026',
      notificationsEnabled: false,
      history: [
        CuttingRecord(day: '15 May', time: '10:00 AM', price: 'S/ 40.00'),
        CuttingRecord(day: '10 May', time: '02:30 PM', price: 'S/ 35.00'),
        CuttingRecord(day: '01 May', time: '11:00 AM', price: 'S/ 40.00'),
      ],
    );
    
    emit(state.copyWith(status: ProfileStatus.loaded, user: mockUser));
  }

  void _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) {
    if (state.user != null) {
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
    }
  }

  void _onToggleNotifications(ToggleNotificationsEvent event, Emitter<ProfileState> emit) async {
    if (event.enabled) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        if (state.user != null) {
          emit(state.copyWith(user: state.user!.copyWith(notificationsEnabled: true)));
        }
      } else {
        // Handle denied permission if needed
      }
    } else {
      if (state.user != null) {
        emit(state.copyWith(user: state.user!.copyWith(notificationsEnabled: false)));
      }
    }
  }

  void _onToggleEditMode(ToggleEditModeEvent event, Emitter<ProfileState> emit) {
    emit(state.copyWith(isEditing: !state.isEditing));
  }
}

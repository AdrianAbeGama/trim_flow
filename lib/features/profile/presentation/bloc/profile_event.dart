import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  const UpdateProfileEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.birthDate,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String birthDate;

  @override
  List<Object?> get props => [firstName, lastName, phone, birthDate];
}

class ToggleNotificationsEvent extends ProfileEvent {
  const ToggleNotificationsEvent({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class ToggleEditModeEvent extends ProfileEvent {}

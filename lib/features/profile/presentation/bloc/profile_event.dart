import 'package:equatable/equatable.dart';

enum ProfileNotificationType { offer, birthday, reservation }

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class SaveProfileData extends ProfileEvent {
  const SaveProfileData({
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

class ClaimReward extends ProfileEvent {}

class RequestNotificationPermissionEvent extends ProfileEvent {}

class TestNotificationEvent extends ProfileEvent {
  const TestNotificationEvent({required this.type});

  final ProfileNotificationType type;

  @override
  List<Object?> get props => [type];
}

class ToggleNotificationsEvent extends ProfileEvent {
  const ToggleNotificationsEvent({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

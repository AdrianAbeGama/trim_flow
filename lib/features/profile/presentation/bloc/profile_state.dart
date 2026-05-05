import 'package:equatable/equatable.dart';
import 'package:trim_flow/features/profile/domain/models/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, updated, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.isEditing = false,
  });

  final ProfileStatus status;
  final UserProfile? user;
  final bool isEditing;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? user,
    bool? isEditing,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [status, user, isEditing];
}

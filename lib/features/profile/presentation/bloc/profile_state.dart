import 'package:equatable/equatable.dart';
import 'package:trim_flow/features/profile/domain/models/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, updated, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.isEditing = false,
    this.completedCuts = 2,
    this.isRewardAvailable = false,
  });

  final ProfileStatus status;
  final UserProfile? user;
  final bool isEditing;
  final int completedCuts;
  final bool isRewardAvailable;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? user,
    bool? isEditing,
    int? completedCuts,
    bool? isRewardAvailable,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
      completedCuts: completedCuts ?? this.completedCuts,
      isRewardAvailable: isRewardAvailable ?? this.isRewardAvailable,
    );
  }

  @override
  List<Object?> get props => [status, user, isEditing, completedCuts, isRewardAvailable];
}

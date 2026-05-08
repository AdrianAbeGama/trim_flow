import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

part 'profile_state.freezed.dart';

enum ProfileStatus { initial, loading, loaded, updated, error }

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    UserProfile? user,
    @Default(false) bool isEditing,
    @Default(2) int completedCuts,
    @Default(false) bool isRewardAvailable,
  }) = _ProfileState;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class CuttingRecord with _$CuttingRecord {
  const factory CuttingRecord({
    required String day,
    required String time,
    required String price,
  }) = _CuttingRecord;

  factory CuttingRecord.fromJson(Map<String, dynamic> json) =>
      _$CuttingRecordFromJson(json);
}

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String tenantId,
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String photoUrl,
    required String phone,
    required String birthDate,
    required bool notificationsEnabled,
    @Default(2) int completedCuts,
    @Default([]) List<CuttingRecord> history,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

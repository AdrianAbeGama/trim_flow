import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_event.freezed.dart';

enum ProfileNotificationType { offer, birthday, reservation }

@freezed
abstract class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.load() = LoadProfileEvent;
  const factory ProfileEvent.save({
    required String firstName,
    required String lastName,
    required String phone,
    required String birthDate,
  }) = SaveProfileData;
  const factory ProfileEvent.claimReward() = ClaimReward;
  const factory ProfileEvent.requestNotificationPermission() = RequestNotificationPermissionEvent;
  const factory ProfileEvent.testNotification() = TestNotificationEvent;
  const factory ProfileEvent.toggleNotifications({
    required bool enabled,
  }) = ToggleNotificationsEvent;
  const factory ProfileEvent.toggleEditMode() = ToggleEditMode;
  const factory ProfileEvent.addScheduledReservation(Reservation reservation) = AddScheduledReservation;
  const factory ProfileEvent.clearBadge() = ClearBadge;
  const factory ProfileEvent.resetFidelityCount() = ResetFidelityCount;
  const factory ProfileEvent.cancelAppointment({
    required String reservationId,
    required String reason,
  }) = CancelAppointment;
  const factory ProfileEvent.updateBranchId(String branchId) = UpdateBranchId;
}

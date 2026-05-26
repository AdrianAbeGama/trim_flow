import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

part 'profile_state.freezed.dart';

enum ProfileStatus { initial, loading, loaded, updated, error }

class PastAppointment {
  final String centerName;
  final String dateStr;
  final String serviceName;
  final String professionalName;
  final String status; // 'completed' or 'cancelled'
  final String? cancellationReason;
  final int rating; // 1 to 5 stars
  /// Monto real pagado (null = sin precio registrado)
  final double? paidPrice;
  /// Verdadero si se aplicó el 50 % de la cartilla de fidelización
  final bool wasDiscounted;

  const PastAppointment({
    required this.centerName,
    required this.dateStr,
    required this.serviceName,
    required this.professionalName,
    required this.status,
    this.cancellationReason,
    required this.rating,
    this.paidPrice,
    this.wasDiscounted = false,
  });
}

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    UserProfile? user,
    @Default(false) bool isEditing,
    @Default(2) int completedCuts,
    @Default(false) bool isRewardAvailable,
    @Default(false) bool isBenefitActive,
    @Default([]) List<Reservation> scheduledAppointments,
    @Default([]) List<PastAppointment> appointmentHistory,
    @Default(0) int notificationIndex,
    @Default(false) bool hasPendingBadge,
  }) = _ProfileState;
}

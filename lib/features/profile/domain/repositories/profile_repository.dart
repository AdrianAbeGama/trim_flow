import 'package:core/core.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

class ProfileLoadResult {
  final UserProfile user;
  final int loyaltyPoints;
  final bool isRewardAvailable;

  const ProfileLoadResult({
    required this.user,
    required this.loyaltyPoints,
    required this.isRewardAvailable,
  });
}

class ProfileUpdateInput {
  final String firstName;
  final String lastName;
  final String phone;
  final String birthDate;

  const ProfileUpdateInput({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.birthDate,
  });
}

abstract class ProfileRepository {
  Future<ProfileLoadResult?> loadCustomerProfile({
    required String authUserId,
    required String fallbackTenantId,
  });

  Future<ProfileLoadResult?> loadStaffProfile({
    required String authUserId,
    required String fallbackTenantId,
  });

  Future<void> updateCustomerProfile({
    required String authUserId,
    required String? tenantId,
    required ProfileUpdateInput input,
  });

  Future<void> updateStaffProfile({
    required String authUserId,
    required String? tenantId,
    required ProfileUpdateInput input,
  });

  Future<List<Reservation>> loadActiveReservations({
    required String customerId,
  });

  Future<List<PastAppointment>> loadAppointmentHistory({
    required String customerId,
    int limit = 50,
  });
}

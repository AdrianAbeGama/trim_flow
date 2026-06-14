import 'package:core/core.dart';
import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

class ProfileLoadResult {
  final UserProfile user;
  final int loyaltyPoints;
  final bool isRewardAvailable;
  final String? clientCode;
  final String? lastVisit;
  final String? branchName;

  const ProfileLoadResult({
    required this.user,
    required this.loyaltyPoints,
    required this.isRewardAvailable,
    this.clientCode,
    this.lastVisit,
    this.branchName,
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

/// Resultado de `get_my_reservations`: proximas + historial en una sola llamada.
class MyReservationsResult {
  final List<Reservation> upcoming;
  final List<PastAppointment> recent;
  final bool recentHasMore;

  const MyReservationsResult({
    this.upcoming = const [],
    this.recent = const [],
    this.recentHasMore = false,
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

  /// Citas del cliente (proximas + historial) via RPC get_my_reservations.
  Future<MyReservationsResult> loadMyReservations({
    required String tenantId,
  });

  Future<List<CustomerCoupon>> loadCustomerCoupons({
    required String tenantId,
  });
}

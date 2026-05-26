import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

const int kLoyaltyRewardThreshold = 7;
const String _kDefaultAvatar = 'https://www.w3schools.com/howto/img_avatar.png';

class CustomerProfileMapper {
  static ProfileLoadResult fromRow({
    required Map<String, dynamic> row,
    required User authUser,
    required String fallbackTenantId,
  }) {
    final fullName = (row['full_name'] as String?) ?? _metaFullName(authUser) ?? 'Usuario';
    final parts = _splitName(fullName);
    final tenantId = (row['tenant_id'] as String?) ?? fallbackTenantId;
    final pointsRaw = row['points'];
    final points = pointsRaw is int ? pointsRaw : int.tryParse('$pointsRaw') ?? 0;
    final loyaltyCount = points.clamp(0, kLoyaltyRewardThreshold);
    final birthDate = (row['birth_date'] as String?) ?? '';
    final email = (row['email'] as String?) ?? authUser.email ?? '';
    final whatsapp = (row['whatsapp'] as String?) ?? '';
    final phone = _normalizeWhatsapp(whatsapp);

    final user = UserProfile(
      tenantId: tenantId,
      id: authUser.id,
      customerId: row['id'] as String?,
      firstName: parts.$1,
      lastName: parts.$2,
      email: email,
      photoUrl: _metaAvatar(authUser) ?? _kDefaultAvatar,
      phone: phone,
      birthDate: birthDate,
      notificationsEnabled: true,
      completedCuts: loyaltyCount,
    );

    return ProfileLoadResult(
      user: user,
      loyaltyPoints: loyaltyCount,
      isRewardAvailable: points >= kLoyaltyRewardThreshold,
    );
  }
}

class StaffProfileMapper {
  static ProfileLoadResult fromRow({
    required Map<String, dynamic> row,
    required User authUser,
    required String fallbackTenantId,
  }) {
    final fullName = (row['full_name'] as String?) ?? _metaFullName(authUser) ?? 'Barbero';
    final parts = _splitName(fullName);
    final tenantId = (row['tenant_id'] as String?) ?? fallbackTenantId;

    final user = UserProfile(
      tenantId: tenantId,
      id: authUser.id,
      barberId: row['id'] as String?,
      firstName: parts.$1,
      lastName: parts.$2,
      email: authUser.email ?? '',
      photoUrl: (row['avatar_url'] as String?) ?? _metaAvatar(authUser) ?? _kDefaultAvatar,
      phone: (row['phone'] as String?) ?? '',
      birthDate: '',
      notificationsEnabled: true,
      completedCuts: 0,
    );

    return ProfileLoadResult(
      user: user,
      loyaltyPoints: 0,
      isRewardAvailable: false,
    );
  }
}

class ReservationMapper {
  static Reservation fromRow(Map<String, dynamic> row) {
    final tenantId = (row['tenant_id'] as String?) ?? '';
    final startTimeRaw = row['start_time'] as String?;
    final startTime = startTimeRaw != null ? DateTime.tryParse(startTimeRaw)?.toLocal() : null;
    final endTimeRaw = row['end_time'] as String?;
    final endTime = endTimeRaw != null ? DateTime.tryParse(endTimeRaw)?.toLocal() : null;
    final priceRaw = row['price_at_booking'];
    final price = (priceRaw is num) ? priceRaw.toDouble() : 0.0;

    final serviceRow = row['service'] as Map<String, dynamic>?;
    final branchRow = row['branch'] as Map<String, dynamic>?;
    final barberRow = row['barber'] as Map<String, dynamic>?;

    final service = serviceRow == null
        ? null
        : Service(
            tenantId: tenantId,
            id: (serviceRow['id'] as String?) ?? (row['service_id'] as String? ?? ''),
            name: (serviceRow['name'] as String?) ?? 'Servicio',
            price: _toDouble(serviceRow['price_pen']),
            durationInMinutes: (serviceRow['duration_minutes'] as int?) ??
                _diffMinutes(startTime, endTime),
            category: (serviceRow['category_id'] as String?) ?? 'general',
          );

    final center = branchRow == null
        ? null
        : BarberCenter(
            tenantId: tenantId,
            id: (branchRow['id'] as String?) ?? (row['branch_id'] as String? ?? ''),
            name: (branchRow['name'] as String?) ?? 'Sede',
            location: (branchRow['address_line'] as String?) ?? '',
          );

    final professional = barberRow == null
        ? null
        : Professional(
            tenantId: tenantId,
            id: (barberRow['id'] as String?) ?? (row['barber_id'] as String? ?? ''),
            name: (barberRow['full_name'] as String?) ?? 'Barbero',
            specialties: _specialtiesFrom(barberRow['specialty']),
            yearsOfExperience: 0,
            imageUrl: barberRow['avatar_url'] as String?,
          );

    return Reservation(
      tenantId: tenantId,
      id: row['id'] as String?,
      center: center,
      services: service != null ? [service] : const [],
      professional: professional,
      date: startTime,
      time: startTime != null ? _formatHour(startTime) : null,
      totalPrice: price,
      totalDurationInMinutes:
          service?.durationInMinutes ?? _diffMinutes(startTime, endTime),
    );
  }
}

class PastAppointmentMapper {
  static PastAppointment? fromLedgerRow(Map<String, dynamic> row) {
    final reservation = row['reservation'] as Map<String, dynamic>?;
    final branch = reservation == null ? null : reservation['branch'] as Map<String, dynamic>?;
    final barber = row['barber'] as Map<String, dynamic>?;
    final reservationStatus = reservation?['status'] as String?;
    final occurredRaw = row['occurred_at'] as String?;
    final occurred = occurredRaw != null ? DateTime.tryParse(occurredRaw)?.toLocal() : null;
    if (occurred == null) return null;

    final isCancelled = reservationStatus == 'cancelled' || reservationStatus == 'no_show';
    final amountRaw = row['amount_value'];
    final amount = (amountRaw is num) ? amountRaw.toDouble() : null;
    final discountRaw = row['discount_applied'];
    final discount = (discountRaw is num) ? discountRaw.toDouble() : 0.0;

    return PastAppointment(
      centerName: (branch?['name'] as String?) ?? 'Sede Principal',
      dateStr: _formatDate(occurred),
      serviceName: (row['service_name_snapshot'] as String?) ?? 'Servicio',
      professionalName: (barber?['full_name'] as String?) ?? 'Barbero',
      status: isCancelled ? 'cancelled' : 'completed',
      cancellationReason: reservation?['cancellation_reason'] as String?,
      rating: 0,
      paidPrice: isCancelled ? null : amount,
      wasDiscounted: discount > 0,
    );
  }
}

String? _metaFullName(User user) => user.userMetadata?['full_name'] as String?;
String? _metaAvatar(User user) => user.userMetadata?['avatar_url'] as String?;

(String, String) _splitName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return ('Usuario', '');
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) return (parts.first, '');
  return (parts.first, parts.sublist(1).join(' '));
}

String _normalizeWhatsapp(String raw) {
  if (raw.isEmpty) return '';
  if (raw.startsWith('+51')) return raw.substring(3);
  if (raw.startsWith('51') && raw.length > 9) return raw.substring(2);
  return raw;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _diffMinutes(DateTime? start, DateTime? end) {
  if (start == null || end == null) return 0;
  return end.difference(start).inMinutes.abs();
}

List<String> _specialtiesFrom(dynamic raw) {
  if (raw == null) return const [];
  if (raw is String && raw.trim().isNotEmpty) return [raw];
  if (raw is List) return raw.whereType<String>().toList();
  return const [];
}

String _formatHour(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _formatDate(DateTime dt) {
  final dd = dt.day.toString().padLeft(2, '0');
  final mm = dt.month.toString().padLeft(2, '0');
  return '$dd / $mm / ${dt.year}';
}

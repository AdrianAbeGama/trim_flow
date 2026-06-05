import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

const int kLoyaltyRewardThreshold = 7;

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
      photoUrl: _metaAvatar(authUser) ?? '',
      phone: phone,
      birthDate: birthDate,
      notificationsEnabled: true,
      completedCuts: loyaltyCount,
    );

    return ProfileLoadResult(
      user: user,
      loyaltyPoints: loyaltyCount,
      isRewardAvailable: points >= kLoyaltyRewardThreshold,
      clientCode: (row['client_code'] as String?)?.trim().isNotEmpty == true
          ? row['client_code'] as String?
          : null,
      lastVisit: _formatLastVisit(row['last_visit_at'] as String?),
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
    final branchRow = row['branch'] as Map<String, dynamic>?;
    final branchName = branchRow?['name'] as String?;

    final user = UserProfile(
      tenantId: tenantId,
      id: authUser.id,
      barberId: row['id'] as String?,
      branchId: row['branch_id'] as String?,
      firstName: parts.$1,
      lastName: parts.$2,
      email: authUser.email ?? '',
      photoUrl: (row['avatar_url'] as String?) ?? _metaAvatar(authUser) ?? '',
      phone: (row['phone'] as String?) ?? '',
      birthDate: '',
      notificationsEnabled: true,
      completedCuts: 0,
    );

    return ProfileLoadResult(
      user: user,
      loyaltyPoints: 0,
      isRewardAvailable: false,
      branchName: branchName,
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
  static PastAppointment? fromReservationRow(Map<String, dynamic> row) {
    final startRaw = row['start_time'] as String?;
    final start = startRaw != null ? DateTime.tryParse(startRaw)?.toLocal() : null;
    if (start == null) return null;

    final status = row['status'] as String?;
    final isCancelled = status == 'cancelled' || status == 'no_show';
    final service = row['service'] as Map<String, dynamic>?;
    final branch = row['branch'] as Map<String, dynamic>?;
    final barber = row['barber'] as Map<String, dynamic>?;
    final priceRaw = row['price_at_booking'];
    final price = (priceRaw is num) ? priceRaw.toDouble() : null;

    return PastAppointment(
      centerName: (branch?['name'] as String?) ?? 'Sede Principal',
      dateStr: _formatDate(start),
      serviceName: (service?['name'] as String?) ?? 'Servicio',
      professionalName: (barber?['full_name'] as String?) ?? 'Barbero',
      status: isCancelled ? 'cancelled' : 'completed',
      cancellationReason: row['cancellation_reason'] as String?,
      rating: 0,
      paidPrice: isCancelled ? null : price,
      wasDiscounted: false,
    );
  }
}

String? _metaFullName(User user) {
  final meta = user.userMetadata;
  if (meta == null) return null;
  final candidates = ['full_name', 'name', 'display_name', 'given_name'];
  for (final key in candidates) {
    final value = meta[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return null;
}

String? _metaAvatar(User user) {
  final meta = user.userMetadata;
  if (meta == null) return null;
  final candidates = ['picture', 'avatar_url', 'photo_url', 'avatar'];
  for (final key in candidates) {
    final value = meta[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return null;
}

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

String? _formatLastVisit(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final dt = DateTime.tryParse(raw)?.toLocal();
  if (dt == null) return null;
  return _formatDate(dt);
}

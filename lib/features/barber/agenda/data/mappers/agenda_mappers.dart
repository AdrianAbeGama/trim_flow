import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';

class AgendaAppointmentMapper {
  static AgendaAppointment? fromRow(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    final startRaw = row['start_time'] as String?;
    final endRaw = row['end_time'] as String?;
    if (id == null || startRaw == null || endRaw == null) return null;

    final start = DateTime.tryParse(startRaw)?.toLocal();
    final end = DateTime.tryParse(endRaw)?.toLocal();
    if (start == null || end == null) return null;

    final customer = row['customer'] as Map<String, dynamic>?;
    final service = row['service'] as Map<String, dynamic>?;
    final branch = row['branch'] as Map<String, dynamic>?;
    final priceRaw = row['price_at_booking'];
    final price = priceRaw is num ? priceRaw.toDouble() : null;
    final duration = service?['duration_minutes'] as int?;

    return AgendaAppointment(
      id: id,
      tenantId: (row['tenant_id'] as String?) ?? '',
      startTime: start,
      endTime: end,
      status: AgendaStatusX.fromRaw(row['status'] as String?),
      customerId: customer?['id'] as String?,
      customerName: customer?['full_name'] as String?,
      customerWhatsapp: customer?['whatsapp'] as String?,
      serviceName: service?['name'] as String?,
      serviceDurationMinutes: duration ?? end.difference(start).inMinutes.abs(),
      priceAtBooking: price,
      branchName: branch?['name'] as String?,
      notes: row['notes'] as String?,
    );
  }
}

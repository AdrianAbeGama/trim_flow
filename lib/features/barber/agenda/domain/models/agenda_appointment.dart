enum AgendaStatus { pending, confirmed, completed, cancelled, noShow, unknown }

extension AgendaStatusX on AgendaStatus {
  static AgendaStatus fromRaw(String? raw) {
    switch (raw) {
      case 'pending':
        return AgendaStatus.pending;
      case 'confirmed':
        return AgendaStatus.confirmed;
      case 'completed':
        return AgendaStatus.completed;
      case 'cancelled':
        return AgendaStatus.cancelled;
      case 'no_show':
        return AgendaStatus.noShow;
      default:
        return AgendaStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case AgendaStatus.pending:
        return 'Pendiente';
      case AgendaStatus.confirmed:
        return 'Confirmada';
      case AgendaStatus.completed:
        return 'Completada';
      case AgendaStatus.cancelled:
        return 'Cancelada';
      case AgendaStatus.noShow:
        return 'No-show';
      case AgendaStatus.unknown:
        return 'Sin estado';
    }
  }
}

class AgendaAppointment {
  final String id;
  final String tenantId;
  final DateTime startTime;
  final DateTime endTime;
  final AgendaStatus status;
  final String? customerName;
  final String? customerWhatsapp;
  final String? serviceName;
  final int? serviceDurationMinutes;
  final double? priceAtBooking;
  final String? branchName;
  final String? notes;

  const AgendaAppointment({
    required this.id,
    required this.tenantId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.customerName,
    this.customerWhatsapp,
    this.serviceName,
    this.serviceDurationMinutes,
    this.priceAtBooking,
    this.branchName,
    this.notes,
  });

  Duration get duration => endTime.difference(startTime);
}

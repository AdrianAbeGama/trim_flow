/// Una cita completada que el cliente todavia puede reseñar (no reseñada aun).
class ReviewableReservation {
  const ReviewableReservation({
    required this.reservationId,
    required this.barberId,
    required this.barberName,
    required this.serviceName,
    required this.branchName,
    this.completedAt,
  });

  final String reservationId;
  final String barberId;
  final String barberName;
  final String serviceName;
  final String branchName;
  final DateTime? completedAt;

  static ReviewableReservation? fromMap(Map<String, dynamic> m) {
    final id = m['reservationId'] as String?;
    if (id == null || id.isEmpty) return null;
    return ReviewableReservation(
      reservationId: id,
      barberId: (m['barberId'] as String?) ?? '',
      barberName: (m['barberName'] as String?) ?? 'Tu barbero',
      serviceName: (m['serviceName'] as String?) ?? 'Servicio',
      branchName: (m['branchName'] as String?) ?? '',
      completedAt:
          DateTime.tryParse(m['completedAt'] as String? ?? '')?.toLocal(),
    );
  }
}

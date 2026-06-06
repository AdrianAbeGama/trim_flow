// Cliente (tabla customers) para el panel admin.

class AdminCustomer {
  const AdminCustomer({
    required this.id,
    required this.name,
    required this.whatsapp,
    required this.points,
    this.lastVisit,
  });

  final String id;
  final String name;
  final String whatsapp;
  final int points;
  final DateTime? lastVisit;

  factory AdminCustomer.fromRow(Map<String, dynamic> r) => AdminCustomer(
        id: r['id'] as String,
        name: (r['full_name'] as String?) ?? 'Cliente',
        whatsapp: (r['whatsapp'] as String?) ?? '',
        points: (r['points'] as num?)?.toInt() ?? 0,
        lastVisit: r['last_visit_at'] == null
            ? null
            : DateTime.tryParse('${r['last_visit_at']}'),
      );
}

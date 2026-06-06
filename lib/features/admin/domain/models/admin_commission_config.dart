// Configuración de comisiones: barbero + línea por servicio (comisión efectiva,
// override o por defecto del servicio).

String _f(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

class AdminBarberRef {
  const AdminBarberRef({required this.id, required this.name});

  final String id;
  final String name;
}

class CommissionLine {
  const CommissionLine({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.type,
    required this.value,
    required this.isOverride,
  });

  final String serviceId;
  final String serviceName;
  final double price;
  final String type; // percentage / fixed
  final double value;
  final bool isOverride; // true = comisión personalizada; false = por defecto

  bool get isPercentage => type == 'percentage';

  double get earns => isPercentage ? price * value / 100 : value;

  String get valueLabel =>
      isPercentage ? '${_f(value)}%' : 'S/ ${_f(value)}';
}

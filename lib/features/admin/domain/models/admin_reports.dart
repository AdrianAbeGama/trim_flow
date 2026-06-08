// DTOs planos para los reportes admin (parseados del JSON de los RPC
// get_dashboard_kpis y get_daily_cash_close_report). Sin codegen.

double _d(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

int _i(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) {
  if (raw is List) {
    return raw.whereType<Map<String, dynamic>>().map(f).toList();
  }
  return <T>[];
}

class AdminPayMethod {
  const AdminPayMethod({
    required this.method,
    required this.count,
    required this.total,
  });

  final String method;
  final int count;
  final double total;

  String get label {
    switch (method) {
      case 'cash':
        return 'Efectivo';
      case 'yape':
        return 'Yape';
      case 'plin':
        return 'Plin';
      case 'card_present':
        return 'Tarjeta';
      case 'transfer':
        return 'Transferencia';
      case 'other':
        return 'Otro';
      case 'unspecified':
        return 'Sin especificar';
      default:
        return method;
    }
  }

  factory AdminPayMethod.fromJson(Map<String, dynamic> j) => AdminPayMethod(
        method: (j['method'] as String?) ?? 'unspecified',
        count: _i(j['count']),
        total: _d(j['total']),
      );
}

class AdminBarberStat {
  const AdminBarberStat({
    required this.barberName,
    required this.serviceCount,
    required this.commission,
  });

  final String barberName;
  final int serviceCount;
  final double commission;

  factory AdminBarberStat.fromJson(Map<String, dynamic> j) => AdminBarberStat(
        barberName: (j['barber_name'] as String?) ?? 'Barbero',
        serviceCount: _i(j['service_count']),
        commission: _d(j['commission']),
      );
}

class AdminDashboard {
  const AdminDashboard({
    required this.revenueTotal,
    required this.serviceCount,
    required this.wastedCount,
    required this.discountTotal,
    required this.commissionTotal,
    required this.byPayment,
    required this.byBarber,
  });

  final double revenueTotal;
  final int serviceCount;
  final int wastedCount;
  final double discountTotal;
  final double commissionTotal;
  final List<AdminPayMethod> byPayment;
  final List<AdminBarberStat> byBarber;

  factory AdminDashboard.fromJson(Map<String, dynamic> j) {
    final fin = (j['financials'] as Map<String, dynamic>?) ?? const {};
    return AdminDashboard(
      revenueTotal: _d(fin['revenue_total']),
      serviceCount: _i(fin['service_count']),
      wastedCount: _i(fin['wasted_count']),
      discountTotal: _d(fin['discount_total']),
      commissionTotal: _d(fin['commission_total']),
      byPayment: _list(j['by_payment_method'], AdminPayMethod.fromJson),
      byBarber: _list(j['by_barber'], AdminBarberStat.fromJson),
    );
  }
}

class AdminBarberCommission {
  const AdminBarberCommission({
    required this.barberName,
    required this.serviceCount,
    required this.revenue,
    required this.commission,
  });

  final String barberName;
  final int serviceCount;
  final double revenue;
  final double commission;

  factory AdminBarberCommission.fromJson(Map<String, dynamic> j) =>
      AdminBarberCommission(
        barberName: (j['barber_name'] as String?) ?? 'Barbero',
        serviceCount: _i(j['service_count']),
        revenue: _d(j['revenue']),
        commission: _d(j['commission']),
      );
}

class AdminServiceCommission {
  const AdminServiceCommission({
    required this.serviceName,
    required this.serviceCount,
    required this.commission,
  });

  final String serviceName;
  final int serviceCount;
  final double commission;

  factory AdminServiceCommission.fromJson(Map<String, dynamic> j) =>
      AdminServiceCommission(
        serviceName: (j['service_name'] as String?) ?? 'Servicio',
        serviceCount: _i(j['service_count']),
        commission: _d(j['commission']),
      );
}

class AdminCommissionsReport {
  const AdminCommissionsReport({
    required this.revenueTotal,
    required this.commissionTotal,
    required this.serviceCount,
    required this.discountTotal,
    required this.byBarber,
    required this.byService,
  });

  final double revenueTotal;
  final double commissionTotal;
  final int serviceCount;
  final double discountTotal;
  final List<AdminBarberCommission> byBarber;
  final List<AdminServiceCommission> byService;

  factory AdminCommissionsReport.fromJson(Map<String, dynamic> j) {
    final s = (j['summary'] as Map<String, dynamic>?) ?? const {};
    return AdminCommissionsReport(
      revenueTotal: _d(s['revenue_total']),
      commissionTotal: _d(s['commission_total']),
      serviceCount: _i(s['service_count']),
      discountTotal: _d(s['discount_total']),
      byBarber: _list(j['by_barber'], AdminBarberCommission.fromJson),
      byService: _list(j['by_service'], AdminServiceCommission.fromJson),
    );
  }
}

class AdminCashReport {
  const AdminCashReport({
    required this.revenueTotal,
    required this.serviceCount,
    required this.discountTotal,
    required this.netBalance,
    required this.byPayment,
  });

  final double revenueTotal;
  final int serviceCount;
  final double discountTotal;
  final double netBalance;
  final List<AdminPayMethod> byPayment;

  factory AdminCashReport.fromJson(Map<String, dynamic> j) {
    final s = (j['summary'] as Map<String, dynamic>?) ?? const {};
    return AdminCashReport(
      revenueTotal: _d(s['revenue_total']),
      serviceCount: _i(s['service_completed_count']),
      discountTotal: _d(s['discount_total']),
      netBalance: _d(s['net_balance']),
      byPayment: _list(j['by_payment_method'], AdminPayMethod.fromJson),
    );
  }
}

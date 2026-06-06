// Promoción (tabla promotions). Modelo plano. El formulario edita solo lo común
// (nombre, código, tipo, valor, vencimiento, activa) y preserva el resto.

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

class AdminPromotion {
  const AdminPromotion({
    this.id,
    required this.code,
    required this.name,
    this.description,
    required this.triggerType,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountPen,
    required this.isAppOnly,
    required this.autoEmit,
    required this.daysBeforeBirthday,
    required this.daysAfterBirthday,
    required this.maxUsesPerCustomer,
    this.maxTotalUses,
    required this.validFrom,
    this.validUntil,
    required this.isActive,
  });

  final String? id;
  final String code;
  final String name;
  final String? description;
  final String triggerType; // manual / birthday / inactivity_15d / ...
  final String discountType; // percentage / fixed
  final double discountValue;
  final double? maxDiscountPen;
  final bool isAppOnly;
  final bool autoEmit;
  final int daysBeforeBirthday;
  final int daysAfterBirthday;
  final int maxUsesPerCustomer;
  final int? maxTotalUses;
  final DateTime validFrom;
  final DateTime? validUntil;
  final bool isActive;

  bool get isPercentage => discountType == 'percentage';

  String get discountLabel =>
      isPercentage ? '${_fmt(discountValue)}%' : 'S/ ${_fmt(discountValue)}';

  String get triggerLabel {
    switch (triggerType) {
      case 'manual':
        return 'Manual';
      case 'birthday':
        return 'Cumpleaños';
      case 'inactivity_15d':
        return 'Te extrañamos';
      default:
        return triggerType;
    }
  }

  factory AdminPromotion.create() => AdminPromotion(
        code: '',
        name: '',
        triggerType: 'manual',
        discountType: 'percentage',
        discountValue: 10,
        isAppOnly: false,
        autoEmit: false,
        daysBeforeBirthday: 0,
        daysAfterBirthday: 0,
        maxUsesPerCustomer: 1,
        validFrom: DateTime.now(),
        isActive: true,
      );

  factory AdminPromotion.fromRow(Map<String, dynamic> r) {
    double d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    int i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    DateTime? dt(dynamic v) => v == null ? null : DateTime.tryParse('$v');
    return AdminPromotion(
      id: r['id'] as String?,
      code: (r['code'] as String?) ?? '',
      name: (r['name'] as String?) ?? '',
      description: r['description'] as String?,
      triggerType: (r['trigger_type'] as String?) ?? 'manual',
      discountType: (r['discount_type'] as String?) ?? 'percentage',
      discountValue: d(r['discount_value']),
      maxDiscountPen:
          r['max_discount_pen'] == null ? null : d(r['max_discount_pen']),
      isAppOnly: (r['is_app_only'] as bool?) ?? false,
      autoEmit: (r['auto_emit'] as bool?) ?? false,
      daysBeforeBirthday: i(r['days_before_birthday']),
      daysAfterBirthday: i(r['days_after_birthday']),
      maxUsesPerCustomer: i(r['max_uses_per_customer']),
      maxTotalUses: r['max_total_uses'] == null ? null : i(r['max_total_uses']),
      validFrom: dt(r['valid_from']) ?? DateTime.now(),
      validUntil: dt(r['valid_until']),
      isActive: (r['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toParams(String tenantId) => {
        'p_id': id,
        'p_tenant_id': tenantId,
        'p_code': code,
        'p_name': name,
        'p_description': description,
        'p_trigger_type': triggerType,
        'p_discount_type': discountType,
        'p_discount_value': discountValue,
        'p_max_discount_pen': maxDiscountPen,
        'p_is_app_only': isAppOnly,
        'p_auto_emit': autoEmit,
        'p_days_before_birthday': daysBeforeBirthday,
        'p_days_after_birthday': daysAfterBirthday,
        'p_valid_from': validFrom.toUtc().toIso8601String(),
        'p_valid_until': validUntil?.toUtc().toIso8601String(),
        'p_max_total_uses': maxTotalUses,
        'p_max_uses_per_customer': maxUsesPerCustomer,
        'p_is_active': isActive,
      };
}

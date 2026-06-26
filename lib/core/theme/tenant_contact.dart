/// Datos de contacto del negocio, leidos de `tenants.branding.contact`.
/// Se llenan desde la web admin (/settings). Si un campo no esta cargado,
/// llega null y la UI muestra "No configurado".
class TenantContact {
  final String? phone;
  final String? email;

  const TenantContact({this.phone, this.email});

  bool get hasPhone => (phone ?? '').trim().isNotEmpty;
  bool get hasEmail => (email ?? '').trim().isNotEmpty;

  /// Solo digitos, para armar el link wa.me (igual que la web).
  String get phoneDigits => (phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
}

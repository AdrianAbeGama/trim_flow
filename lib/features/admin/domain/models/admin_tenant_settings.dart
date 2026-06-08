// Ajustes de la barbería (tabla tenants): datos generales + recordatorio
// automático de "vuelve, te extrañamos".

class AdminTenantSettings {
  const AdminTenantSettings({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.reminderEnabled,
    required this.reminderDays,
    required this.reminderMessage,
  });

  final String name;
  final String phone;
  final String address;
  final String email;
  final bool reminderEnabled;
  final int reminderDays;
  final String reminderMessage;

  factory AdminTenantSettings.fromRow(Map<String, dynamic> r) {
    final branding =
        (r['branding'] as Map?)?.cast<String, dynamic>() ?? const {};
    final contact =
        (branding['contact'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AdminTenantSettings(
      name: (r['name'] as String?) ?? '',
      phone: (contact['phone'] as String?) ?? '',
      address: (contact['address_line'] as String?) ?? '',
      email: (contact['email'] as String?) ?? '',
      reminderEnabled: (r['comeback_reminder_enabled'] as bool?) ?? false,
      reminderDays: (r['comeback_reminder_days'] as num?)?.toInt() ?? 15,
      reminderMessage:
          (r['comeback_reminder_message_template'] as String?) ?? '',
    );
  }
}

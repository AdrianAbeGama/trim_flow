class AppRoles {
  static const String barber = 'barber';
  static const String tenantAdmin = 'tenant_admin';
  static const String superAdmin = 'super_admin';

  static const List<String> accepted = [barber, tenantAdmin, superAdmin];
}

bool isAdminRole(String? role) =>
    role == AppRoles.tenantAdmin || role == AppRoles.superAdmin;

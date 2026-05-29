class StaffMember {
  final String id;
  final String fullName;
  final String? specialty;
  final String? avatarUrl;
  final String? phone;
  final String role;
  final bool isActive;

  const StaffMember({
    required this.id,
    required this.fullName,
    this.specialty,
    this.avatarUrl,
    this.phone,
    required this.role,
    this.isActive = true,
  });
}

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_catalog.freezed.dart';

@freezed
abstract class TeamMember with _$TeamMember {
  const TeamMember._();

  const factory TeamMember({
    required String tenantId,
    required String id,
    required String fullName,
    @Default(0) int yearsOfExperience,
    String? specialty,
    String? avatarUrl,
    String? branchId,
  }) = _TeamMember;

  Professional toProfessional() => Professional(
        tenantId: tenantId,
        id: id,
        name: fullName,
        specialties: (specialty == null || specialty!.trim().isEmpty)
            ? const <String>[]
            : [specialty!.trim()],
        yearsOfExperience: yearsOfExperience,
        isAvailable: true,
        imageUrl: (avatarUrl == null || avatarUrl!.isEmpty) ? null : avatarUrl,
      );
}

@freezed
abstract class TenantCatalog with _$TenantCatalog {
  const factory TenantCatalog({
    @Default(<BarberCenter>[]) List<BarberCenter> centers,
    @Default(<Service>[]) List<Service> services,
    @Default(<TeamMember>[]) List<TeamMember> team,
  }) = _TenantCatalog;
}

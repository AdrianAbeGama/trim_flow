import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/staff/domain/models/staff_member.dart';
import 'package:trim_flow/core/staff/domain/repositories/staff_repository.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_admin_widgets.dart';

/// Tab "Staff" del admin dashboard — readonly listing de barberos.
class GalleryAdminStaffTab extends StatefulWidget {
  const GalleryAdminStaffTab({super.key});

  @override
  State<GalleryAdminStaffTab> createState() => _GalleryAdminStaffTabState();
}

class _GalleryAdminStaffTabState extends State<GalleryAdminStaffTab> {
  late Future<List<StaffMember>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<StaffMember>> _load() {
    final repo = getIt<StaffRepository>();
    final tenantId = getIt<TenantThemeBloc>().state.tenantId;
    final resolved = tenantId == kDefaultTenantId ? null : tenantId;
    return repo.listActiveBarbers(tenantId: resolved);
  }

  Future<void> _refresh() async {
    final next = await _load();
    if (!mounted) return;
    setState(() => _future = Future.value(next));
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return FutureBuilder<List<StaffMember>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator(color: gold, radius: 12));
        }
        final list = snap.data ?? const [];
        if (list.isEmpty) {
          return const GalleryAdminEmptyState(
            icon: Icons.groups_2_outlined,
            title: 'Sin staff registrado',
            subtitle: 'Pide a tu administrador agregar barberos en profiles.',
          );
        }
        return RefreshIndicator(
          color: gold,
          backgroundColor: const Color(0xFF0E0E0E),
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _StaffTile(member: list[i]),
          ),
        );
      },
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          AvatarPremium(
            displayName: member.fullName,
            photoUrl: member.avatarUrl,
            size: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (member.specialty != null && member.specialty!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(width: 10, height: 1.5, color: gold),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          member.specialty!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              member.role.toUpperCase(),
              style: GoogleFonts.inter(
                color: gold,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

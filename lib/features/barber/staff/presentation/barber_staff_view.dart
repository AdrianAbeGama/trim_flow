import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/catalog/domain/models/tenant_catalog.dart';
import 'package:trim_flow/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:trim_flow/features/barber/staff/data/staff_admin_repository.dart';
import 'package:trim_flow/features/barber/staff/presentation/add_barber_view.dart';

class _StaffData {
  const _StaffData(this.team, this.branches);
  final List<TeamMember> team;
  final List<BranchOption> branches;
}

/// Pantalla "Equipo" del panel admin: lista de barberos del tenant + boton para
/// agregar uno nuevo (Edge Function `create-barber`).
class BarberStaffView extends StatefulWidget {
  const BarberStaffView({super.key, required this.tenantId});
  final String tenantId;

  @override
  State<BarberStaffView> createState() => _BarberStaffViewState();
}

class _BarberStaffViewState extends State<BarberStaffView> {
  final _staffRepo = StaffAdminRepository(Supabase.instance.client);
  Future<_StaffData>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_StaffData> _load() async {
    final results = await Future.wait([
      getIt<CatalogRepository>().fetchCatalog(tenantId: widget.tenantId),
      _staffRepo.fetchBranches(tenantId: widget.tenantId),
    ]);
    final catalog = results[0] as TenantCatalog;
    final branches = results[1] as List<BranchOption>;
    return _StaffData(catalog.team, branches);
  }

  Future<void> _add(List<BranchOption> branches) async {
    HapticFeedback.lightImpact();
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddBarberView(tenantId: widget.tenantId, branches: branches),
      ),
    );
    if (created == true && mounted) {
      setState(() => _future = _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_StaffData>(
          future: _future,
          builder: (context, snap) {
            final loading = snap.connectionState == ConnectionState.waiting;
            final data = snap.data;
            final branches = data?.branches ?? const <BranchOption>[];
            final team = data?.team ?? const <TeamMember>[];
            final branchName = {for (final b in branches) b.id: b.name};

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      Row(
                        children: [
                          PremiumBackButton(onTap: () => Navigator.pop(context)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const PremiumPill(
                          icon: Icons.groups_rounded, label: 'TU EQUIPO'),
                      const SizedBox(height: 18),
                      Text(
                        'Tus',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.55),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Barberos',
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.4,
                          height: 1.05,
                        ),
                      ),
                      if (!loading) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(width: 16, height: 1.5, color: gold),
                            const SizedBox(width: 8),
                            Text(
                              team.isEmpty
                                  ? 'Aún no tienes barberos'
                                  : '${team.length} ${team.length == 1 ? "barbero" : "barberos"} en tu equipo',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.45),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 26),
                      if (loading)
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Center(
                            child: CupertinoActivityIndicator(
                                color: gold, radius: 14),
                          ),
                        )
                      else if (team.isEmpty)
                        _EmptyTeam(gold: gold)
                      else
                        for (var i = 0; i < team.length; i++) ...[
                          if (i > 0)
                            Container(
                              height: 0.6,
                              margin: const EdgeInsets.only(left: 60, bottom: 14),
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          _BarberRow(
                            member: team[i],
                            branchLabel: branchName[team[i].branchId],
                          ),
                        ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 8, 20, MediaQuery.of(context).viewPadding.bottom + 14),
                  child: PremiumPressable(
                    pressedScale: 0.98,
                    onTap: loading ? () {} : () => _add(branches),
                    child: Opacity(
                      opacity: loading ? 0.5 : 1,
                      child: Container(
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3EC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_alt_1_rounded,
                                color: Colors.black, size: 19),
                            const SizedBox(width: 10),
                            Text(
                              'AGREGAR BARBERO',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BarberRow extends StatelessWidget {
  const _BarberRow({required this.member, this.branchLabel});
  final TeamMember member;
  final String? branchLabel;

  @override
  Widget build(BuildContext context) {
    final sub = [
      if ((member.specialty ?? '').trim().isNotEmpty) member.specialty!.trim(),
      if ((branchLabel ?? '').trim().isNotEmpty) branchLabel!.trim(),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          AvatarPremium(
            displayName: member.fullName,
            photoUrl: member.avatarUrl,
            size: 46,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTeam extends StatelessWidget {
  const _EmptyTeam({required this.gold});
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.22)),
            ),
            child: Icon(Icons.groups_rounded, color: gold, size: 30),
          ),
          const SizedBox(height: 18),
          Text(
            'Tu equipo está vacío',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Agrega tu primer barbero con el botón de abajo.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

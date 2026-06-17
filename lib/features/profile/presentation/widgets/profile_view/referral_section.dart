import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/referral_sheet.dart';

/// Bloque de referidos en el perfil: acceso "Invita a un amigo" (abre la
/// ventanita flotante) + referidos y puntos justo debajo.
class ReferralSection extends StatefulWidget {
  const ReferralSection({super.key});

  @override
  State<ReferralSection> createState() => _ReferralSectionState();
}

class _ReferralSectionState extends State<ReferralSection> {
  final _repo = getIt<ProfileRepository>();

  String get _tenantId => getIt<TenantThemeBloc>().state.tenantId;

  ReferralStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      var stats = await _repo.getReferralStats(tenantId: _tenantId);
      if (stats.code == null || stats.code!.isEmpty) {
        await _repo.generateReferralCode(tenantId: _tenantId);
        stats = await _repo.getReferralStats(tenantId: _tenantId);
      }
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open() async {
    await ReferralSheet.show(
      context,
      code: _stats?.code ?? '',
      tenantId: _tenantId,
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: ProfilePressableScale(
        onTap: _open,
        pressedScale: 0.98,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: FaIcon(FontAwesomeIcons.gift, color: gold, size: 17),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invita a un amigo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text('Comparte y ganen los dos',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: Colors.white.withValues(alpha: 0.45))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _MiniStat(
              gold: gold,
              value: _loading ? '·' : '${_stats?.referredCount ?? 0}',
              label: 'REFERIDOS',
            ),
            const SizedBox(width: 16),
            _MiniStat(
              gold: gold,
              value: _loading ? '·' : '${_stats?.totalEarned ?? 0}',
              label: 'PUNTOS',
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 22, color: Colors.white.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.gold, required this.value, required this.label});

  final Color gold;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            style: GoogleFonts.inter(
                color: gold,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5)),
        const SizedBox(height: 1),
        Text(label,
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8)),
      ],
    );
  }
}

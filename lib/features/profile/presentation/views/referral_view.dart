import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';

/// Pantalla "Invita a un amigo" — codigo de referido del cliente + estadisticas
/// + aplicar el codigo de otro. Usa las RPCs de referidos (por barberia).
class ReferralView extends StatefulWidget {
  const ReferralView({super.key});

  @override
  State<ReferralView> createState() => _ReferralViewState();
}

class _ReferralViewState extends State<ReferralView> {
  final _repo = getIt<ProfileRepository>();
  final _applyController = TextEditingController();

  String get _tenantId => getIt<TenantThemeBloc>().state.tenantId;

  ReferralStats? _stats;
  bool _loading = true;
  bool _applying = false;
  String? _applyMsg;
  String? _applyError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _applyController.dispose();
    super.dispose();
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
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copy(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Código copiado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _share(String code) async {
    HapticFeedback.lightImpact();
    await SharePlus.instance.share(
      ShareParams(
        text: 'Reserva tu corte con mi código $code en TrimFlow y ganamos los dos.',
      ),
    );
  }

  String _mapApplyError(String message) {
    if (message.contains('referral_code_not_found')) return 'Ese código no existe.';
    if (message.contains('referral_self')) return 'No puedes usar tu propio código.';
    if (message.contains('referral_already_redeemed')) {
      return 'Ya usaste un código de referido antes.';
    }
    if (message.contains('referral_not_new_customer')) {
      return 'Los referidos son solo para clientes nuevos (sin citas pagadas).';
    }
    if (message.contains('referral_max_uses_reached')) {
      return 'Ese código ya llegó a su límite de usos.';
    }
    if (message.contains('referral_wrong_tenant')) {
      return 'Ese código es de otra barbería.';
    }
    if (message.contains('customer_not_linked')) {
      return 'Activa tu cuenta en esta barbería primero.';
    }
    return 'No se pudo aplicar el código.';
  }

  Future<void> _apply() async {
    final code = _applyController.text.trim();
    if (code.isEmpty) {
      setState(() => _applyError = 'Escribe el código.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _applying = true;
      _applyError = null;
      _applyMsg = null;
    });
    try {
      final msg = await _repo.applyReferralCode(tenantId: _tenantId, code: code);
      if (mounted) {
        setState(() {
          _applying = false;
          _applyMsg = msg;
          _applyController.clear();
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _applying = false;
          _applyError = _mapApplyError(e.message);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _applying = false;
          _applyError = 'No se pudo aplicar el código.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(color: gold, strokeWidth: 2))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PremiumBackButton(onTap: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Invita a un',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.55))),
                    Text('Amigo',
                        style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.2,
                            height: 1.05)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(width: 16, height: 1.5, color: gold),
                        const SizedBox(width: 8),
                        Text('Comparte tu código y ganen los dos',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.45))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _CodeCard(
                      code: _stats?.code ?? '—',
                      gold: gold,
                      onCopy: () => _copy(_stats?.code ?? ''),
                      onShare: () => _share(_stats?.code ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            gold: gold,
                            value: '${_stats?.referredCount ?? 0}',
                            label: 'AMIGOS REFERIDOS',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            gold: gold,
                            value: '${_stats?.totalEarned ?? 0}',
                            label: 'PUNTOS GANADOS',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('¿TIENES EL CÓDIGO DE UN AMIGO?',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.45),
                            letterSpacing: 1.4)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _applyController,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.characters,
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1),
                            decoration: InputDecoration(
                              hintText: 'CÓDIGO',
                              hintStyle: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1),
                              filled: true,
                              fillColor: const Color(0xFF141414),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: gold, width: 1.5),
                              ),
                            ),
                            onSubmitted: (_) => _apply(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PremiumPressable(
                          pressedScale: 0.95,
                          onTap: _applying ? null : _apply,
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _applying
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: premiumOnAccent(gold)),
                                  )
                                : Text('APLICAR',
                                    style: GoogleFonts.inter(
                                        color: premiumOnAccent(gold),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8)),
                          ),
                        ),
                      ],
                    ),
                    if (_applyMsg != null) ...[
                      const SizedBox(height: 10),
                      Text(_applyMsg!,
                          style: GoogleFonts.inter(
                              color: gold,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.4)),
                    ],
                    if (_applyError != null) ...[
                      const SizedBox(height: 10),
                      Text(_applyError!,
                          style: GoogleFonts.inter(
                              color: const Color(0xFFFF8A95),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.4)),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.code,
    required this.gold,
    required this.onCopy,
    required this.onShare,
  });

  final String code;
  final Color gold;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text('TU CÓDIGO',
              style: GoogleFonts.inter(
                  color: gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
          const SizedBox(height: 10),
          Text(code,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.copy_rounded,
                  label: 'COPIAR',
                  filled: false,
                  gold: gold,
                  onTap: onCopy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.ios_share_rounded,
                  label: 'COMPARTIR',
                  filled: true,
                  gold: gold,
                  onTap: onShare,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.filled,
    required this.gold,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? premiumOnAccent(gold) : gold;
    return PremiumPressable(
      pressedScale: 0.96,
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? gold : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 7),
            Text(label,
                style: GoogleFonts.inter(
                    color: fg,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.gold,
    required this.value,
    required this.label,
  });

  final Color gold;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: GoogleFonts.inter(
                  color: gold,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
        ],
      ),
    );
  }
}

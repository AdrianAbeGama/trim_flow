import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';

/// Hoja inferior de referidos: codigo a un lado, QR al otro, copiar y compartir,
/// y "tienes el codigo de un amigo?" desplegable con flechita.
class ReferralSheet extends StatefulWidget {
  const ReferralSheet({super.key, required this.code, required this.tenantId});

  final String code;
  final String tenantId;

  static Future<void> show(
    BuildContext context, {
    required String code,
    required String tenantId,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReferralSheet(code: code, tenantId: tenantId),
    );
  }

  @override
  State<ReferralSheet> createState() => _ReferralSheetState();
}

class _ReferralSheetState extends State<ReferralSheet> {
  final _repo = getIt<ProfileRepository>();
  final _applyController = TextEditingController();
  bool _expanded = false;
  bool _applying = false;
  String? _applyMsg;
  String? _applyError;

  @override
  void dispose() {
    _applyController.dispose();
    super.dispose();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    HapticFeedback.lightImpact();
    AppToast.success(context, 'Código copiado',
        message: 'Compártelo con un amigo.');
  }

  Future<void> _share() async {
    HapticFeedback.lightImpact();
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Reserva tu corte con mi código ${widget.code} en TrimFlow y ganamos los dos.',
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
      return 'Los referidos son solo para clientes nuevos.';
    }
    if (message.contains('referral_max_uses_reached')) {
      return 'Ese código llegó a su límite de usos.';
    }
    if (message.contains('referral_wrong_tenant')) {
      return 'Ese código es de otro negocio.';
    }
    if (message.contains('customer_not_linked')) {
      return 'Activa tu cuenta en este negocio primero.';
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
      final msg = await _repo.applyReferralCode(tenantId: widget.tenantId, code: code);
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
    } catch (_) {
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
    final code = widget.code.trim().isEmpty ? '—' : widget.code;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Invita a un amigo',
                    style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5)),
                const SizedBox(height: 3),
                Text('Comparte tu código y ganen los dos',
                    style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.45))),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TU CÓDIGO',
                              style: GoogleFonts.inter(
                                  color: gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2)),
                          const SizedBox(height: 10),
                          Text(code,
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text('Tu amigo lo escanea o lo escribe',
                              style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: code,
                        version: QrVersions.auto,
                        size: 90,
                        padding: EdgeInsets.zero,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scaleXY(
                            begin: 0.85,
                            end: 1,
                            duration: 450.ms,
                            curve: Curves.easeOutBack),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(
                        begin: 0.12,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SheetBtn(
                        icon: Icons.copy_rounded,
                        label: 'COPIAR',
                        filled: false,
                        onTap: _copy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SheetBtn(
                        icon: Icons.ios_share_rounded,
                        label: 'COMPARTIR',
                        filled: true,
                        onTap: _share,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 350.ms)
                    .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 120.ms,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic),
                const SizedBox(height: 10),
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                PremiumPressable(
                  pressedScale: 0.99,
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('¿Tienes el código de un amigo?',
                              style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.8))),
                        ),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.expand_more_rounded,
                              color: Colors.white.withValues(alpha: 0.5), size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? _applyArea(gold)
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _applyArea(Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  fillColor: const Color(0xFF161616),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: gold, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _apply(),
              ),
            ),
            const SizedBox(width: 10),
            _SheetBtn(
              icon: Icons.check_rounded,
              label: _applying ? '' : 'APLICAR',
              filled: true,
              loading: _applying,
              onTap: _applying ? () {} : _apply,
              compact: true,
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
        const SizedBox(height: 4),
      ],
    );
  }
}

class _SheetBtn extends StatelessWidget {
  const _SheetBtn({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
    this.loading = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final bool loading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.black : Colors.white.withValues(alpha: 0.9);
    return PremiumPressable(
      pressedScale: 0.96,
      onTap: onTap,
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFF7F3EC) : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(15),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: fg),
                  if (label.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(label,
                        style: GoogleFonts.inter(
                            color: fg,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8)),
                  ],
                ],
              ),
      ),
    );
  }
}

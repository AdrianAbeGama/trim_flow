import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

class OrderCancelSheet {
  static const List<String> reasons = [
    'Cambié de opinión',
    'Ya no lo necesito',
    'Encontré un mejor precio',
    'Me equivoqué de producto',
    'Demora en la preparación',
    'Otro motivo',
  ];

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _CancelSheetBody(),
    );
  }
}

class _CancelSheetBody extends StatelessWidget {
  const _CancelSheetBody();

  @override
  Widget build(BuildContext context) {
    final danger = const Color(0xFFCF6679);
    final gold = context.primaryGold;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38, height: 4,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.warning_amber_rounded, color: danger, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cancelar pedido', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text('Elige el motivo de tu cancelación', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...OrderCancelSheet.reasons.map((reason) => _ReasonTile(
                reason: reason,
                accent: danger,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, reason);
                },
              )),
          const SizedBox(height: 10),
          PremiumPressable(
            pressedScale: 0.98,
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gold.withValues(alpha: 0.2)),
              ),
              child: Text('MANTENER PEDIDO', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.reason, required this.accent, required this.onTap});

  final String reason;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked_rounded, color: accent, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(reason, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.25), size: 18),
          ],
        ),
      ),
    );
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_primitives.dart';

/// Datos personales del barbero (WhatsApp + Sucursal) con el mismo diseño de
/// tarjetas Wallet del cliente. Tocar una tarjeta abre la edición.
class BarberProfilePersonalData extends StatelessWidget {
  const BarberProfilePersonalData({
    super.key,
    required this.user,
    required this.onTap,
    this.branchName,
  });

  final UserProfile user;
  final VoidCallback onTap;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    final phoneVal = user.phone.isEmpty ? 'Pendiente' : '+51 ${user.phone}';
    final branchVal = (branchName != null && branchName!.isNotEmpty)
        ? branchName!
        : (user.branchId == null ? 'Sin asignar' : 'Sede asignada');

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BarberSectionTitle(text: 'Datos personales'),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _DataCard(
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WHATSAPP',
                      value: phoneVal,
                      isPending: user.phone.isEmpty,
                      onTap: onTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DataCard(
                      icon: FontAwesomeIcons.shop,
                      label: 'SUCURSAL',
                      value: branchVal,
                      isPending: user.branchId == null,
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 660.ms, duration: 600.ms),
      ),
    );
  }
}

/// Tarjeta premium de dato personal (estilo Wallet). Editable al tocar.
class _DataCard extends StatefulWidget {
  const _DataCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPending,
    required this.onTap,
  });

  final dynamic icon;
  final String label;
  final String value;
  final bool isPending;
  final VoidCallback onTap;

  @override
  State<_DataCard> createState() => _DataCardState();
}

class _DataCardState extends State<_DataCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    const red = Color(0xFFFF8A95);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isPending ? red.withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(widget.icon, size: 19, color: widget.isPending ? red : gold),
              const SizedBox(height: 16),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: widget.isPending ? red : Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

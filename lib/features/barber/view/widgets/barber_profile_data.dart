import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_primitives.dart';

/// Sección Datos personales (WhatsApp + Sucursal) con mini botón EDITAR.
class BarberProfilePersonalData extends StatelessWidget {
  const BarberProfilePersonalData({
    super.key,
    required this.user,
    required this.onTap,
  });

  final UserProfile user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final phoneVal = user.phone.isEmpty ? 'Pendiente' : '+51 ${user.phone}';
    final branchVal = user.branchId == null ? 'Sin asignar' : 'Sede asignada';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: BarberSectionTitle(text: 'Datos personales')),
                _MiniEditButton(onTap: onTap),
              ],
            ),
            const SizedBox(height: 8),
            _DataRow(
              icon: Icons.chat_rounded,
              label: 'WHATSAPP',
              value: phoneVal,
              isPending: user.phone.isEmpty,
              onTap: onTap,
            ),
            const _DataDivider(),
            _DataRow(
              icon: Icons.storefront_rounded,
              label: 'SUCURSAL',
              value: branchVal,
              isPending: user.branchId == null,
              onTap: onTap,
            ),
          ],
        ).animate().fadeIn(delay: 660.ms, duration: 600.ms),
      ),
    );
  }
}

/// Fila de dato personal — sin recuadro, ícono + label + valor + acción.
class _DataRow extends StatefulWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPending,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isPending;
  final VoidCallback onTap;

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
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
        scale: _pressed ? 0.99 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: gold.withValues(alpha: 0.18)),
                ),
                child: Icon(widget.icon, size: 18, color: gold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.isPending ? const Color(0xFFFF8A95) : Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                widget.isPending ? Icons.add_circle_outline_rounded : Icons.chevron_right_rounded,
                size: widget.isPending ? 18 : 20,
                color: widget.isPending ? const Color(0xFFFF8A95) : Colors.white.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Separador fino entre filas de datos.
class _DataDivider extends StatelessWidget {
  const _DataDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 1,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}

class _MiniEditButton extends StatefulWidget {
  const _MiniEditButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_MiniEditButton> createState() => _MiniEditButtonState();
}

class _MiniEditButtonState extends State<_MiniEditButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
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
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: gold.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 11, color: gold),
              const SizedBox(width: 5),
              Text(
                'EDITAR',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: gold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

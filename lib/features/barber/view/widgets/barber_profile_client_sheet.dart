import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_clients.dart';

/// Sheet con detalle de un cliente agendado + acciones CANCELAR / COMPLETAR.
class BarberClientDetailSheet extends StatelessWidget {
  const BarberClientDetailSheet({super.key, required this.client});

  final BarberClientItem client;

  static void show(BuildContext context, BarberClientItem client) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BarberClientDetailSheet(client: client),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    gold.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
            _SheetBody(client: client, gold: gold),
          ],
        ),
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.client, required this.gold});
  final BarberClientItem client;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BE38C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5, height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7BE38C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'AGENDADO',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7BE38C),
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            client.time,
            style: GoogleFonts.inter(
              fontSize: 58,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -3,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            client.dateLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _DetailRow(label: 'CLIENTE', value: client.name),
          const SizedBox(height: 14),
          _DetailRow(label: 'SERVICIO', value: client.service),
          const SizedBox(height: 22),
          Container(height: 0.5, color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'CANCELAR',
                  icon: Icons.close_rounded,
                  color: const Color(0xFFFF6B6B),
                  isPrimary: false,
                  onTap: () {
                    final rootContext =
                        Navigator.of(context, rootNavigator: true).context;
                    Navigator.pop(context);
                    AppToast.cancel(rootContext, 'Cita cancelada');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: 'COMPLETAR',
                  icon: Icons.check_rounded,
                  color: gold,
                  isPrimary: true,
                  onTap: () {
                    final rootContext =
                        Navigator.of(context, rootNavigator: true).context;
                    Navigator.pop(context);
                    AppToast.success(rootContext, 'Cita completada');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatefulWidget {
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.isPrimary ? widget.color : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : widget.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isPrimary ? Colors.black : widget.color,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: widget.isPrimary ? Colors.black : widget.color,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

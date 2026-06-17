import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Botón "CERRAR SESIÓN" destructive con borde rojo sutil.
class SettingsLogoutButton extends StatefulWidget {
  const SettingsLogoutButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<SettingsLogoutButton> createState() => _SettingsLogoutButtonState();
}

class _SettingsLogoutButtonState extends State<SettingsLogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.22),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 17,
                  color: Color(0xFFFF6B6B),
                ),
                const SizedBox(width: 9),
                Text(
                  'Cerrar sesión',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFF6B6B),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

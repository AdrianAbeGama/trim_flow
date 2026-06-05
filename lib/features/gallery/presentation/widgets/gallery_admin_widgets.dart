import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Widgets compartidos por las pestañas del admin dashboard.

/// TabBar premium con pill dorado deslizante (PORTAFOLIOS / STAFF / CATEGORÍAS).
class GalleryAdminTabBar extends StatelessWidget {
  const GalleryAdminTabBar({
    super.key,
    required this.controller,
    required this.gold,
  });

  final TabController controller;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: TabBar(
          controller: controller,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(9),
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
          labelStyle: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
          ),
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(vertical: 8),
          tabs: const [
            Tab(text: 'PORTAFOLIOS'),
            Tab(text: 'STAFF'),
            Tab(text: 'CATEGORÍAS'),
          ],
        ),
      ),
    );
  }
}

/// CTA primario dorado full-width con glow (usado para "Crear nuevo portafolio",
/// "Nueva categoría", etc.).
class GalleryPrimaryCta extends StatefulWidget {
  const GalleryPrimaryCta({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<GalleryPrimaryCta> createState() => _GalleryPrimaryCtaState();
}

class _GalleryPrimaryCtaState extends State<GalleryPrimaryCta> {
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
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: gold.withValues(alpha: 0.25), blurRadius: 12),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.black, size: 17),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
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

/// Empty state premium con halo dorado.
class GalleryAdminEmptyState extends StatelessWidget {
  const GalleryAdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: gold.withValues(alpha: 0.8), size: 38),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de icono pequeño circular (edit/delete) usado en filas del admin.
class GalleryAdminIconButton extends StatefulWidget {
  const GalleryAdminIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<GalleryAdminIconButton> createState() => _GalleryAdminIconButtonState();
}

class _GalleryAdminIconButtonState extends State<GalleryAdminIconButton> {
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
        scale: _pressed ? 0.85 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: widget.color, size: 15),
        ),
      ),
    );
  }
}

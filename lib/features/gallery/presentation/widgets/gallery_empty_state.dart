import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Empty state premium con halo dorado + icono + título + subtítulo.
class GalleryEmptyState extends StatelessWidget {
  const GalleryEmptyState({super.key, required this.isEditing});
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              color: gold.withValues(alpha: 0.8),
              size: 38,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            isEditing ? 'Sin portafolio aún' : 'Sin piezas todavía',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEditing
                ? 'Agrega la primera foto desde el botón "Nuevo portafolio" arriba.'
                : 'Aún estamos curando el portafolio. Vuelve pronto.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
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

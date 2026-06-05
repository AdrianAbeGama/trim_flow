import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Header premium del create form (greeting + pills + delete pill).
class GalleryFormHeader extends StatelessWidget {
  const GalleryFormHeader({
    super.key,
    required this.isEditing,
    required this.onBack,
    required this.onDelete,
  });

  final bool isEditing;
  final VoidCallback onBack;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GalleryBackButton(onTap: onBack),
              const SizedBox(width: 12),
              GalleryPill(
                icon: isEditing
                    ? Icons.edit_rounded
                    : Icons.add_photo_alternate_rounded,
                label: isEditing ? 'EDITAR PORTAFOLIO' : 'NUEVO PORTAFOLIO',
              ),
              const Spacer(),
              if (onDelete != null) _DeletePill(onTap: onDelete!),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 18),
          Text(
            isEditing ? 'Editando' : 'Nuevo',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.55),
              letterSpacing: -0.2,
            ),
          ).animate().fadeIn(delay: 120.ms, duration: 500.ms),
          const SizedBox(height: 4),
          Text(
            'Portafolio',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.4,
              height: 1.05,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 14, height: 1.5, color: gold),
              const SizedBox(width: 7),
              Text(
                isEditing
                    ? 'Actualizá las fotos y datos'
                    : 'Sube fotos al portafolio del barbero',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

class _DeletePill extends StatefulWidget {
  const _DeletePill({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_DeletePill> createState() => _DeletePillState();
}

class _DeletePillState extends State<_DeletePill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFFF8A95);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: danger.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: danger.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline_rounded, color: danger, size: 12),
              const SizedBox(width: 5),
              Text(
                'ELIMINAR',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: danger,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

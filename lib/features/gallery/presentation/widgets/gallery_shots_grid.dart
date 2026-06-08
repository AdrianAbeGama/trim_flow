import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Foto pendiente de upload en el create form. path = local path o http URL.
class PendingShot {
  final String path;
  final bool isLocal;
  const PendingShot({required this.path, required this.isLocal});
}

/// Grid horizontal reordenable de fotos pendientes (con crop/remove inline).
class GalleryShotsGrid extends StatelessWidget {
  const GalleryShotsGrid({
    super.key,
    required this.shots,
    required this.onCrop,
    required this.onRemove,
    required this.onReorder,
    required this.onAdd,
  });

  final List<PendingShot> shots;
  final ValueChanged<int> onCrop;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    if (shots.isEmpty) {
      return GalleryPressable(
        onTap: onAdd,
        pressedScale: 0.98,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gold.withValues(alpha: 0.30)),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_library_rounded, color: gold, size: 28),
              const SizedBox(height: 8),
              Text(
                'TOCA PARA AGREGAR FOTOS',
                style: GoogleFonts.inter(
                  color: gold,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Desde tu galería · podrás recortar después',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 140,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: shots.length,
        onReorder: onReorder,
        itemBuilder: (context, i) {
          final shot = shots[i];
          return _ShotTile(
            key: ValueKey('${shot.path}_$i'),
            shot: shot,
            index: i,
            onCrop: shot.isLocal ? () => onCrop(i) : null,
            onRemove: () => onRemove(i),
          );
        },
      ),
    );
  }
}

class _ShotTile extends StatelessWidget {
  const _ShotTile({
    super.key,
    required this.shot,
    required this.index,
    required this.onCrop,
    required this.onRemove,
  });

  final PendingShot shot;
  final int index;
  final VoidCallback? onCrop;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ReorderableDragStartListener(
        index: index,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _ShotPreview(shot: shot),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 5, left: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: gold.withValues(alpha: 0.40)),
                ),
                child: Text(
                  '#${index + 1}',
                  style: GoogleFonts.inter(
                    color: gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5, right: 5,
              child: _MiniButton(
                icon: Icons.close_rounded,
                onTap: onRemove,
                bg: const Color(0xFFFF8A95),
                fg: Colors.black,
              ),
            ),
            if (onCrop != null)
              Positioned(
                bottom: 5, right: 5,
                child: _MiniButton(
                  icon: Icons.crop_rounded,
                  onTap: onCrop!,
                  bg: gold,
                  fg: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShotPreview extends StatelessWidget {
  const _ShotPreview({required this.shot});
  final PendingShot shot;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 120, height: 140,
      color: const Color(0xFF181818),
      child: Icon(Icons.image_rounded, color: Colors.white.withValues(alpha: 0.18)),
    );
    if (shot.isLocal) {
      return Image.file(
        File(shot.path),
        width: 120, height: 140,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    }
    return Image.network(
      shot.path,
      width: 120, height: 140,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.icon,
    required this.onTap,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
        ),
        child: Icon(icon, color: fg, size: 14),
      ),
    );
  }
}

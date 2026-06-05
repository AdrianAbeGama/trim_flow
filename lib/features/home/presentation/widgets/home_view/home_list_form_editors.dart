import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';

class HomeListEditorSheet extends StatelessWidget {
  const HomeListEditorSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.addLabel,
    required this.items,
    required this.titleKey,
    required this.subtitleKey,
    required this.imageKey,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
    required this.onClose,
    this.maxItems,
  });

  final String title;
  final String subtitle;
  final String addLabel;
  final List<Map<String, String>> items;
  final String titleKey;
  final String subtitleKey;
  final String imageKey;
  final VoidCallback onAdd;
  final void Function(int, Map<String, String>) onEdit;
  final void Function(int) onRemove;
  final VoidCallback onClose;
  final int? maxItems;

  bool get _atMax => maxItems != null && items.length >= maxItems!;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        left: 12,
        right: 12,
        top: 100,
      ),
      child: Container(
        constraints: BoxConstraints(
          // Sheet más compacto — ~55% del alto, no toma toda la pantalla
          maxHeight: MediaQuery.of(context).size.height * 0.62,
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle estilo iOS
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: _atMax ? const Color(0xFFFF8A95) : gold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: items.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text(
                        'Sin items. Agrega el primero.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return HomeListEditorRow(
                          image: item[imageKey] ?? '',
                          title: item[titleKey] ?? '—',
                          subtitle: item[subtitleKey] ?? '',
                          onEdit: () => onEdit(i, item),
                          onRemove: () => onRemove(i),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            HomePressable(
              onTap: _atMax ? null : onAdd,
              pressedScale: 0.97,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _atMax
                      ? Colors.white.withValues(alpha: 0.03)
                      : gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _atMax
                        ? Colors.white.withValues(alpha: 0.06)
                        : gold.withValues(alpha: 0.30),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _atMax ? 'LÍMITE ALCANZADO · MÁX ${maxItems!}' : addLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: _atMax ? Colors.white.withValues(alpha: 0.35) : gold,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeListEditorRow extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const HomeListEditorRow({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onRemove,
  });

  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: HomeItemThumb(image: image, size: 44),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: gold.withValues(alpha: 0.85),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit_rounded, color: gold, size: 14),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A95).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF8A95), size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Imagen que detecta automáticamente si es URL http o file local.
/// Usar en lugar de CachedNetworkImage cuando el path puede venir del picker.
class HomeFormEditorSheet extends StatelessWidget {
  const HomeFormEditorSheet({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    required this.onClose,
  });

  final String title;
  final List<Widget> fields;
  final VoidCallback onSave;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        left: 12,
        right: 12,
        top: 60,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...fields,
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: HomePressable(
                      onTap: onClose,
                      pressedScale: 0.97,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'CANCELAR',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HomePressable(
                      onTap: onSave,
                      pressedScale: 0.97,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: context.primaryGold,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'GUARDAR',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card unificado para Looks / Servicios / Productos.
/// Imagen + gradient + nombre + tijera + precio + duración.

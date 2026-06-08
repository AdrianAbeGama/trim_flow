import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_admin_widgets.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Tab "Categorías" del admin dashboard — CRUD completo.
class GalleryAdminCategoriesTab extends StatelessWidget {
  const GalleryAdminCategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: GalleryPrimaryCta(
                icon: Icons.add_rounded,
                label: 'NUEVA CATEGORÍA',
                onTap: () async {
                  final result = await _CategorySheet.show(context, initial: '');
                  if (result != null && result.isNotEmpty && context.mounted) {
                    HapticFeedback.mediumImpact();
                    context.read<GalleryBloc>().add(GalleryEvent.categoryAdded(result));
                  }
                },
              ),
            ),
            Expanded(
              child: state.categories.isEmpty
                  ? const GalleryAdminEmptyState(
                      icon: Icons.label_outline_rounded,
                      title: 'Sin categorías',
                      subtitle: 'Crea la primera desde el botón superior.',
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      itemCount: state.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final cat = state.categories[index];
                        return _CategoryTile(label: cat.label, slug: cat.slug);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.label, required this.slug});

  final String label;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    const danger = Color(0xFFFF8A95);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.label_rounded, color: gold, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          GalleryAdminIconButton(
            icon: Icons.edit_rounded,
            color: gold,
            onTap: () async {
              final result = await _CategorySheet.show(context, initial: label);
              if (result != null && result.isNotEmpty && result != label && context.mounted) {
                HapticFeedback.mediumImpact();
                context
                    .read<GalleryBloc>()
                    .add(GalleryEvent.categoryUpdated(slug, result));
              }
            },
          ),
          const SizedBox(width: 4),
          GalleryAdminIconButton(
            icon: Icons.delete_outline_rounded,
            color: danger,
            onTap: () async {
              final ok = await GalleryConfirmDelete.show(
                context,
                title: 'Eliminar categoría',
                message:
                    '¿Seguro que quieres eliminar "$label"? Esta acción no se puede deshacer.',
              );
              if (ok && context.mounted) {
                HapticFeedback.lightImpact();
                context.read<GalleryBloc>().add(GalleryEvent.categoryDeleted(slug));
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Sheet para crear/editar categoría.
class _CategorySheet extends StatefulWidget {
  const _CategorySheet({required this.initial});
  final String initial;

  static Future<String?> show(BuildContext context, {required String initial}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CategorySheet(initial: initial),
    );
  }

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final isEditing = widget.initial.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        left: 12, right: 12, top: 60,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEditing ? 'Editar categoría' : 'Nueva categoría',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'NOMBRE',
              style: GoogleFonts.inter(
                color: gold,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: gold,
              decoration: InputDecoration(
                hintText: 'Ej. Fade premium',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.30),
                  fontSize: 12.5,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.03),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: gold.withValues(alpha: 0.50), width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GalleryPressable(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
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
                  child: GalleryPressable(
                    onTap: () => Navigator.pop(context, _ctrl.text.trim()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(12),
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
    );
  }
}

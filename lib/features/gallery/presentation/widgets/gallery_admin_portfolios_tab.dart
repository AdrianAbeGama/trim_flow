import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_create_form_view.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_admin_widgets.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Tab "Portafolios" del admin dashboard.
class GalleryAdminPortfoliosTab extends StatelessWidget {
  const GalleryAdminPortfoliosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        final gb = context.read<GalleryBloc>();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: GalleryPrimaryCta(
                icon: Icons.add_photo_alternate_rounded,
                label: 'CREAR NUEVO PORTAFOLIO',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: gb,
                      child: const GalleryCreateFormView(),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.allItems.isEmpty
                  ? const GalleryAdminEmptyState(
                      icon: Icons.photo_library_outlined,
                      title: 'Sin portafolios aún',
                      subtitle: 'Crea el primero desde el botón superior.',
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      itemCount: state.allItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = state.allItems[i];
                        return _PortfolioTile(
                          item: item,
                          onEdit: () => _openEdit(context, gb, item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _openEdit(BuildContext context, GalleryBloc gb, GalleryItem item) {
    final baseId = item.externalId.replaceAll(RegExp(r'_\d+$'), '');
    final groupItems = gb.state.allItems.where((i) {
      return i.externalId.replaceAll(RegExp(r'_\d+$'), '') == baseId;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: gb,
          child: GalleryCreateFormView(
            editingGroup: groupItems.isEmpty ? [item] : groupItems,
          ),
        ),
      ),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({required this.item, required this.onEdit});

  final GalleryItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GalleryPressable(
      onTap: onEdit,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isFeatured
                ? gold.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: item.isFeatured ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SafeImage(
                url: item.imageUrl,
                width: 56, height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.barberFullName ?? 'Sin barbero',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(width: 10, height: 1.5, color: gold),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.categoryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      if (item.isFeatured) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded, color: context.primaryGold, size: 13),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit_rounded, color: gold, size: 15),
            ),
          ],
        ),
      ),
    );
  }
}

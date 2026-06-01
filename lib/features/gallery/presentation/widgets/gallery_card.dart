import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_create_form_view.dart';

class GalleryMasonryCard extends StatefulWidget {
  const GalleryMasonryCard({
    super.key,
    required this.item,
    required this.height,
    required this.isEditing,
    required this.onTap,
    required this.onDelete,
    this.isFirstItem = false,
  });

  final GalleryItem item;
  final double height;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isFirstItem;

  @override
  State<GalleryMasonryCard> createState() => _GalleryMasonryCardState();
}

class _GalleryMasonryCardState extends State<GalleryMasonryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: _isExpanded
                      ? const BorderRadius.vertical(top: Radius.circular(23))
                      : BorderRadius.circular(23),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: SizedBox(
                      width: double.infinity,
                      child: _buildImage(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: _isExpanded,
                    child: AnimatedOpacity(
                      opacity: _isExpanded ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(23)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 32, 50, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (widget.item.barberFullName ?? 'ESTILISTA').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.item.barberSpecialty ?? widget.item.categoryLabel,
                              style: TextStyle(
                                color: context.primaryGold,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _ActionBtn(
                    icon: widget.item.isFeatured ? Icons.star_rounded : Icons.star_border_rounded,
                    color: widget.item.isFeatured ? context.primaryGold : Colors.white,
                    onTap: () {
                      if (widget.item.id != null) {
                        context.read<GalleryBloc>().add(GalleryItemToggledFeatured(widget.item.id!));
                      }
                    },
                  ),
                ),
                if (widget.isEditing)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        final gb = context.read<GalleryBloc>();
                        final baseId = widget.item.externalId.replaceAll(RegExp(r'_\d+$'), '');
                        final groupItems = gb.state.allItems.where((i) {
                          return i.externalId.replaceAll(RegExp(r'_\d+$'), '') == baseId;
                        }).toList();
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: gb,
                              child: GalleryCreateFormView(editingGroup: groupItems.isEmpty ? [widget.item] : groupItems),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: context.primaryGold.withValues(alpha: 0.4), width: 1),
                            ),
                            child: const Text(
                              'EDITAR',
                              style: TextStyle(
                                color: Color(0xFFF5F5DC),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: _ActionBtn(
                    icon: _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: context.primaryGold,
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila Superior: Nombre y Categoría
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            (widget.item.barberFullName ?? 'ESTILISTA').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.item.categoryLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Fila Inferior: Descripción
                    Text(
                      widget.item.barberSpecialty ?? 'Corte clásico',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Fila 4: Botón de Reservar
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: context.primaryGold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'RESERVAR',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.item.isLocalAsset) {
      final file = File(widget.item.imageUrl);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.item.imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => _placeholder(context),
      errorWidget: (_, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.scissors,
          color: context.primaryGold.withValues(alpha: 0.3),
          size: 26,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

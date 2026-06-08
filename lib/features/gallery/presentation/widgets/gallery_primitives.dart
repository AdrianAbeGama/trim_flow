import 'package:flutter/material.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';

/// Capa de compatibilidad: los primitivos genéricos viven ahora en
/// lib/core/widgets/premium/premium_primitives.dart y se comparten con otras
/// features. Aquí se exponen con el prefijo histórico Gallery* para no tocar
/// las vistas existentes, más los primitivos específicos de galería.

typedef GalleryPressable = PremiumPressable;
typedef GallerySmartImage = PremiumSmartImage;
typedef GalleryBackButton = PremiumBackButton;
typedef GalleryPill = PremiumPill;
typedef GallerySectionLabel = PremiumSectionLabel;
typedef GalleryConfirmDelete = PremiumConfirmDelete;

/// Badge pulsante con el label histórico de galería.
class GalleryEditingBadge extends StatelessWidget {
  const GalleryEditingBadge({super.key, this.label = 'EDICIÓN ACTIVA · GALERÍA'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return PremiumEditingBadge(label: label);
  }
}

/// Imagen específica para GalleryItem (detecta isLocalAsset del modelo).
class GalleryItemImage extends StatelessWidget {
  const GalleryItemImage({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final GalleryItem item;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return PremiumSmartImage(
      path: item.imageUrl,
      fit: fit,
      width: width,
      height: height,
      isLocalAsset: item.isLocalAsset,
    );
  }
}

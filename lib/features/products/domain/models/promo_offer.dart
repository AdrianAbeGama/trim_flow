import 'package:flutter/material.dart';

/// Oferta/promoción mostrada en el banner de productos (mock en memoria).
class PromoOffer {
  final String id;
  final String iconKey;
  final String eyebrow;
  final String title;
  final String caption;

  const PromoOffer({
    required this.id,
    required this.iconKey,
    required this.eyebrow,
    required this.title,
    required this.caption,
  });

  PromoOffer copyWith({
    String? iconKey,
    String? eyebrow,
    String? title,
    String? caption,
  }) {
    return PromoOffer(
      id: id,
      iconKey: iconKey ?? this.iconKey,
      eyebrow: eyebrow ?? this.eyebrow,
      title: title ?? this.title,
      caption: caption ?? this.caption,
    );
  }

  /// Íconos seleccionables para una oferta.
  static const Map<String, IconData> iconChoices = {
    'offer': Icons.local_offer_rounded,
    'redeem': Icons.redeem_rounded,
    'new': Icons.fiber_new_rounded,
    'drop': Icons.water_drop_rounded,
    'percent': Icons.percent_rounded,
    'star': Icons.star_rounded,
    'bolt': Icons.bolt_rounded,
    'cut': Icons.content_cut_rounded,
  };

  IconData get icon => iconChoices[iconKey] ?? Icons.local_offer_rounded;
}

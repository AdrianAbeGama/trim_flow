class GalleryItem {
  final int? id;
  final String externalId;
  final String imageUrl;
  final bool isLocalAsset;
  final String categorySlug;
  final String categoryLabel;
  final String? description;
  final String? barberProfileId;
  final String? barberFullName;
  final String? barberSpecialty;
  final DateTime createdAt;
  final int displayOrder;
  final bool isFeatured;
  final double? price;

  const GalleryItem({
    this.id,
    required this.externalId,
    required this.imageUrl,
    this.isLocalAsset = false,
    required this.categorySlug,
    required this.categoryLabel,
    this.description,
    this.barberProfileId,
    this.barberFullName,
    this.barberSpecialty,
    required this.createdAt,
    this.displayOrder = 0,
    this.isFeatured = false,
    this.price,
  });

  GalleryItem copyWith({
    int? id,
    String? categorySlug,
    String? categoryLabel,
    int? displayOrder,
    bool? isFeatured,
    String? barberProfileId,
    String? barberFullName,
    String? barberSpecialty,
    double? price,
  }) {
    return GalleryItem(
      id: id ?? this.id,
      externalId: externalId,
      imageUrl: imageUrl,
      isLocalAsset: isLocalAsset,
      categorySlug: categorySlug ?? this.categorySlug,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      description: description,
      barberProfileId: barberProfileId ?? this.barberProfileId,
      barberFullName: barberFullName ?? this.barberFullName,
      barberSpecialty: barberSpecialty ?? this.barberSpecialty,
      createdAt: createdAt,
      displayOrder: displayOrder ?? this.displayOrder,
      isFeatured: isFeatured ?? this.isFeatured,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'externalId': externalId,
      'imageUrl': imageUrl,
      'isLocalAsset': isLocalAsset,
      'categorySlug': categorySlug,
      'categoryLabel': categoryLabel,
      'description': description,
      'barberProfileId': barberProfileId,
      'barberFullName': barberFullName,
      'barberSpecialty': barberSpecialty,
      'createdAt': createdAt.toIso8601String(),
      'displayOrder': displayOrder,
      'isFeatured': isFeatured,
      'price': price,
    };
  }

  static GalleryItem fromMap(int? key, Map<dynamic, dynamic> raw) {
    final map = raw.cast<String, dynamic>();
    return GalleryItem(
      id: key,
      externalId: map['externalId'] as String? ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: map['imageUrl'] as String? ?? '',
      isLocalAsset: map['isLocalAsset'] as bool? ?? false,
      categorySlug: map['categorySlug'] as String? ?? 'general',
      categoryLabel: map['categoryLabel'] as String? ?? 'General',
      description: map['description'] as String?,
      barberProfileId: map['barberProfileId'] as String?,
      barberFullName: map['barberFullName'] as String?,
      barberSpecialty: map['barberSpecialty'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      displayOrder: map['displayOrder'] as int? ?? 0,
      isFeatured: map['isFeatured'] as bool? ?? false,
      price: (map['price'] as num?)?.toDouble(),
    );
  }
}

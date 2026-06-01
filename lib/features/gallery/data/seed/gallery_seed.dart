import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';

class GallerySeed {
  const GallerySeed._();

  static List<GalleryItem> initial() {
    // Galería arranca vacía. Los barberos suben sus propias piezas vía Admin Panel.
    return const <GalleryItem>[];
  }

  // ignore: unused_element
  static List<GalleryItem> _legacyDemoData() {
    final now = DateTime.now();
    final specs = <_SeedSpec>[
      _SeedSpec(
        externalId: 'seed_fade_01',
        imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=900',
        categorySlug: 'fade',
        categoryLabel: 'Fade',
        description: 'Fade alto con transicion limpia.',
        barberName: 'Carlos Diaz',
        specialty: 'Experto en Fades',
      ),
      _SeedSpec(
        externalId: 'seed_fade_02',
        imageUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=900',
        categorySlug: 'fade',
        categoryLabel: 'Fade',
        description: 'Mid fade clasico con textura encima.',
        barberName: 'Luis Gomez',
        specialty: 'Experto en Diseno',
      ),
      _SeedSpec(
        externalId: 'seed_classic_01',
        imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=900',
        categorySlug: 'classic',
        categoryLabel: 'Clasicos',
        description: 'Corte caballero estilo italiano.',
        barberName: 'Juan Perez',
        specialty: 'Experto en Clasicos',
      ),
      _SeedSpec(
        externalId: 'seed_classic_02',
        imageUrl: 'https://images.unsplash.com/photo-1512690196252-741ef2ae7626?w=900',
        categorySlug: 'classic',
        categoryLabel: 'Clasicos',
        description: 'Pompadour moderno con raya marcada.',
        barberName: 'Juan Perez',
        specialty: 'Experto en Clasicos',
      ),
      _SeedSpec(
        externalId: 'seed_beard_01',
        imageUrl: 'https://images.unsplash.com/photo-1621605815841-2dddbaa20b2a?w=900',
        categorySlug: 'beard',
        categoryLabel: 'Barbas',
        description: 'Perfilado de barba con toalla caliente.',
        barberName: 'Carlos Diaz',
        specialty: 'Experto en Barba Luxury',
      ),
      _SeedSpec(
        externalId: 'seed_beard_02',
        imageUrl: 'https://images.unsplash.com/photo-1634480251976-88062030061e?w=900',
        categorySlug: 'beard',
        categoryLabel: 'Barbas',
        description: 'Barba full con hidratacion premium.',
        barberName: 'Luis Gomez',
        specialty: 'Experto en Diseno',
      ),
      _SeedSpec(
        externalId: 'seed_design_01',
        imageUrl: 'https://images.unsplash.com/photo-1542856391-010fb87dcfed?w=900',
        categorySlug: 'design',
        categoryLabel: 'Disenos',
        description: 'Tatuaje capilar con linea precisa.',
        barberName: 'Luis Gomez',
        specialty: 'Experto en Diseno',
      ),
      _SeedSpec(
        externalId: 'seed_design_02',
        imageUrl: 'https://images.unsplash.com/photo-1559599101-f09722fb4948?w=900',
        categorySlug: 'design',
        categoryLabel: 'Disenos',
        description: 'Diseno geometrico personalizado.',
        barberName: 'Luis Gomez',
        specialty: 'Experto en Diseno',
      ),
      _SeedSpec(
        externalId: 'seed_platinum_01',
        imageUrl: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=900',
        categorySlug: 'platinum',
        categoryLabel: 'Platinados',
        description: 'Decoloracion full con tono platino.',
        barberName: 'Andrea Salas',
        specialty: 'Experto en Platinados',
      ),
      _SeedSpec(
        externalId: 'seed_platinum_02',
        imageUrl: 'https://images.unsplash.com/photo-1620049554683-c3f0e9b21c7e?w=900',
        categorySlug: 'platinum',
        categoryLabel: 'Platinados',
        description: 'Mechas plateadas con base oscura.',
        barberName: 'Andrea Salas',
        specialty: 'Experto en Platinados',
      ),
      _SeedSpec(
        externalId: 'seed_kids_01',
        imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=900',
        categorySlug: 'kids',
        categoryLabel: 'Ninos',
        description: 'Corte infantil con detalle lateral.',
        barberName: 'Juan Perez',
        specialty: 'Experto en Clasicos',
      ),
      _SeedSpec(
        externalId: 'seed_mustache_01',
        imageUrl: 'https://images.unsplash.com/photo-1517423568366-8b83523034fd?w=900',
        categorySlug: 'mustache',
        categoryLabel: 'Bigotes',
        description: 'Bigote estilo gentleman con cera.',
        barberName: 'Carlos Diaz',
        specialty: 'Experto en Barba Luxury',
      ),
      _SeedSpec(
        externalId: 'seed_trend_01',
        imageUrl: 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=900',
        categorySlug: 'fade',
        categoryLabel: 'Fade',
        description: 'Skin fade con texturizado encima.',
        barberName: 'Carlos Diaz',
        specialty: 'Experto en Fades',
      ),
      _SeedSpec(
        externalId: 'seed_trend_02',
        imageUrl: 'https://images.unsplash.com/photo-1590159443202-05459341777d?w=900',
        categorySlug: 'design',
        categoryLabel: 'Disenos',
        description: 'Hard part con linea quirurgica.',
        barberName: 'Luis Gomez',
        specialty: 'Experto en Diseno',
      ),
      _SeedSpec(
        externalId: 'seed_trend_03',
        imageUrl: 'https://images.unsplash.com/photo-1567894340315-735d7c361db0?w=900',
        categorySlug: 'classic',
        categoryLabel: 'Clasicos',
        description: 'Side part empresarial con brillo.',
        barberName: 'Juan Perez',
        specialty: 'Experto en Clasicos',
      ),
    ];

    final items = <GalleryItem>[];
    for (var i = 0; i < specs.length; i++) {
      final spec = specs[i];
      items.add(GalleryItem(
        externalId: spec.externalId,
        imageUrl: spec.imageUrl,
        isLocalAsset: false,
        categorySlug: spec.categorySlug,
        categoryLabel: spec.categoryLabel,
        description: spec.description,
        barberProfileId: null,
        barberFullName: spec.barberName,
        barberSpecialty: spec.specialty,
        createdAt: now.subtract(Duration(hours: i)),
        displayOrder: i,
        isFeatured: i < 3,
      ));
    }
    return items;
  }
}

class _SeedSpec {
  final String externalId;
  final String imageUrl;
  final String categorySlug;
  final String categoryLabel;
  final String description;
  final String barberName;
  final String specialty;

  const _SeedSpec({
    required this.externalId,
    required this.imageUrl,
    required this.categorySlug,
    required this.categoryLabel,
    required this.description,
    required this.barberName,
    required this.specialty,
  });
}

class Species {
  final String id;
  final String slug;
  final String scientificName;
  final String commonName;
  final String category;
  // Los campos opcionales pueden faltar en la API o en la copia local de favoritos
  final String? conservationStatus;
  final String? dangerLevel;
  final double? sizeMinCm;
  final double? sizeMaxCm;
  final double? depthMinM;
  final double? depthMaxM;
  final List<String> habitats;
  final List<String> behaviors;
  final String? shortDescription;
  final String? primaryPhoto;
  final bool featured;

  const Species({
    required this.id,
    required this.slug,
    required this.scientificName,
    required this.commonName,
    required this.category,
    this.conservationStatus,
    this.dangerLevel,
    this.sizeMinCm,
    this.sizeMaxCm,
    this.depthMinM,
    this.depthMaxM,
    this.habitats = const [],
    this.behaviors = const [],
    this.shortDescription,
    this.primaryPhoto,
    this.featured = false,
  });
}

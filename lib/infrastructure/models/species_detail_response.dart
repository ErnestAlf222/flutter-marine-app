// Detalle por slug: nombre, descripción y foto ya no vienen planos sino en
// `translations` y `photos`.
class TranslationResponse {
  final String language;
  final String? commonName;
  final String? fullDescription;
  final String? shortDescription;

  TranslationResponse({
    required this.language,
    required this.commonName,
    required this.fullDescription,
    required this.shortDescription,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      language: json['language'] as String,
      commonName: json['common_name'] as String?,
      fullDescription: json['full_description'] as String?,
      shortDescription: json['short_description'] as String?,
    );
  }
}

class PhotoResponse {
  final String url;
  final String? credit;
  final bool isPrimary;

  PhotoResponse({
    required this.url,
    required this.credit,
    required this.isPrimary,
  });

  factory PhotoResponse.fromJson(Map<String, dynamic> json) {
    return PhotoResponse(
      url: json['url'] as String,
      credit: json['credit'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

class TaxonomyResponse {
  final String? kingdom;
  final String? phylum;
  final String? taxonomicClass;
  final String? order;
  final String? family;
  final String? genus;

  TaxonomyResponse({
    required this.kingdom,
    required this.phylum,
    required this.taxonomicClass,
    required this.order,
    required this.family,
    required this.genus,
  });

  factory TaxonomyResponse.fromJson(Map<String, dynamic> json) {
    return TaxonomyResponse(
      kingdom: json['kingdom'] as String?,
      phylum: json['phylum'] as String?,
      taxonomicClass: json['class'] as String?,
      order: json['order'] as String?,
      family: json['family'] as String?,
      genus: json['genus'] as String?,
    );
  }
}

class SpeciesDetailResponse {
  final String id;
  final String slug;
  final String scientificName;
  final String category;
  final String? conservationStatus;
  final String? dangerLevel;
  final double? sizeMinCm;
  final double? sizeMaxCm;
  final double? depthMinM;
  final double? depthMaxM;
  final List<String> habitats;
  final List<String> behaviors;
  final bool featured;
  final TaxonomyResponse taxonomy;
  final List<TranslationResponse> translations;
  final List<PhotoResponse> photos;
  final List<String> zones;

  SpeciesDetailResponse({
    required this.id,
    required this.slug,
    required this.scientificName,
    required this.category,
    required this.conservationStatus,
    required this.dangerLevel,
    required this.sizeMinCm,
    required this.sizeMaxCm,
    required this.depthMinM,
    required this.depthMaxM,
    required this.habitats,
    required this.behaviors,
    required this.featured,
    required this.taxonomy,
    required this.translations,
    required this.photos,
    required this.zones,
  });

  factory SpeciesDetailResponse.fromJson(Map<String, dynamic> json) {
    final size = json['size'] as Map<String, dynamic>?;
    final depth = json['depth'] as Map<String, dynamic>?;
    final taxonomy = json['taxonomy'] as Map<String, dynamic>? ?? const {};

    return SpeciesDetailResponse(
      id: json['id'] as String,
      slug: json['slug'] as String,
      scientificName: json['scientific_name'] as String,
      category: json['category'] as String,
      conservationStatus: json['conservation_status'] as String?,
      dangerLevel: json['danger_level'] as String?,
      sizeMinCm: (size?['min_cm'] as num?)?.toDouble(),
      sizeMaxCm: (size?['max_cm'] as num?)?.toDouble(),
      depthMinM: (depth?['min_m'] as num?)?.toDouble(),
      depthMaxM: (depth?['max_m'] as num?)?.toDouble(),
      habitats: List<String>.from(json['habitats'] as List? ?? const []),
      behaviors: List<String>.from(json['behaviors'] as List? ?? const []),
      featured: json['featured'] as bool? ?? false,
      taxonomy: TaxonomyResponse.fromJson(taxonomy),
      translations: (json['translations'] as List? ?? const [])
          .map((e) => TranslationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List? ?? const [])
          .map((e) => PhotoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      zones: List<String>.from(json['zones'] as List? ?? const []),
    );
  }
}

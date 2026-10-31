// Formato plano de /species y /search (el detalle por slug tiene el suyo)
class SpeciesResponse {
  final String id;
  final String slug;
  final String scientificName;
  final String? commonName;
  final String category;
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

  SpeciesResponse({
    required this.id,
    required this.slug,
    required this.scientificName,
    required this.commonName,
    required this.category,
    required this.conservationStatus,
    required this.dangerLevel,
    required this.sizeMinCm,
    required this.sizeMaxCm,
    required this.depthMinM,
    required this.depthMaxM,
    required this.habitats,
    required this.behaviors,
    required this.shortDescription,
    required this.primaryPhoto,
    required this.featured,
  });

  factory SpeciesResponse.fromJson(Map<String, dynamic> json) {
    final size = json['size'] as Map<String, dynamic>?;
    final depth = json['depth'] as Map<String, dynamic>?;

    return SpeciesResponse(
      id: json['id'] as String,
      slug: json['slug'] as String,
      scientificName: json['scientific_name'] as String,
      commonName: json['common_name'] as String?,
      category: json['category'] as String,
      conservationStatus: json['conservation_status'] as String?,
      dangerLevel: json['danger_level'] as String?,
      sizeMinCm: (size?['min_cm'] as num?)?.toDouble(),
      sizeMaxCm: (size?['max_cm'] as num?)?.toDouble(),
      depthMinM: (depth?['min_m'] as num?)?.toDouble(),
      depthMaxM: (depth?['max_m'] as num?)?.toDouble(),
      habitats: List<String>.from(json['habitats'] as List? ?? const []),
      behaviors: List<String>.from(json['behaviors'] as List? ?? const []),
      shortDescription: json['short_description'] as String?,
      primaryPhoto: json['primary_photo'] as String?,
      featured: json['featured'] as bool? ?? false,
    );
  }
}

class PaginationResponse {
  final int total;
  final int page;
  final int perPage;

  PaginationResponse({
    required this.total,
    required this.page,
    required this.perPage,
  });

  factory PaginationResponse.fromJson(Map<String, dynamic> json) {
    return PaginationResponse(
      total: json['total'] as int,
      page: json['page'] as int,
      perPage: json['per_page'] as int,
    );
  }
}

// `pagination` es null en /search, que devuelve una lista simple
class SpeciesListResponse {
  final List<SpeciesResponse> data;
  final PaginationResponse? pagination;

  SpeciesListResponse({required this.data, required this.pagination});

  factory SpeciesListResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>?;

    return SpeciesListResponse(
      data: (json['data'] as List)
          .map((e) => SpeciesResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: pagination == null
          ? null
          : PaginationResponse.fromJson(pagination),
    );
  }
}

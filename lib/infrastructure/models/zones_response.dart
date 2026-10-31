class ZoneTranslationResponse {
  final String name;
  final String language;
  final String? description;

  ZoneTranslationResponse({
    required this.name,
    required this.language,
    required this.description,
  });

  factory ZoneTranslationResponse.fromJson(Map<String, dynamic> json) {
    return ZoneTranslationResponse(
      name: json['name'] as String,
      language: json['language'] as String,
      description: json['description'] as String?,
    );
  }
}

// `bounds` llega de dos formas: {zoom, center: [lat, lon]} en seis zonas y
// {lat_min, lat_max, lon_min, lon_max} en eastern-pacific
class ZoneBoundsResponse {
  final double? centerLat;
  final double? centerLon;
  final double? latMin;
  final double? latMax;
  final double? lonMin;
  final double? lonMax;

  const ZoneBoundsResponse({
    this.centerLat,
    this.centerLon,
    this.latMin,
    this.latMax,
    this.lonMin,
    this.lonMax,
  });

  factory ZoneBoundsResponse.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as List?;

    return ZoneBoundsResponse(
      centerLat: (center?.elementAtOrNull(0) as num?)?.toDouble(),
      centerLon: (center?.elementAtOrNull(1) as num?)?.toDouble(),
      latMin: (json['lat_min'] as num?)?.toDouble(),
      latMax: (json['lat_max'] as num?)?.toDouble(),
      lonMin: (json['lon_min'] as num?)?.toDouble(),
      lonMax: (json['lon_max'] as num?)?.toDouble(),
    );
  }
}

class ZoneResponse {
  final String id;
  final int speciesCount;
  final int displayOrder;
  final ZoneBoundsResponse? bounds;
  final List<ZoneTranslationResponse> translations;

  ZoneResponse({
    required this.id,
    required this.speciesCount,
    required this.displayOrder,
    required this.bounds,
    required this.translations,
  });

  factory ZoneResponse.fromJson(Map<String, dynamic> json) {
    final bounds = json['bounds'] as Map<String, dynamic>?;

    return ZoneResponse(
      id: json['id'] as String,
      speciesCount: json['species_count'] as int,
      displayOrder: json['display_order'] as int? ?? 0,
      bounds: bounds == null ? null : ZoneBoundsResponse.fromJson(bounds),
      translations: (json['zone_translations'] as List? ?? const [])
          .map(
            (e) => ZoneTranslationResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ZonesResponse {
  final List<ZoneResponse> data;

  ZonesResponse({required this.data});

  factory ZonesResponse.fromJson(Map<String, dynamic> json) {
    return ZonesResponse(
      data: (json['data'] as List)
          .map((e) => ZoneResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

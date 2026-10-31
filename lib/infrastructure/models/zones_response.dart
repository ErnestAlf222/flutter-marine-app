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

// `bounds` se ignora: el mapa de zonas queda fuera de la v1
class ZoneResponse {
  final String id;
  final int speciesCount;
  final int displayOrder;
  final List<ZoneTranslationResponse> translations;

  ZoneResponse({
    required this.id,
    required this.speciesCount,
    required this.displayOrder,
    required this.translations,
  });

  factory ZoneResponse.fromJson(Map<String, dynamic> json) {
    return ZoneResponse(
      id: json['id'] as String,
      speciesCount: json['species_count'] as int,
      displayOrder: json['display_order'] as int? ?? 0,
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

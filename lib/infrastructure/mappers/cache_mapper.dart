import 'dart:convert';

import 'package:marine_app/domain/domain.dart';

/// Pasa especies, detalles y zonas a JSON y de vuelta, para guardarlos en Isar.
class CacheMapper {
  static Map<String, Object?> _species(Species s) => {
    'id': s.id,
    'slug': s.slug,
    'scientificName': s.scientificName,
    'commonName': s.commonName,
    'category': s.category,
    'conservationStatus': s.conservationStatus,
    'dangerLevel': s.dangerLevel,
    'sizeMinCm': s.sizeMinCm,
    'sizeMaxCm': s.sizeMaxCm,
    'depthMinM': s.depthMinM,
    'depthMaxM': s.depthMaxM,
    'habitats': s.habitats,
    'behaviors': s.behaviors,
    'shortDescription': s.shortDescription,
    'primaryPhoto': s.primaryPhoto,
    'featured': s.featured,
    'updatedAt': s.updatedAt,
  };

  static List<String> _strings(Object? v) => [
    for (final item in (v as List? ?? const <Object?>[])) item as String,
  ];

  static Species _speciesFrom(Map<String, dynamic> m) => Species(
    id: m['id'] as String,
    slug: m['slug'] as String,
    scientificName: m['scientificName'] as String,
    commonName: m['commonName'] as String,
    category: m['category'] as String,
    conservationStatus: m['conservationStatus'] as String?,
    dangerLevel: m['dangerLevel'] as String?,
    sizeMinCm: (m['sizeMinCm'] as num?)?.toDouble(),
    sizeMaxCm: (m['sizeMaxCm'] as num?)?.toDouble(),
    depthMinM: (m['depthMinM'] as num?)?.toDouble(),
    depthMaxM: (m['depthMaxM'] as num?)?.toDouble(),
    habitats: _strings(m['habitats']),
    behaviors: _strings(m['behaviors']),
    shortDescription: m['shortDescription'] as String?,
    primaryPhoto: m['primaryPhoto'] as String?,
    featured: m['featured'] as bool? ?? false,
    updatedAt: m['updatedAt'] as String?,
  );

  static String speciesListToJson(List<Species> items) =>
      jsonEncode([for (final s in items) _species(s)]);

  static List<Species> speciesListFromJson(String json) => [
    for (final m in jsonDecode(json) as List)
      _speciesFrom(m as Map<String, dynamic>),
  ];

  static String detailToJson(SpeciesDetail d) => jsonEncode({
    ..._species(d),
    'fullDescription': d.fullDescription,
    'taxonomy': {
      'kingdom': d.taxonomy.kingdom,
      'phylum': d.taxonomy.phylum,
      'taxonomicClass': d.taxonomy.taxonomicClass,
      'order': d.taxonomy.order,
      'family': d.taxonomy.family,
      'genus': d.taxonomy.genus,
    },
    'photos': [
      for (final p in d.photos)
        {'url': p.url, 'credit': p.credit, 'isPrimary': p.isPrimary},
    ],
    'zones': d.zones,
  });

  static SpeciesDetail detailFromJson(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    final base = _speciesFrom(m);
    final t = m['taxonomy'] as Map<String, dynamic>? ?? const {};

    return SpeciesDetail(
      id: base.id,
      slug: base.slug,
      scientificName: base.scientificName,
      commonName: base.commonName,
      category: base.category,
      conservationStatus: base.conservationStatus,
      dangerLevel: base.dangerLevel,
      sizeMinCm: base.sizeMinCm,
      sizeMaxCm: base.sizeMaxCm,
      depthMinM: base.depthMinM,
      depthMaxM: base.depthMaxM,
      habitats: base.habitats,
      behaviors: base.behaviors,
      shortDescription: base.shortDescription,
      primaryPhoto: base.primaryPhoto,
      featured: base.featured,
      fullDescription: m['fullDescription'] as String?,
      taxonomy: SpeciesTaxonomy(
        kingdom: t['kingdom'] as String?,
        phylum: t['phylum'] as String?,
        taxonomicClass: t['taxonomicClass'] as String?,
        order: t['order'] as String?,
        family: t['family'] as String?,
        genus: t['genus'] as String?,
      ),
      photos: [
        for (final p in (m['photos'] as List? ?? const <Object?>[]))
          SpeciesPhoto(
            url: (p as Map<String, dynamic>)['url'] as String,
            credit: p['credit'] as String?,
            isPrimary: p['isPrimary'] as bool? ?? false,
          ),
      ],
      zones: _strings(m['zones']),
    );
  }

  static String zonesToJson(List<OceanZone> zones) => jsonEncode([
    for (final z in zones)
      {
        'id': z.id,
        'speciesCount': z.speciesCount,
        'name': z.name,
        'description': z.description,
        'lat': z.lat,
        'lon': z.lon,
      },
  ]);

  static List<OceanZone> zonesFromJson(String json) => [
    for (final m in jsonDecode(json) as List)
      OceanZone(
        id: (m as Map<String, dynamic>)['id'] as String,
        speciesCount: m['speciesCount'] as int,
        name: m['name'] as String,
        description: m['description'] as String,
        lat: (m['lat'] as num).toDouble(),
        lon: (m['lon'] as num).toDouble(),
      ),
  ];
}

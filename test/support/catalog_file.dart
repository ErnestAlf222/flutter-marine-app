import 'dart:convert';
import 'dart:io';

import 'package:marine_app/domain/domain.dart';

/// Catálogo real descargado con `python tool/download_catalog.py` (fuera de git).
/// Las pruebas de aceptación se saltan si el archivo no existe.
class CatalogFile {
  static const String directory = 'tool/catalog';

  static File file(String lang) => File('$directory/catalog_$lang.json');

  static bool get exists => file('es').existsSync() && file('en').existsSync();

  static const String missingReason =
      'Falta tool/catalog; se crea con: python tool/download_catalog.py';

  /// Registros tal como los devolvió /species en [lang]
  static List<Map<String, dynamic>> raw(String lang) {
    final json = jsonDecode(file(lang).readAsStringSync()) as Map<String, dynamic>;
    return (json['data'] as List).cast<Map<String, dynamic>>();
  }

  /// Especies de la lista en [lang], con los mismos campos que lee la app
  static List<Species> species(String lang) => [
    for (final r in raw(lang))
      Species(
        id: r['id'] as String,
        slug: r['slug'] as String,
        scientificName: r['scientific_name'] as String,
        commonName: (r['common_name'] as String?) ?? r['scientific_name'] as String,
        category: r['category'] as String,
        conservationStatus: r['conservation_status'] as String?,
        dangerLevel: r['danger_level'] as String?,
        sizeMinCm: ((r['size'] as Map?)?['min_cm'] as num?)?.toDouble(),
        sizeMaxCm: ((r['size'] as Map?)?['max_cm'] as num?)?.toDouble(),
        depthMinM: ((r['depth'] as Map?)?['min_m'] as num?)?.toDouble(),
        depthMaxM: ((r['depth'] as Map?)?['max_m'] as num?)?.toDouble(),
        habitats: ((r['habitats'] as List?) ?? const []).cast<String>(),
        behaviors: ((r['behaviors'] as List?) ?? const []).cast<String>(),
        shortDescription: r['short_description'] as String?,
        primaryPhoto: r['primary_photo'] as String?,
        featured: (r['featured'] as bool?) ?? false,
      ),
  ];
}

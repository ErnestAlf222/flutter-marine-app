import 'package:marine_app/domain/entities/ocean_zone.dart';
import 'package:marine_app/domain/entities/species.dart';
import 'package:marine_app/domain/entities/species_detail.dart';
import 'package:marine_app/domain/entities/species_page.dart';

// Cada método devuelve (dato, mensaje); si falla, dato es null y el mensaje explica el error.
// `lang` lo decide quien llama: el domain no conoce idiomas concretos.
abstract class SpeciesDatasource {
  Future<(SpeciesPage?, String)> getSpecies({
    required String lang,
    required int page,
    required int perPage,
    String? zone,
    String? category,
    String? conservationStatus,
    String? dangerLevel,
    double? sizeMin,
    double? sizeMax,
    double? depthMin,
    double? depthMax,
    bool? featured,
  });

  Future<(List<Species>?, String)> searchSpecies({
    required String query,
    required String lang,
  });

  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  });

  Future<(List<OceanZone>?, String)> getZones({required String lang});
}

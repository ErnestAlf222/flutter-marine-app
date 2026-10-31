import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/datasources/species_datasources_impl.dart';

class SpeciesRepositoryImpl extends SpeciesRepository {
  final SpeciesDatasource datasource;

  // Sin datasource inyectado se usa el de la API, como en la referencia
  SpeciesRepositoryImpl({SpeciesDatasource? datasource})
    : datasource = datasource ?? SpeciesDatasourcesImpl();

  @override
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
  }) {
    return datasource.getSpecies(
      lang: lang,
      page: page,
      perPage: perPage,
      zone: zone,
      category: category,
      conservationStatus: conservationStatus,
      dangerLevel: dangerLevel,
      sizeMin: sizeMin,
      sizeMax: sizeMax,
      depthMin: depthMin,
      depthMax: depthMax,
      featured: featured,
    );
  }

  @override
  Future<(List<Species>?, String)> searchSpecies({
    required String query,
    required String lang,
  }) {
    return datasource.searchSpecies(query: query, lang: lang);
  }

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  }) {
    return datasource.getSpeciesBySlug(slug: slug, lang: lang);
  }

  @override
  Future<(List<OceanZone>?, String)> getZones({required String lang}) {
    return datasource.getZones(lang: lang);
  }
}

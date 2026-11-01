import 'package:marine_app/domain/domain.dart';

// Repositorio falso para pruebas de pantallas: responde al instante, sin red y sin fotos.
// Las especies alternan fish/coral y crecen en tamaño y profundidad con su número.
class FakeUiRepository extends SpeciesRepository {
  final int count;
  // Cuántas especies devuelve /search (la API real no pasa de 50)
  final int searchCount;
  final searchQueries = <String>[];
  // Cuántas veces se pidió una página de /species (para saber si la lista se recargó)
  int speciesCalls = 0;

  FakeUiRepository({this.count = 6, int? searchCount})
    : searchCount = searchCount ?? count;

  static List<Species> species(int n) => [
    for (var i = 1; i <= n; i++)
      Species(
        id: 'id-$i',
        slug: 'especie-$i',
        scientificName: 'Species $i',
        commonName: 'Especie $i',
        category: i.isEven ? 'coral' : 'fish',
        conservationStatus: 'LC',
        dangerLevel: 'harmless',
        sizeMaxCm: i * 100.0,
        depthMaxM: i * 10.0,
      ),
  ];

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
  }) async {
    speciesCalls++;
    return (
      SpeciesPage(items: species(count), page: 1, perPage: perPage, total: count),
      '',
    );
  }

  @override
  Future<(List<Species>?, String)> searchSpecies({
    required String query,
    required String lang,
  }) async {
    searchQueries.add(query);
    return (species(searchCount), '');
  }

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  }) async => (null, 'Sin detalle en las pruebas.');

  @override
  Future<(List<OceanZone>?, String)> getZones({required String lang}) async =>
      (<OceanZone>[], '');

  @override
  Future<(List<Species>?, String)> getZoneTopSpecies({
    required String zone,
    required String lang,
    required int limit,
  }) async => (<Species>[], '');
}

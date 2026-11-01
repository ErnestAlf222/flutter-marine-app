import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';

class _Call {
  final int page;
  final int perPage;
  final double? sizeMin;
  final String? dangerLevel;
  final String? conservationStatus;

  _Call(this.page, this.perPage, this.sizeMin, this.dangerLevel, this.conservationStatus);
}

// Repositorio falso: registra las llamadas y responde con un total fijo
class _FakeRepository extends SpeciesRepository {
  final int total;
  final bool fails;
  final calls = <_Call>[];

  _FakeRepository({this.total = 1505, this.fails = false});

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
    calls.add(_Call(page, perPage, sizeMin, dangerLevel, conservationStatus));
    if (fails) return (null, 'El servidor tuvo un problema.');

    return (
      SpeciesPage(
        items: [
          Species(
            id: 'id-$page',
            slug: 'especie-$page',
            scientificName: 'Species $page',
            commonName: 'Especie $page',
            category: 'fish',
          ),
        ],
        page: page,
        perPage: perPage,
        total: total,
      ),
      '',
    );
  }

  @override
  Future<(List<Species>?, String)> searchSpecies({required String query, required String lang}) async =>
      (<Species>[], '');

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({required String slug, required String lang}) async =>
      (null, 'no usado');

  @override
  Future<(List<OceanZone>?, String)> getZones({required String lang}) async => (<OceanZone>[], '');

  @override
  Future<(List<Species>?, String)> getZoneTopSpecies({
    required String zone,
    required String lang,
    required int limit,
  }) async => (<Species>[], '');
}

ProviderContainer _container(_FakeRepository repository) {
  final container = ProviderContainer(
    // Como en la app: un error no se reintenta, se muestra
    retry: (_, _) => null,
    overrides: [speciesRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('colecciones de Inicio', () {
    test('son tres y cada una define un solo filtro', () {
      expect(CollectionConstants.items, hasLength(3));
      for (final c in CollectionConstants.items) {
        final filters = [c.sizeMinCm, c.dangerLevel, c.conservationStatus];
        expect(filters.where((f) => f != null), hasLength(1), reason: c.id);
      }
    });

    test('Gigantes del mar usa size_min=1000, Con veneno venomous y En peligro crítico CR', () {
      expect(CollectionConstants.byId('giants').sizeMinCm, 1000);
      expect(CollectionConstants.byId('venomous').dangerLevel, 'venomous');
      expect(CollectionConstants.byId('critical').conservationStatus, 'CR');
    });

    test('el conteo sale de pagination.total con per_page=1 y el filtro de la colección', () async {
      final repository = _FakeRepository(total: 9);
      final container = _container(repository);

      final count = await container.read(collectionCountProvider('giants').future);

      expect(count, 9);
      expect(repository.calls, hasLength(1));
      expect(repository.calls.single.perPage, 1);
      expect(repository.calls.single.sizeMin, 1000);
      expect(repository.calls.single.dangerLevel, isNull);
    });

    test('cada colección pide solo su propio filtro', () async {
      final repository = _FakeRepository(total: 38);
      final container = _container(repository);

      await container.read(collectionCountProvider('venomous').future);
      await container.read(collectionCountProvider('critical').future);

      expect(repository.calls[0].dangerLevel, 'venomous');
      expect(repository.calls[0].conservationStatus, isNull);
      expect(repository.calls[1].conservationStatus, 'CR');
      expect(repository.calls[1].dangerLevel, isNull);
    });

    test('si el servidor falla, el conteo propaga el mensaje', () async {
      final container = _container(_FakeRepository(fails: true));

      await expectLater(
        container.read(collectionCountProvider('giants').future),
        throwsA('El servidor tuvo un problema.'),
      );
    });
  });

  group('Sorpréndeme', () {
    test('elige una página al azar con per_page=1 dentro del total', () async {
      final repository = _FakeRepository(total: 50);
      final container = _container(repository);

      // Varias veces, para cubrir distintas páginas aleatorias
      for (int i = 0; i < 30; i++) {
        repository.calls.clear();
        final species = await container.read(surpriseSpeciesProvider)();

        expect(repository.calls.every((c) => c.perPage == 1), isTrue);
        final page = repository.calls.last.page;
        expect(page, inInclusiveRange(1, 50));
        expect(species.slug, 'especie-$page');
      }
    });

    test('con una sola especie en total no pide una segunda página', () async {
      final repository = _FakeRepository(total: 1);
      final container = _container(repository);

      final species = await container.read(surpriseSpeciesProvider)();

      expect(repository.calls, hasLength(1));
      expect(species.slug, 'especie-1');
    });

    test('si el servidor falla, lanza el mensaje en español', () async {
      final container = _container(_FakeRepository(fails: true));

      await expectLater(
        container.read(surpriseSpeciesProvider)(),
        throwsA('El servidor tuvo un problema.'),
      );
    });
  });
}

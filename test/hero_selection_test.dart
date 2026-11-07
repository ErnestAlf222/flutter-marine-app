import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';

import 'support/fake_offline.dart';
import 'support/fake_ui_repository.dart';

// [total] especies; solo las de número par son destacadas
List<Species> _catalog(int total) => [
  for (int i = 1; i <= total; i++)
    Species(
      id: 'id-$i',
      slug: 'especie-$i',
      scientificName: 'Species $i',
      commonName: 'Especie $i',
      category: 'fish',
      featured: i.isEven,
    ),
];

// Sin red: cualquier petición al servidor falla
class _NoServer extends FakeUiRepository {
  int requests = 0;

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
    requests++;
    return (null, ApiConstants.offlineMessage);
  }
}

// Un "proceso" nuevo: contenedor nuevo, misma base de Isar (la caché)
ProviderContainer _process({
  required InMemoryOfflineCache cache,
  required CatalogRepository catalog,
  required int seed,
  SpeciesRepository? server,
  bool online = true,
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      ...offlineOverrides(
        cache: cache,
        catalog: catalog,
        connectivity: FakeConnectivity(online: online),
      ),
      speciesRepositoryProvider.overrideWithValue(server ?? _NoServer()),
      heroRandomProvider.overrideWithValue(Random(seed)),
    ],
  );
  addTearDown(container.dispose);
  // Inicio está mirando el héroe
  container.listen(featuredSpeciesProvider, (_, _) {});
  return container;
}

Future<List<String>> _hero(ProviderContainer c) async =>
    [for (final s in await c.read(featuredSpeciesProvider.future)) s.slug];

void main() {
  group('selección pura', () {
    final all = _catalog(60).where((s) => s.featured).toList();
    String slugOf(Species s) => s.slug;

    test('elige la cantidad pedida entre las disponibles, sin repetir', () {
      final picked = pickHeroSpecies(
        featured: all,
        slugOf: slugOf,
        previous: {},
        random: Random(1),
        count: 8,
      );
      expect(picked.length, 8);
      expect(picked.map(slugOf).toSet().length, 8);
    });

    test('excluye las anteriores si hay otras suficientes', () {
      final previous = all.take(8).map(slugOf).toSet();
      final picked = pickHeroSpecies(
        featured: all,
        slugOf: slugOf,
        previous: previous,
        random: Random(2),
        count: 8,
      );
      expect(picked.map(slugOf).toSet().intersection(previous), isEmpty);
    });

    test('si las demás no alcanzan, completa con las anteriores', () {
      final few = all.take(10).toList();
      final previous = few.take(8).map(slugOf).toSet();
      final picked = pickHeroSpecies(
        featured: few,
        slugOf: slugOf,
        previous: previous,
        random: Random(3),
        count: 8,
      );
      expect(picked.length, 8);
      // Las 2 nuevas van siempre; el resto sale de las anteriores
      expect(picked.map(slugOf).toSet().length, 8);
      expect(picked.take(2).map(slugOf).toSet().intersection(previous), isEmpty);
    });

    test('con menos destacadas que las pedidas devuelve las que haya', () {
      final picked = pickHeroSpecies(
        featured: all.take(3).toList(),
        slugOf: slugOf,
        previous: {},
        random: Random(4),
        count: 8,
      );
      expect(picked.length, 3);
    });
  });

  group('héroe de Inicio con catálogo local completo', () {
    test('elige 8, solo destacadas, y las guarda para sin conexión', () async {
      final cache = InMemoryOfflineCache();
      final c = _process(
        cache: cache,
        catalog: FakeCatalogRepository(items: _catalog(100), ready: true),
        seed: 1,
      );

      final slugs = await _hero(c);
      await pumpEventQueue();

      expect(slugs.length, ApiConstants.featuredPerPage);
      expect(slugs.toSet().length, 8);
      for (final slug in slugs) {
        expect(int.parse(slug.split('-').last).isEven, isTrue, reason: '$slug no es destacada');
      }
      // Lo guardado como "destacadas de Inicio" y como "las del arranque" es esta selección
      expect(cache.heroList, slugs);
      expect(cache.featuredList?.map((s) => s.slug).toList(), slugs);
    });

    test('dos arranques seguidos no repiten ninguna', () async {
      final cache = InMemoryOfflineCache();
      final catalog = FakeCatalogRepository(items: _catalog(100), ready: true);

      final first = await _hero(_process(cache: cache, catalog: catalog, seed: 5));
      await pumpEventQueue();
      final second = await _hero(_process(cache: cache, catalog: catalog, seed: 5));
      await pumpEventQueue();
      final third = await _hero(_process(cache: cache, catalog: catalog, seed: 5));

      // Incluso con la misma semilla: lo que cambia es lo que se excluye
      expect(second.toSet().intersection(first.toSet()), isEmpty);
      expect(third.toSet().intersection(second.toSet()), isEmpty);
    });

    test('si no alcanzan las demás, completa con las del arranque anterior', () async {
      final cache = InMemoryOfflineCache();
      // 12 destacadas (números pares hasta 24): tras 8 solo quedan 4 distintas
      final catalog = FakeCatalogRepository(items: _catalog(24), ready: true);

      final first = await _hero(_process(cache: cache, catalog: catalog, seed: 1));
      await pumpEventQueue();
      final second = await _hero(_process(cache: cache, catalog: catalog, seed: 2));

      expect(second.length, 8);
      expect(second.toSet().length, 8);
      expect(second.toSet().difference(first.toSet()).length, 4);
    });

    test('es estable dentro de la misma sesión (incluso al volver de segundo plano)', () async {
      final cache = InMemoryOfflineCache();
      final c = _process(
        cache: cache,
        catalog: FakeCatalogRepository(items: _catalog(100), ready: true),
        seed: 7,
      );

      final first = await _hero(c);
      await pumpEventQueue();
      // La app pasa a segundo plano y vuelve: nadie recalcula, el provider sigue igual
      expect(await _hero(c), first);
      expect(await _hero(c), first);
      expect(cache.heroList, first, reason: 'no se vuelve a guardar otra selección');
    });

    test('cambia con un proceso nuevo y con el pull-to-refresh', () async {
      final cache = InMemoryOfflineCache();
      final catalog = FakeCatalogRepository(items: _catalog(100), ready: true);
      final c = _process(cache: cache, catalog: catalog, seed: 9);

      final first = await _hero(c);
      await pumpEventQueue();

      // Pull-to-refresh: se invalida y se elige otra (sin las de ahora)
      c.invalidate(featuredSpeciesProvider);
      final refreshed = await _hero(c);
      await pumpEventQueue();
      expect(refreshed, isNot(first));
      expect(refreshed.toSet().intersection(first.toSet()), isEmpty);

      // Un proceso nuevo parte de lo último que se vio
      final next = await _hero(_process(cache: cache, catalog: catalog, seed: 9));
      expect(next.toSet().intersection(refreshed.toSet()), isEmpty);
    });

    test('funciona sin red: no pide nada al servidor y no hay error', () async {
      final cache = InMemoryOfflineCache();
      final server = _NoServer();
      final c = _process(
        cache: cache,
        catalog: FakeCatalogRepository(items: _catalog(100), ready: true),
        seed: 3,
        server: server,
        online: false,
      );

      final slugs = await _hero(c);

      expect(slugs.length, 8);
      expect(server.requests, 0);
      expect(c.read(featuredSpeciesProvider).hasError, isFalse);
    });
  });

  group('héroe de Inicio sin catálogo listo', () {
    test('con lista guardada y red: la muestra y en ese mismo arranque llega la del servidor', () async {
      final cache = InMemoryOfflineCache()..featuredList = _catalog(8);
      final emissions = <List<String>>[];
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          ...offlineOverrides(cache: cache),
          speciesRepositoryProvider.overrideWithValue(FakeUiRepository(count: 8)),
        ],
      );
      addTearDown(c.dispose);
      c.listen(featuredSpeciesProvider, (_, next) {
        final value = next.asData?.value;
        if (value != null) emissions.add([for (final s in value) s.slug]);
      });

      await pumpEventQueue();

      // Primero lo guardado y, sin esperar a la próxima apertura, la lista del servidor
      expect(emissions.length, 2);
      expect(emissions.first, _catalog(8).map((s) => s.slug).toList());
      expect(emissions.last.first, 'especie-1');
      expect(cache.featuredList?.length, 8);
    });

    test('con lista guardada y sin red: se queda con lo guardado', () async {
      final cache = InMemoryOfflineCache()..featuredList = _catalog(8);
      final c = _process(
        cache: cache,
        catalog: FakeCatalogRepository(),
        seed: 1,
        online: false,
      );

      expect((await _hero(c)).length, 8);
      await pumpEventQueue();
      expect(c.read(featuredSpeciesProvider).hasError, isFalse);
    });

    test('sin nada guardado y sin red: error de sin conexión (sale el estado amigable)', () async {
      final c = _process(
        cache: InMemoryOfflineCache(),
        catalog: FakeCatalogRepository(),
        seed: 1,
        online: false,
      );

      await expectLater(
        c.read(featuredSpeciesProvider.future),
        throwsA(ApiConstants.offlineMessage),
      );
    });
  });
}

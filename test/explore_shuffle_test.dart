import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';

import 'support/fake_ui_repository.dart';

// Catálogo local falso con N especies en un orden conocido
class _Catalog extends CatalogRepository {
  final List<Species> items;
  int searches = 0;

  _Catalog(int count) : items = FakeUiRepository.species(count);

  @override
  bool get isReady => true;

  @override
  Future<bool> prepare() async => true;

  @override
  Stream<CatalogProgress> sync() => const Stream.empty();

  @override
  Future<List<Species>?> search({required String query, bool Function(Species)? filter}) async {
    searches++;
    return items.where((s) => filter == null || filter(s)).toList();
  }
}

// Sin catálogo: 100 especies en páginas de 20; guarda qué páginas se pidieron
class _PagedRepository extends FakeUiRepository {
  final requested = <int>[];

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
    requested.add(page);
    final all = FakeUiRepository.species(100);
    final start = (page - 1) * perPage;
    return (
      SpeciesPage(items: all.skip(start).take(perPage).toList(), page: page, perPage: perPage, total: 100),
      '',
    );
  }
}

// Semilla fija para predecir el orden
class _FixedSeed extends ExploreSeedNotifier {
  final int seed;

  _FixedSeed(this.seed);

  @override
  int build() => seed;
}

ProviderContainer _container({
  required SpeciesRepository server,
  CatalogRepository? catalog,
  int? seed,
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      speciesRepositoryProvider.overrideWithValue(server),
      if (catalog != null) catalogRepositoryProvider.overrideWithValue(catalog),
      if (seed != null) exploreSeedProvider.overrideWith(() => _FixedSeed(seed)),
    ],
  );
  addTearDown(container.dispose);
  container.listen(exploreSeedProvider, (_, _) {});
  return container;
}

// Mantiene viva la lista (como la pantalla) y devuelve sus slugs
Future<List<String>> _slugs(ProviderContainer container) async {
  container.listen(speciesListProvider, (_, _) {});
  return (await container.read(speciesListProvider.future)).items.map((s) => s.slug).toList();
}

void main() {
  group('con el catálogo local', () {
    test('sin texto ni filtros baraja con la semilla: mismas especies, otro orden', () async {
      final catalog = _Catalog(50);
      final container = _container(server: FakeUiRepository(), catalog: catalog, seed: 7);

      final slugs = await _slugs(container);

      expect(slugs.toSet(), catalog.items.map((s) => s.slug).toSet());
      expect(slugs, isNot(catalog.items.map((s) => s.slug).toList()));
      expect(slugs, ([...catalog.items]..shuffle(Random(7))).map((s) => s.slug).toList());
    });

    test('la misma semilla da siempre el mismo orden (recargar, volver del Detalle)', () async {
      final container = _container(server: FakeUiRepository(), catalog: _Catalog(50), seed: 7);
      final first = await _slugs(container);

      container.invalidate(speciesListProvider);
      expect(await _slugs(container), first);
    });

    test('una semilla nueva cambia el orden', () async {
      final container = _container(server: FakeUiRepository(), catalog: _Catalog(50));
      final before = await _slugs(container);
      final seed = container.read(exploreSeedProvider);

      container.read(exploreSeedProvider.notifier).reshuffle();
      final after = await _slugs(container);

      expect(container.read(exploreSeedProvider), isNot(seed));
      expect(after.toSet(), before.toSet());
      expect(after, isNot(before));
    });

    test('con filtros el orden es estable y la semilla no lo toca', () async {
      final catalog = _Catalog(50);
      final container = _container(server: FakeUiRepository(), catalog: catalog);
      container.read(speciesFiltersProvider.notifier).setCategory('coral');
      final before = await _slugs(container);
      // El catálogo falso queda "listo" al arrancar y eso rehace la lista una vez
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await _slugs(container);
      final searches = catalog.searches;

      container.read(exploreSeedProvider.notifier).reshuffle();
      final after = await _slugs(container);

      expect(after, before);
      expect(before, catalog.items.where((s) => s.category == 'coral').map((s) => s.slug).toList());
      expect(catalog.searches, searches, reason: 'ni siquiera se vuelve a consultar');
    });

    test('con texto el orden es el de relevancia del catálogo, sin barajar', () async {
      final catalog = _Catalog(50);
      final container = _container(server: FakeUiRepository(), catalog: catalog);
      container.read(speciesFiltersProvider.notifier).setQuery('especie');

      final slugs = await _slugs(container);
      container.read(exploreSeedProvider.notifier).reshuffle();

      expect(slugs, catalog.items.map((s) => s.slug).toList());
      expect(await _slugs(container), slugs);
    });
  });

  group('sin catálogo: páginas en círculo', () {
    test('empieza en la página que dicta la semilla y da la vuelta sin repetir', () async {
      final server = _PagedRepository();
      final container = _container(server: server, seed: 7);
      final start = Random(7).nextInt(5) + 1;

      final slugs = <String>[];
      container.listen(speciesListProvider, (_, _) {});
      SpeciesListState state = await container.read(speciesListProvider.future);
      slugs.addAll(state.items.map((s) => s.slug));
      while (state.hasNextPage) {
        await container.read(speciesListProvider.notifier).loadNextPage();
        state = container.read(speciesListProvider).requireValue;
        slugs
          ..clear()
          ..addAll(state.items.map((s) => s.slug));
      }

      expect(slugs, hasLength(100));
      expect(slugs.toSet(), hasLength(100), reason: 'sin especies repetidas');
      // Primero la página 1 (da el total), luego la elegida y el resto en círculo
      expect(server.requested.first, 1);
      expect(server.requested.toSet(), {1, 2, 3, 4, 5});
      expect(slugs.first, FakeUiRepository.species(100)[(start - 1) * 20].slug);
    });

    test('con filtros pide las páginas en orden, como siempre', () async {
      final server = _PagedRepository();
      final container = _container(server: server, seed: 7);
      container.read(speciesFiltersProvider.notifier).setCategory('fish');

      container.listen(speciesListProvider, (_, _) {});
      await container.read(speciesListProvider.future);
      await container.read(speciesListProvider.notifier).loadNextPage();

      expect(server.requested, [1, 2]);
    });
  });

  group('cuándo cambia la semilla', () {
    test('cambia al salir de Explorar y volver a ella', () {
      final container = _container(server: FakeUiRepository());
      final tabs = container.read(currentTabProvider.notifier);

      tabs.set(RouteConstants.exploreTab);
      final first = container.read(exploreSeedProvider);
      tabs.set(0);
      expect(container.read(exploreSeedProvider), first, reason: 'al salir no cambia');
      tabs.set(RouteConstants.exploreTab);

      expect(container.read(exploreSeedProvider), isNot(first));
    });

    test('no cambia la primera vez que se entra ni al quedarse en la pestaña (volver del Detalle)', () {
      final container = _container(server: FakeUiRepository());
      final tabs = container.read(currentTabProvider.notifier);
      final first = container.read(exploreSeedProvider);

      tabs.set(RouteConstants.exploreTab);
      expect(container.read(exploreSeedProvider), first);

      // Abrir y cerrar el Detalle no mueve la pestaña
      tabs.set(RouteConstants.exploreTab);
      expect(container.read(exploreSeedProvider), first);
    });

    test('pasar por otras pestañas sin haber estado en Explorar no baraja', () {
      final container = _container(server: FakeUiRepository());
      final tabs = container.read(currentTabProvider.notifier);
      final first = container.read(exploreSeedProvider);

      tabs.set(2);
      tabs.set(0);

      expect(container.read(exploreSeedProvider), first);
    });
  });

  testWidgets('tirar hacia abajo para refrescar baraja de nuevo', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final catalog = _Catalog(50);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          speciesRepositoryProvider.overrideWithValue(FakeUiRepository()),
          catalogRepositoryProvider.overrideWithValue(catalog),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: const [OceanPalette.dark]),
          home: const Scaffold(body: ExploreView()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final container = ProviderScope.containerOf(tester.element(find.byType(ExploreView)));
    final seed = container.read(exploreSeedProvider);

    await tester.fling(find.byType(CustomScrollView).last, const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(exploreSeedProvider), isNot(seed));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}

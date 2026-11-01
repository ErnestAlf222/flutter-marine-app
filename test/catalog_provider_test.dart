import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

// Catálogo falso: lista fija y avance controlado por la prueba
class _FakeCatalog extends CatalogRepository {
  bool ready;
  final List<Species> items;
  final controller = StreamController<CatalogProgress>();
  int searches = 0;

  _FakeCatalog({this.ready = false, this.items = const []});

  @override
  bool get isReady => ready;

  @override
  Future<bool> prepare() async => ready;

  @override
  Stream<CatalogProgress> sync() => controller.stream;

  @override
  Future<List<Species>?> search({
    required String query,
    bool Function(Species)? filter,
  }) async {
    if (!ready) return null;
    searches++;
    return items.where((s) => filter == null || filter(s)).toList();
  }
}

ProviderContainer _container(FakeUiRepository server, _FakeCatalog catalog) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      speciesRepositoryProvider.overrideWithValue(server),
      catalogRepositoryProvider.overrideWithValue(catalog),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('lista de Explorar: de dónde sale', () {
    test('sin catálogo listo sigue usando el servidor, con su reintento y su tope', () async {
      final server = FakeUiRepository(searchCount: 3);
      final catalog = _FakeCatalog();
      final container = _container(server, catalog);

      container.read(speciesFiltersProvider.notifier).setQuery('especie');
      final state = await container.read(speciesListProvider.future);

      expect(server.searchQueries, ['especie']);
      expect(state.items, hasLength(3));
      expect(catalog.searches, 0);
    });

    test('con el catálogo listo todo es local: ni una petición y sin tope de 50', () async {
      final server = FakeUiRepository();
      final catalog = _FakeCatalog(ready: true, items: FakeUiRepository.species(300));
      final container = _container(server, catalog);

      final all = await container.read(speciesListProvider.future);
      expect(all.items, hasLength(300));
      expect(all.hasNextPage, isFalse);

      container.read(speciesFiltersProvider.notifier).setQuery('especie');
      final searched = await container.read(speciesListProvider.future);
      expect(searched.items, hasLength(300));
      expect(searched.searchCapped, isFalse);

      expect(server.speciesCalls, 0);
      expect(server.searchQueries, isEmpty);
    });

    test('los filtros también se resuelven en local', () async {
      final catalog = _FakeCatalog(ready: true, items: FakeUiRepository.species(10));
      final container = _container(FakeUiRepository(), catalog);

      container.read(speciesFiltersProvider.notifier).setCategory('coral');
      final state = await container.read(speciesListProvider.future);

      expect(state.items, hasLength(5));
      expect(state.items.every((s) => s.category == 'coral'), isTrue);
    });

    test('la zona solo existe en el servidor: con zona se usa aunque haya catálogo', () async {
      final server = FakeUiRepository();
      final catalog = _FakeCatalog(ready: true, items: FakeUiRepository.species(10));
      final container = _container(server, catalog);

      container.read(speciesFiltersProvider.notifier).setZone('caribbean');
      await container.read(speciesListProvider.future);

      expect(server.speciesCalls, 1);
      expect(catalog.searches, 0);
    });

    test('cuando el catálogo queda listo, la lista se rehace con él', () async {
      final server = FakeUiRepository();
      final catalog = _FakeCatalog(items: FakeUiRepository.species(40));
      final container = _container(server, catalog);
      container.listen(catalogSyncProvider, (_, _) {});
      container.listen(speciesListProvider, (_, _) {});

      await container.read(speciesListProvider.future);
      expect(server.speciesCalls, 1);

      // Termina la sincronización
      await Future<void>.delayed(Duration.zero);
      catalog.ready = true;
      await catalog.controller.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final state = await container.read(speciesListProvider.future);
      expect(state.items, hasLength(40));
      expect(server.speciesCalls, 1, reason: 'ya no vuelve al servidor');
    });
  });

  group('estado de la sincronización', () {
    test('muestra "x de 16" solo en la primera vez y no tras quedar listo', () async {
      final catalog = _FakeCatalog();
      final container = _container(FakeUiRepository(), catalog);
      container.listen(catalogSyncProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(container.read(catalogSyncProvider).showProgress, isTrue);

      catalog.controller.add(const CatalogProgress(3, 16));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final status = container.read(catalogSyncProvider);
      expect((status.step, status.total), (3, 16));

      catalog.ready = true;
      await catalog.controller.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(catalogSyncProvider).ready, isTrue);
      expect(container.read(catalogSyncProvider).showProgress, isFalse);
    });

    test('la actualización con catálogo ya listo no muestra progreso', () async {
      final catalog = _FakeCatalog(ready: true);
      final container = _container(FakeUiRepository(), catalog);
      container.listen(catalogSyncProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));

      catalog.controller.add(const CatalogProgress(2, 16));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(container.read(catalogSyncProvider).showProgress, isFalse);
    });

    test('si falla, la app sigue con el servidor y no muestra progreso', () async {
      final catalog = _FakeCatalog();
      final container = _container(FakeUiRepository(), catalog);
      container.listen(catalogSyncProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));

      catalog.controller.addError('sin red');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final status = container.read(catalogSyncProvider);
      expect(status.showProgress, isFalse);
      expect(status.ready, isFalse);
    });
  });

  group('indicador en Explorar', () {
    testWidgets('el pez y "x de 16" aparecen durante la primera sincronización y se van al terminar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final catalog = _FakeCatalog();

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
      await tester.pump(const Duration(milliseconds: 50));

      catalog.controller.add(const CatalogProgress(3, 16));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(CatalogConstants.progress(3, 16)), findsOneWidget);
      expect(find.byType(FishLoader), findsWidgets);

      // Al buscar, el progreso desaparece: solo queda el pez de los resultados
      final container = ProviderScope.containerOf(tester.element(find.byType(ExploreView)));
      container.read(speciesFiltersProvider.notifier).setQuery('tiburon');
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining(CatalogConstants.preparing), findsNothing);
      expect(find.textContaining(' de 16'), findsNothing);

      // Sin texto vuelve mientras dura la primera sincronización
      container.read(speciesFiltersProvider.notifier).setQuery('');
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(CatalogConstants.progress(3, 16)), findsOneWidget);

      catalog.ready = true;
      await catalog.controller.close();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining(CatalogConstants.preparing), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    });
  });
}

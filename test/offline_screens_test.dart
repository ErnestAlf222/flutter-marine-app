import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_offline.dart';
import 'support/fake_ui_repository.dart';

// Sin fotos: la prueba no debe tocar la red ni la caché de imágenes
SpeciesDetail _detail(int n, {String? description}) => SpeciesDetail(
  id: 'id-$n',
  slug: 'especie-$n',
  scientificName: 'Species $n',
  commonName: 'Especie $n',
  category: 'fish',
  fullDescription: description,
);

class _Repository extends FakeUiRepository {
  String? failWith;
  int detailCalls = 0;

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  }) async {
    detailCalls++;
    if (failWith != null) return (null, failWith!);
    return (_detail(int.parse(slug.split('-').last), description: 'Vista en línea'), '');
  }
}

// Favoritos en memoria: marcar crea la fila (sin ficha) en la caché, como hace Isar
class _Favorites extends FavoritesRepository {
  final InMemoryOfflineCache cache;

  _Favorites(this.cache);

  @override
  Future<(bool?, String)> saveFavorite(Species species) async {
    cache.favorites.putIfAbsent(species.slug, () => null);
    return (true, '');
  }

  @override
  Future<(bool?, String)> removeFavorite(String slug) async {
    cache.favorites.remove(slug);
    return (true, '');
  }

  @override
  Future<(bool?, String)> isFavorite(String slug) async => (cache.favorites.containsKey(slug), '');

  @override
  Stream<List<Species>> watchFavorites() => Stream.value(const <Species>[]);
}

Widget _host(Widget child, List<Override> overrides) => ProviderScope(
  retry: (_, _) => null,
  overrides: overrides,
  child: MaterialApp(
    theme: ThemeData(extensions: const [OceanPalette.dark]),
    home: Scaffold(body: child),
  ),
);

Future<void> _size(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

ProviderContainer _container(List<Override> overrides) {
  final c = ProviderContainer(retry: (_, _) => null, overrides: overrides);
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('favoritos: ficha completa para verlos sin conexión', () {
    test('al marcar uno sin ficha cargada, la descarga y la guarda', () async {
      final cache = InMemoryOfflineCache();
      final repository = _Repository();
      final c = _container([
        ...offlineOverrides(cache: cache),
        speciesRepositoryProvider.overrideWithValue(repository),
        favoritesRepositoryProvider.overrideWithValue(_Favorites(cache)),
      ]);

      expect(await c.read(favoriteActionsProvider).add(FakeUiRepository.species(1).first), isNull);
      await pumpEventQueue();

      expect(repository.detailCalls, 1);
      expect(cache.favorites['especie-1']?.fullDescription, 'Vista en línea');
    });

    test('si la ficha ya está cargada, no se vuelve a pedir', () async {
      final cache = InMemoryOfflineCache();
      final repository = _Repository();
      final c = _container([
        ...offlineOverrides(cache: cache),
        speciesRepositoryProvider.overrideWithValue(repository),
        favoritesRepositoryProvider.overrideWithValue(_Favorites(cache)),
      ]);

      await c.read(favoriteActionsProvider).add(_detail(2, description: 'Ya cargada'));
      await pumpEventQueue();

      expect(repository.detailCalls, 0);
      expect(cache.favorites['especie-2']?.fullDescription, 'Ya cargada');
    });

    test('si estaba entre los últimos vistos, usa esa copia sin red', () async {
      final cache = InMemoryOfflineCache();
      await cache.saveDetail(_detail(3, description: 'Vista antes'), limit: 10);
      final repository = _Repository()..failWith = ApiConstants.offlineMessage;
      final c = _container([
        ...offlineOverrides(cache: cache),
        speciesRepositoryProvider.overrideWithValue(repository),
        favoritesRepositoryProvider.overrideWithValue(_Favorites(cache)),
      ]);

      await c.read(favoriteActionsProvider).add(FakeUiRepository.species(3).last);
      await pumpEventQueue();

      expect(repository.detailCalls, 0);
      expect(cache.favorites['especie-3']?.fullDescription, 'Vista antes');
    });

    test('migración: los favoritos sin ficha la descargan al abrir la app con red', () async {
      final cache = InMemoryOfflineCache()
        ..favorites['especie-4'] = null
        ..favorites['especie-5'] = _detail(5, description: 'Ya tenía');
      final repository = _Repository();
      final c = _container([
        ...offlineOverrides(cache: cache),
        speciesRepositoryProvider.overrideWithValue(repository),
      ]);

      await c.read(favoritesBackfillProvider.future);

      expect(repository.detailCalls, 1, reason: 'solo el que no tenía ficha');
      expect(cache.favorites['especie-4']?.fullDescription, 'Vista en línea');
      expect(cache.favorites['especie-5']?.fullDescription, 'Ya tenía');
    });

    test('migración sin conexión: no insiste y queda para la próxima', () async {
      final cache = InMemoryOfflineCache()..favorites['especie-4'] = null;
      final repository = _Repository();
      final c = _container([
        ...offlineOverrides(cache: cache, connectivity: FakeConnectivity(online: false)),
        speciesRepositoryProvider.overrideWithValue(repository),
      ]);

      await c.read(favoritesBackfillProvider.future);

      expect(repository.detailCalls, 0);
      expect(cache.favorites['especie-4'], isNull);
    });
  });

  group('Detalle sin conexión', () {
    testWidgets('un favorito abre con su ficha y la franja avisa que es lo guardado', (tester) async {
      await _size(tester);
      final cache = InMemoryOfflineCache()
        ..favorites['especie-1'] = _detail(1, description: 'Ficha guardada del favorito');
      final repository = _Repository()..failWith = ApiConstants.offlineMessage;

      await tester.pumpWidget(
        _host(const SpeciesDetailView(slug: 'especie-1'), [
          ...offlineOverrides(cache: cache, connectivity: FakeConnectivity(online: false)),
          speciesRepositoryProvider.overrideWithValue(repository),
        ]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(MotionConstants.short);

      expect(find.text('Especie 1'), findsWidgets);
      expect(find.text('Ficha guardada del favorito'), findsOneWidget);
      expect(find.byType(FriendlyState), findsNothing);
      expect(find.text(OfflineConstants.savedStrip), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('una especie nunca vista sin conexión usa el estado amigable', (tester) async {
      await _size(tester);
      final repository = _Repository()..failWith = ApiConstants.offlineMessage;
      final connectivity = FakeConnectivity(online: false);

      await tester.pumpWidget(
        _host(const SpeciesDetailView(slug: 'especie-9'), [
          ...offlineOverrides(connectivity: connectivity),
          speciesRepositoryProvider.overrideWithValue(repository),
        ]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FriendlyState), findsOneWidget);
      expect(find.text(FriendlyConstants.messages[FailureKind.offline]!), findsOneWidget);
      expect(find.text(FriendlyConstants.seeFavorites), findsOneWidget);
      expect(find.text(FriendlyConstants.retry), findsOneWidget);
      // No hay nada guardado que mostrar: la franja no aparece
      expect(find.text(OfflineConstants.savedStrip), findsNothing);
      await _drain(tester);
    });

    testWidgets('un 404 dice que no se encontró y ofrece volver, no reintentar', (tester) async {
      await _size(tester);
      final repository = _Repository()..failWith = ApiConstants.notFoundMessage;

      await tester.pumpWidget(
        _host(const SpeciesDetailView(slug: 'especie-9'), [
          ...offlineOverrides(),
          speciesRepositoryProvider.overrideWithValue(repository),
        ]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(FriendlyConstants.messages[FailureKind.notFound]!), findsOneWidget);
      expect(find.text(FriendlyConstants.back), findsOneWidget);
      expect(find.text(FriendlyConstants.retry), findsNothing);
      await _drain(tester);
    });
  });

  group('franja "mostrando lo guardado"', () {
    Future<ProviderContainer> pumpStrip(
      WidgetTester tester,
      FakeConnectivity connectivity,
    ) async {
      await tester.pumpWidget(
        _host(const Stack(children: [OfflineStrip()]), offlineOverrides(connectivity: connectivity)),
      );
      await tester.pump();
      return ProviderScope.containerOf(tester.element(find.byType(OfflineStrip)));
    }

    testWidgets('solo aparece sin conexión y con algo guardado en pantalla', (tester) async {
      final connectivity = FakeConnectivity(online: false);
      final container = await pumpStrip(tester, connectivity);

      // Sin conexión pero sin nada guardado a la vista
      await tester.pump(MotionConstants.short);
      expect(find.text(OfflineConstants.savedStrip), findsNothing);

      container.read(savedContentProvider.notifier).mark(OfflineConstants.savedZones);
      await tester.pump();
      await tester.pump(MotionConstants.short);
      expect(find.text(OfflineConstants.savedStrip), findsOneWidget);

      // Vuelve la conexión: se va
      connectivity.set(true);
      await tester.pump();
      await tester.pump(MotionConstants.short);
      await tester.pump(MotionConstants.short);
      expect(find.text(OfflineConstants.savedStrip), findsNothing);
    });

    testWidgets('con conexión no aparece aunque haya algo marcado', (tester) async {
      final container = await pumpStrip(tester, FakeConnectivity());
      container.read(savedContentProvider.notifier).mark(OfflineConstants.savedZones);
      await tester.pump();
      await tester.pump(MotionConstants.short);

      expect(find.text(OfflineConstants.savedStrip), findsNothing);
    });
  });

  group('primera carga de Inicio', () {
    Future<void> pumpHome(WidgetTester tester, InMemoryOfflineCache cache) async {
      await _size(tester);
      await tester.pumpWidget(
        _host(const HomeView(), [
          // Sin el override de tiempo cero: aquí se mide el mínimo real
          offlineCacheRepositoryProvider.overrideWithValue(cache),
          connectivityRepositoryProvider.overrideWithValue(FakeConnectivity()),
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
          speciesRepositoryProvider.overrideWithValue(FakeUiRepository()),
        ]),
      );
    }

    testWidgets('sin datos guardados, el pez grande se queda al menos el tiempo mínimo', (
      tester,
    ) async {
      await pumpHome(tester, InMemoryOfflineCache());

      // Los datos llegan al instante, pero el pez sigue visible y sin carrusel
      await tester.pump();
      await tester.pump(OfflineConstants.firstLoadFishDelay + MotionConstants.short);
      expect(find.byType(FishLoader), findsOneWidget);
      expect(tester.widget<FishLoader>(find.byType(FishLoader)).size, DesignConstants.firstLoadFishSize);
      expect(find.byType(PageView), findsNothing);

      // Pasaron ~500 ms de 600: todavía no
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(PageView), findsNothing);

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(FishLoader), findsNothing);
      await _drain(tester);
    });

    testWidgets('con datos guardados se ven de inmediato y sin el pez', (tester) async {
      final cache = InMemoryOfflineCache()..featuredList = FakeUiRepository.species(4);
      await pumpHome(tester, cache);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(FishLoader), findsNothing);
      // Y se actualizan para la próxima apertura
      await tester.pump(const Duration(milliseconds: 100));
      expect(cache.featuredList?.length, 6);
      await _drain(tester);
    });

    testWidgets('el pez no aparece si los datos guardados llegan antes de su espera', (tester) async {
      final cache = InMemoryOfflineCache()..featuredList = FakeUiRepository.species(4);
      await pumpHome(tester, cache);

      await tester.pump();
      await tester.pump(OfflineConstants.firstLoadFishDelay);

      expect(find.byType(FishLoader), findsNothing);
      await _drain(tester);
    });
  });
}

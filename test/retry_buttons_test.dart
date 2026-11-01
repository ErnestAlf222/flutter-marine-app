import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

// Mensaje con el que falla el servidor falso (los providers lanzan Strings en español)
const _failure = 'Falla de prueba del servidor.';

// Primera llamada: falla al instante. Las siguientes quedan esperando a que la prueba
// decida, para poder mirar la pantalla "mientras reintenta".
class _Gate<T> {
  int calls = 0;
  final retry = Completer<(T?, String)>();

  Future<(T?, String)> next() {
    calls++;
    return calls == 1 ? Future.value((null, _failure)) : retry.future;
  }
}

class _GatedRepository extends FakeUiRepository {
  // Qué llamadas a /species pasan por la compuerta (página, por página, destacadas)
  bool Function(int page, int perPage, bool? featured)? gateSpeciesIf;
  final species = _Gate<SpeciesPage>();
  final zones = _Gate<List<OceanZone>>();
  final detail = _Gate<SpeciesDetail>();
  // Total que reporta la primera página de /species (para probar "cargar más")
  final int total;

  _GatedRepository({this.gateSpeciesIf, this.total = 6});

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
    if (gateSpeciesIf?.call(page, perPage, featured) ?? false) {
      return species.next();
    }
    return Future.value((
      SpeciesPage(
        items: FakeUiRepository.species(perPage > 20 ? 20 : perPage),
        page: page,
        perPage: perPage,
        total: total,
      ),
      '',
    ));
  }

  @override
  Future<(List<OceanZone>?, String)> getZones({required String lang}) =>
      zones.next();

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  }) => detail.next();
}

// Favoritos cuya primera lectura falla; la segunda espera a la prueba
class _BrokenFavorites extends FavoritesRepository {
  int listens = 0;
  final gate = Completer<void>();

  @override
  Stream<List<Species>> watchFavorites() async* {
    listens++;
    if (listens == 1) throw _failure;
    await gate.future;
    yield <Species>[];
  }

  @override
  Future<(bool?, String)> saveFavorite(Species species) async => (true, '');

  @override
  Future<(bool?, String)> removeFavorite(String slug) async => (true, '');

  @override
  Future<(bool?, String)> isFavorite(String slug) async => (false, '');
}

Future<void> _pump(
  WidgetTester tester,
  Widget view, {
  required SpeciesRepository repository,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        speciesRepositoryProvider.overrideWithValue(repository),
        ...overrides,
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        home: Scaffold(body: view),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

// Las entradas escalonadas y el carrusel usan temporizadores: se desmonta y se deja vencer
Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

// Toca "Reintentar": el error anterior debe desaparecer de inmediato (la pantalla carga)
Future<void> _retryAndExpectLoading(
  WidgetTester tester, {
  Finder? button,
}) async {
  expect(find.text(_failure), findsWidgets);
  await tester.tap((button ?? find.text('Reintentar')).first);
  await tester.pump();
  // El fundido entre estados (AnimatedSwitcher) deja un instante al anterior en pantalla
  await tester.pump(MotionConstants.medium);
  await tester.pump(MotionConstants.medium);

  expect(
    find.text(_failure),
    findsNothing,
    reason: 'sigue mostrando el error anterior',
  );
  expect(find.text('Reintentar'), findsNothing);
}

bool _footerStarted() =>
    find.byType(FishLoader).evaluate().isNotEmpty ||
    find.text('Reintentar').evaluate().isNotEmpty;

void main() {
  group('cada botón "Reintentar" muestra la carga', () {
    testWidgets('Inicio: héroe de destacadas', (tester) async {
      final repository = _GatedRepository(
        gateSpeciesIf: (page, perPage, featured) => featured == true,
      );
      await _pump(tester, const HomeView(), repository: repository);

      await _retryAndExpectLoading(tester);
      expect(repository.species.calls, 2);
      await _drain(tester);
    });

    testWidgets('Inicio: mosaico "Descubre más"', (tester) async {
      final repository = _GatedRepository(
        gateSpeciesIf: (page, perPage, featured) =>
            featured != true && perPage == DesignConstants.discoverFetch,
      );
      await _pump(tester, const HomeView(), repository: repository);

      await tester.dragUntilVisible(
        find.text('Reintentar'),
        find.byType(CustomScrollView).first,
        const Offset(0, -300),
      );
      // Un poco más, para que el botón quede libre de la barra inferior
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -250),
      );
      await tester.pump();
      await _retryAndExpectLoading(tester);
      expect(repository.species.calls, 2);
      await _drain(tester);
    });

    testWidgets('Explorar: lista de resultados', (tester) async {
      final repository = _GatedRepository(
        gateSpeciesIf: (page, perPage, featured) =>
            perPage == ApiConstants.defaultPerPage,
      );
      await _pump(tester, const ExploreView(), repository: repository);

      await _retryAndExpectLoading(tester);
      expect(find.byType(SkeletonBox), findsWidgets);
      expect(repository.species.calls, 2);
      await _drain(tester);
    });

    testWidgets('Explorar: "cargar más" al pie de la lista', (tester) async {
      // Hay 40 resultados: la página 2 falla la primera vez
      final repository = _GatedRepository(
        total: 40,
        gateSpeciesIf: (page, perPage, featured) => page == 2,
      );
      await _pump(tester, const ExploreView(), repository: repository);
      // La lista entra con un fundido antes de poder desplazarse
      await tester.pump(MotionConstants.medium);

      final scroll = find.descendant(
        of: find.byType(ExploreView),
        matching: find.byType(CustomScrollView),
      );
      // El pie se construye solo al llegar: se desplaza hasta que aparezca el fallo
      // (se corta en cuanto empieza la carga del pie: seguir arrastrando la repetiría)
      for (var i = 0; i < 80 && !_footerStarted(); i++) {
        await tester.drag(scroll.last, const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(milliseconds: 100));
      expect(repository.species.calls, 1);
      await _retryAndExpectLoading(tester);
      // La lista ya cargada se queda y el pie muestra el pez
      expect(find.byType(SpeciesTile), findsWidgets);
      expect(find.byType(FishLoader), findsOneWidget);
      expect(repository.species.calls, 2);
      await _drain(tester);
    });

    testWidgets('Detalle', (tester) async {
      final repository = _GatedRepository();
      await _pump(
        tester,
        const SpeciesDetailView(slug: 'especie-1'),
        repository: repository,
      );

      await _retryAndExpectLoading(tester);
      expect(repository.detail.calls, 2);
      await _drain(tester);
    });

    testWidgets('Favoritos', (tester) async {
      final favorites = _BrokenFavorites();
      await _pump(
        tester,
        const FavoritesView(),
        repository: FakeUiRepository(),
        overrides: [favoritesRepositoryProvider.overrideWithValue(favorites)],
      );

      const message = 'No se pudieron leer tus favoritos.';
      expect(find.text(message), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(message),
        findsNothing,
        reason: 'sigue mostrando el error anterior',
      );
      expect(find.text('Reintentar'), findsNothing);
      expect(favorites.listens, 2);
      await _drain(tester);
    });

    testWidgets('Mapa: zonas', (tester) async {
      final repository = _GatedRepository();
      await _pump(tester, const MapView(), repository: repository);

      await _retryAndExpectLoading(tester);
      expect(find.byType(FishLoader), findsOneWidget);
      expect(repository.zones.calls, 2);
      await _drain(tester);
    });
  });
}

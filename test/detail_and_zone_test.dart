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

Widget _host(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      retry: (_, _) => null,
      overrides: overrides,
      child: MaterialApp(
        // Tema simple con la paleta: evita descargar Montserrat en la prueba
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        home: Scaffold(body: child),
      ),
    );

// Favoritos en memoria: la lista se emite al escuchar y con cada cambio, como la base real
class _FakeFavorites extends FavoritesRepository {
  final List<Species> _items;
  final _changes = StreamController<List<Species>>.broadcast();
  // Si se da, la primera lista tarda en llegar (arranque en frío de la base local)
  final Completer<void>? firstEmission;

  _FakeFavorites({List<Species> initial = const [], this.firstEmission})
    : _items = [...initial];

  @override
  Stream<List<Species>> watchFavorites() async* {
    await firstEmission?.future;
    yield [..._items];
    yield* _changes.stream;
  }

  @override
  Future<(bool?, String)> saveFavorite(Species species) async {
    _items.add(species);
    _changes.add([..._items]);
    return (true, '');
  }

  @override
  Future<(bool?, String)> removeFavorite(String slug) async {
    _items.removeWhere((s) => s.slug == slug);
    _changes.add([..._items]);
    return (true, '');
  }

  @override
  Future<(bool?, String)> isFavorite(String slug) async =>
      (_items.any((s) => s.slug == slug), '');
}

// Falla la primera vez y deja controlar cuándo y cómo responde el reintento
class _FlakyZoneRepository extends FakeUiRepository {
  int calls = 0;
  final retry = Completer<(List<Species>?, String)>();

  @override
  Future<(List<Species>?, String)> getZoneTopSpecies({
    required String zone,
    required String lang,
    required int limit,
  }) {
    calls++;
    if (calls == 1) return Future.value((null, 'El servidor falló.'));
    return retry.future;
  }
}

const _zone = OceanZone(
  id: 'mediterranean',
  speciesCount: 100,
  name: 'Mediterráneo',
  description: 'Un mar casi cerrado.',
  lat: 35,
  lon: 18,
);

final _species = FakeUiRepository.species(1).first;

void main() {
  group('estado de conservación', () {
    testWidgets(
      'muestra los 7 niveles y resalta el de la especie con su frase',
      (tester) async {
        await tester.pumpWidget(_host(const ConservationScale(status: 'CR')));
        await tester.pumpAndSettle();

        for (final code in ConservationConstants.scale) {
          expect(find.text(code), findsOneWidget);
        }
        expect(find.text('DD'), findsNothing);
        expect(find.text('En peligro crítico'), findsOneWidget);
        expect(find.text(ConservationConstants.phrases['CR']!), findsOneWidget);

        // El activo es más alto que los demás
        final active = tester.getSize(
          find
              .ancestor(
                of: find.text('CR'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final other = tester.getSize(
          find
              .ancestor(
                of: find.text('LC'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(active.height, greaterThan(other.height));
      },
    );

    testWidgets('DD va aparte de la escala, como "Datos insuficientes"', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const ConservationScale(status: 'DD')));
      await tester.pumpAndSettle();

      expect(find.text('Datos insuficientes'), findsOneWidget);
      expect(find.text(ConservationConstants.phrases['DD']!), findsOneWidget);
      for (final code in ConservationConstants.scale) {
        expect(find.text(code), findsNothing);
      }
    });

    test('cada nivel de la escala tiene nombre y frase', () {
      for (final code in [...ConservationConstants.scale, 'DD', 'NE']) {
        expect(ConservationConstants.labels[code], isNotNull, reason: code);
        expect(ConservationConstants.phrases[code], isNotNull, reason: code);
      }
    });
  });

  group('peligrosidad', () {
    testWidgets('muestra nombre y frase de cada nivel', (tester) async {
      for (final level in TraitConstants.dangerLevels.keys) {
        await tester.pumpWidget(_host(DangerInfo(level: level)));
        expect(find.text(TraitConstants.dangerLevels[level]!), findsOneWidget);
        expect(find.text(TraitConstants.dangerPhrases[level]!), findsOneWidget);
      }
    });
  });

  group('tarjetas de profundidad y tamaño', () {
    testWidgets(
      'la profundidad dice entre qué valores va, desde la superficie al fondo',
      (tester) async {
        await tester.pumpWidget(_host(const DepthGauge(minM: 5, maxM: 30)));
        await tester.pumpAndSettle();

        expect(find.text(MeasureConstants.depthQuestion), findsOneWidget);
        expect(find.text('5–30 m'), findsOneWidget);
        expect(find.text(MeasureConstants.surfaceLabel), findsOneWidget);
        expect(find.text('${MeasureConstants.untilLabel} 50 m'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      },
    );

    testWidgets(
      'el tamaño dice entre qué valores va, de lo pequeño a lo grande',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const SizedBox(width: 340, child: SizeBar(minCm: 10, maxCm: 50)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(MeasureConstants.sizeQuestion), findsOneWidget);
        expect(find.text('10 cm – 50 cm'), findsOneWidget);
        expect(find.text(MeasureConstants.smallLabel), findsOneWidget);
        expect(find.text(MeasureConstants.largeLabel), findsOneWidget);
      },
    );
  });

  group('hoja de zona: reintentar', () {
    Future<_FlakyZoneRepository> openZone(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final repository = _FlakyZoneRepository();
      await tester.pumpWidget(
        _host(
          const MapView(),
          overrides: [
            speciesRepositoryProvider.overrideWithValue(repository),
            zonesProvider.overrideWith((ref) async => [_zone]),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // La lista bajo el mapa abre la misma hoja que el círculo del mapa
      await tester.tap(find.text('Mediterráneo').first);
      await tester.pump();
      await tester.pump(MotionConstants.long);
      await tester.pump(const Duration(milliseconds: 100));
      return repository;
    }

    testWidgets(
      'reintentar muestra el pez y, si vuelve a fallar, el mensaje final',
      (tester) async {
        final repository = await openZone(tester);

        expect(find.text('Reintentar'), findsOneWidget);
        expect(find.byType(FishLoader), findsNothing);

        await tester.tap(find.text('Reintentar'));
        await tester.pump();
        // Mientras espera la respuesta nada el pez
        expect(find.byType(FishLoader), findsOneWidget);
        expect(find.text('Reintentar'), findsNothing);

        repository.retry.complete((null, 'El servidor falló.'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text(ApiConstants.zoneRetryFailedMessage), findsOneWidget);
        expect(find.text('Reintentar'), findsNothing);
        expect(find.byType(FishLoader), findsNothing);
        expect(repository.calls, 2);
      },
    );

    testWidgets('si el reintento funciona se muestran las especies', (
      tester,
    ) async {
      final repository = await openZone(tester);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      repository.retry.complete((FakeUiRepository.species(2), ''));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(ApiConstants.zoneRetryFailedMessage), findsNothing);
      expect(find.byType(SpeciesTile), findsWidgets);
    });
  });

  group('corazón: lista y Detalle se comportan igual', () {
    Finder bursts() => find.byType(BubbleBurst);

    Future<void> pumpTile(WidgetTester tester, _FakeFavorites favorites) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            height: 260,
            child: SpeciesTile(species: _species),
          ),
          overrides: [favoritesRepositoryProvider.overrideWithValue(favorites)],
        ),
      );
      await tester.pump();
    }

    Future<void> pumpDetail(
      WidgetTester tester,
      _FakeFavorites favorites,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          SpeciesDetailView(slug: _species.slug, preview: _species),
          overrides: [
            speciesRepositoryProvider.overrideWithValue(FakeUiRepository()),
            favoritesRepositoryProvider.overrideWithValue(favorites),
          ],
        ),
      );
      await tester.pump();
    }

    Future<void> tapHeart(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Agregar a favoritos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    Future<void> drain(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets(
      'en la lista, marcar guarda, cambia el corazón y suelta burbujas',
      (tester) async {
        final favorites = _FakeFavorites();
        await pumpTile(tester, favorites);

        await tapHeart(tester);

        expect(favorites._items.map((s) => s.slug), [_species.slug]);
        expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
        expect(bursts(), findsOneWidget);
        await drain(tester);
      },
    );

    testWidgets(
      'en el Detalle, marcar guarda, cambia el corazón y suelta burbujas',
      (tester) async {
        final favorites = _FakeFavorites();
        await pumpDetail(tester, favorites);

        await tapHeart(tester);

        expect(favorites._items.map((s) => s.slug), [_species.slug]);
        expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
        expect(bursts(), findsOneWidget);
        await drain(tester);
      },
    );

    testWidgets('quitar no suelta burbujas', (tester) async {
      final favorites = _FakeFavorites(initial: [_species]);
      await pumpDetail(tester, favorites);
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byTooltip('Quitar de favoritos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(favorites._items, isEmpty);
      expect(bursts(), findsNothing);
      await drain(tester);
    });

    testWidgets(
      'regresión: abrir el Detalle de un favorito antes de que la base responda no suelta burbujas',
      (tester) async {
        final gate = Completer<void>();
        final favorites = _FakeFavorites(
          initial: [_species],
          firstEmission: gate,
        );
        await pumpDetail(tester, favorites);

        // La base local responde con la especie ya guardada
        gate.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
        expect(bursts(), findsNothing);
        await drain(tester);
      },
    );
  });
}

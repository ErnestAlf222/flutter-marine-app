import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

const _zone = OceanZone(
  id: 'mediterranean',
  speciesCount: 100,
  name: 'Mar de prueba',
  description: 'Un mar casi cerrado.',
  lat: 35,
  lon: 18,
);

Species _species(
  String slug, {
  String category = 'fish',
  double? size,
  double? depth,
  String? status,
}) => Species(
  id: slug,
  slug: slug,
  scientificName: 'Genus $slug',
  commonName: 'Nombre $slug',
  category: category,
  sizeMaxCm: size,
  depthMaxM: depth,
  conservationStatus: status,
);

// B y C empatan en tamaño (gana B, la primera); C llega más hondo y es la más amenazada
final _official = [
  _species('a', size: 100, depth: 50, status: 'EN'),
  _species('b', category: 'coral', size: 500, depth: 20, status: 'LC'),
  _species('c', size: 500, depth: 1200, status: 'CR'),
  _species('d', category: 'mollusk'),
];

class _Repository extends FakeUiRepository {
  final List<Species>? top;

  _Repository({this.top});

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
  }) async =>
      (SpeciesPage(items: const [], page: 1, perPage: 1, total: 1505), '');

  @override
  Future<(List<Species>?, String)> getZoneTopSpecies({
    required String zone,
    required String lang,
    required int limit,
  }) async => top == null ? (null, 'El servidor falló.') : (top, '');
}

final _opened = <Species>[];

Future<void> _pump(
  WidgetTester tester, {
  required _Repository repository,
  Stream<ZoneSample>? sample,
}) async {
  tester.view.physicalSize = const Size(360, 800) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  _opened.clear();

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        speciesRepositoryProvider.overrideWithValue(repository),
        zonesProvider.overrideWith((ref) async => [_zone]),
        openSpeciesProvider.overrideWithValue(
          (context, species) => _opened.add(species),
        ),
        zoneRandomProvider.overrideWithValue(Random(1)),
        if (sample != null)
          zoneSampleProvider.overrideWith((ref, zone) => sample),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        home: const Scaffold(body: SafeArea(bottom: false, child: MapView())),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));

  await tester.tap(find.text(_zone.name).first);
  await tester.pump();
  await tester.pump(MotionConstants.long);
  await tester.pump(
    MotionConstants.mapFocus + const Duration(milliseconds: 100),
  );
  // Sube la hoja para ver el contenido
  await tester.drag(
    find.byType(DraggableScrollableSheet),
    const Offset(0, -700),
  );
  await tester.pump();
  await tester.pump(MotionConstants.long);
}

// El pez anima sin parar: se avanza el reloj a mano
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    120,
    scrollable: find
        .descendant(
          of: find.byType(DraggableScrollableSheet),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await _settle(tester);
}

Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

List<Species> _tiles(WidgetTester tester) => tester
    .widgetList<SpeciesTile>(find.byType(SpeciesTile))
    .map((t) => t.species)
    .toList();

void main() {
  group('con la lista oficial de destacadas', () {
    testWidgets(
      'rotula "Según las N especies destacadas" y muestra los tres récords',
      (tester) async {
        await _pump(tester, repository: _Repository(top: _official));
        await _reveal(tester, find.text(MapConstants.basedOnFeatured(4)));

        expect(find.text(MapConstants.basedOnFeatured(4)), findsOneWidget);
        expect(
          find.text(MapConstants.recordsTitle.toUpperCase()),
          findsOneWidget,
        );
        expect(
          find.text(MapConstants.recordLargest.toUpperCase()),
          findsOneWidget,
        );
        expect(
          find.text(MapConstants.recordDeepest.toUpperCase()),
          findsOneWidget,
        );
        expect(
          find.text(MapConstants.recordThreatened.toUpperCase()),
          findsOneWidget,
        );
        // Valores: 5 m (b, la primera del empate), 1,200 m y En peligro crítico (c)
        expect(find.text('5 m'), findsOneWidget);
        expect(find.text('1,200 m'), findsOneWidget);
        expect(find.text('En peligro crítico'), findsOneWidget);
        await _drain(tester);
      },
    );

    testWidgets('tocar una tarjeta de récord abre esa especie', (tester) async {
      await _pump(tester, repository: _Repository(top: _official));
      await _reveal(
        tester,
        find.text(MapConstants.recordLargest.toUpperCase()),
      );

      await tester.tap(find.text(MapConstants.recordLargest.toUpperCase()));
      await tester.tap(find.text('1,200 m'));
      await tester.tap(find.text('En peligro crítico'));

      expect(_opened.map((s) => s.slug), ['b', 'c', 'c']);
      await _drain(tester);
    });

    testWidgets('sin datos de un récord, esa tarjeta se oculta', (
      tester,
    ) async {
      await _pump(
        tester,
        repository: _Repository(top: [_species('a', size: 10), _species('b')]),
      );
      await _reveal(tester, find.text(MapConstants.recordsTitle.toUpperCase()));

      expect(
        find.text(MapConstants.recordLargest.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(MapConstants.recordDeepest.toUpperCase()), findsNothing);
      expect(
        find.text(MapConstants.recordThreatened.toUpperCase()),
        findsNothing,
      );
      await _drain(tester);
    });

    testWidgets('sin ningún dato no hay bloque de récords', (tester) async {
      await _pump(
        tester,
        repository: _Repository(top: [_species('a'), _species('b')]),
      );
      await _reveal(tester, find.text(MapConstants.groupsTitle.toUpperCase()));

      expect(find.text(MapConstants.recordsTitle.toUpperCase()), findsNothing);
      await _drain(tester);
    });

    testWidgets('con una sola especie todo sigue funcionando', (tester) async {
      await _pump(
        tester,
        repository: _Repository(
          top: [_species('a', size: 80, depth: 9, status: 'VU')],
        ),
      );
      await _reveal(tester, find.text(MapConstants.basedOnFeatured(1)));

      expect(find.text(MapConstants.basedOnFeatured(1)), findsOneWidget);
      expect(find.text('80 cm'), findsOneWidget);
      expect(find.text('Peces 1'), findsOneWidget);
      await _drain(tester);
    });

    testWidgets(
      'los chips muestran el conteo por grupo y filtran la fila al tocarlos',
      (tester) async {
        await _pump(tester, repository: _Repository(top: _official));
        await _reveal(tester, find.text('Peces 2'));

        expect(find.text('Peces 2'), findsOneWidget);
        expect(find.text('Corales 1'), findsOneWidget);
        expect(find.text('Moluscos 1'), findsOneWidget);

        await tester.tap(find.text('Corales 1'));
        await tester.pump(MotionConstants.short);
        expect(_tiles(tester).map((s) => s.slug), ['b']);

        // Cambiar de grupo reemplaza el filtro
        await tester.tap(find.text('Peces 2'));
        await tester.pump(MotionConstants.short);
        expect(_tiles(tester).map((s) => s.category).toSet(), {'fish'});

        // Tocar de nuevo el mismo grupo quita el filtro
        await tester.tap(find.text('Peces 2'));
        await tester.pump(MotionConstants.short);
        expect(
          _tiles(tester).map((s) => s.category).toSet().length,
          greaterThan(1),
        );
        await _drain(tester);
      },
    );

    testWidgets(
      '"Sorpréndeme en esta zona" abre una especie al azar de la muestra',
      (tester) async {
        await _pump(tester, repository: _Repository(top: _official));
        await _reveal(tester, find.text(MapConstants.surpriseLabel));

        await tester.tap(find.text(MapConstants.surpriseLabel));

        expect(_opened.single, _official[Random(1).nextInt(_official.length)]);
        await _drain(tester);
      },
    );
  });

  group('con la muestra armada desde los detalles', () {
    testWidgets(
      'los bloques aparecen según llegan las especies y el pez sigue hasta el final',
      (tester) async {
        final stream = StreamController<ZoneSample>();
        addTearDown(stream.close);
        await _pump(tester, repository: _Repository(), sample: stream.stream);

        // Sin nada todavía: el pez y "Sorpréndeme" deshabilitado
        stream.add(const ZoneSample([], done: false));
        await _settle(tester);
        await _reveal(tester, find.text(MapConstants.surpriseLabel));
        expect(find.byType(FishLoader), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.ancestor(
                  of: find.text(MapConstants.surpriseLabel),
                  matching: find.byType(FilledButton),
                ),
              )
              .onPressed,
          isNull,
        );
        expect(
          find.text(MapConstants.recordsTitle.toUpperCase()),
          findsNothing,
        );

        // Llega una: rótulo de muestra, récords, chips y botón habilitado; el pez sigue
        stream.add(ZoneSample([_official[0]], done: false));
        await _settle(tester);
        await _reveal(tester, find.text(MapConstants.basedOnSample(1)));
        expect(find.text(MapConstants.basedOnSample(1)), findsOneWidget);
        expect(
          find.text(MapConstants.recordsTitle.toUpperCase()),
          findsOneWidget,
        );
        expect(find.text('Peces 1'), findsOneWidget);
        expect(find.byType(FishLoader), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.ancestor(
                  of: find.text(MapConstants.surpriseLabel),
                  matching: find.byType(FilledButton),
                ),
              )
              .onPressed,
          isNotNull,
        );

        // Llegan todas: se actualiza el rótulo y el pez se va
        stream.add(ZoneSample(_official.take(3).toList(), done: true));
        await _settle(tester);
        await _reveal(tester, find.text(MapConstants.basedOnSample(3)));
        expect(find.text(MapConstants.basedOnSample(3)), findsOneWidget);
        expect(find.byType(FishLoader), findsNothing);
        await _drain(tester);
      },
    );
  });

  test(
    'los textos de la hoja están en constantes y cuentan bien el plural',
    () {
      expect(MapConstants.basedOnSample(1), 'Según una muestra de 1 especie');
      expect(MapConstants.basedOnSample(8), 'Según una muestra de 8 especies');
      expect(
        MapConstants.basedOnFeatured(12),
        'Según las 12 especies destacadas',
      );
    },
  );
}

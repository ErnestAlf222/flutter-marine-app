import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

// Como el Mediterráneo: lejos del centro de la vista inicial, pero centrable sin chocar con los bordes
const _zone = OceanZone(
  id: 'mediterranean',
  speciesCount: 100,
  name: 'Mar de prueba',
  description: 'Un mar casi cerrado con una descripción de varias palabras para ocupar línea.',
  lat: 35,
  lon: 18,
);

class _Repository extends FakeUiRepository {
  final bool topFails;

  _Repository({this.topFails = true});

  @override
  Future<(List<Species>?, String)> getZoneTopSpecies({
    required String zone,
    required String lang,
    required int limit,
  }) async => topFails
      ? (null, 'El servidor falló.')
      : (FakeUiRepository.species(3), '');
}

const _screen = Size(360, 800);

Future<void> _pump(WidgetTester tester, {bool topFails = true}) async {
  tester.view.physicalSize = _screen * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        speciesRepositoryProvider.overrideWithValue(
          _Repository(topFails: topFails),
        ),
        zonesProvider.overrideWith((ref) async => [_zone]),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        home: const Scaffold(body: SafeArea(bottom: false, child: MapView())),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _openZone(WidgetTester tester) async {
  await tester.tap(find.text(_zone.name).first);
  await tester.pump();
  await tester.pump(MotionConstants.long);
  // El mapa se acerca con su propia animación
  await tester.pump(
    MotionConstants.mapFocus + const Duration(milliseconds: 100),
  );
}

Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

Rect _mapRect(WidgetTester tester) => tester.getRect(find.byType(OceanMap));

// Centro en pantalla del círculo de la zona: el nodo de accesibilidad se coloca encima de él
Offset _zoneCenter(WidgetTester tester) {
  final label =
      '${_zone.name}, ${formatSpeciesCount(_zone.speciesCount)} especies';
  return tester.getCenter(
    find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == label,
    ),
  );
}

Rect _sheetRect(WidgetTester tester) =>
    tester.getRect(find.byType(DraggableScrollableSheet));

void main() {
  group('geometría', () {
    const world = Size(1000, 500);
    const viewport = Size(400, 300);

    test('centerOn con anchor deja el punto en ese lugar del marco', () {
      final view = centerOn(
        worldPoint: const Offset(500, 250),
        scale: 2,
        world: world,
        viewport: viewport,
        anchor: const Offset(200, 80),
      );
      final onScreen = view.apply(const Offset(500, 250));
      expect(onScreen.dx, closeTo(200, 0.001));
      expect(onScreen.dy, closeTo(80, 0.001));
    });

    test('sin anchor sigue centrando en el marco', () {
      final view = centerOn(
        worldPoint: const Offset(500, 250),
        scale: 2,
        world: world,
        viewport: viewport,
      );
      final onScreen = view.apply(const Offset(500, 250));
      expect(onScreen.dx, closeTo(200, 0.001));
      expect(onScreen.dy, closeTo(150, 0.001));
    });

    test(
      'con una zona seleccionada, las demás se atenúan; la seleccionada no',
      () {
        expect(zoneAlpha(lit: true, selectedId: null, zoneId: 'a'), 1);
        expect(zoneAlpha(lit: true, selectedId: 'a', zoneId: 'a'), 1);
        expect(
          zoneAlpha(lit: true, selectedId: 'a', zoneId: 'b'),
          MapConstants.unselectedAlpha,
        );
        expect(
          zoneAlpha(lit: false, selectedId: null, zoneId: 'a'),
          MapConstants.compactDimmedAlpha,
        );
      },
    );
  });

  group('hoja de zona', () {
    testWidgets('abre a ~30% de la pantalla y llega a ~85% al arrastrar', (
      tester,
    ) async {
      await _pump(tester);
      await _openZone(tester);

      final initial = _sheetRect(tester).height / _screen.height;
      debugPrint('ALTURA inicial: ${(initial * 100).toStringAsFixed(1)}%');
      expect(initial, closeTo(MapConstants.sheetInitialFraction, 0.01));

      await tester.drag(
        find.byType(DraggableScrollableSheet),
        const Offset(0, -700),
      );
      await tester.pumpAndSettle();
      final expanded = _sheetRect(tester).height / _screen.height;
      debugPrint('ALTURA arrastrada: ${(expanded * 100).toStringAsFixed(1)}%');
      expect(expanded, closeTo(MapConstants.sheetMaxFraction, 0.01));
      await _drain(tester);
    });

    testWidgets('el mapa queda a la vista por encima de la hoja inicial', (
      tester,
    ) async {
      await _pump(tester);
      await _openZone(tester);

      final map = _mapRect(tester);
      final sheet = _sheetRect(tester);
      // Toda la altura del mapa se ve: la hoja empieza debajo de él
      expect(sheet.top, greaterThanOrEqualTo(map.bottom));
      await _drain(tester);
    });

    testWidgets(
      'al abrirla, la zona queda centrada en el mapa libre y se acerca',
      (tester) async {
        await _pump(tester);
        final before = _zoneCenter(tester);

        await _openZone(tester);
        final map = _mapRect(tester);
        final center = _zoneCenter(tester);
        debugPrint(
          'ZONA antes $before, después $center, centro del mapa ${map.center}',
        );

        expect(center.dx, closeTo(map.center.dx, 2));
        expect(center.dy, closeTo(map.center.dy, 2));
        expect(center, isNot(before), reason: 'el mapa se movió');
        await _drain(tester);
      },
    );

    testWidgets('al subir la hoja, la zona se recentra por encima de ella', (
      tester,
    ) async {
      await _pump(tester);
      await _openZone(tester);

      await tester.drag(
        find.byType(DraggableScrollableSheet),
        const Offset(0, -700),
      );
      await tester.pumpAndSettle();

      final map = _mapRect(tester);
      final sheet = _sheetRect(tester);
      final free = (sheet.top - map.top).clamp(
        MapConstants.minFreeHeight,
        map.height,
      );
      final center = _zoneCenter(tester);
      debugPrint(
        'ZONA con la hoja arriba: $center; mapa libre ${free.toStringAsFixed(0)} dp',
      );

      expect(center.dx, closeTo(map.center.dx, 2));
      expect(center.dy, closeTo(map.top + free / 2, 2));
      await _drain(tester);
    });

    testWidgets('al cerrar la hoja el mapa vuelve a como estaba', (
      tester,
    ) async {
      await _pump(tester);
      final before = _zoneCenter(tester);

      await _openZone(tester);
      // Toca fuera de la hoja (el velo es transparente)
      await tester.tapAt(const Offset(180, 20));
      await tester.pump();
      await tester.pump(MotionConstants.long);
      await tester.pump(
        MotionConstants.mapFocus + const Duration(milliseconds: 100),
      );

      final after = _zoneCenter(tester);
      expect(after.dx, closeTo(before.dx, 2));
      expect(after.dy, closeTo(before.dy, 2));
      await _drain(tester);
    });

    testWidgets(
      'cuando fallan las especies destacadas es una sola línea, sin encabezado',
      (tester) async {
        await _pump(tester);
        await _openZone(tester);

        expect(find.text('ESPECIES DESTACADAS'), findsNothing);
        final note = find.text('Destacadas no disponibles.');
        expect(note, findsOneWidget);
        expect(find.text('Reintentar'), findsOneWidget);
        // Una línea: el texto no se parte en varias
        expect(tester.getSize(note).height, lessThan(24));
        await _drain(tester);
      },
    );

    testWidgets('con especies muestra el encabezado y las fichas', (
      tester,
    ) async {
      await _pump(tester, topFails: false);
      await _openZone(tester);

      expect(find.text('ESPECIES DESTACADAS'), findsOneWidget);
      expect(find.byType(SpeciesTile), findsWidgets);
      await _drain(tester);
    });

    testWidgets('con animaciones reducidas el mapa salta sin animar', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await _pump(tester);

      await tester.tap(find.text(_zone.name).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      final map = _mapRect(tester);
      final center = _zoneCenter(tester);
      expect(center.dx, closeTo(map.center.dx, 2));
      expect(center.dy, closeTo(map.center.dy, 2));
      await _drain(tester);
    });
  });
}

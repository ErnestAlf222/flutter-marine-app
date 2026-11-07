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

import 'support/fake_offline.dart';
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
  // Con true, los detalles responden: las especies pares viven en la zona de la prueba
  final bool detailsOk;
  final bool totalFails;
  // Con gated, cada detalle espera a que la prueba lo libere (para ver el avance paso a paso)
  final bool gated;
  final gates = <String, Completer<void>>{};
  int detailCalls = 0;
  int running = 0;
  int maxRunning = 0;

  void release(String slug) {
    final gate = gates[slug] ??= Completer<void>();
    if (!gate.isCompleted) gate.complete();
  }

  _Repository({
    this.topFails = true,
    this.detailsOk = false,
    this.totalFails = false,
    this.gated = false,
    super.count,
  });

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
    // El total de todo el catálogo se lee con per_page=1
    if (perPage == 1) {
      if (totalFails) return (null, 'Sin total.');
      return (SpeciesPage(items: const [], page: 1, perPage: 1, total: 1505), '');
    }
    return super.getSpecies(
      lang: lang,
      page: page,
      perPage: perPage,
      featured: featured,
    );
  }

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  }) async {
    detailCalls++;
    running++;
    if (running > maxRunning) maxRunning = running;
    if (gated) {
      await (gates[slug] ??= Completer<void>()).future;
    } else {
      await Future<void>.delayed(Duration.zero);
    }
    running--;
    if (!detailsOk) return (null, 'Sin detalle.');

    final n = int.parse(slug.split('-').last);
    return (
      SpeciesDetail(
        id: 'id-$n',
        slug: slug,
        scientificName: 'Species $n',
        commonName: 'Especie $n',
        category: 'fish',
        zones: [n.isEven ? _zone.id : 'caribbean'],
      ),
      '',
    );
  }

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

Future<void> _pump(
  WidgetTester tester, {
  bool topFails = true,
  bool detailsOk = false,
  _Repository? repository,
}) async {
  tester.view.physicalSize = _screen * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        ...offlineOverrides(),
        speciesRepositoryProvider.overrideWithValue(
          repository ?? _Repository(topFails: topFails, detailsOk: detailsOk),
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

// La hoja enriquecida deja las especies más abajo: se sube para verlas
Future<void> _expandSheet(WidgetTester tester, {bool animating = false}) async {
  await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, -700));
  if (animating) {
    // El pez anima sin parar: pumpAndSettle nunca terminaría
    await tester.pump();
    await tester.pump(MotionConstants.long);
    await tester.pump(MotionConstants.long);
  } else {
    await tester.pumpAndSettle();
  }
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

  group('muestra desde los detalles', () {
    test('para al juntar 8, con 4 detalles a la vez como máximo', () async {
      final repository = _Repository(detailsOk: true, count: 100);
      // Todas las pares coinciden: la mitad de 100
      final found = (await sampleZoneSpecies(repository, _zone.id, random: Random(1)).last).items;

      expect(found, hasLength(ApiConstants.zoneSampleSize));
      expect(repository.maxRunning, lessThanOrEqualTo(ApiConstants.zoneSampleConcurrency));
      expect(repository.detailCalls, lessThanOrEqualTo(ApiConstants.zoneSampleMaxDetails));
    });

    test('nunca pide más de 24 detalles por zona', () async {
      // Ninguna coincide: se agota el tope
      final repository = _Repository(detailsOk: true, count: 100);
      final found = (await sampleZoneSpecies(repository, 'zona-inexistente', random: Random(2)).last).items;

      expect(found, isEmpty);
      expect(repository.detailCalls, ApiConstants.zoneSampleMaxDetails);
    });

    test('si los detalles fallan se deja de insistir tras 4 fallos', () async {
      final repository = _Repository(count: 100);
      final found = (await sampleZoneSpecies(repository, _zone.id, random: Random(3)).last).items;

      expect(found, isEmpty);
      // Los trabajadores que ya tenían un detalle en vuelo terminan: como mucho 3 de más
      expect(repository.detailCalls, greaterThanOrEqualTo(ApiConstants.zoneSampleMaxFailures));
      expect(
        repository.detailCalls,
        lessThan(ApiConstants.zoneSampleMaxFailures + ApiConstants.zoneSampleConcurrency),
      );
    });

    test('progresiva: cada coincidencia se emite en cuanto llega y done solo al final', () async {
      // 6 especies; las pares (2, 4, 6) viven en la zona. 4 detalles a la vez
      final repository = _Repository(detailsOk: true, gated: true, count: 6);
      final emissions = <ZoneSample>[];
      final done = Completer<void>();
      sampleZoneSpecies(repository, _zone.id, random: Random(5)).listen(
        emissions.add,
        onDone: done.complete,
      );
      Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));
      await settle();

      // Arranca ya, sin resultados y sin terminar (la hoja muestra el pez)
      expect(emissions.last.items, isEmpty);
      expect(emissions.last.done, isFalse);

      // Una impar llega: no coincide, no cambia nada
      repository.release('especie-1');
      await settle();
      expect(emissions.last.items, isEmpty);

      // Una par llega: aparece al instante, aunque falten detalles
      repository.release('especie-2');
      await settle();
      expect(emissions.last.items.map((s) => s.slug), ['especie-2']);
      expect(emissions.last.done, isFalse);

      repository.release('especie-4');
      await settle();
      expect(emissions.last.items.map((s) => s.slug).toSet(), {'especie-2', 'especie-4'});
      expect(emissions.last.done, isFalse);

      for (final n in [3, 5, 6]) {
        repository.release('especie-$n');
      }
      await done.future;
      expect(emissions.last.items, hasLength(3));
      expect(emissions.last.done, isTrue);
      // Antes del final nunca hubo done
      expect(emissions.where((e) => e.done), hasLength(1));
    });

    test('las coordenadas se escriben en español', () {
      expect(CoordinateUtils.format(28.5, -16), '28.5° N, 16.0° O');
      expect(CoordinateUtils.format(-5, 135), '5.0° S, 135.0° E');
    });
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
      'cuando fallan las especies destacadas sale el estado amigable, sin encabezado',
      (tester) async {
        await _pump(tester);
        await _openZone(tester);
        await _expandSheet(tester);

        expect(find.text('ESPECIES DESTACADAS'), findsNothing);
        expect(find.text(MapConstants.sampleTitle.toUpperCase()), findsNothing);
        expect(find.byType(FriendlyState), findsOneWidget);
        expect(find.text(FriendlyConstants.messages[FailureKind.server]!), findsOneWidget);
        expect(find.text('Reintentar'), findsOneWidget);
        await _drain(tester);
      },
    );

    testWidgets('con especies muestra el encabezado y las fichas', (
      tester,
    ) async {
      final repository = _Repository(topFails: false, detailsOk: true);
      await _pump(tester, repository: repository);
      await _openZone(tester);
      await _expandSheet(tester);

      expect(find.text('ESPECIES DESTACADAS'), findsOneWidget);
      // Si top-species responde no se arma la muestra: ni una petición de detalle
      expect(repository.detailCalls, 0);
      expect(find.text(MapConstants.sampleTitle.toUpperCase()), findsNothing);
      expect(find.byType(SpeciesTile), findsWidgets);
      await _drain(tester);
    });

    testWidgets('la hoja trae descripción completa, proporción del catálogo y coordenadas', (
      tester,
    ) async {
      await _pump(tester);
      await _openZone(tester);
      await _expandSheet(tester);

      expect(find.text(_zone.description), findsOneWidget);
      // El total sale de /species (1505 en la prueba), no de un número escrito a mano
      expect(find.text('100 de 1,505 especies'), findsOneWidget);
      expect(
        find.text('${MapConstants.centerLabel}: 35.0° N, 18.0° E'),
        findsOneWidget,
      );
      await _drain(tester);
    });

    testWidgets('si falla el total del catálogo, la hoja sigue completa sin la barra', (
      tester,
    ) async {
      await _pump(tester, repository: _Repository(totalFails: true));
      await _openZone(tester);
      await _expandSheet(tester);

      expect(find.textContaining('100 de '), findsNothing);
      expect(find.text(_zone.description), findsOneWidget);
      expect(find.textContaining(MapConstants.centerLabel), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('con top-species caído, la muestra sale de los detalles', (tester) async {
      final repository = _Repository(detailsOk: true);
      await _pump(tester, repository: repository);
      await _openZone(tester);
      await _expandSheet(tester);

      expect(find.text(MapConstants.sampleTitle.toUpperCase()), findsOneWidget);
      expect(find.text('ESPECIES DESTACADAS'), findsNothing);
      // Solo las pares (3 de 6) viven en la zona; se piden los 6 detalles
      expect(find.byType(SpeciesTile), findsWidgets);
      expect(repository.detailCalls, 6);
      await _drain(tester);
    });

    testWidgets('la muestra aparece poco a poco y el pez sigue hasta el final', (tester) async {
      final repository = _Repository(detailsOk: true, gated: true, count: 6);
      await _pump(tester, repository: repository);
      await _openZone(tester);
      await _expandSheet(tester, animating: true);

      // Sin nada todavía: el pez y ninguna ficha
      expect(find.text(MapConstants.sampleTitle.toUpperCase()), findsOneWidget);
      expect(find.byType(FishLoader), findsOneWidget);
      expect(find.byType(SpeciesTile), findsNothing);

      // Llega una coincidencia: su ficha aparece y el pez sigue. Solo 4 detalles van a la vez,
      // así que se libera una par de las que ya arrancaron (entre 4 de 6 siempre hay una)
      final first = repository.gates.keys.firstWhere(
        (slug) => int.parse(slug.split('-').last).isEven,
      );
      repository.release(first);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SpeciesTile), findsOneWidget);
      expect(find.byType(FishLoader), findsOneWidget);

      // Terminan todos los detalles: el pez se va
      // Los que faltan arrancan según se liberan: se sueltan en rondas
      for (int round = 0; round < 3; round++) {
        for (int n = 1; n <= 6; n++) {
          if (n.toString() != first.split('-').last) repository.release('especie-$n');
        }
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(FishLoader), findsNothing);
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

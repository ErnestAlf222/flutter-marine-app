import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/shared/photo_scrim.dart';

import 'support/fake_ui_repository.dart';

// Repositorio con un detalle completo: taxonomía con "incertae sedis" y crédito de foto
class _DetailRepo extends FakeUiRepository {
  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  }) async => (
    const SpeciesDetail(
      id: 'id-1',
      slug: 'especie-1',
      scientificName: 'Species 1',
      commonName: 'Especie 1',
      category: 'fish',
      photos: [
        SpeciesPhoto(
          url: 'x',
          credit: '© Autor / iNaturalist (CC0)',
          isPrimary: true,
        ),
      ],
      taxonomy: SpeciesTaxonomy(
        kingdom: 'Animalia',
        phylum: 'Chordata',
        taxonomicClass: 'Teleostei',
        order: 'Incertae sedis',
        family: 'Gobiidae',
        genus: 'Gobius',
      ),
    ),
    '',
  );
}

Widget _host(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      retry: (_, _) => null,
      overrides: overrides,
      child: MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        home: Scaffold(body: child),
      ),
    );

double _luminanceContrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

// Color de lo que se ve cuando el degradado cae sobre una foto blanca
Color _overWhite(double alpha) =>
    Color.alphaBlend(OceanPalette.dark.ink.withValues(alpha: alpha), Colors.white);

// El pez de las fotos que cargan anima sin parar: se avanza el reloj a mano
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('degradado del Detalle', () {
    test('la zona del animal queda sin oscurecer', () {
      final alpha = scrimAlphaAt(
        DesignConstants.detailScrimCoverage,
        solid: DesignConstants.detailScrimSolid,
        coverage: DesignConstants.detailScrimCoverage,
      );
      expect(alpha, 0);
      expect(DesignConstants.detailScrimCoverage, lessThan(DesignConstants.heroScrimCoverage));
    });

    test('el texto llega a 4.5:1 sobre una foto blanca, también el acento', () {
      // El bloque de nombres llega hasta ~30 % del alto de la cabecera
      final alpha = scrimAlphaAt(
        0.3,
        solid: DesignConstants.detailScrimSolid,
        coverage: DesignConstants.detailScrimCoverage,
      );
      final background = _overWhite(alpha);
      const palette = OceanPalette.dark;
      expect(_luminanceContrast(palette.paper, background), greaterThanOrEqualTo(4.5));
      expect(
        _luminanceContrast(
          ColorScheme.fromSeed(
            seedColor: AppTheme.seedColor,
            brightness: Brightness.dark,
          ).primary,
          background,
        ),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('el fondo borroso de "foto entera" oscurece menos que el del héroe', () {
      expect(DesignConstants.detailBackdropDim, lessThan(DesignConstants.backdropDim));
    });
  });

  group('Detalle completo', () {
    Future<void> pumpDetail(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          const SpeciesDetailView(slug: 'especie-1'),
          overrides: [speciesRepositoryProvider.overrideWithValue(_DetailRepo())],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets('clasificación: de entrada solo Familia y Género, sin migas', (tester) async {
      await pumpDetail(tester);

      expect(find.text('CLASIFICACIÓN'), findsOneWidget);
      expect(find.text(DetailConstants.taxonomyIntro), findsOneWidget);
      expect(find.text('Gobiidae'), findsOneWidget);
      expect(find.text('Gobius'), findsOneWidget);
      expect(find.text('Animalia'), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('el control despliega los seis rangos y aclara "incertae sedis"', (tester) async {
      await pumpDetail(tester);

      await tester.ensureVisible(find.text(DetailConstants.taxonomyExpand));
      await tester.tap(find.text(DetailConstants.taxonomyExpand));
      await _settle(tester);

      for (final label in [
        DetailConstants.kingdom,
        DetailConstants.phylum,
        DetailConstants.taxonomicClass,
        DetailConstants.order,
        DetailConstants.family,
        DetailConstants.genus,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Animalia'), findsOneWidget);
      expect(find.text('Incertae sedis ${DetailConstants.uncertainPosition}'), findsOneWidget);
      expect(find.text('Gobius ${DetailConstants.uncertainPosition}'), findsNothing);
    });

    testWidgets('la hoja de créditos de la foto incluye la atribución de los datos', (tester) async {
      await pumpDetail(tester);

      // El botón está al final de la página: se desplaza hasta que quede a la vista
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
      await _settle(tester);
      await tester.tap(find.text(DetailConstants.creditsButton));
      await _settle(tester);

      expect(find.text('© Autor / iNaturalist (CC0)'), findsOneWidget);
      expect(find.text(DetailConstants.dataCredit), findsOneWidget);
    });
  });

  group('encabezado a 360 dp', () {
    testWidgets('el nombre conserva al menos 200 dp de ancho', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      const name = 'Tiburón ballena gigante del Pacífico oriental tropical';
      await tester.pumpWidget(
        _host(
          const SpeciesDetailView(
            slug: 'x',
            preview: Species(
              id: 'a',
              slug: 'x',
              scientificName: 'Rhincodon typus',
              commonName: name,
              category: 'fish',
            ),
          ),
          overrides: [speciesRepositoryProvider.overrideWithValue(FakeUiRepository())],
        ),
      );
      await tester.pump();

      final block = find.ancestor(of: find.text(name), matching: find.byType(Column)).first;
      final width = tester.getSize(block).width;
      // ignore: avoid_print
      print('ANCHO DEL NOMBRE a 360 dp: $width dp');
      expect(width, greaterThanOrEqualTo(200));

      // Suelta los temporizadores del cargador antes de terminar
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    });
  });
}

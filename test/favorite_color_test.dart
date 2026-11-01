import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

// Distancia en RGB (0 a 255 por canal): una medida simple de "se ve distinto"
double _distance(Color a, Color b) {
  double d(double x, double y) => (x - y) * 255;
  return (d(a.r, b.r) * d(a.r, b.r) +
          d(a.g, b.g) * d(a.g, b.g) +
          d(a.b, b.b) * d(a.b, b.b))
      .abs();
}

double _distanceRoot(Color a, Color b) =>
    _distance(a, b) == 0 ? 0 : sqrt(_distance(a, b));

class _Favorites extends FavoritesRepository {
  final List<Species> items;

  _Favorites(this.items);

  @override
  Stream<List<Species>> watchFavorites() => Stream.value(items);

  @override
  Future<(bool?, String)> saveFavorite(Species species) async => (true, '');

  @override
  Future<(bool?, String)> removeFavorite(String slug) async => (true, '');

  @override
  Future<(bool?, String)> isFavorite(String slug) async => (true, '');
}

void main() {
  const palette = OceanPalette.dark;
  group('color de favorito', () {
    test('es un rojo franco y se distingue del coral de peligro', () {
      final hsl = HSLColor.fromColor(palette.favorite);
      // Rojo: matiz en torno a 0° y muy saturado (no un rosa ni un naranja)
      expect(hsl.hue < 8 || hsl.hue > 352, isTrue, reason: 'matiz ${hsl.hue}');
      expect(hsl.saturation, greaterThan(0.9));
      // Aparte del coral de peligro (un salmón más claro y menos saturado)
      expect(_distance(palette.favorite, palette.coral), greaterThan(50 * 50));
      expect(palette.favorite, isNot(palette.coral));
      debugPrint(
        'FAVORITO vs coral: distancia RGB ${_distanceRoot(palette.favorite, palette.coral).toStringAsFixed(0)}/441',
      );
    });

    test('contraste del corazón sobre el cristal con el peor caso: una foto blanca detrás', () {
      // Cristal del botón: tinte oscuro al glassSolidAlpha sobre blanco
      final glassOnWhite = Color.alphaBlend(
        palette.ink.withValues(alpha: DesignConstants.glassSolidAlpha),
        palette.paper,
      );
      final onWhite = _contrast(palette.favorite, glassOnWhite);
      final onBlack = _contrast(
        palette.favorite,
        Color.alphaBlend(
          palette.ink.withValues(alpha: DesignConstants.glassSolidAlpha),
          const Color(0xFF000000),
        ),
      );
      debugPrint(
        'FAVORITO sobre foto blanca: ${onWhite.toStringAsFixed(2)}:1, sobre foto negra: ${onBlack.toStringAsFixed(2)}:1',
      );

      // Un icono necesita 3:1 (WCAG 1.4.11)
      expect(onWhite, greaterThanOrEqualTo(3));
      expect(onBlack, greaterThanOrEqualTo(3));
    });

    test(
      'con el tinte anterior (32%) no llegaba a 3:1 sobre una foto blanca',
      () {
        final old = Color.alphaBlend(
          palette.ink.withValues(alpha: DesignConstants.glassAlpha),
          palette.paper,
        );
        expect(_contrast(palette.favorite, old), lessThan(3));
        expect(_contrast(palette.coral, old), lessThan(3));
      },
    );

    test('contraste contra los fondos de la app (fondo de profundidad)', () {
      for (final background in [
        palette.surface,
        palette.reef,
        palette.deep,
        palette.abyss,
      ]) {
        debugPrint(
          'FAVORITO sobre ${background.toARGB32().toRadixString(16)}: ${_contrast(palette.favorite, background).toStringAsFixed(2)}:1',
        );
      }
      expect(
        _contrast(palette.favorite, palette.abyss),
        greaterThanOrEqualTo(3),
      );
    });
  });

  group('dónde se usa', () {
    final species = FakeUiRepository.species(1).first;

    Widget host(List<Species> favorites) => ProviderScope(
      retry: (_, _) => null,
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(_Favorites(favorites)),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        home: Scaffold(
          body: Center(child: FavoriteButton(species: species, large: true)),
        ),
      ),
    );

    testWidgets('el corazón marcado es del color de favorito, no coral', (
      tester,
    ) async {
      await tester.pumpWidget(host([species]));
      await tester.pump();

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, palette.favorite);
      expect(icon.color, isNot(palette.coral));
    });

    testWidgets('sin marcar sigue siendo blanco', (tester) async {
      await tester.pumpWidget(host([]));
      await tester.pump();

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border));
      expect(icon.color, palette.paper);
    });

    testWidgets(
      'las burbujas que suben del corazón son del color de favorito',
      (tester) async {
        final controller = StreamController<List<Species>>();
        addTearDown(controller.close);
        await tester.pumpWidget(
          ProviderScope(
            retry: (_, _) => null,
            overrides: [
              favoritesProvider.overrideWith((ref) => controller.stream),
            ],
            child: MaterialApp(
              theme: ThemeData(extensions: const [OceanPalette.dark]),
              home: Scaffold(
                body: Center(
                  child: FavoriteButton(species: species, large: true),
                ),
              ),
            ),
          ),
        );
        controller.add([]);
        await tester.pump();
        controller.add([species]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final burst = tester.widget<BubbleBurst>(find.byType(BubbleBurst));
        expect(burst.color, palette.favorite);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 2));
      },
    );

    testWidgets('el botón de vidrio marcado también usa el rojo de favorito', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [OceanPalette.dark]),
          home: Scaffold(
            body: GlassButton(
              icon: Icons.favorite_border,
              selectedIcon: Icons.favorite,
              selected: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump(MotionConstants.short);

      expect(
        tester.widget<Icon>(find.byIcon(Icons.favorite)).color,
        palette.favorite,
      );
    });
  });
}

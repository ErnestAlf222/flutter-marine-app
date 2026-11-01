import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

// Contraste WCAG entre dos colores opacos
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

// Pinta [top] (con su alfa) sobre [base] opaco
Color _over(Color base, Color top) => Color.alphaBlend(top, base);

void main() {
  const palette = OceanPalette.dark;
  final accent = ColorScheme.fromSeed(
    seedColor: AppTheme.seedColor,
    brightness: Brightness.dark,
  ).primary;

  // Peor caso: una foto blanca detrás. El desenfoque no cambia el blanco, así que el fondo
  // del cristal es blanco; encima van el tinte oscuro y la luz suave en su punto más claro
  // (esquina superior izquierda).
  final whitePhoto = palette.paper;
  Color glass({double tint = DesignConstants.glassSolidAlpha}) => _over(
    _over(whitePhoto, palette.ink.withValues(alpha: tint)),
    palette.paper.withValues(alpha: DesignConstants.glassLightAlpha),
  );

  group('contraste del texto sobre cristal con una foto blanca detrás', () {
    const minimum = 4.5;

    test('texto principal (hoja, chips y burbuja)', () {
      final ratio = _contrast(palette.paper, glass());
      expect(ratio, greaterThanOrEqualTo(minimum), reason: 'medido: $ratio');
    });

    test('texto atenuado ("Cualquiera")', () {
      final background = glass();
      final text = _over(
        background,
        palette.paper.withValues(alpha: DesignConstants.glassMutedTextAlpha),
      );
      final ratio = _contrast(text, background);
      expect(ratio, greaterThanOrEqualTo(minimum), reason: 'medido: $ratio');
    });

    test('valor elegido en el color de acento', () {
      final ratio = _contrast(accent, glass());
      expect(ratio, greaterThanOrEqualTo(minimum), reason: 'medido: $ratio');
    });

    test(
      'el tinte anterior (32%) no llegaba: la prueba sí detecta el problema',
      () {
        expect(
          _contrast(palette.paper, glass(tint: DesignConstants.glassAlpha)),
          lessThan(minimum),
        );
      },
    );
  });

  group('hoja de filtros', () {
    Future<void> openSheet(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            speciesRepositoryProvider.overrideWithValue(FakeUiRepository()),
          ],
          child: MaterialApp(
            theme: ThemeData(extensions: const [OceanPalette.dark]),
            home: const ExploreScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pump();
      await tester.pump(MotionConstants.long);
    }

    Future<void> drain(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    }

    Finder sheetGlass() => find
        .ancestor(of: find.text('Aplicar'), matching: find.byType(GlassSurface))
        .last;

    testWidgets('se ajusta al contenido: no ocupa la pantalla completa', (
      tester,
    ) async {
      await openSheet(tester);

      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      final sheet = tester.getSize(sheetGlass());
      expect(
        sheet.height,
        lessThan(screen.height * 0.7),
        reason: 'alto: ${sheet.height}',
      );
      expect(sheet.height, greaterThan(300));
      await drain(tester);
    });

    testWidgets(
      '"Aplicar" va dentro de la hoja, abajo, como botón ancho de 52 dp',
      (tester) async {
        await openSheet(tester);

        final sheet = tester.getRect(sheetGlass());
        final apply = tester.getRect(
          find.widgetWithText(FilledButton, 'Aplicar'),
        );
        expect(
          sheet.contains(apply.topLeft) && sheet.contains(apply.bottomRight),
          isTrue,
        );
        expect(apply.height, DesignConstants.filterButtonHeight);
        expect(apply.width, greaterThan(sheet.width * 0.5));
        // Pegado al pie de la hoja, no flotando lejos de las filas
        expect(
          sheet.bottom - apply.bottom,
          lessThan(DesignConstants.pagePadding + 8),
        );
        await drain(tester);
      },
    );

    testWidgets('"Limpiar" solo aparece con algo elegido, también de 52 dp', (
      tester,
    ) async {
      await openSheet(tester);
      expect(find.text('Limpiar'), findsNothing);

      await tester.tap(find.text('Grupo'));
      await tester.pump(MotionConstants.medium);
      await tester.ensureVisible(find.text('Corales'));
      await tester.pump(MotionConstants.short);
      await tester.tap(find.text('Corales'));
      await tester.pump(MotionConstants.medium);

      expect(find.text('Limpiar'), findsOneWidget);
      final clear = tester.getRect(
        find.widgetWithText(OutlinedButton, 'Limpiar'),
      );
      expect(clear.height, DesignConstants.filterButtonHeight);
      final sheet = tester.getRect(sheetGlass());
      expect(
        sheet.contains(clear.topLeft) && sheet.contains(clear.bottomRight),
        isTrue,
      );
      await drain(tester);
    });

    testWidgets(
      'filas de 56 dp, etiquetas de 16, valores de 15 y flecha visible',
      (tester) async {
        await openSheet(tester);

        for (final title in [
          'Grupo',
          'Estado de conservación',
          'Peligrosidad',
          'Profundidad',
          'Tamaño',
        ]) {
          final row = find
              .ancestor(of: find.text(title), matching: find.byType(InkWell))
              .first;
          expect(
            tester.getSize(row).height,
            greaterThanOrEqualTo(DesignConstants.filterRowHeight),
            reason: title,
          );
          expect(
            tester.widget<Text>(find.text(title)).style?.fontSize,
            DesignConstants.filterLabelSize,
          );
        }
        expect(
          tester.widget<Text>(find.text('Cualquiera').first).style?.fontSize,
          DesignConstants.filterValueSize,
        );
        final arrow = tester.widget<Icon>(find.byIcon(Icons.expand_more).first);
        expect(arrow.size, DesignConstants.filterArrowSize);
        expect(arrow.color, OceanPalette.dark.paper);
        await drain(tester);
      },
    );

    testWidgets('el cristal de la hoja usa el tinte casi sólido', (
      tester,
    ) async {
      await openSheet(tester);

      final glassWidget = tester.widget<GlassSurface>(sheetGlass());
      expect(glassWidget.tintAlpha, DesignConstants.glassSolidAlpha);
      expect(glassWidget.tintAlpha, closeTo(0.85, 0.001));
      await drain(tester);
    });
  });
}

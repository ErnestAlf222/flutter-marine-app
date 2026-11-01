import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';

import 'support/fake_ui_repository.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [speciesRepositoryProvider.overrideWithValue(FakeUiRepository())],
      child: MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        home: const Scaffold(body: ExploreView()),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(ExploreView)));
}

Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

// La X de cada chip (la del buscador no cuenta: no lleva etiqueta "Quitar ...")
Finder _chipX() => find.byWidgetPredicate(
  (w) => w is Icon && w.icon == Icons.close && (w.semanticLabel ?? '').startsWith('Quitar'),
);

void main() {
  testWidgets('el texto de búsqueda no genera chip: vive solo en la barra', (tester) async {
    final container = await _pump(tester);

    container.read(speciesFiltersProvider.notifier).setQuery('tiburon toro');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('«tiburon toro»'), findsNothing);
    expect(_chipX(), findsNothing);
    await _drain(tester);
  });

  testWidgets('sin filtros la fila no ocupa espacio', (tester) async {
    await _pump(tester);

    expect(_chipX(), findsNothing);
    expect(find.text('Quitar todos'), findsNothing);
    await _drain(tester);
  });

  testWidgets('con 2 filtros se ven ambos con su x, y la x quita el filtro', (tester) async {
    final container = await _pump(tester);
    container.read(speciesFiltersProvider.notifier)
      ..setCategory('fish')
      ..setDangerLevel('dangerous');
    await tester.pump(const Duration(milliseconds: 100));

    expect(_chipX(), findsNWidgets(2));
    expect(find.textContaining('+'), findsNothing);
    // Cada chip lleva su punto de color
    expect(tester.getSize(_chipX().first).height, DesignConstants.filterChipIcon);

    await tester.tap(_chipX().first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(container.read(speciesFiltersProvider).category, isNull);
    expect(_chipX(), findsOneWidget);
    await _drain(tester);
  });

  testWidgets('con más de 2 filtros: 2 chips y un "+N" que abre la hoja de filtros', (tester) async {
    final container = await _pump(tester);
    container.read(speciesFiltersProvider.notifier)
      ..setCategory('fish')
      ..setDangerLevel('dangerous')
      ..setConservationStatus('EN')
      ..setDepthRange(100, null);
    await tester.pump(const Duration(milliseconds: 100));

    expect(_chipX(), findsNWidgets(DesignConstants.filterChipsShown));
    expect(find.text('+2'), findsOneWidget);

    await tester.tap(find.text('+2'));
    await tester.pumpAndSettle();
    // La hoja de filtros ofrece "Limpiar" cuando hay algo elegido
    expect(find.text('Limpiar'), findsOneWidget);
    await _drain(tester);
  });

  test('el texto de los chips llega a 4.5:1 incluso con una foto blanca detrás', () {
    final palette = OceanPalette.dark;
    final background = Color.alphaBlend(
      palette.ink.withValues(alpha: DesignConstants.glassSolidAlpha),
      Colors.white,
    );
    double lum(Color c) => c.computeLuminance();
    final ratio = (lum(palette.paper) + 0.05) / (lum(background) + 0.05);

    expect(ratio, greaterThanOrEqualTo(4.5));
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final scheme = ColorScheme.fromSeed(seedColor: AppTheme.seedColor, brightness: Brightness.dark);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [speciesRepositoryProvider.overrideWithValue(FakeUiRepository())],
      child: MaterialApp(
        theme: ThemeData(colorScheme: scheme, extensions: const [OceanPalette.dark]),
        home: const ExploreScreen(),
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

void main() {
  testWidgets('es un FAB estándar, sólido, abajo a la derecha y sin cristal', (tester) async {
    await _pump(tester);

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    final scheme = Theme.of(tester.element(find.byType(FloatingActionButton))).colorScheme;
    expect(fab.backgroundColor, scheme.primary);
    expect(fab.backgroundColor!.a, 1);
    expect(find.descendant(of: find.byType(FloatingActionButton), matching: find.byType(GlassSurface)), findsNothing);
    expect(find.descendant(of: find.byType(FloatingActionButton), matching: find.byType(BackdropFilter)), findsNothing);

    final rect = tester.getRect(find.byType(FloatingActionButton));
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(rect.right, greaterThan(screen.width - 24));
    expect(rect.bottom, greaterThan(screen.height - 24));
    await _drain(tester);
  });

  testWidgets('no se arrastra ni se minimiza', (tester) async {
    await _pump(tester);
    final before = tester.getCenter(find.byType(FloatingActionButton));

    await tester.drag(find.byType(FloatingActionButton), const Offset(-200, -200));
    await tester.pump(MotionConstants.long * 2);

    expect(tester.getCenter(find.byType(FloatingActionButton)), before);
    await _drain(tester);
  });

  testWidgets('con filtros se extiende a "Filtros · N", también sólido', (tester) async {
    final container = await _pump(tester);
    container.read(speciesFiltersProvider.notifier)
      ..setCategory('fish')
      ..setDangerLevel('dangerous');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Filtros · 2'), findsOneWidget);
    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.isExtended, isTrue);
    expect(fab.backgroundColor!.a, 1);
    await _drain(tester);
  });

  testWidgets('abre la hoja de filtros', (tester) async {
    await _pump(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(MotionConstants.long);

    expect(find.text('Aplicar'), findsOneWidget);
    await _drain(tester);
  });

  test('contraste: primary contra el fondo oscuro y su texto', () {
    final scheme = ColorScheme.fromSeed(seedColor: AppTheme.seedColor, brightness: Brightness.dark);
    double ratio(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
    }

    expect(ratio(scheme.primary, scheme.onPrimary), greaterThanOrEqualTo(4.5));
    expect(ratio(scheme.primary, OceanPalette.dark.abyss), greaterThanOrEqualTo(3));
  });
}

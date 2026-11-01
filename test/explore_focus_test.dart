import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/main.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';
import 'support/fake_ui_repository.dart';

// ¿El foco está en un campo de texto? (lo que abre el teclado)
bool _textFieldHasFocus() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context != null &&
      (context.widget is EditableText ||
          context.findAncestorWidgetOfExactType<EditableText>() != null);
}

Future<void> _pumpApp(WidgetTester tester, {int searchCount = 6}) async {
  tester.view.physicalSize = const Size(1080, 2200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  // El router es global: cada prueba empieza en Inicio
  appRouter.go(RouteConstants.home);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        speciesRepositoryProvider.overrideWithValue(
          FakeUiRepository(searchCount: searchCount),
        ),
      ],
      child: const MainApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

// Deja pasar el cambio de pestaña y la espera del foco
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(MotionConstants.medium);
  await tester.pump(MotionConstants.medium);
  await tester.pump(const Duration(milliseconds: 100));
}

// Las entradas escalonadas (flutter_animate) y la burbuja usan temporizadores: se dejan
// vencer antes de terminar para que la prueba no los deje pendientes
// Se desmonta la app y se deja correr el reloj: los temporizadores de las entradas
// escalonadas no se cancelan al desmontar, así que se les da tiempo de vencer
Future<void> _flush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('tocar el campo de Inicio abre Explorar con el campo enfocado', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byType(SpeciesSearchField).first);
    await _settle(tester);

    expect(find.byType(ExploreView), findsOneWidget);
    expect(_textFieldHasFocus(), isTrue);
    await _flush(tester);
  });

  testWidgets(
    'regresión: al volver del Detalle el buscador no recupera el foco ni el teclado',
    (tester) async {
      await _pumpApp(tester);

      // Inicio -> Explorar con el campo enfocado (teclado abierto)
      await tester.tap(find.byType(SpeciesSearchField).first);
      await _settle(tester);
      expect(_textFieldHasFocus(), isTrue);

      // Abre una especie con el campo aún enfocado
      await tester.tap(
        find.descendant(of: find.byType(ExploreView), matching: find.byType(SpeciesTile)).first,
      );
      await tester.pump();
      await tester.pump(MotionConstants.long);
      expect(find.byType(SpeciesDetailView), findsOneWidget);
      expect(_textFieldHasFocus(), isFalse);

      // Vuelve: antes, Flutter devolvía el foco al campo y se abría el teclado
      await tester.tap(find.byTooltip('Volver'));
      await tester.pump();
      await tester.pump(MotionConstants.long);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SpeciesDetailView), findsNothing);
      expect(_textFieldHasFocus(), isFalse);
      await _flush(tester);
    },
  );

  testWidgets(
    'regresión: con el foco olvidado en Explorar, cambiar de pestaña lo suelta',
    (tester) async {
      await _pumpApp(tester);

      await tester.tap(find.byType(SpeciesSearchField).first);
      await _settle(tester);
      expect(_textFieldHasFocus(), isTrue);

      // Se va a Inicio sin cerrar el teclado a mano
      await tester.tap(find.text('Inicio'));
      await _settle(tester);

      expect(_textFieldHasFocus(), isFalse);
      await _flush(tester);
    },
  );

  testWidgets('con búsqueda de 50 resultados Explorar avisa del tope', (tester) async {
    await _pumpApp(tester, searchCount: 50);

    await tester.tap(find.text('Explorar'));
    await _settle(tester);

    final container = ProviderScope.containerOf(tester.element(find.byType(ExploreView)));
    container.read(speciesFiltersProvider.notifier).setQuery('pe');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Va hasta el final de la lista para ver el aviso
    final results = find
        .descendant(of: find.byType(ExploreView), matching: find.byType(CustomScrollView))
        .last;
    await tester.dragUntilVisible(
      find.textContaining('hasta ${ApiConstants.searchResultCap} resultados'),
      results,
      const Offset(0, -600),
      maxIteration: 80,
    );
    expect(find.textContaining('hasta 50 resultados'), findsOneWidget);
    await _flush(tester);
  });

  testWidgets('los filtros no se desactivan al escribir: el botón sigue activo', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Explorar'));
    await _settle(tester);

    final container = ProviderScope.containerOf(tester.element(find.byType(ExploreView)));
    container.read(speciesFiltersProvider.notifier)
      ..setQuery('pe')
      ..setCategory('coral');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // El filtro activo se ve como chip y el botón extendido muestra su número
    expect(find.text('Corales'), findsOneWidget);
    expect(find.text('Filtros · 1'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.tune));
    // La hoja entra deslizándose: se espera a que llegue a su sitio
    await tester.pump();
    await tester.pump(MotionConstants.long);
    expect(find.text('Aplicar'), findsOneWidget);
    await tester.tap(find.text('Aplicar'));
    await tester.pump();
    await tester.pump(MotionConstants.long);
    await _flush(tester);
  });
}

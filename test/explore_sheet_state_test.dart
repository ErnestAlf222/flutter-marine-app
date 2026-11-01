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

late FakeUiRepository _repository;

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  _repository = FakeUiRepository(count: 20);
  appRouter.go(RouteConstants.home);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [speciesRepositoryProvider.overrideWithValue(_repository)],
      child: const MainApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(find.text('Explorar'));
  await tester.pump(MotionConstants.medium);
  await tester.pump(MotionConstants.medium);
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _flush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

ScrollableState _scrollable(WidgetTester tester) =>
    tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(ExploreView),
            matching: find.byType(Scrollable),
          )
          .last,
    );

double _offset(WidgetTester tester) => _scrollable(tester).position.pixels;

Future<void> _scrollDown(WidgetTester tester) async {
  await tester.drag(find.byType(SpeciesTile).first, const Offset(0, -700));
  await tester.pump(MotionConstants.long);
  await tester.pump(MotionConstants.long);
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.tune));
  await tester.pump();
  await tester.pump(MotionConstants.long);
}

Future<void> _closeSheetByScrim(WidgetTester tester) async {
  await tester.tapAt(const Offset(180, 60));
  await tester.pump();
  await tester.pump(MotionConstants.long);
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _focusSearch(WidgetTester tester) async {
  await tester.tap(find.byType(SpeciesSearchField).first);
  await tester.pump(MotionConstants.medium);
  expect(
    _textFieldHasFocus(),
    isTrue,
    reason: 'el campo debe tener el foco al tocarlo',
  );
}

void main() {
  group('igualdad de los filtros', () {
    test('dos filtros con los mismos valores son iguales', () {
      expect(
        const SpeciesFilters(category: 'fish', depthMin: 10),
        const SpeciesFilters(category: 'fish', depthMin: 10),
      );
      expect(
        const SpeciesFilters(category: 'fish').hashCode,
        const SpeciesFilters(category: 'fish').hashCode,
      );
      expect(
        const SpeciesFilters(category: 'fish'),
        isNot(const SpeciesFilters(category: 'coral')),
      );
    });

    test(
      'aplicar filtros idénticos a los actuales no recarga la lista',
      () async {
        final repository = FakeUiRepository(count: 6);
        final container = ProviderContainer(
          retry: (_, _) => null,
          overrides: [speciesRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        container.read(speciesFiltersProvider.notifier).setCategory('fish');
        await container.read(speciesListProvider.future);
        expect(repository.speciesCalls, 1);

        final current = container.read(speciesFiltersProvider);
        container
            .read(speciesFiltersProvider.notifier)
            .apply(current.copyWith(category: () => 'fish'));
        await container.read(speciesListProvider.future);
        expect(
          repository.speciesCalls,
          1,
          reason: 'una copia igual no es un cambio',
        );

        container
            .read(speciesFiltersProvider.notifier)
            .apply(current.copyWith(category: () => 'coral'));
        await container.read(speciesListProvider.future);
        expect(
          repository.speciesCalls,
          2,
          reason: 'un filtro distinto sí recarga',
        );
      },
    );
  });

  group('hoja de filtros no toca el estado', () {
    testWidgets(
      'cerrar sin aplicar no recarga la lista ni pierde la posición',
      (tester) async {
        await _pumpApp(tester);
        await _scrollDown(tester);
        final calls = _repository.speciesCalls;
        final offset = _offset(tester);
        expect(offset, greaterThan(300), reason: 'la lista debió desplazarse');

        await _openSheet(tester);
        expect(find.text('Aplicar'), findsOneWidget);
        await _closeSheetByScrim(tester);

        expect(find.text('Aplicar'), findsNothing);
        expect(
          _repository.speciesCalls,
          calls,
          reason: 'no debe pedir la lista otra vez',
        );
        expect(
          _offset(tester),
          offset,
          reason: 'la posición del scroll se conserva',
        );
        await _flush(tester);
      },
    );

    testWidgets('"Aplicar" con los mismos filtros no hace nada', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _scrollDown(tester);
      final calls = _repository.speciesCalls;
      final offset = _offset(tester);

      await _openSheet(tester);
      await tester.tap(find.text('Aplicar'));
      await tester.pump();
      await tester.pump(MotionConstants.long);

      expect(_repository.speciesCalls, calls);
      expect(_offset(tester), offset);
      await _flush(tester);
    });

    testWidgets('"Aplicar" con un cambio sí recarga desde el inicio', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _scrollDown(tester);
      final calls = _repository.speciesCalls;

      await _openSheet(tester);
      await tester.tap(find.text('Grupo'));
      await tester.pump(MotionConstants.medium);
      await tester.ensureVisible(find.text('Corales'));
      await tester.pump(MotionConstants.short);
      await tester.tap(find.text('Corales'));
      await tester.pump(MotionConstants.medium);
      await tester.tap(find.text('Aplicar'));
      await tester.pump();
      await tester.pump(MotionConstants.long);
      await tester.pump(MotionConstants.long);

      // (con red real la lista pasa por el esqueleto y vuelve al inicio; el repositorio falso
      // responde al instante y no llega a pintarlo)
      expect(_repository.speciesCalls, calls + 1);
      await _flush(tester);
    });

    testWidgets(
      'al cambiar de pestaña y volver, la lista conserva su posición',
      (tester) async {
        await _pumpApp(tester);
        await _scrollDown(tester);
        final calls = _repository.speciesCalls;
        final offset = _offset(tester);

        await tester.tap(find.text('Favoritos'));
        await tester.pump(MotionConstants.medium);
        await tester.pump(MotionConstants.medium);
        await tester.tap(find.text('Explorar'));
        await tester.pump(MotionConstants.medium);
        await tester.pump(MotionConstants.medium);

        expect(_repository.speciesCalls, calls);
        expect(_offset(tester), offset);
        await _flush(tester);
      },
    );
  });

  group('el teclado solo se abre al tocar el campo', () {
    testWidgets('abrir la hoja suelta el foco y cerrarla no lo devuelve', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _focusSearch(tester);

      await _openSheet(tester);
      expect(
        _textFieldHasFocus(),
        isFalse,
        reason: 'al abrir la hoja el campo suelta el foco',
      );

      await _closeSheetByScrim(tester);
      expect(
        _textFieldHasFocus(),
        isFalse,
        reason: 'al cerrar la hoja no vuelve solo',
      );
      await _flush(tester);
    });

    testWidgets('aplicar un filtro no devuelve el foco al campo', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _focusSearch(tester);

      await _openSheet(tester);
      await tester.tap(find.text('Grupo'));
      await tester.pump(MotionConstants.medium);
      await tester.ensureVisible(find.text('Corales'));
      await tester.pump(MotionConstants.short);
      await tester.tap(find.text('Corales'));
      await tester.pump(MotionConstants.medium);
      await tester.tap(find.text('Aplicar'));
      await tester.pump();
      await tester.pump(MotionConstants.long);
      await tester.pump(MotionConstants.long);

      expect(_textFieldHasFocus(), isFalse);
      await _flush(tester);
    });

    testWidgets('limpiar y quitar un chip tampoco', (tester) async {
      await _pumpApp(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ExploreView)),
      );
      container.read(speciesFiltersProvider.notifier).setCategory('coral');
      await tester.pump();
      await tester.pump(MotionConstants.medium);
      await _focusSearch(tester);

      // Quitar el chip (su X) con el campo enfocado: el foco no se va a otra parte ni vuelve solo
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump(MotionConstants.medium);
      expect(container.read(speciesFiltersProvider).category, isNull);
      container.read(speciesFiltersProvider.notifier).setCategory('coral');
      await tester.pump(MotionConstants.medium);

      await _openSheet(tester);
      await tester.tap(find.text('Limpiar'));
      await tester.pump(MotionConstants.medium);
      await tester.tap(find.text('Aplicar'));
      await tester.pump();
      await tester.pump(MotionConstants.long);
      await tester.pump(MotionConstants.long);

      expect(_textFieldHasFocus(), isFalse);
      await _flush(tester);
    });

    testWidgets('al desplazar la lista el teclado se cierra', (tester) async {
      await _pumpApp(tester);
      await _focusSearch(tester);

      await _scrollDown(tester);

      expect(
        _textFieldHasFocus(),
        isFalse,
        reason: 'keyboardDismissBehavior: onDrag',
      );
      await _flush(tester);
    });

    testWidgets('tocar el campo sigue abriendo el teclado (tiene el foco)', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _focusSearch(tester);
      await _flush(tester);
    });
  });
}

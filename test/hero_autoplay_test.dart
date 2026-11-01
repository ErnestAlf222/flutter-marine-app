import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';

import 'support/fake_ui_repository.dart';

Future<void> _pump(
  WidgetTester tester, {
  int count = 6,
  bool reduceMotion = false,
  Widget Function(Widget home)? wrap,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final home = wrap == null ? const HomeView() : wrap(const HomeView());
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        speciesRepositoryProvider.overrideWithValue(
          FakeUiRepository(count: count),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: reduceMotion),
          child: app!,
        ),
        home: Scaffold(body: home),
      ),
    ),
  );
  // Llegan las especies destacadas y el carrusel se construye
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// Deja correr el reloj en pasos cortos para que los temporizadores y animaciones avancen
Future<void> _wait(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 100);
  for (Duration t = Duration.zero; t < total; t += step) {
    await tester.pump(step);
  }
}

double _page(WidgetTester tester) => tester
    .widget<PageView>(find.byType(PageView, skipOffstage: false).first)
    .controller!
    .page!;

Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

// Una vuelta completa: lo que tarda en avanzar y terminar de desplazarse
final _step = MotionConstants.heroAutoAdvance + MotionConstants.heroAdvance;

// Cuánto tarda en cambiar de página desde ahora (en pasos de 100 ms)
Future<Duration> _untilChange(WidgetTester tester, double from) async {
  Duration elapsed = Duration.zero;
  while (_page(tester) == from && elapsed < const Duration(seconds: 20)) {
    await tester.pump(const Duration(milliseconds: 100));
    elapsed += const Duration(milliseconds: 100);
  }
  return elapsed;
}

void main() {
  test('el intervalo es de 3 segundos y está en las constantes', () {
    expect(MotionConstants.heroAutoAdvance, const Duration(seconds: 3));
  });

  testWidgets('avanza solo cada 3 segundos', (tester) async {
    await _pump(tester);
    final start = _page(tester);

    final first = await _untilChange(tester, start);
    expect(first.inMilliseconds, inInclusiveRange(2400, 3000));

    await _wait(tester, MotionConstants.heroAdvance);
    final afterFirst = _page(tester);
    expect(afterFirst, start + 1);
    final second = await _untilChange(tester, afterFirst);
    expect(second.inMilliseconds, inInclusiveRange(2000, 2500));
    await _drain(tester);
  });

  testWidgets(
    'da la vuelta al llegar al final (6 especies: tras 6 avances vuelve a la primera)',
    (tester) async {
      await _pump(tester);
      final start = _page(tester);

      // Un avance cada 3 s (el primero a los ~3 s de construirse): a los 19 s van 6
      await _wait(tester, const Duration(seconds: 19));
      expect(_page(tester), start + 6);
      expect(_page(tester).round() % 6, start.round() % 6);
      await _drain(tester);
    },
  );

  testWidgets('con pocas especies (2) regresa a la primera sin saltos de tag', (
    tester,
  ) async {
    await _pump(tester, count: 2);
    expect(_page(tester), 0);

    await _wait(tester, const Duration(seconds: 4));
    expect(_page(tester), 1);

    await _wait(tester, const Duration(seconds: 3));
    expect(_page(tester), 0);
    await _drain(tester);
  });

  testWidgets(
    'se pausa mientras se mantiene tocado y se reanuda unos segundos después',
    (tester) async {
      await _pump(tester);
      final start = _page(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView).first),
      );
      await _wait(tester, const Duration(seconds: 10));
      expect(_page(tester), start, reason: 'tocado: no avanza');

      await gesture.cancel();
      // Soltar no reanuda de inmediato: espera unos segundos
      await _wait(
        tester,
        MotionConstants.heroResumeDelay - const Duration(milliseconds: 300),
      );
      expect(_page(tester), start, reason: 'recién soltado: sigue en pausa');

      await _wait(
        tester,
        const Duration(milliseconds: 300) + MotionConstants.heroAdvance,
      );
      expect(
        _page(tester),
        start + 1,
        reason: 'pasado el tiempo de espera, avanza',
      );
      await _drain(tester);
    },
  );

  testWidgets('se pausa al arrastrarlo y reanuda después de soltarlo', (
    tester,
  ) async {
    await _pump(tester);
    final start = _page(tester);

    // El usuario lo lleva a la siguiente tarjeta con el dedo
    await tester.drag(find.byType(PageView).first, const Offset(-300, 0));
    await tester.pumpAndSettle();
    final dragged = _page(tester);
    expect(dragged, greaterThan(start));

    // Recién soltado: sigue en pausa (la espera de 5 s ya gastó ~0.5 s del asentamiento)
    await _wait(
      tester,
      MotionConstants.heroResumeDelay - const Duration(milliseconds: 1500),
    );
    expect(_page(tester), dragged);

    await _wait(
      tester,
      const Duration(seconds: 2) + MotionConstants.heroAdvance,
    );
    expect(_page(tester), dragged + 1);
    await _drain(tester);
  });

  testWidgets('no corre cuando la pestaña Inicio no está visible', (
    tester,
  ) async {
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    await _pump(
      tester,
      wrap: (home) => ValueListenableBuilder<bool>(
        valueListenable: visible,
        // Las pestañas ocultas del shell llevan los tickers apagados
        builder: (_, on, _) => TickerMode(enabled: on, child: home),
      ),
    );
    final start = _page(tester);

    // El usuario cambia de pestaña
    visible.value = false;
    await tester.pump();
    await _wait(tester, const Duration(seconds: 10));
    expect(_page(tester), start, reason: 'pestaña oculta: no avanza');

    visible.value = true;
    await tester.pump();
    await _wait(tester, _step);
    expect(_page(tester), start + 1, reason: 'al volver a verse, reanuda');
    await _drain(tester);
  });

  testWidgets('no corre cuando hay otra pantalla (el Detalle) encima', (
    tester,
  ) async {
    await _pump(tester);
    final start = _page(tester);

    final context = tester.element(find.byType(HomeView));
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Detalle')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final beforeWait = _page(tester);

    await _wait(tester, const Duration(seconds: 10));
    expect(find.text('Detalle'), findsOneWidget);
    expect(
      _page(tester),
      beforeWait,
      reason: 'con el Detalle encima no avanza',
    );
    expect(beforeWait, lessThanOrEqualTo(start + 1));

    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final afterPop = _page(tester);
    await _wait(tester, _step);
    expect(
      _page(tester),
      afterPop + 1,
      reason: 'al volver del Detalle, reanuda',
    );
    await _drain(tester);
  });

  testWidgets('no corre con la app en segundo plano', (tester) async {
    await _pump(tester);
    final start = _page(tester);

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await _wait(tester, const Duration(seconds: 10));
    expect(_page(tester), start, reason: 'en segundo plano: no avanza');

    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await _wait(tester, _step);
    expect(
      _page(tester),
      start + 1,
      reason: 'al volver a primer plano, reanuda',
    );
    await _drain(tester);
  });

  testWidgets('con animaciones reducidas no hay avance automático', (
    tester,
  ) async {
    await _pump(tester, reduceMotion: true);
    final start = _page(tester);

    await _wait(tester, const Duration(seconds: 12));
    expect(_page(tester), start);
    await _drain(tester);
  });
}

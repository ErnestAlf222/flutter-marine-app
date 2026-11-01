import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

const _screen = Size(360, 800);

Widget _app(Widget home) => MaterialApp(
  theme: ThemeData(extensions: const [OceanPalette.dark]),
  home: home,
);

void _setScreen(WidgetTester tester) {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

// ---------------------------------------------------------------------------
// Transición de la ruta
// ---------------------------------------------------------------------------

Future<AnimationController> _pumpTransition(WidgetTester tester) async {
  final controller = AnimationController(
    vsync: tester,
    duration: MotionConstants.medium,
    value: 1,
  );
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    _app(
      DetailPageTransition(
        animation: controller,
        child: const SizedBox.expand(key: Key('pagina')),
      ),
    ),
  );
  return controller;
}

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byType(DetailPageTransition),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

void main() {
  group('transición de salida', () {
    testWidgets('al salir la pantalla se encoge, se desvanece, redondea esquinas y oscurece el fondo', (
      tester,
    ) async {
      _setScreen(tester);
      final controller = await _pumpTransition(tester);

      unawaited(controller.reverse());
      await tester.pump();
      await tester.pump(MotionConstants.medium ~/ 2);

      // Encogida: el rectángulo de la página es menor que la pantalla
      final page = tester.getRect(find.byKey(const Key('pagina')));
      expect(page.width, lessThan(_screen.width));
      expect(page.width, greaterThanOrEqualTo(_screen.width * MotionConstants.minimizeScale));
      // Desvanecida
      expect(_opacity(tester), lessThan(1));
      expect(_opacity(tester), greaterThan(0));
      // Con esquinas redondeadas
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clip.borderRadius, isNot(BorderRadius.zero));
      // Y el fondo oscureciéndose
      final scrim = tester.widget<ColoredBox>(
        find.descendant(of: find.byType(DetailPageTransition), matching: find.byType(ColoredBox)).first,
      );
      expect(scrim.color.a, greaterThan(0));

      await tester.pumpAndSettle();
    });

    testWidgets('al entrar no se encoge: desvanece y desliza como antes', (tester) async {
      _setScreen(tester);
      final controller = await _pumpTransition(tester);
      controller.value = 0.4;
      unawaited(controller.forward());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ClipRRect), findsNothing);
      expect(find.byType(FractionalTranslation), findsWidgets);
      expect(tester.getSize(find.byKey(const Key('pagina'))), _screen);
      await tester.pumpAndSettle();
    });

    testWidgets('con animaciones reducidas solo se desvanece, sin encoger', (tester) async {
      _setScreen(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      final controller = await _pumpTransition(tester);

      unawaited(controller.reverse());
      await tester.pump();
      await tester.pump(MotionConstants.medium ~/ 2);

      expect(find.byType(ClipRRect), findsNothing);
      expect(tester.getSize(find.byKey(const Key('pagina'))), _screen);
      await tester.pumpAndSettle();
    });
  });

  // -------------------------------------------------------------------------
  // Arrastrar hacia abajo para cerrar
  // -------------------------------------------------------------------------

  group('arrastrar para cerrar', () {
    int dismissed = 0;

    Future<ScrollController> pumpPull(WidgetTester tester, {Widget? over}) async {
      _setScreen(tester);
      dismissed = 0;
      late ScrollController controller;

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: PullToDismiss(
              onDismiss: () => dismissed++,
              builder: (context, scroll, physics) {
                controller = scroll;
                return ListView.builder(
                  key: const Key('lista'),
                  controller: scroll,
                  physics: physics,
                  itemCount: 60,
                  itemBuilder: (_, i) => SizedBox(height: 60, child: Text('fila $i')),
                );
              },
            ),
          ),
        ),
      );
      return controller;
    }

    Rect list(WidgetTester tester) => tester.getRect(find.byKey(const Key('lista')));

    // El resorte termina con errores de punto flotante: se compara con tolerancia
    void expectFull(Rect rect) {
      expect(rect.left, closeTo(0, 0.01));
      expect(rect.top, closeTo(0, 0.01));
      expect(rect.width, closeTo(360, 0.01));
      expect(rect.height, closeTo(800, 0.01));
    }

    testWidgets('con el scroll arriba, arrastrar hacia abajo encoge la pantalla siguiendo el dedo', (
      tester,
    ) async {
      await pumpPull(tester);

      final gesture = await tester.startGesture(const Offset(180, 300));
      for (int i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump(const Duration(milliseconds: 16));
      }

      final rect = list(tester);
      expect(rect.width, lessThan(_screen.width));
      expect(rect.width / _screen.width, greaterThanOrEqualTo(MotionConstants.pullMinScale));
      // Baja con el dedo: la parte de arriba ya no está en 0
      expect(rect.top, greaterThan(100));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('el scroll no se mueve mientras se arrastra para cerrar', (tester) async {
      final scroll = await pumpPull(tester);

      final gesture = await tester.startGesture(const Offset(180, 300));
      for (int i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(scroll.offset, 0);
      // Subir el dedo no desplaza el contenido: primero devuelve la pantalla a su sitio
      for (int i = 0; i < 3; i++) {
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(scroll.offset, 0);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('al soltar pasado el umbral se cierra', (tester) async {
      await pumpPull(tester);

      final gesture = await tester.startGesture(const Offset(180, 300));
      // 150 px es más de 0.3 del recorrido (320 px)
      for (int i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();

      expect(dismissed, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('al soltar antes del umbral vuelve con un resorte y no cierra', (tester) async {
      await pumpPull(tester);

      final gesture = await tester.startGesture(const Offset(180, 300));
      for (int i = 0; i < 4; i++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();

      expect(dismissed, 0);
      // Aún no volvió del todo: el resorte tarda
      expect(list(tester).width, lessThan(_screen.width));
      await tester.pumpAndSettle();
      expectFull(list(tester));
    });

    testWidgets('no choca con el scroll normal: con el contenido desplazado, bajar solo hace scroll', (
      tester,
    ) async {
      final scroll = await pumpPull(tester);

      await tester.drag(find.byKey(const Key('lista')), const Offset(0, -400));
      await tester.pumpAndSettle();
      final scrolled = scroll.offset;
      expect(scrolled, greaterThan(0));

      await tester.drag(find.byKey(const Key('lista')), const Offset(0, 150));
      await tester.pumpAndSettle();

      expect(scroll.offset, lessThan(scrolled));
      expectFull(list(tester));
      expect(dismissed, 0);
    });

    testWidgets('un gesto que empieza desplazado y llega arriba a media caricia no cierra', (
      tester,
    ) async {
      final scroll = await pumpPull(tester);
      await tester.drag(find.byKey(const Key('lista')), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(0));

      // Un tirón largo hacia abajo: vuelve al inicio y sigue bajando, pero empezó desplazado
      final gesture = await tester.startGesture(const Offset(180, 200));
      for (int i = 0; i < 30; i++) {
        await gesture.moveBy(const Offset(0, 25));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(scroll.offset, 0);
      expect(dismissed, 0);
      expectFull(list(tester));
    });

    testWidgets('empujar hacia arriba con el scroll arriba hace scroll y no encoge', (
      tester,
    ) async {
      final scroll = await pumpPull(tester);

      await tester.drag(find.byKey(const Key('lista')), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(scroll.offset, greaterThan(0));
      expectFull(list(tester));
    });

    testWidgets('con otra pantalla encima (como el visor de foto) no recibe el arrastre', (
      tester,
    ) async {
      await pumpPull(tester);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              body: ListView(children: const [SizedBox(height: 2000, child: Text('visor'))]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(180, 300));
      for (int i = 0; i < 8; i++) {
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(dismissed, 0);
      expect(find.text('visor'), findsOneWidget);
    });

    testWidgets('con animaciones reducidas, soltar antes del umbral vuelve al instante', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await pumpPull(tester);

      final gesture = await tester.startGesture(const Offset(180, 300));
      for (int i = 0; i < 4; i++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();

      expect(dismissed, 0);
      expectFull(list(tester));
    });
  });
}

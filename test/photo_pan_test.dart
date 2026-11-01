import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

const _screen = Size(360, 800);
// Marco de la galería: 360 x 500 (proporción 0.72)
const _frame = Size(360, 500);

Future<ImageProvider> _photo(WidgetTester tester, int width, int height) async {
  return (await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..color = const ui.Color(0xFF336699),
    );
    final image = await recorder.endRecording().toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return MemoryImage(Uint8List.view(data!.buffer));
  }))!;
}

Future<void> _pump(WidgetTester tester, List<ImageProvider> providers) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: const [OceanPalette.dark]),
      home: Scaffold(
        body: SizedBox(
          height: _frame.height,
          child: DetailGallery(
            photos: [for (final _ in providers) const GalleryPhoto(url: null)],
            providers: providers,
            category: 'fish',
            heroTag: 'especie',
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
  await tester.pump();
  await tester.pump();
}

// Alineación de la foto visible: -1 muestra su borde izquierdo, 1 el derecho
double _align(WidgetTester tester) =>
    tester.widget<SpeciesPhotoView>(find.byType(SpeciesPhotoView).first).alignment.x;

double _barOpacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

void main() {
  group('cuentas del recorrido', () {
    test('una foto cuadrada en un marco 0.72 se sale por los lados; una alta, no', () {
      expect(panOverflow(imageAspect: 1, frame: _frame), closeTo(140, 0.001));
      expect(panOverflow(imageAspect: 0.5, frame: _frame), 0);
      expect(panOverflow(imageAspect: 0.72, frame: _frame), closeTo(0, 0.001));
    });

    test('la barrita muestra la fracción visible', () {
      expect(panVisibleFraction(overflow: 140, frame: _frame), closeTo(0.72, 0.001));
      expect(panVisibleFraction(overflow: 0, frame: _frame), 1);
    });
  });

  group('recorrer la foto en Llenar', () {
    testWidgets('arrastrar la mueve pegada al dedo (1:1), sin pasar de foto', (tester) async {
      await _pump(tester, [await _photo(tester, 1000, 1000), await _photo(tester, 1000, 1000)]);
      expect(_align(tester), 0);

      // Sobran 140 px (70 por lado): 35 px de dedo son la mitad del recorrido
      await tester.drag(find.byType(PageView), const Offset(35, 0));
      await tester.pump();

      expect(_align(tester), closeTo(-0.5, 0.01));
      expect(find.text('1/2'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('la barrita aparece al arrastrar y se desvanece al segundo', (tester) async {
      await _pump(tester, [await _photo(tester, 1000, 1000), await _photo(tester, 1000, 1000)]);

      await tester.drag(find.byType(PageView), const Offset(20, 0));
      await tester.pump();
      expect(_barOpacity(tester), 1);

      await tester.pump(MotionConstants.panBarHide + const Duration(milliseconds: 10));
      expect(_barOpacity(tester), 0);
    });

    testWidgets('al llegar al borde se queda; el siguiente arrastre pasa a la galería', (tester) async {
      await _pump(tester, [await _photo(tester, 1000, 1000), await _photo(tester, 1000, 1000)]);

      // Un arrastre largo llega al borde derecho de la foto y no cambia de página
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(_align(tester), 1);
      expect(find.text('1/2'), findsOneWidget);

      // El siguiente, en el mismo sentido, ya es de la galería
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('2/2'), findsOneWidget);
    });

    testWidgets('en la foto nueva todavía hay qué recorrer antes de volver a la anterior', (tester) async {
      await _pump(tester, [await _photo(tester, 1000, 1000), await _photo(tester, 1000, 1000)]);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('2/2'), findsOneWidget);

      // La segunda foto está centrada: arrastrar a la derecha la recorre y no vuelve a la primera
      await tester.drag(find.byType(PageView), const Offset(30, 0));
      await tester.pumpAndSettle();
      expect(find.text('2/2'), findsOneWidget);
    });

    testWidgets('con una sola foto se queda en el borde', (tester) async {
      await _pump(tester, [await _photo(tester, 1000, 1000)]);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(_align(tester), 1);
      expect(find.text('1/1'), findsNothing);
    });

    testWidgets('si la foto no se recorta por los lados no se mueve y arrastrar pasa de foto', (
      tester,
    ) async {
      await _pump(tester, [await _photo(tester, 600, 1200), await _photo(tester, 600, 1200)]);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
      expect(_align(tester), 0);
    });

    testWidgets('en modo foto entera tampoco se recorre', (tester) async {
      await _pump(tester, [await _photo(tester, 1000, 1000), await _photo(tester, 1000, 1000)]);

      await tester.tap(find.text(DetailConstants.showWhole));
      await tester.pump(MotionConstants.photoFade);
      await tester.pump();

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('2/2'), findsOneWidget);
    });

    testWidgets('al soltar con velocidad sigue con inercia hasta el borde', (tester) async {
      await _pump(tester, [await _photo(tester, 1000, 1000)]);

      await tester.fling(find.byType(PageView), const Offset(-60, 0), 1500);
      await tester.pump();
      final atRelease = _align(tester);
      await tester.pump(const Duration(milliseconds: 600));

      expect(_align(tester), greaterThan(atRelease));
      await tester.pumpAndSettle();
    });

    testWidgets('con animaciones reducidas no hay inercia ni barra animada', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await _pump(tester, [await _photo(tester, 1000, 1000)]);

      await tester.fling(find.byType(PageView), const Offset(-30, 0), 2000);
      await tester.pump();
      final atRelease = _align(tester);
      await tester.pump(const Duration(milliseconds: 600));

      expect(_align(tester), atRelease);
      // La barra cambia al instante, sin fundido
      expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).duration, Duration.zero);
      await tester.pump(MotionConstants.panBarHide + const Duration(milliseconds: 10));
    });
  });

  group('con arrastrar hacia abajo para cerrar', () {
    testWidgets('cerrar hacia abajo sigue funcionando sobre una foto recorrible', (tester) async {
      tester.view.physicalSize = _screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final photo = await _photo(tester, 1000, 1000);
      int dismissed = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [OceanPalette.dark]),
          home: Scaffold(
            body: PullToDismiss(
              onDismiss: () => dismissed++,
              builder: (context, scroll, physics) => CustomScrollView(
                controller: scroll,
                physics: physics,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: _frame.height,
                      child: DetailGallery(
                        photos: const [GalleryPhoto(url: null), GalleryPhoto(url: null)],
                        providers: [photo, photo],
                        category: 'fish',
                        heroTag: 'especie',
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 1500)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();

      final gesture = await tester.startGesture(const Offset(180, 200));
      for (int i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();

      expect(dismissed, 1);
      expect(_align(tester), 0, reason: 'un arrastre vertical no recorre la foto');
      await tester.pumpAndSettle();
    });
  });
}

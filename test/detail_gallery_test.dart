import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

const _screen = Size(360, 800);

// Foto sólida del tamaño pedido, sin red
Future<ImageProvider> _fakePhoto(WidgetTester tester, int width, int height) async {
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

void _setScreen(WidgetTester tester) {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Widget home) => MaterialApp(
  theme: ThemeData(extensions: const [OceanPalette.dark]),
  home: Scaffold(body: home),
);

Future<void> _pumpGallery(
  WidgetTester tester, {
  required List<ImageProvider> providers,
  bool showHint = false,
  VoidCallback? onHintShown,
  ValueChanged<int>? onPageChanged,
  bool swipeEnabled = true,
}) async {
  _setScreen(tester);
  await tester.pumpWidget(
    _app(
      SizedBox(
        height: 500,
        child: DetailGallery(
          photos: [for (final _ in providers) const GalleryPhoto(url: null)],
          providers: providers,
          category: 'fish',
          heroTag: 'especie',
          showHint: showHint,
          onHintShown: onHintShown,
          onPageChanged: onPageChanged,
          swipeEnabled: swipeEnabled,
          footer: const Text('NOMBRE'),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
  await tester.pump();
  await tester.pump();
}

Future<void> _swipeLeft(WidgetTester tester) async {
  await tester.drag(find.byType(PageView), const Offset(-300, 0));
  await tester.pumpAndSettle();
}

void main() {
  group('galería con una sola foto', () {
    testWidgets('se ve como siempre: sin puntos, contador ni aviso, y sin deslizar', (tester) async {
      final photo = await _fakePhoto(tester, 768, 1024);
      await _pumpGallery(tester, providers: [photo], showHint: true);

      expect(find.text('1/1'), findsNothing);
      expect(find.text(DetailConstants.swipeHint), findsNothing);
      expect(find.byType(AnimatedContainer), findsNothing);
      expect(find.text('NOMBRE'), findsOneWidget);
      // El botón de ver completa sigue ahí
      expect(find.text(DetailConstants.showWhole), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('NOMBRE'), findsOneWidget);
    });
  });

  group('galería con varias fotos', () {
    testWidgets('puntos, contador "1/3" y deslizamiento entre fotos', (tester) async {
      final photo = await _fakePhoto(tester, 768, 1024);
      final changes = <int>[];
      await _pumpGallery(tester, providers: [photo, photo, photo], onPageChanged: changes.add);

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
      expect(find.text('1/3'), findsOneWidget);

      await _swipeLeft(tester);
      expect(find.text('2/3'), findsOneWidget);
      expect(changes, [1]);

      await _swipeLeft(tester);
      expect(find.text('3/3'), findsOneWidget);
      expect(changes, [1, 2]);
    });

    testWidgets('los textos de abajo son fijos: no se mueven al deslizar', (tester) async {
      final photo = await _fakePhoto(tester, 768, 1024);
      await _pumpGallery(tester, providers: [photo, photo]);

      final before = tester.getTopLeft(find.text('NOMBRE'));
      await _swipeLeft(tester);
      expect(tester.getTopLeft(find.text('NOMBRE')), before);
      expect(find.text('NOMBRE'), findsOneWidget);
    });

    testWidgets('solo la primera foto lleva el Hero', (tester) async {
      final photo = await _fakePhoto(tester, 768, 1024);
      await _pumpGallery(tester, providers: [photo, photo, photo]);

      final heroes = tester.widgetList<Hero>(find.byType(Hero)).toList();
      expect(heroes, hasLength(1));
      expect(heroes.single.tag, 'especie');
    });

    testWidgets('el botón de ver completa aplica a la foto actual', (tester) async {
      final square = await _fakePhoto(tester, 1000, 1000);
      final panorama = await _fakePhoto(tester, 1600, 900);
      await _pumpGallery(tester, providers: [square, panorama]);

      // La primera se llena el marco; la segunda, apaisada, se ve entera sola
      expect(find.text(DetailConstants.showWhole), findsOneWidget);
      await _swipeLeft(tester);
      // La segunda foto se decodifica ahora: se deja correr fuera del reloj falso
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
      await tester.pump();
      expect(find.text(DetailConstants.fillFrame), findsOneWidget);

      // Cambiar la segunda no toca a la primera
      await tester.tap(find.text(DetailConstants.fillFrame));
      await tester.pump(MotionConstants.short);
      await tester.pump();
      expect(find.text(DetailConstants.showWhole), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.text(DetailConstants.showWhole), findsOneWidget);
    });

    testWidgets('con el Detalle arrastrándose para cerrar no se desliza entre fotos', (tester) async {
      final photo = await _fakePhoto(tester, 768, 1024);
      await _pumpGallery(tester, providers: [photo, photo], swipeEnabled: false);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
    });
  });

  group('aviso "Desliza para ver más fotos"', () {
    testWidgets('sale, se desvanece a los 3 s y avisa una sola vez', (tester) async {
      final photo = await _fakePhoto(tester, 768, 1024);
      var shown = 0;
      await _pumpGallery(
        tester,
        providers: [photo, photo],
        showHint: true,
        onHintShown: () => shown++,
      );

      expect(find.text(DetailConstants.swipeHint), findsOneWidget);
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1,
      );
      expect(shown, 1);

      await tester.pump(MotionConstants.galleryHint - const Duration(milliseconds: 100));
      expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 1);

      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 0);
      await tester.pump(MotionConstants.short);
      expect(shown, 1);
    });

    testWidgets('si ya se mostró antes, no sale', (tester) async {
      final photo = await _fakePhoto(tester, 768, 1024);
      await _pumpGallery(tester, providers: [photo, photo]);

      expect(find.text(DetailConstants.swipeHint), findsNothing);
    });

    testWidgets('deslizar lo quita antes de tiempo', (tester) async {
      final photo = await _fakePhoto(tester, 768, 1024);
      await _pumpGallery(tester, providers: [photo, photo], showHint: true);
      expect(find.text(DetailConstants.swipeHint), findsOneWidget);

      await _swipeLeft(tester);
      await tester.pump(MotionConstants.short);

      expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 0);
    });

    testWidgets('con animaciones reducidas desaparece sin fundido', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      final photo = await _fakePhoto(tester, 768, 1024);
      await _pumpGallery(tester, providers: [photo, photo], showHint: true);
      expect(find.text(DetailConstants.swipeHint), findsOneWidget);

      await tester.pump(MotionConstants.galleryHint + const Duration(milliseconds: 10));

      expect(find.text(DetailConstants.swipeHint), findsNothing);
    });
  });

  group('con arrastrar hacia abajo para cerrar', () {
    var dismissed = 0;

    Future<void> pumpPull(WidgetTester tester) async {
      _setScreen(tester);
      dismissed = 0;
      final photo = await _fakePhoto(tester, 768, 1024);

      await tester.pumpWidget(
        _app(
          PullToDismiss(
            onDismiss: () => dismissed++,
            builder: (context, scroll, physics) => CustomScrollView(
              controller: scroll,
              physics: physics,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 500,
                    child: DetailGallery(
                      photos: const [GalleryPhoto(url: null), GalleryPhoto(url: null)],
                      providers: [photo, photo],
                      category: 'fish',
                      heroTag: 'especie',
                      swipeEnabled: physics is! NeverScrollableScrollPhysics,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 1500)),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
    }

    Rect gallery(WidgetTester tester) => tester.getRect(find.byType(PageView));

    testWidgets('deslizar de lado cambia de foto y no encoge la pantalla', (tester) async {
      await pumpPull(tester);
      final before = gallery(tester);

      // Un deslizamiento con algo de caída, como el de un dedo real
      final gesture = await tester.startGesture(const Offset(300, 200));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(-30, 2));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
      expect(gallery(tester).width, before.width);
      expect(dismissed, 0);
    });

    testWidgets('arrastrar hacia abajo encoge la pantalla y no cambia de foto', (tester) async {
      await pumpPull(tester);

      final gesture = await tester.startGesture(const Offset(180, 200));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();

      expect(dismissed, 1);
      expect(find.text('1/2'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('crédito de la foto visible', () {
    testWidgets('la hoja de créditos muestra el de la foto en la que se está', (tester) async {
      _setScreen(tester);
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            speciesRepositoryProvider.overrideWithValue(_TwoPhotosRepository()),
          ],
          child: _app(const SpeciesDetailView(slug: 'especie-1')),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Las fotos salen con la principal primero, aunque la API la mande segunda
      expect(find.text('1/2'), findsOneWidget);

      Future<void> openCredits() async {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.tap(find.text(DetailConstants.creditsButton));
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await openCredits();
      expect(find.text('© Autor Principal'), findsOneWidget);
      await tester.tapAt(const Offset(180, 20));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // La hoja se cerró
      expect(find.text('© Autor Principal'), findsNothing);

      // Desliza a la segunda foto
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('2/2'), findsOneWidget);

      await openCredits();
      expect(find.text('© Autor Segunda'), findsOneWidget);
      expect(find.text('© Autor Principal'), findsNothing);
    });
  });

  group('visor a pantalla completa', () {
    Future<void> pumpViewer(WidgetTester tester, {int initialIndex = 0}) async {
      _setScreen(tester);
      await tester.pumpWidget(
        _app(
          PhotoViewer(
            category: 'fish',
            initialIndex: initialIndex,
            photos: const [
              ViewerPhoto(url: 'a', credit: '© Uno'),
              ViewerPhoto(url: 'b', credit: '© Dos'),
              ViewerPhoto(url: 'c', credit: '© Tres'),
            ],
          ),
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('abre en la foto tocada, con contador y su crédito', (tester) async {
      await pumpViewer(tester, initialIndex: 1);

      expect(find.text('2/3'), findsOneWidget);
      expect(find.text('© Dos'), findsOneWidget);
    });

    testWidgets('desliza de lado entre fotos y el crédito cambia con ellas', (tester) async {
      await pumpViewer(tester);
      expect(find.text('© Uno'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('2/3'), findsOneWidget);
      expect(find.text('© Dos'), findsOneWidget);
      expect(find.text('© Uno'), findsNothing);
    });

    testWidgets('con una foto ampliada, arrastrar la mueve y no cambia de foto', (tester) async {
      await pumpViewer(tester);

      final viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer).first);
      viewer.transformationController!.value = Matrix4.diagonal3Values(2.5, 2.5, 1);
      await tester.pump();

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('sin zoom, deslizar sí cambia de foto (el zoom no se queda pegado)', (tester) async {
      await pumpViewer(tester);

      final viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer).first);
      viewer.transformationController!.value = Matrix4.diagonal3Values(2.5, 2.5, 1);
      await tester.pump();
      viewer.transformationController!.value = Matrix4.identity();
      await tester.pump();

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('2/3'), findsOneWidget);
    });

    testWidgets('cada foto tiene su propio zoom', (tester) async {
      await pumpViewer(tester);

      expect(find.byType(InteractiveViewer), findsWidgets);
      final controllers = tester
          .widgetList<InteractiveViewer>(find.byType(InteractiveViewer))
          .map((v) => v.transformationController)
          .toSet();
      expect(controllers.length, tester.widgetList(find.byType(InteractiveViewer)).length);
    });
  });
}

// Detalle con dos fotos: la API manda primero la que no es principal
class _TwoPhotosRepository extends FakeUiRepository {
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
        SpeciesPhoto(url: 'segunda', credit: '© Autor Segunda'),
        SpeciesPhoto(url: 'principal', credit: '© Autor Principal', isPrimary: true),
      ],
    ),
    '',
  );
}

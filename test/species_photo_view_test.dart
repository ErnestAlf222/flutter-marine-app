import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

// Genera una imagen PNG sólida del tamaño pedido, sin tocar la red
Future<ImageProvider> _fakePhoto(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFF336699),
  );
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(Uint8List.view(data!.buffer));
}

// Marco vertical de la cabecera del Detalle (200 x 250, proporción 0.8)
Widget _frame(Widget photo, {Duration routeTime = Duration.zero}) {
  return MaterialApp(
    // Tema simple con la paleta: evita descargar Montserrat en la prueba
    theme: ThemeData(extensions: const [OceanPalette.dark]),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              PageRouteBuilder<void>(
                transitionDuration: routeTime,
                pageBuilder: (_, _, _) => Scaffold(
                  body: Center(child: SizedBox(width: 200, height: 250, child: photo)),
                ),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
}

DetailGallery _detail(ImageProvider provider) => DetailGallery(
  photos: const [GalleryPhoto(url: null)],
  category: 'fish',
  heroTag: 'especie',
  providers: [provider],
);

Future<void> _open(WidgetTester tester, ImageProvider provider, {Duration routeTime = Duration.zero}) async {
  await tester.pumpWidget(_frame(_detail(provider), routeTime: routeTime));
  await tester.tap(find.text('abrir'));
  await tester.pump();
  // La decodificación es asíncrona real: se deja correr fuera del reloj falso
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
  await tester.pump();
}

// Contraste del texto blanco del botón contra una foto blanca: tinta semitransparente y,
// en la esquina más clara, la luz del cristal encima
double _toggleContrast({required double tint}) {
  const palette = OceanPalette.dark;
  final glass = Color.alphaBlend(palette.ink.withValues(alpha: tint), Colors.white);
  final lit = Color.alphaBlend(
    palette.paper.withValues(alpha: DesignConstants.glassLightAlpha),
    glass,
  );
  final l = lit.computeLuminance();
  return (palette.paper.computeLuminance() + 0.05) / (l + 0.05);
}

void main() {
  group('botón discreto', () {
    test('es semitransparente y su texto llega a 4.5:1 contra una foto blanca', () {
      expect(DesignConstants.photoToggleAlpha, lessThan(DesignConstants.glassSolidAlpha));
      final ratio = _toggleContrast(tint: DesignConstants.photoToggleAlpha);
      // ignore: avoid_print
      print('CONTRASTE del botón (peor caso): ${ratio.toStringAsFixed(2)}:1');
      expect(ratio, greaterThanOrEqualTo(4.5));
      // Con el 55 % pedido al principio no llegaba
      expect(_toggleContrast(tint: 0.55), lessThan(4.5));
    });

    testWidgets('sin borde de acento y de 48 dp', (tester) async {
      final provider = (await tester.runAsync(() => _fakePhoto(768, 1024)))!;
      await _open(tester, provider);
      await tester.pump(MotionConstants.short);
      await tester.pump();

      final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(surface.tintAlpha, DesignConstants.photoToggleAlpha);
      expect(surface.borderAlpha, 0);
      expect(surface.borderColor, isNull);
      expect(tester.getSize(find.byType(GlassSurface)).height, DesignConstants.photoToggleHeight);
    });
  });

  group('recorte de la foto', () {
    test('una foto igual al marco no pierde nada', () {
      expect(photoCropLoss(imageAspect: 0.8, frameAspect: 0.8), 0);
    });

    test('3:4 en un marco 4:5 pierde poco', () {
      expect(photoCropLoss(imageAspect: 0.75, frameAspect: 0.8), closeTo(0.0625, 1e-9));
      expect(isExtremeCrop(imageAspect: 0.75, frameAspect: 0.8), isFalse);
    });

    test('una foto apaisada en un marco vertical pierde más de la mitad', () {
      // 16:9 en 0.8: se ve solo el 45 % del ancho
      final loss = photoCropLoss(imageAspect: 16 / 9, frameAspect: 0.8);
      expect(loss, closeTo(0.55, 0.01));
      expect(isExtremeCrop(imageAspect: 16 / 9, frameAspect: 0.8), isTrue);
    });

    test('el umbral es de 45 %: justo debajo no es extremo', () {
      // frame 0.8 -> imagen 0.8 / 0.56 = 1.43 pierde 44 %
      expect(isExtremeCrop(imageAspect: 0.8 / 0.56, frameAspect: 0.8), isFalse);
      expect(isExtremeCrop(imageAspect: 0.8 / 0.54, frameAspect: 0.8), isTrue);
    });

    test('también cuenta una foto muy alta en un marco apaisado', () {
      expect(isExtremeCrop(imageAspect: 0.4, frameAspect: 1.5), isTrue);
    });
  });

  group('DetailGallery con una foto', () {
    testWidgets('una foto apaisada extrema pasa a verse entera al terminar el Hero', (
      tester,
    ) async {
      final provider = (await tester.runAsync(() => _fakePhoto(1600, 900)))!;
      await _open(tester, provider, routeTime: const Duration(milliseconds: 500));

      // Mientras la ruta (y el Hero) se mueve, sigue en cover
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(ImageFiltered), findsNothing);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(MotionConstants.short);
      expect(find.byType(ImageFiltered), findsOneWidget);
    });

    testWidgets('una foto parecida al marco se queda en cover', (tester) async {
      final provider = (await tester.runAsync(() => _fakePhoto(768, 1024)))!;
      await _open(tester, provider);
      await tester.pump(MotionConstants.short);

      expect(find.byType(ImageFiltered), findsNothing);
    });

    testWidgets('una foto cuadrada se queda en cover', (tester) async {
      final provider = (await tester.runAsync(() => _fakePhoto(1000, 1000)))!;
      await _open(tester, provider);
      await tester.pump(MotionConstants.short);

      // 1.0 en un marco 0.8 pierde el 20 %, menos que el límite
      expect(find.byType(ImageFiltered), findsNothing);
    });

    testWidgets('el botón alterna entre llenar y ver entera en cualquier foto', (
      tester,
    ) async {
      final provider = (await tester.runAsync(() => _fakePhoto(768, 1024)))!;
      await _open(tester, provider);
      await tester.pump(MotionConstants.short);
      expect(find.byType(ImageFiltered), findsNothing);

      await tester.tap(find.byTooltip('Ver la foto entera'));
      await tester.pump(MotionConstants.short);
      // El botón se entera un cuadro después: la foto avisa a la cabecera al terminar el suyo
      await tester.pump();
      expect(find.byType(ImageFiltered), findsOneWidget);

      await tester.tap(find.byTooltip('Llenar el marco'));
      // Una animación cuenta desde su primer cuadro: se espera a que termine el fundido de salida
      await tester.pumpAndSettle();
      expect(find.byType(ImageFiltered), findsNothing);
    });

    testWidgets('el botón mide 48 dp, lleva etiqueta y la cambia con el modo', (
      tester,
    ) async {
      final provider = (await tester.runAsync(() => _fakePhoto(768, 1024)))!;
      await _open(tester, provider);
      await tester.pump(MotionConstants.short);

      expect(find.text(DetailConstants.showWhole), findsOneWidget);
      final pill = find.ancestor(
        of: find.text(DetailConstants.showWhole),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(pill).height, DesignConstants.photoToggleHeight);
      expect(DesignConstants.photoToggleHeight, greaterThanOrEqualTo(48));

      await tester.tap(find.byTooltip('Ver la foto entera'));
      await tester.pump(MotionConstants.short);
      await tester.pump();
      expect(find.text(DetailConstants.fillFrame), findsOneWidget);
    });

    testWidgets('la elección manual gana sobre el modo automático', (tester) async {
      final provider = (await tester.runAsync(() => _fakePhoto(1600, 900)))!;
      await _open(tester, provider);
      await tester.pump(MotionConstants.short);
      expect(find.byType(ImageFiltered), findsOneWidget);

      await tester.tap(find.byTooltip('Llenar el marco'));
      await tester.pumpAndSettle();
      expect(find.byType(ImageFiltered), findsNothing);
    });
  });
}

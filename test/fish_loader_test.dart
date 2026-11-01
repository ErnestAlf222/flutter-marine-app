import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MaterialApp(
  theme: ThemeData(extensions: const [OceanPalette.dark]),
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
    child: app!,
  ),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('el pez nada: la animación corre y se repinta', (tester) async {
    await tester.pumpWidget(_host(const FishLoader()));

    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(MotionConstants.fishCycle ~/ 3);
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('con animaciones reducidas el pez queda quieto', (tester) async {
    await tester.pumpWidget(_host(const FishLoader(), disableAnimations: true));

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('mide el tamaño pedido y es más ancho que alto', (tester) async {
    await tester.pumpWidget(_host(const FishLoader(size: 30)));

    final size = tester.getSize(find.byType(CustomPaint).last);
    expect(size.height, 30);
    expect(size.width, 30 * DesignConstants.fishTrackFactor);
  });

  testWidgets('se anuncia como "Cargando" a accesibilidad', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const FishLoader()));

    expect(find.bySemanticsLabel('Cargando'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('la foto que carga muestra un pez pequeño sobre el color del grupo', (
    tester,
  ) async {
    // Sin red la imagen nunca llega: el marcador de carga se queda a la vista
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 150,
          child: SpeciesPhotoView(url: 'https://example.invalid/foto.jpg', category: 'fish'),
        ),
      ),
    );

    expect(find.byType(FishLoader), findsOneWidget);
    final loader = tester.widget<FishLoader>(find.byType(FishLoader));
    expect(loader.size, DesignConstants.fishPhotoSize);
  });

  testWidgets('los peces pequeños comparten un solo reloj, sin un controlador por foto', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Wrap(
          children: [
            for (int i = 0; i < 20; i++) const FishLoader.small(),
          ],
        ),
      ),
    );

    expect(FishClock.instance.users, 20);
    expect(tester.hasRunningAnimations, isTrue);

    // Al irse el último, el reloj se detiene y no pide más cuadros
    await tester.pumpWidget(_host(const SizedBox.shrink()));
    expect(FishClock.instance.users, 0);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('con animaciones reducidas el pez pequeño no usa el reloj', (tester) async {
    await tester.pumpWidget(_host(const FishLoader.small(), disableAnimations: true));

    expect(FishClock.instance.users, 0);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

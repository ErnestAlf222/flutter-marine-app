import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MaterialApp(
  // Tema simple con la paleta: evita descargar Montserrat en la prueba
  theme: ThemeData(extensions: const [OceanPalette.dark]),
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
    child: app!,
  ),
  home: Scaffold(body: child),
);

class _BubbleLauncher extends StatelessWidget {
  const _BubbleLauncher();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => FavoriteBubbles.show(context, color: const Color(0xFFFF6B5E)),
          child: const Text('marcar'),
        ),
      ),
    );
  }
}

void main() {
  group('burbujas del favorito', () {
    testWidgets('suben y se retiran solas al terminar', (tester) async {
      await tester.pumpWidget(_host(const _BubbleLauncher()));

      await tester.tap(find.text('marcar'));
      await tester.pump();
      expect(find.byType(BubbleBurst), findsOneWidget);

      await tester.pump(MotionConstants.long ~/ 2);
      expect(find.byType(BubbleBurst), findsOneWidget);

      await tester.pump(MotionConstants.long);
      expect(find.byType(BubbleBurst), findsNothing);
    });

    testWidgets('con animaciones reducidas no aparecen', (tester) async {
      await tester.pumpWidget(_host(const _BubbleLauncher(), disableAnimations: true));

      await tester.tap(find.text('marcar'));
      await tester.pump();

      expect(find.byType(BubbleBurst), findsNothing);
    });

    testWidgets('las burbujas salen del corazón y ascienden', (tester) async {
      Offset? origin;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (_) => BubbleBurst(
                    origin: const Offset(200, 400),
                    color: const Color(0xFFFF6B5E),
                    onDone: () {},
                    random: Random(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      origin = const Offset(200, 400);

      await tester.pump(MotionConstants.long ~/ 2);
      final positioned = tester.widgetList<Positioned>(
        find.descendant(of: find.byType(BubbleBurst), matching: find.byType(Positioned)),
      );

      expect(positioned, hasLength(MotionConstants.bubbleCount));
      // A mitad del vuelo todas las que ya salieron están por encima del origen
      expect(positioned.where((p) => p.top! < origin!.dy), isNotEmpty);
      expect(positioned.every((p) => p.top! <= origin!.dy), isTrue);
    });
  });

  group('cambio de pestañas', () {
    Widget switcher(int index) => _host(
      BranchSwitcher(
        currentIndex: index,
        children: const [Text('inicio'), Text('explorar'), Text('mapa')],
      ),
    );

    Opacity opacityOf(WidgetTester tester, String text) => tester.widget<Opacity>(
      find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first,
    );

    testWidgets('solo se ve la pestaña activa y las demás siguen montadas', (tester) async {
      await tester.pumpWidget(switcher(0));
      await tester.pump(MotionConstants.medium);

      expect(find.text('inicio'), findsOneWidget);
      expect(find.text('explorar', skipOffstage: false), findsOneWidget);
      expect(find.text('explorar'), findsNothing);
    });

    testWidgets('al cambiar, la nueva entra con fundido y la anterior sale', (tester) async {
      await tester.pumpWidget(switcher(0));
      await tester.pump(MotionConstants.medium);

      await tester.pumpWidget(switcher(1));
      await tester.pump(MotionConstants.medium ~/ 2);

      // A mitad de camino se ven las dos, a medias
      expect(find.text('inicio'), findsOneWidget);
      expect(find.text('explorar'), findsOneWidget);
      expect(opacityOf(tester, 'explorar').opacity, inExclusiveRange(0, 1));
      expect(opacityOf(tester, 'inicio').opacity, inExclusiveRange(0, 1));

      await tester.pump(MotionConstants.medium);
      expect(find.text('inicio'), findsNothing);
      expect(opacityOf(tester, 'explorar').opacity, 1);
    });

    testWidgets('la pestaña que entra sube un poco mientras aparece', (tester) async {
      await tester.pumpWidget(switcher(0));
      await tester.pump(MotionConstants.medium);

      await tester.pumpWidget(switcher(1));
      await tester.pump(const Duration(milliseconds: 50));
      final during = tester.getTopLeft(find.text('explorar')).dy;

      await tester.pump(MotionConstants.medium);
      final after = tester.getTopLeft(find.text('explorar')).dy;

      expect(during, greaterThan(after));
      expect(during - after, lessThanOrEqualTo(MotionConstants.tabShift));
    });

    testWidgets('con animaciones reducidas el cambio es instantáneo', (tester) async {
      Widget build(int index) => _host(
        BranchSwitcher(
          currentIndex: index,
          children: const [Text('inicio'), Text('explorar')],
        ),
        disableAnimations: true,
      );

      await tester.pumpWidget(build(0));
      await tester.pumpWidget(build(1));
      await tester.pump();

      expect(find.text('inicio'), findsNothing);
      expect(opacityOf(tester, 'explorar').opacity, 1);
    });
  });

  group('parallax de la foto', () {
    // Lista de tarjetas de 200 px; la "foto" es una caja con clave dentro de cada una
    Widget list(Key photoKey, {bool disableAnimations = false}) => _host(
      ListView.builder(
        itemCount: 20,
        itemBuilder: (context, i) => SizedBox(
          height: 200,
          child: ClipRect(
            child: ParallaxPhoto(
              child: SizedBox.expand(key: i == 5 ? photoKey : null, child: const ColoredBox(color: Color(0xFF123456))),
            ),
          ),
        ),
      ),
      disableAnimations: disableAnimations,
    );

    testWidgets('la foto se desplaza dentro de su tarjeta al hacer scroll', (tester) async {
      const key = ValueKey('foto');
      await tester.pumpWidget(list(key));
      final scrollable = find.byType(Scrollable);

      // Lleva la tarjeta 5 a la parte alta y luego a la baja de la pantalla
      await tester.drag(scrollable, const Offset(0, -700));
      await tester.pump();
      final high = tester.getTopLeft(find.byKey(key)).dy;
      final highCard = high;

      await tester.drag(scrollable, const Offset(0, -150));
      await tester.pump();
      final low = tester.getTopLeft(find.byKey(key)).dy;

      // La tarjeta subió 150 px; sin parallax la foto subiría exactamente lo mismo
      expect((high - low).abs(), isNot(closeTo(150, 1)));
      expect(highCard, isNotNull);
    });

    testWidgets('la foto es más alta que la tarjeta por el recorrido del parallax', (tester) async {
      const key = ValueKey('foto');
      await tester.pumpWidget(list(key));
      await tester.drag(find.byType(Scrollable), const Offset(0, -700));
      await tester.pump();

      expect(
        tester.getSize(find.byKey(key)).height,
        200 + DesignConstants.parallaxTravel * 2,
      );
    });

    testWidgets('con animaciones reducidas la foto no se mueve ni crece', (tester) async {
      const key = ValueKey('foto');
      await tester.pumpWidget(list(key, disableAnimations: true));
      await tester.drag(find.byType(Scrollable), const Offset(0, -700));
      await tester.pump();

      expect(tester.getSize(find.byKey(key)).height, 200);
    });
  });
}

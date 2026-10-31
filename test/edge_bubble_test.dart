import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

const _area = Size(360, 700);
const _top = 24.0; // barra de estado

void main() {
  group('geometría de la burbuja', () {
    final travel = bubbleTravel(area: _area, topInset: _top);

    test('el recorrido vertical queda dentro del área, sobre la barra de navegación', () {
      expect(travel.min, _top + DesignConstants.bubbleMargin);
      // La esquina inferior de la burbuja no pasa del borde del área
      expect(travel.max + DesignConstants.bubbleSize, lessThanOrEqualTo(_area.height));
    });

    test('con un área muy baja (teclado abierto) el recorrido se reduce a un punto', () {
      final tiny = bubbleTravel(area: const Size(360, 80), topInset: _top);
      expect(tiny.max, tiny.min);
    });

    test('derecha e izquierda dejan el margen del borde', () {
      final right = bubbleOrigin(
        placement: const BubblePlacement(onRight: true, yFraction: 0),
        area: _area,
        topInset: _top,
      );
      final left = bubbleOrigin(
        placement: const BubblePlacement(onRight: false, yFraction: 0),
        area: _area,
        topInset: _top,
      );
      expect(right.dx + DesignConstants.bubbleSize + DesignConstants.bubbleMargin, _area.width);
      expect(left.dx, DesignConstants.bubbleMargin);
    });

    test('minimizada queda pegada al borde con solo el ancho de la pestaña', () {
      final right = bubbleOrigin(
        placement: const BubblePlacement(onRight: true, minimized: true),
        area: _area,
        topInset: _top,
      );
      final left = bubbleOrigin(
        placement: const BubblePlacement(onRight: false, minimized: true),
        area: _area,
        topInset: _top,
      );
      expect(right.dx, _area.width - DesignConstants.bubbleTabWidth);
      expect(left.dx, 0);
    });

    test('la altura 0 es el tope y la 1 el fondo del recorrido', () {
      final top = bubbleOrigin(
        placement: const BubblePlacement(yFraction: 0),
        area: _area,
        topInset: _top,
      );
      final bottom = bubbleOrigin(
        placement: const BubblePlacement(yFraction: 1),
        area: _area,
        topInset: _top,
      );
      expect(top.dy, travel.min);
      expect(bottom.dy, travel.max);
    });

    test('al soltar a la izquierda de la mitad se pega al borde izquierdo', () {
      final p = snapBubble(topLeft: const Offset(60, 300), area: _area, topInset: _top);
      expect(p.onRight, isFalse);
    });

    test('al soltar pasada la mitad se pega al derecho', () {
      final p = snapBubble(topLeft: const Offset(200, 300), area: _area, topInset: _top);
      expect(p.onRight, isTrue);
    });

    test('lo que cuenta es el centro de la burbuja, no su esquina', () {
      // Esquina a 150 -> centro a 178 (< 180): izquierda; a 153 -> 181: derecha
      expect(snapBubble(topLeft: const Offset(150, 100), area: _area, topInset: _top).onRight, isFalse);
      expect(snapBubble(topLeft: const Offset(153, 100), area: _area, topInset: _top).onRight, isTrue);
    });

    test('la altura se recuerda como fracción y no se sale del recorrido', () {
      expect(snapBubble(topLeft: const Offset(0, -500), area: _area, topInset: _top).yFraction, 0);
      expect(snapBubble(topLeft: const Offset(0, 9999), area: _area, topInset: _top).yFraction, 1);
      final middle = (travel.min + travel.max) / 2;
      expect(
        snapBubble(topLeft: Offset(0, middle), area: _area, topInset: _top).yFraction,
        closeTo(0.5, 1e-9),
      );
    });

    test('al arrastrar nunca sale del área visible ni baja de la barra de navegación', () {
      final far = clampBubble(topLeft: const Offset(9999, 9999), area: _area, topInset: _top);
      expect(far.dx + DesignConstants.bubbleSize, lessThanOrEqualTo(_area.width));
      expect(far.dy + DesignConstants.bubbleSize, lessThanOrEqualTo(_area.height));

      final near = clampBubble(topLeft: const Offset(-50, -50), area: _area, topInset: _top);
      expect(near.dx, DesignConstants.bubbleMargin);
      expect(near.dy, travel.min);
    });
  });

  group('burbuja en pantalla', () {
    // Host con estado: el widget real recibe la ubicación y avisa de los cambios
    Widget host({
      required ValueNotifier<BubblePlacement> placement,
      int badge = 0,
      VoidCallback? onTap,
      bool pauseIdle = false,
      bool disableAnimations = false,
    }) {
      return MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
          child: app!,
        ),
        home: Scaffold(
          body: SizedBox(
            width: _area.width,
            height: _area.height,
            child: ValueListenableBuilder<BubblePlacement>(
              valueListenable: placement,
              builder: (context, value, _) => EdgeBubble(
                placement: value,
                onPlacementChanged: (p) => placement.value = p,
                icon: Icons.tune,
                badge: badge,
                label: 'Filtros',
                pauseIdle: pauseIdle,
                onTap: onTap ?? () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('se arrastra y al soltar se pega al borde más cercano', (tester) async {
      final placement = ValueNotifier(const BubblePlacement());
      await tester.pumpWidget(host(placement: placement));
      expect(placement.value.onRight, isTrue);

      await tester.drag(find.byIcon(Icons.tune), const Offset(-280, -120));
      await tester.pumpAndSettle();

      expect(placement.value.onRight, isFalse);
      // Ya pegada a la izquierda, con el margen del borde
      expect(tester.getTopLeft(find.byIcon(Icons.tune)).dx, lessThan(DesignConstants.bubbleSize));
    });

    testWidgets('un arrastre corto la deja del mismo lado', (tester) async {
      final placement = ValueNotifier(const BubblePlacement());
      await tester.pumpWidget(host(placement: placement));

      await tester.drag(find.byIcon(Icons.tune), const Offset(-40, 0));
      await tester.pumpAndSettle();

      expect(placement.value.onRight, isTrue);
    });

    testWidgets('tocarla avisa y no la mueve', (tester) async {
      var taps = 0;
      final placement = ValueNotifier(const BubblePlacement());
      await tester.pumpWidget(host(placement: placement, onTap: () => taps++));
      final before = tester.getCenter(find.byIcon(Icons.tune));

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pump();

      expect(taps, 1);
      expect(tester.getCenter(find.byIcon(Icons.tune)), before);
    });

    testWidgets('muestra cuántos filtros hay aplicados', (tester) async {
      final placement = ValueNotifier(const BubblePlacement());
      await tester.pumpWidget(host(placement: placement, badge: 3));
      expect(find.text('3'), findsOneWidget);

      await tester.pumpWidget(host(placement: placement, badge: 0));
      expect(find.text('3'), findsNothing);
    });

    testWidgets('tras unos segundos sin usarla se minimiza a una pestaña', (tester) async {
      final placement = ValueNotifier(const BubblePlacement());
      await tester.pumpWidget(host(placement: placement));
      expect(placement.value.minimized, isFalse);

      await tester.pump(MotionConstants.bubbleIdle - const Duration(milliseconds: 100));
      expect(placement.value.minimized, isFalse);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(placement.value.minimized, isTrue);
      // La pestaña es más angosta que el círculo
      expect(find.byIcon(Icons.tune), findsNothing);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('al tocar la pestaña vuelve a su posición', (tester) async {
      final placement = ValueNotifier(const BubblePlacement(minimized: true));
      await tester.pumpWidget(host(placement: placement));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(placement.value.minimized, isFalse);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('no se minimiza mientras la hoja de filtros está abierta', (tester) async {
      final placement = ValueNotifier(const BubblePlacement());
      await tester.pumpWidget(host(placement: placement, pauseIdle: true));

      await tester.pump(MotionConstants.bubbleIdle * 2);
      expect(placement.value.minimized, isFalse);

      // Al cerrar la hoja vuelve a contar el tiempo
      await tester.pumpWidget(host(placement: placement));
      await tester.pump(MotionConstants.bubbleIdle + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(placement.value.minimized, isTrue);
    });

    testWidgets('usarla reinicia la cuenta del tiempo', (tester) async {
      final placement = ValueNotifier(const BubblePlacement());
      await tester.pumpWidget(host(placement: placement));

      await tester.pump(MotionConstants.bubbleIdle - const Duration(seconds: 1));
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pump(const Duration(seconds: 2));

      // Pasó más del tiempo desde el inicio, pero no desde el último uso
      expect(placement.value.minimized, isFalse);
    });

    testWidgets('con animaciones reducidas se mueve sin deslizarse', (tester) async {
      final placement = ValueNotifier(const BubblePlacement());
      await tester.pumpWidget(host(placement: placement, disableAnimations: true));

      await tester.drag(find.byIcon(Icons.tune), const Offset(-280, 0));
      await tester.pump();

      // Un solo cuadro basta: ya está en su sitio
      expect(placement.value.onRight, isFalse);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}

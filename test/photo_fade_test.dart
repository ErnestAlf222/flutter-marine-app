import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

// Abre el visor y devuelve el estado de su animación de ruta
Future<Animation<double>> _openViewer(WidgetTester tester) async {
  late BuildContext launcher;
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: const [OceanPalette.dark]),
      home: Builder(
        builder: (context) {
          launcher = context;
          return const Scaffold(body: SizedBox());
        },
      ),
    ),
  );
  PhotoViewer.show(
    launcher,
    category: 'fish',
    photos: const [ViewerPhoto(url: 'a')],
  );
  await tester.pump();
  await tester.pump();
  return ModalRoute.of(tester.element(find.byType(PhotoViewer)))!.animation!;
}

void main() {
  test('la ampliación es un fundido corto de unos 200 ms', () {
    expect(MotionConstants.photoFade, const Duration(milliseconds: 200));
    expect(MotionConstants.photoFadeCurve, Curves.easeOut);
  });

  testWidgets('el visor entra con un fundido de 200 ms', (tester) async {
    final animation = await _openViewer(tester);

    await tester.pump(MotionConstants.photoFade ~/ 2);
    expect(animation.status, AnimationStatus.forward);
    await tester.pump(MotionConstants.photoFade ~/ 2 + const Duration(milliseconds: 1));
    expect(animation.status, AnimationStatus.completed);
  });

  testWidgets('con animaciones reducidas el visor aparece sin transición', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final animation = await _openViewer(tester);
    await tester.pump(const Duration(milliseconds: 1));

    expect(animation.status, AnimationStatus.completed);
  });
}

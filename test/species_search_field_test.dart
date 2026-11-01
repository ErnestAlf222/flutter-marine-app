import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

Widget _host(Widget child) => MaterialApp(
  // Tema simple con la paleta: evita descargar Montserrat en la prueba
  theme: ThemeData(extensions: const [OceanPalette.dark]),
  home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
);

void main() {
  testWidgets('muestra la X solo con texto y la X borra', (tester) async {
    final controller = TextEditingController();
    int cleared = 0;

    await tester.pumpWidget(
      _host(
        SpeciesSearchField(
          controller: controller,
          onClear: () {
            cleared++;
            controller.clear();
          },
        ),
      ),
    );
    expect(find.byIcon(Icons.close), findsNothing);

    await tester.enterText(find.byType(TextField), 'tortuga');
    await tester.pump();
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(cleared, 1);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('con onTap no toma el foco y avisa del toque', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    int taps = 0;

    await tester.pumpWidget(
      _host(
        SpeciesSearchField(
          controller: controller,
          focusNode: focusNode,
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byType(SpeciesSearchField));
    await tester.pump();

    expect(taps, 1);
    expect(focusNode.hasFocus, isFalse);
  });
}

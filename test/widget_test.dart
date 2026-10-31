import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/main.dart';

void main() {
  testWidgets('MainApp muestra la barra de 4 pestañas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    // Sin pumpAndSettle: el esqueleto de carga repite su brillo sin parar
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    // La cuarta pestaña es el Mapa; Acerca de ya no existe
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Acerca de'), findsNothing);
  });
}

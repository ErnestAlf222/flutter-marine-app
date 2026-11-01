import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

import 'support/fake_ui_repository.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        speciesRepositoryProvider.overrideWithValue(FakeUiRepository()),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: const [OceanPalette.dark]),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

// Mide el círculo de cristal del corazón y su icono tal como se pintan en pantalla
// (con las transformaciones de los padres y la escala del rebote), no solo lo declarado
({Size button, Size icon}) _measure(WidgetTester tester, Finder heart) {
  final button = tester.getRect(
    find.descendant(of: heart, matching: find.byType(ClipOval)),
  );
  final icon = tester.getRect(
    find.descendant(of: heart, matching: find.byIcon(Icons.favorite_border)),
  );
  return (button: button.size, icon: icon.size);
}

// Con tolerancia: la escala del rebote deja restos de coma flotante
void _expectSize(Size actual, double expected) {
  expect(actual.width, closeTo(expected, 0.01));
  expect(actual.height, closeTo(expected, 0.01));
}

void main() {
  const largeSize = 56.0;
  const largeIcon = 34.0;
  const tileSize = 48.0;
  const tileIcon = 30.0;

  test('las constantes son las pedidas', () {
    expect(DesignConstants.favoriteLargeSize, largeSize);
    expect(DesignConstants.favoriteLargeIcon, largeIcon);
    expect(DesignConstants.favoriteTileSize, tileSize);
    expect(DesignConstants.favoriteTileIcon, tileIcon);
  });

  testWidgets('héroe de Inicio: 56 dp con icono de 34', (tester) async {
    await _pump(tester, const HomeView());

    final hearts = find.byType(FavoriteButton);
    expect(hearts, findsWidgets);
    // El carrusel muestra la tarjeta activa y, a los lados, dos vecinas giradas y más chicas
    // (cover-flow): se mide la activa, que es la de la mitad de la pantalla
    final screenCenter =
        tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
    final active = hearts.evaluate().toList()
      ..sort((a, b) {
        double gap(Element e) =>
            (tester.getCenter(find.byWidget(e.widget)).dx - screenCenter).abs();
        return gap(a).compareTo(gap(b));
      });
    final measured = _measure(tester, find.byWidget(active.first.widget));
    debugPrint('HEROE: botón ${measured.button}, icono ${measured.icon}');

    _expectSize(measured.button, largeSize);
    _expectSize(measured.icon, largeIcon);

    await _drain(tester);
  });

  testWidgets('tarjeta (SpeciesTile): 48 dp con icono de 30', (tester) async {
    await _pump(
      tester,
      SizedBox(
        width: 180,
        height: 240,
        child: SpeciesTile(species: FakeUiRepository.species(1).first),
      ),
    );

    final measured = _measure(tester, find.byType(FavoriteButton));
    debugPrint('TARJETA: botón ${measured.button}, icono ${measured.icon}');

    _expectSize(measured.button, tileSize);
    _expectSize(measured.icon, tileIcon);
    await _drain(tester);
  });

  testWidgets('Detalle: 56 dp con icono de 34', (tester) async {
    final species = FakeUiRepository.species(1).first;
    await _pump(
      tester,
      SpeciesDetailView(slug: species.slug, preview: species),
    );

    final measured = _measure(tester, find.byType(FavoriteButton));
    debugPrint('DETALLE: botón ${measured.button}, icono ${measured.icon}');

    _expectSize(measured.button, largeSize);
    _expectSize(measured.icon, largeIcon);
    await _drain(tester);
  });
}

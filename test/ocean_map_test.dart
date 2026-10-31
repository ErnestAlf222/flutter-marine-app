import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

const _zones = [
  OceanZone(id: 'mediterranean', speciesCount: 535, name: 'Mediterráneo', description: '', lat: 38, lon: 15),
  OceanZone(id: 'asian-pacific', speciesCount: 706, name: 'Pacífico Asiático', description: '', lat: 0, lon: 100),
];

const _size = Size(360, 400);

Widget _host(Widget child) => MaterialApp(
  // Tema simple con la paleta: evita descargar Montserrat en la prueba
  theme: ThemeData(extensions: const [OceanPalette.dark]),
  home: Scaffold(body: Align(alignment: Alignment.topLeft, child: SizedBox.fromSize(size: _size, child: child))),
);

// Dónde cae una zona en pantalla con la vista inicial del mapa completo
Offset _screenPosition(OceanZone zone) {
  final projection = MapProjection(
    worldWidth: _size.width * MapConstants.worldWidthFactor,
    height: _size.height,
  );
  final view = centerOn(
    worldPoint: projection.project(MapConstants.initialCenterLat, MapConstants.initialCenterLon),
    scale: MapConstants.minScale,
    world: Size(projection.worldWidth, projection.height),
    viewport: _size,
  );
  return view.apply(projection.project(zone.lat, zone.lon));
}

void main() {
  testWidgets('tocar un círculo avisa de su zona', (tester) async {
    OceanZone? tapped;
    await tester.pumpWidget(_host(OceanMap(zones: _zones, onZoneTap: (z) => tapped = z)));
    await tester.pump();

    await tester.tapAt(_screenPosition(_zones[1]));
    expect(tapped?.id, 'asian-pacific');

    await tester.tapAt(_screenPosition(_zones[0]) + const Offset(4, 3));
    expect(tapped?.id, 'mediterranean');
  });

  testWidgets('un toque lejos de las zonas no abre nada', (tester) async {
    OceanZone? tapped;
    await tester.pumpWidget(_host(OceanMap(zones: _zones, onZoneTap: (z) => tapped = z)));
    await tester.pump();

    await tester.tapAt(const Offset(10, 390));
    expect(tapped, isNull);
  });

  testWidgets('cada zona expone su nombre y conteo a accesibilidad', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(OceanMap(zones: _zones)));
    await tester.pump();

    expect(find.bySemanticsLabel('Mediterráneo, 535 especies'), findsOneWidget);
    expect(find.bySemanticsLabel('Pacífico Asiático, 706 especies'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('el mini mapa ignora los toques y describe las zonas resaltadas', (tester) async {
    OceanZone? tapped;
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        OceanMap(
          compact: true,
          zones: _zones,
          highlighted: const {'mediterranean'},
          onZoneTap: (z) => tapped = z,
        ),
      ),
    );
    await tester.pump();

    await tester.tapAt(const Offset(180, 200));
    expect(tapped, isNull);
    expect(find.bySemanticsLabel('Mapa de las zonas donde vive: Mediterráneo'), findsOneWidget);
    handle.dispose();
  });
}

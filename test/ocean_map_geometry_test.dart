import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/ocean_map_geometry.dart';

void main() {
  const projection = MapProjection(worldWidth: 720, height: 400, centerLat: 20);

  group('proyección lat/lon a pantalla', () {
    test('los extremos de longitud caen en los bordes del mundo', () {
      expect(projection.project(20, -180).dx, 0);
      expect(projection.project(20, 180).dx, 720);
      expect(projection.project(20, 0).dx, 360);
    });

    test('la latitud central queda en el centro vertical y el norte arriba', () {
      expect(projection.project(20, 0).dy, 200);
      expect(projection.project(40, 0).dy, lessThan(200));
      expect(projection.project(0, 0).dy, greaterThan(200));
    });

    test('mismos píxeles por grado en ambos ejes', () {
      final a = projection.project(20, 0);
      final b = projection.project(30, 10);
      expect((b.dx - a.dx).abs(), closeTo((b.dy - a.dy).abs(), 1e-9));
    });

    test('proyectar y deshacer devuelve el punto original', () {
      final p = projection.project(-17.5, 133.25);
      final back = projection.unproject(p);
      expect(back.lat, closeTo(-17.5, 1e-9));
      expect(back.lon, closeTo(133.25, 1e-9));
    });
  });

  group('encuadre de la vista', () {
    test('fitBounds deja el centro de la caja en el centro del marco', () {
      const box = Size(300, 160);
      final t = fitBounds(
        projection: projection,
        lonMin: -40,
        lonMax: 40,
        latMin: 0,
        latMax: 40,
        box: box,
      );
      final center = t.apply(projection.project(20, 0));
      expect(center.dx, closeTo(150, 1e-9));
      expect(center.dy, closeTo(80, 1e-9));
    });

    test('fitBounds escoge el zoom del eje más ajustado', () {
      const box = Size(300, 160);
      final t = fitBounds(
        projection: projection,
        lonMin: -40,
        lonMax: 40,
        latMin: 0,
        latMax: 40,
        box: box,
      );
      // 80° de longitud = 160 px y 40° de latitud = 80 px: manda el ancho (300 / 160)
      // y el alto (160 / 80) empata, así que ambos dan 1.875 y 2
      expect(t.scale, closeTo(1.875, 1e-9));
    });

    test('clampTransform no deja ver fuera del lienzo', () {
      const world = Size(720, 400);
      const viewport = Size(360, 400);
      final left = clampTransform(const ViewTransform(1, Offset(500, 0)), world, viewport);
      final right = clampTransform(const ViewTransform(1, Offset(-900, 0)), world, viewport);
      expect(left.translation.dx, 0);
      expect(right.translation.dx, -360);
    });

    test('clampTransform centra un lienzo menor que el marco', () {
      final t = clampTransform(
        const ViewTransform(1, Offset(40, 40)),
        const Size(200, 100),
        const Size(300, 200),
      );
      expect(t.translation, const Offset(50, 50));
    });

    test('centerOn centra el punto salvo que choque con un borde', () {
      const world = Size(720, 400);
      const viewport = Size(360, 400);
      final middle = centerOn(
        worldPoint: const Offset(360, 200),
        scale: 1,
        world: world,
        viewport: viewport,
      );
      expect(middle.apply(const Offset(360, 200)).dx, closeTo(180, 1e-9));

      final edge = centerOn(
        worldPoint: const Offset(10, 200),
        scale: 1,
        world: world,
        viewport: viewport,
      );
      expect(edge.translation.dx, 0);
    });
  });

  group('tamaño de los círculos', () {
    test('crece con el número de especies', () {
      final small = zoneRadius(count: 100, maxCount: 700, scale: 1);
      final big = zoneRadius(count: 700, maxCount: 700, scale: 1);
      expect(big, greaterThan(small));
      expect(big, MapConstants.circleMaxRadius);
    });

    test('al acercar crece poco y con tope', () {
      final base = zoneRadius(count: 700, maxCount: 700, scale: 1);
      final zoomed = zoneRadius(count: 700, maxCount: 700, scale: 5);
      expect(zoomed, greaterThan(base));
      expect(zoomed / base, lessThanOrEqualTo(MapConstants.zoomGrowthMax));
      // A 100x de zoom no crece más que a 5x: el tope se mantiene
      expect(zoneRadius(count: 700, maxCount: 700, scale: 100) / base,
          MapConstants.zoomGrowthMax);
    });
  });

  group('toque sobre zonas', () {
    const a = ZoneAnchor(id: 'a', center: Offset(100, 100), radius: 30);
    const b = ZoneAnchor(id: 'b', center: Offset(130, 100), radius: 30);

    test('con círculos superpuestos gana la zona más cercana al dedo', () {
      expect(resolveZoneTap(const Offset(108, 100), [a, b]), 'a');
      expect(resolveZoneTap(const Offset(122, 100), [a, b]), 'b');
    });

    test('no importa el orden de la lista', () {
      expect(resolveZoneTap(const Offset(108, 100), [b, a]), 'a');
    });

    test('un toque lejos de todo no elige nada', () {
      expect(resolveZoneTap(const Offset(300, 300), [a, b]), isNull);
    });

    test('un toque junto al borde cuenta dentro de la holgura', () {
      // A 40 del centro: 10 fuera del círculo, dentro de la holgura de 24
      expect(resolveZoneTap(const Offset(60, 100), [a]), 'a');
      expect(resolveZoneTap(const Offset(60, 100), [a], slop: 5), isNull);
    });
  });

  group('etiquetas', () {
    const bounds = Rect.fromLTWH(0, 0, 400, 400);
    const full = Size(90, 30);
    const short = Size(70, 15);

    LabelRequest request(String id, Offset anchor) => LabelRequest(
      id: id,
      anchor: anchor,
      radius: 18,
      full: full,
      short: short,
    );

    test('tres zonas muy cercanas no se pisan entre sí', () {
      // Macaronesia, Atlántico Este y Mediterráneo: separadas por pocos píxeles
      final placements = placeLabels([
        request('mediterranean', const Offset(200, 200)),
        request('east-atlantic', const Offset(172, 178)),
        request('macaronesia', const Offset(176, 222)),
      ], bounds: bounds);

      expect(placements, hasLength(3));
      for (int i = 0; i < placements.length; i++) {
        for (int j = i + 1; j < placements.length; j++) {
          final overlap = placements[i].rect.intersect(placements[j].rect);
          expect(
            overlap.width <= 0 || overlap.height <= 0,
            isTrue,
            reason: '${placements[i].id} pisa a ${placements[j].id}',
          );
        }
      }
    });

    test('una zona aislada lleva la etiqueta completa debajo', () {
      final p = placeLabels([request('a', const Offset(200, 100))], bounds: bounds).single;
      expect(p.isShort, isFalse);
      expect(p.rect.top, greaterThan(100));
    });

    test('las etiquetas se quedan dentro del marco', () {
      final p = placeLabels([request('a', const Offset(10, 10))], bounds: bounds).single;
      expect(bounds.contains(p.rect.topLeft), isTrue);
      expect(bounds.contains(p.rect.bottomRight), isTrue);
    });

    test('si la completa no cabe, usa la versión corta', () {
      // Marco de 80 x 40: la etiqueta completa (90 x 30) no entra, la corta (70 x 15) sí
      final p = placeLabels(
        [request('a', const Offset(40, 8))],
        bounds: const Rect.fromLTWH(0, 0, 80, 60),
      ).single;
      expect(p.isShort, isTrue);
    });

    test('una zona fuera del marco no recibe etiqueta', () {
      expect(
        placeLabels([request('a', const Offset(900, 900))], bounds: bounds),
        isEmpty,
      );
    });
  });

  group('tierra firme', () {
    const geojson = '''
{"type":"FeatureCollection","features":[
 {"type":"Feature","geometry":{"type":"Polygon","coordinates":[
   [[0,0],[10,0],[10,10],[0,10],[0,0]],
   [[2,2],[4,2],[4,4],[2,4],[2,2]]]}},
 {"type":"Feature","geometry":{"type":"MultiPolygon","coordinates":[
   [[[20,20],[30,20],[30,30],[20,20]]],
   [[[40,40],[50,40],[50,50],[40,40]]]]}},
 {"type":"Feature","geometry":null}
]}''';

    test('lee polígonos, huecos y multipolígonos como anillos [lon, lat, ...]', () {
      final rings = parseLandGeoJson(geojson);
      // 1 borde + 1 hueco + 2 polígonos del multipolígono; la geometría nula se omite
      expect(rings, hasLength(4));
      expect(rings.first.sublist(0, 4), [0, 0, 10, 0]);
    });

    test('un anillo entero en la Antártida no se dibuja', () {
      final rings = parseLandGeoJson('''
{"type":"FeatureCollection","features":[{"type":"Feature","geometry":
 {"type":"Polygon","coordinates":[[[-60,-80],[60,-80],[60,-70],[-60,-70],[-60,-80]]]}}]}''');
      expect(buildLandPath(rings, projection).getBounds(), Rect.zero);
    });

    test('la tierra se recorta a la franja de latitudes útil', () {
      final rings = parseLandGeoJson('''
{"type":"FeatureCollection","features":[{"type":"Feature","geometry":
 {"type":"Polygon","coordinates":[[[-10,60],[10,60],[10,89],[-10,89],[-10,60]]]}}]}''');
      final bounds = buildLandPath(rings, projection).getBounds();
      final top = projection.project(MapConstants.latMax, 0).dy;
      expect(bounds.top, closeTo(top, 1e-9));
    });

    test('el archivo real de Natural Earth se interpreta', () {
      final text = File(MapConstants.landAsset).readAsStringSync();
      final rings = parseLandGeoJson(text);
      expect(rings.length, greaterThanOrEqualTo(127));
      expect(rings.every((r) => r.length.isEven && r.length >= 6), isTrue);
    });
  });

  test('formatSpeciesCount separa los miles con coma', () {
    expect(formatSpeciesCount(7), '7');
    expect(formatSpeciesCount(351), '351');
    expect(formatSpeciesCount(1505), '1,505');
    expect(formatSpeciesCount(1234567), '1,234,567');
  });
}

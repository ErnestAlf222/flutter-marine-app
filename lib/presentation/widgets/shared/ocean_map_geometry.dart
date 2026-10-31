import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:marine_app/config/constants/map_constants.dart';

// Lógica pura del mapa de zonas (sin widgets): proyección, encuadre, toque y etiquetas.
// Vive aparte para poder probarla sin pintar nada.

/// "1234" -> "1,234"
String formatSpeciesCount(int n) {
  final digits = n.abs().toString();
  final buffer = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Anillos del GeoJSON de tierra firme como pares [lon, lat, lon, lat, ...].
/// Se llama en otro hilo con `compute`, por eso es una función de primer nivel.
List<Float64List> parseLandGeoJson(String source) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  final rings = <Float64List>[];

  void addPolygon(List<dynamic> polygon) {
    // El primer anillo es el borde y los siguientes son huecos (lagos): todos se
    // dibujan con relleno par-impar, así los huecos quedan vacíos
    for (final ring in polygon) {
      final points = ring as List<dynamic>;
      final flat = Float64List(points.length * 2);
      for (var i = 0; i < points.length; i++) {
        final p = points[i] as List<dynamic>;
        flat[i * 2] = (p[0] as num).toDouble();
        flat[i * 2 + 1] = (p[1] as num).toDouble();
      }
      rings.add(flat);
    }
  }

  for (final feature in json['features'] as List<dynamic>) {
    final geometry =
        (feature as Map<String, dynamic>)['geometry'] as Map<String, dynamic>?;
    if (geometry == null) continue;

    final coordinates = geometry['coordinates'] as List<dynamic>;
    switch (geometry['type']) {
      case 'Polygon':
        addPolygon(coordinates);
      case 'MultiPolygon':
        for (final polygon in coordinates) {
          addPolygon(polygon as List<dynamic>);
        }
    }
  }
  return rings;
}

/// Proyección equirectangular: x lineal en la longitud, y lineal en la latitud,
/// con los mismos píxeles por grado en ambos ejes.
class MapProjection {
  final double worldWidth;
  final double height;
  // Latitud que queda en el centro vertical del lienzo
  final double centerLat;

  const MapProjection({
    required this.worldWidth,
    required this.height,
    this.centerLat = MapConstants.initialCenterLat,
  });

  double get pixelsPerDegree => worldWidth / 360;

  Offset project(double lat, double lon) => Offset(
    (lon + 180) * pixelsPerDegree,
    height / 2 - (lat - centerLat) * pixelsPerDegree,
  );

  ({double lat, double lon}) unproject(Offset p) => (
    lat: centerLat + (height / 2 - p.dy) / pixelsPerDegree,
    lon: p.dx / pixelsPerDegree - 180,
  );

  @override
  bool operator ==(Object other) =>
      other is MapProjection &&
      other.worldWidth == worldWidth &&
      other.height == height &&
      other.centerLat == centerLat;

  @override
  int get hashCode => Object.hash(worldWidth, height, centerLat);
}

/// Zoom uniforme y desplazamiento de la vista sobre el lienzo del mundo.
class ViewTransform {
  final double scale;
  final Offset translation;

  const ViewTransform(this.scale, this.translation);

  Offset apply(Offset worldPoint) => worldPoint * scale + translation;

  Offset invert(Offset screenPoint) => (screenPoint - translation) / scale;
}

/// Zoom y desplazamiento que encajan una caja de lat/lon dentro de [box].
ViewTransform fitBounds({
  required MapProjection projection,
  required double lonMin,
  required double lonMax,
  required double latMin,
  required double latMax,
  required Size box,
}) {
  final rect = Rect.fromPoints(
    projection.project(latMax, lonMin),
    projection.project(latMin, lonMax),
  );
  final scale = min(box.width / rect.width, box.height / rect.height);
  return ViewTransform(
    scale,
    box.center(Offset.zero) - rect.center * scale,
  );
}

/// Mantiene el lienzo cubriendo el marco; si el lienzo es menor, lo centra.
ViewTransform clampTransform(ViewTransform t, Size world, Size viewport) {
  double clamp1(double value, double worldExtent, double viewExtent) {
    final scaled = worldExtent * t.scale;
    if (scaled <= viewExtent) return (viewExtent - scaled) / 2;
    return value.clamp(viewExtent - scaled, 0.0).toDouble();
  }

  return ViewTransform(
    t.scale,
    Offset(
      clamp1(t.translation.dx, world.width, viewport.width),
      clamp1(t.translation.dy, world.height, viewport.height),
    ),
  );
}

/// Vista que deja [worldPoint] en el centro del marco, sin salirse del lienzo.
ViewTransform centerOn({
  required Offset worldPoint,
  required double scale,
  required Size world,
  required Size viewport,
}) {
  return clampTransform(
    ViewTransform(scale, viewport.center(Offset.zero) - worldPoint * scale),
    world,
    viewport,
  );
}

/// Radio del círculo de una zona: crece con sqrt(species_count) y, al acercar el
/// mapa, solo un poco y con tope, para que los círculos no tapen todo.
double zoneRadius({
  required int count,
  required int maxCount,
  required double scale,
  bool compact = false,
}) {
  final growth = min(
    pow(scale, MapConstants.zoomGrowthExponent).toDouble(),
    MapConstants.zoomGrowthMax,
  );
  if (compact) return MapConstants.compactRadius * growth;

  final t = maxCount <= 0 ? 0.0 : sqrt(count / maxCount).clamp(0.0, 1.0);
  final base =
      MapConstants.circleMinRadius +
      (MapConstants.circleMaxRadius - MapConstants.circleMinRadius) * t;
  return base * growth;
}

class ZoneAnchor {
  final String id;
  final Offset center;
  final double radius;

  const ZoneAnchor({
    required this.id,
    required this.center,
    required this.radius,
  });
}

/// Zona tocada: la de centro más cercano al dedo entre las que lo alcanzan
/// (a menos de [slop] del borde de su círculo). Así, con círculos superpuestos
/// gana la que el dedo tiene más cerca, no la que se dibujó encima.
String? resolveZoneTap(
  Offset tap,
  List<ZoneAnchor> anchors, {
  double slop = MapConstants.hitSlop,
}) {
  String? best;
  var bestDistance = double.infinity;

  for (final anchor in anchors) {
    final distance = (tap - anchor.center).distance;
    if (distance - anchor.radius > slop) continue;
    if (distance < bestDistance) {
      bestDistance = distance;
      best = anchor.id;
    }
  }
  return best;
}

class LabelRequest {
  final String id;
  final Offset anchor;
  final double radius;
  // Etiqueta completa (nombre y conteo) y versión corta (solo nombre)
  final Size full;
  final Size short;

  const LabelRequest({
    required this.id,
    required this.anchor,
    required this.radius,
    required this.full,
    required this.short,
  });
}

class LabelPlacement {
  final String id;
  final Rect rect;
  final bool isShort;

  const LabelPlacement({
    required this.id,
    required this.rect,
    required this.isShort,
  });
}

double _overlapArea(Rect a, Rect b) {
  final i = a.intersect(b);
  return i.width <= 0 || i.height <= 0 ? 0 : i.width * i.height;
}

/// Coloca cada etiqueta junto a su círculo sin pisar a las demás. Prueba varias
/// posiciones alrededor del círculo y, si la completa no cabe, la versión corta.
/// El orden de [requests] es la prioridad: las primeras eligen sitio primero.
List<LabelPlacement> placeLabels(
  List<LabelRequest> requests, {
  required Rect bounds,
  double gap = MapConstants.labelGap,
}) {
  final circles = {
    for (final r in requests) r.id: Rect.fromCircle(center: r.anchor, radius: r.radius),
  };
  final placed = <LabelPlacement>[];

  List<Rect> candidates(LabelRequest r, Size s) {
    final a = r.anchor;
    final d = r.radius + gap;
    final diagonal = r.radius * 0.7 + gap;
    return [
      Rect.fromLTWH(a.dx - s.width / 2, a.dy + d, s.width, s.height), // abajo
      Rect.fromLTWH(a.dx - s.width / 2, a.dy - d - s.height, s.width, s.height), // arriba
      Rect.fromLTWH(a.dx + d, a.dy - s.height / 2, s.width, s.height), // derecha
      Rect.fromLTWH(a.dx - d - s.width, a.dy - s.height / 2, s.width, s.height), // izquierda
      Rect.fromLTWH(a.dx + diagonal, a.dy + diagonal, s.width, s.height), // abajo-derecha
      Rect.fromLTWH(a.dx - diagonal - s.width, a.dy + diagonal, s.width, s.height), // abajo-izquierda
      Rect.fromLTWH(a.dx + diagonal, a.dy - diagonal - s.height, s.width, s.height), // arriba-derecha
      Rect.fromLTWH(a.dx - diagonal - s.width, a.dy - diagonal - s.height, s.width, s.height), // arriba-izquierda
    ];
  }

  double cost(Rect rect, String ownId) {
    var total = 0.0;
    // Pisar otra etiqueta pesa mucho más que tapar un círculo ajeno
    for (final p in placed) {
      total += _overlapArea(rect, p.rect) * 1000;
    }
    for (final entry in circles.entries) {
      if (entry.key != ownId) total += _overlapArea(rect, entry.value);
    }
    return total;
  }

  for (final request in requests) {
    Rect? bestRect;
    var bestShort = false;
    var bestCost = double.infinity;

    for (final isShort in [false, true]) {
      final size = isShort ? request.short : request.full;
      for (final rect in candidates(request, size)) {
        // Debe quedar entera dentro del marco visible
        if (rect.left < bounds.left ||
            rect.top < bounds.top ||
            rect.right > bounds.right ||
            rect.bottom > bounds.bottom) {
          continue;
        }
        final c = cost(rect, request.id);
        // Estrictamente menor: ante un empate se conserva la primera posición y
        // la versión completa
        if (c < bestCost) {
          bestCost = c;
          bestRect = rect;
          bestShort = isShort;
        }
        if (bestCost == 0) break;
      }
      if (bestCost == 0) break;
    }

    if (bestRect != null) {
      placed.add(LabelPlacement(id: request.id, rect: bestRect, isShort: bestShort));
    }
  }
  return placed;
}

/// Contornos de tierra firme como un solo [Path] ya proyectado. Se construye una
/// vez por tamaño de mapa y se reutiliza en cada repintado.
Path buildLandPath(List<Float64List> rings, MapProjection projection) {
  final path = Path()..fillType = PathFillType.evenOdd;

  for (final ring in rings) {
    var maxLat = -90.0;
    for (var i = 1; i < ring.length; i += 2) {
      maxLat = max(maxLat, ring[i]);
    }
    // Contornos enteros fuera de la franja útil (Antártida) no se dibujan
    if (maxLat < MapConstants.latMin) continue;

    for (var i = 0; i < ring.length; i += 2) {
      final lat = ring[i + 1].clamp(MapConstants.latMin, MapConstants.latMax).toDouble();
      final p = projection.project(lat, ring[i]);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
  }
  return path;
}

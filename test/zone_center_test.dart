import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/infrastructure/mappers/species_mapper.dart';
import 'package:marine_app/infrastructure/models/zones_response.dart';

void main() {
  group('centro de una zona', () {
    test('con center [lat, lon] usa ese punto', () {
      final center = SpeciesMapper.boundsCenter(
        const ZoneBoundsResponse(centerLat: 38, centerLon: 15),
      );
      expect(center.lat, 38);
      expect(center.lon, 15);
    });

    test('eastern-pacific: punto medio de sus límites', () {
      // Datos reales de la API: lat -5..32 y lon -130..-77
      final center = SpeciesMapper.boundsCenter(
        const ZoneBoundsResponse(latMin: -5, latMax: 32, lonMin: -130, lonMax: -77),
      );
      expect(center.lat, 13.5);
      expect(center.lon, -103.5);
    });

    test('una caja que cruza el antimeridiano se centra por el lado corto', () {
      final center = SpeciesMapper.boundsCenter(
        const ZoneBoundsResponse(latMin: -10, latMax: 10, lonMin: 170, lonMax: -150),
      );
      expect(center.lat, 0);
      expect(center.lon, -170);
    });

    test('sin datos o con límites incompletos cae en (0, 0)', () {
      expect(SpeciesMapper.boundsCenter(null).lat, 0);
      final partial = SpeciesMapper.boundsCenter(const ZoneBoundsResponse(latMin: 1, latMax: 2));
      expect(partial.lat, 0);
      expect(partial.lon, 0);
    });
  });

  group('bounds de /zones', () {
    test('lee la forma con center', () {
      final zone = ZoneResponse.fromJson({
        'id': 'caribbean',
        'species_count': 499,
        'display_order': 5,
        'bounds': {'zoom': 4, 'center': [18, -75]},
        'zone_translations': <dynamic>[],
      });
      expect(zone.bounds?.centerLat, 18);
      expect(zone.bounds?.centerLon, -75);
    });

    test('lee la forma con límites y la convierte en entidad con su centro', () {
      final zone = ZoneResponse.fromJson({
        'id': 'eastern-pacific',
        'species_count': 597,
        'display_order': 7,
        'bounds': {'lat_max': 32, 'lat_min': -5, 'lon_max': -77, 'lon_min': -130},
        'zone_translations': [
          {'name': 'Pacífico Oriental', 'language': 'es', 'description': 'd'},
        ],
      });
      final entity = SpeciesMapper.zoneToEntity(zone, 'es');
      expect(entity.name, 'Pacífico Oriental');
      expect(entity.lat, 13.5);
      expect(entity.lon, -103.5);
    });
  });
}

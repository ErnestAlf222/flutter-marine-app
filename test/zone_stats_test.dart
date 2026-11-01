import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';

Species _species(
  String slug, {
  String category = 'fish',
  double? size,
  double? depth,
  String? status,
}) => Species(
  id: slug,
  slug: slug,
  scientificName: 'Genus $slug',
  commonName: slug,
  category: category,
  sizeMaxCm: size,
  depthMaxM: depth,
  conservationStatus: status,
);

void main() {
  group('récords', () {
    test('elige la más grande, la más profunda y la más amenazada', () {
      final records = ZoneStats.records([
        _species('a', size: 100, depth: 50, status: 'VU'),
        _species('b', size: 500, depth: 20, status: 'LC'),
        _species('c', size: 300, depth: 1200, status: 'CR'),
      ]);

      expect(records.largest?.slug, 'b');
      expect(records.deepest?.slug, 'c');
      expect(records.mostThreatened?.slug, 'c');
    });

    test('en los empates gana la primera de la lista', () {
      final records = ZoneStats.records([
        _species('a', size: 200, depth: 80, status: 'EN'),
        _species('b', size: 200, depth: 80, status: 'EN'),
        _species('c', size: 200, depth: 80, status: 'EN'),
      ]);

      expect(records.largest?.slug, 'a');
      expect(records.deepest?.slug, 'a');
      expect(records.mostThreatened?.slug, 'a');
    });

    test('una especie con riesgo mayor que las anteriores desempata a su favor', () {
      final records = ZoneStats.records([
        _species('a', status: 'NT'),
        _species('b', status: 'EN'),
        _species('c', status: 'VU'),
        _species('d', status: 'EN'),
      ]);

      expect(records.mostThreatened?.slug, 'b');
    });

    test('sin datos no hay récords', () {
      final records = ZoneStats.records([
        _species('a'),
        // DD y NE no son un nivel de riesgo
        _species('b', status: 'DD'),
        _species('c', status: 'NE'),
      ]);

      expect(records.largest, isNull);
      expect(records.deepest, isNull);
      expect(records.mostThreatened, isNull);
      expect(records.isEmpty, isTrue);
    });

    test('cada récord falta por separado si falta su dato', () {
      final records = ZoneStats.records([
        _species('a', size: 40),
        _species('b', depth: 10),
      ]);

      expect(records.largest?.slug, 'a');
      expect(records.deepest?.slug, 'b');
      expect(records.mostThreatened, isNull);
      expect(records.isEmpty, isFalse);
    });

    test('con una sola especie es todos los récords que tenga', () {
      final records = ZoneStats.records([_species('a', size: 5, depth: 1, status: 'LC')]);

      expect(records.largest?.slug, 'a');
      expect(records.deepest?.slug, 'a');
      expect(records.mostThreatened?.slug, 'a');
    });

    test('una lista vacía no rompe nada', () {
      expect(ZoneStats.records(const []).isEmpty, isTrue);
      expect(ZoneStats.groups(const []), isEmpty);
    });
  });

  group('grupos', () {
    test('cuenta por grupo, de más a menos', () {
      final groups = ZoneStats.groups([
        _species('a', category: 'coral'),
        _species('b'),
        _species('c'),
        _species('d', category: 'mollusk'),
        _species('e'),
      ]);

      expect(groups.first, ('fish', 3));
      expect(groups.map((g) => g.$2).reduce((a, b) => a + b), 5);
    });

    test('a igual conteo, el orden estable de la app', () {
      final groups = ZoneStats.groups([
        _species('a', category: 'mollusk'),
        _species('b', category: 'fish'),
        _species('c', category: 'coral'),
      ]);
      final order = CategoryConstants.ids;

      expect(
        groups.map((g) => g.$1).toList(),
        ['fish', 'coral', 'mollusk']..sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b))),
      );
    });

    test('un grupo desconocido va al final y no se pierde', () {
      final groups = ZoneStats.groups([_species('a', category: 'rareza'), _species('b')]);

      expect(groups.last, ('rareza', 1));
    });

    test('inGroup filtra, y sin grupo devuelve todas', () {
      final items = [_species('a'), _species('b', category: 'coral'), _species('c')];

      expect(ZoneStats.inGroup(items, 'fish').map((s) => s.slug), ['a', 'c']);
      expect(ZoneStats.inGroup(items, null), items);
      expect(ZoneStats.inGroup(items, 'algae'), isEmpty);
    });
  });
}

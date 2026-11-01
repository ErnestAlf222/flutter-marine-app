import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';

// 250 especies = 3 páginas de 100 (la última con 50). La página 4 da error, como la 17 real.
List<Species> _species(int n, {String stamp = 'v1'}) => [
  for (var i = 0; i < n; i++)
    Species(
      id: 'id-$i',
      slug: 'especie-$i',
      scientificName: 'Genus species$i',
      commonName: 'Nombre $i',
      category: i.isEven ? 'fish' : 'coral',
      updatedAt: '$stamp-$i',
    ),
];

class _FakeRemote implements SpeciesDatasource {
  List<Species> catalog;
  // Nombre en inglés: otra lista con el mismo orden
  final requests = <String>[];
  final lowPriority = <bool>[];
  // Páginas (en español) que fallan mientras la prueba lo pida
  final failingPages = <int>{};

  _FakeRemote(this.catalog);

  @override
  Future<(SpeciesPage?, String)> getSpecies({
    required String lang,
    required int page,
    required int perPage,
    String? zone,
    String? category,
    String? conservationStatus,
    String? dangerLevel,
    double? sizeMin,
    double? sizeMax,
    double? depthMin,
    double? depthMax,
    bool? featured,
  }) async {
    requests.add('$lang:$page');
    lowPriority.add(RequestPriority.isLow);

    final start = (page - 1) * perPage;
    if (start >= catalog.length || failingPages.contains(page)) {
      return (null, 'Error 500');
    }
    final items = catalog.skip(start).take(perPage).map((s) {
      // En inglés solo cambia el nombre
      return lang == 'en'
          ? Species(
              id: s.id,
              slug: s.slug,
              scientificName: s.scientificName,
              commonName: 'English ${s.slug.split('-').last}',
              category: s.category,
              updatedAt: s.updatedAt,
            )
          : s;
    }).toList();
    return (
      SpeciesPage(items: items, page: page, perPage: perPage, total: catalog.length),
      '',
    );
  }

  @override
  Future<(List<Species>?, String)> searchSpecies({required String query, required String lang}) async =>
      (null, 'no se usa');

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({required String slug, required String lang}) async =>
      (null, 'no se usa');

  @override
  Future<(List<OceanZone>?, String)> getZones({required String lang}) async => (null, 'no se usa');

  @override
  Future<(List<Species>?, String)> getZoneTopSpecies({
    required String zone,
    required String lang,
    required int limit,
  }) async => (null, 'no se usa');
}

// Base local en memoria con la misma semántica que la de Isar
class _FakeLocal implements CatalogDatasource {
  final rows = <String, _Row>{};
  CatalogSyncState sync = const CatalogSyncState();
  int writes = 0;

  @override
  Future<(List<CatalogEntry>?, String)> loadAll() async {
    final listed = rows.values.where((r) => r.species != null).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return ([for (final r in listed) CatalogEntry(species: r.species!, nameEn: r.nameEn)], '');
  }

  @override
  Future<(bool?, String)> savePage(
    List<Species> items, {
    required String lang,
    required int firstPosition,
    required int runId,
  }) async {
    for (var i = 0; i < items.length; i++) {
      final s = items[i];
      final row = rows.putIfAbsent(s.slug, _Row.new);
      if (lang == 'en') {
        row
          ..nameEn = s.commonName
          ..runId = runId;
        continue;
      }
      row
        ..position = firstPosition + i
        ..runId = runId;
      // Lo que no cambió en updated_at no se reescribe
      if (row.species?.updatedAt != s.updatedAt) {
        row.species = s;
        writes++;
      }
    }
    return (true, '');
  }

  @override
  Future<(int?, String)> removeStale(int runId) async {
    final stale = rows.entries.where((e) => e.value.runId != runId).map((e) => e.key).toList();
    stale.forEach(rows.remove);
    return (stale.length, '');
  }

  @override
  Future<(CatalogSyncState?, String)> readSync() async => (sync, '');

  @override
  Future<(bool?, String)> writeSync(CatalogSyncState state) async {
    sync = state;
    return (true, '');
  }
}

class _Row {
  Species? species;
  String? nameEn;
  int position = 0;
  int runId = 0;
}

Future<List<CatalogProgress>> _runSync(CatalogRepositoryImpl repository) =>
    repository.sync().toList();

void main() {
  late _FakeRemote remote;
  late _FakeLocal local;
  late DateTime now;

  CatalogRepositoryImpl build() =>
      CatalogRepositoryImpl(local: local, remote: remote, now: () => now);

  setUp(() {
    remote = _FakeRemote(_species(250));
    local = _FakeLocal();
    now = DateTime(2026, 11, 1);
  });

  group('primera sincronización', () {
    test('baja las 3 páginas en es y en, informa "x de 3" y se detiene en la última', () async {
      final repository = build();
      expect(await repository.prepare(), isFalse);
      expect(await repository.search(query: 'nombre'), isNull, reason: 'sin catálogo no hay búsqueda local');

      final progress = await _runSync(repository);

      expect(progress.map((p) => (p.step, p.total)), [(1, 3), (2, 3), (3, 3)]);
      expect(remote.requests, ['es:1', 'en:1', 'es:2', 'en:2', 'es:3', 'en:3']);
      expect(remote.requests.any((r) => r.endsWith(':4')), isFalse);
      expect(local.sync.isComplete, isTrue);
      expect(repository.isReady, isTrue);
    });

    test('todo corre con baja prioridad', () async {
      await _runSync(build());

      expect(remote.lowPriority, isNotEmpty);
      expect(remote.lowPriority.every((low) => low), isTrue);
    });

    test('al terminar busca en local, con el nombre en inglés incluido y sin tope', () async {
      final repository = build();
      await _runSync(repository);

      expect((await repository.search(query: ''))!.length, 250);
      // "7" también es prefijo de 70-79 en inglés, pero la palabra completa va primero
      expect((await repository.search(query: 'english 7'))!.first.slug, 'especie-7');
      // El filtro se aplica sobre el catálogo completo (125 peces)
      final fish = await repository.search(query: '', filter: (s) => s.category == 'fish');
      expect(fish!.length, 125);
    });

    test('un total exacto de páginas (300 = 3) no pide una cuarta', () async {
      remote = _FakeRemote(_species(300));
      await _runSync(build());

      expect(remote.requests.any((r) => r.endsWith(':4')), isFalse);
      expect(local.rows.length, 300);
    });
  });

  group('reanudado', () {
    test('si se interrumpe en la página 2, continúa ahí sin repetir la 1', () async {
      remote.failingPages.add(2);
      final first = build();

      await expectLater(first.sync().toList(), throwsA(anything));
      expect(local.sync.isComplete, isFalse);
      expect(local.sync.nextPage, 2);
      expect(first.isReady, isFalse);
      expect(await first.search(query: 'nombre'), isNull);

      // Otra apertura de la app: el servidor ya responde
      remote.failingPages.clear();
      remote.requests.clear();
      final second = build();
      final progress = await _runSync(second);

      expect(remote.requests.first, 'es:2');
      expect(remote.requests.contains('es:1'), isFalse);
      expect(progress.map((p) => p.step), [2, 3]);
      expect(second.isReady, isTrue);
      expect(local.rows.length, 250);
    });

    test('lo ya guardado de la página 1 sobrevive y la pasada es la misma', () async {
      remote.failingPages.add(2);
      await expectLater(build().sync().toList(), throwsA(anything));
      final runId = local.sync.runId;
      expect(local.rows.length, 100);

      remote.failingPages.clear();
      await _runSync(build());

      expect(local.sync.runId, runId);
      expect(local.rows.length, 250);
    });
  });

  group('actualización en segundo plano', () {
    test('al día no hace ninguna petición', () async {
      await _runSync(build());
      remote.requests.clear();

      now = now.add(CatalogConstants.refreshAfter - const Duration(hours: 1));
      final progress = await _runSync(build());

      expect(progress, isEmpty);
      expect(remote.requests, isEmpty);
    });

    test('pasado el plazo vuelve a bajar, reescribe solo lo que cambió y quita lo que desapareció', () async {
      final repository = build();
      await _runSync(repository);
      local.writes = 0;
      remote.requests.clear();

      // Cambia 1 especie y desaparecen las 10 últimas
      final changed = _species(240);
      changed[5] = Species(
        id: 'id-5',
        slug: 'especie-5',
        scientificName: 'Genus species5',
        commonName: 'Nombre nuevo',
        category: 'fish',
        updatedAt: 'v2-5',
      );
      remote.catalog = changed;
      now = now.add(CatalogConstants.refreshAfter + const Duration(days: 1));

      await _runSync(repository);

      expect(remote.requests.length, 6);
      expect(local.writes, 1);
      expect(local.rows.length, 240);
      final found = await repository.search(query: 'nombre nuevo');
      expect(found!.map((s) => s.slug), ['especie-5']);
      expect(local.sync.completedAt, now);
    });

    test('mientras actualiza, la búsqueda local sigue disponible', () async {
      final repository = build();
      await _runSync(repository);
      now = now.add(CatalogConstants.refreshAfter + const Duration(days: 1));

      final running = repository.sync().toList();
      expect(repository.isReady, isTrue);
      expect(await repository.search(query: 'nombre 3'), isNotEmpty);
      await running;
    });

    test('una apertura nueva carga el catálogo guardado con prepare()', () async {
      await _runSync(build());

      final reopened = build();
      expect(reopened.isReady, isFalse);
      expect(await reopened.prepare(), isTrue);
      expect(reopened.isReady, isTrue);
      expect((await reopened.search(query: ''))!.length, 250);
    });
  });

  group('relevancia', () {
    CatalogIndex index(List<(String, String, String?)> rows) => CatalogIndex([
      for (final (i, row) in rows.indexed)
        CatalogEntry(
          species: Species(
            id: '$i',
            slug: 's$i',
            scientificName: row.$2,
            commonName: row.$1,
            category: 'fish',
          ),
          nameEn: row.$3,
        ),
    ]);

    test('palabra completa antes que prefijo', () {
      final result = index([
        ('Tiburón ballena', 'A a', null),
        ('Tibur raro', 'B b', null),
        ('Tibur', 'C c', null),
      ]).search('tibur');

      expect(result.map((s) => s.slug), ['s2', 's1', 's0']);
    });

    test('nombre común antes que científico', () {
      final result = index([
        ('Otro', 'Cosa nostra', null),
        ('Cosa común', 'Nombre cientifico', null),
      ]).search('cosa');

      expect(result.map((s) => s.slug), ['s1', 's0']);
    });

    test('español antes que inglés', () {
      final result = index([
        ('Otro', 'A a', 'Shark'),
        ('Shark', 'B b', null),
      ]).search('shark');

      expect(result.map((s) => s.slug), ['s1', 's0']);
    });

    test('varias palabras en cualquier orden, todas obligatorias', () {
      final catalog = index([
        ('Tiburón toro', 'A a', null),
        ('Tiburón blanco', 'B b', null),
        ('Pez toro', 'C c', null),
      ]);

      expect(catalog.search('toro tiburon').map((s) => s.slug), ['s0']);
      expect(catalog.search('tiburon toro').map((s) => s.slug), ['s0']);
      expect(catalog.search('tiburon cebra'), isEmpty);
    });

    test('plurales y símbolos: alces, calamares, Indo-Pacífico', () {
      final catalog = index([
        ('Coral cuerno de alce', 'A a', null),
        ('Calamar común', 'B b', null),
        ('Sargento Indo-Pacífico (mar)', 'C c', null),
      ]);

      expect(catalog.search('alces').map((s) => s.slug), ['s0']);
      expect(catalog.search('calamares').map((s) => s.slug), ['s1']);
      expect(catalog.search('indo pacifico').map((s) => s.slug), ['s2']);
      expect(catalog.search('Indo-Pacífico').map((s) => s.slug), ['s2']);
    });

    test('un nombre sin coincidencias devuelve vacío (no hay nautilos en el catálogo)', () {
      final catalog = index([('Pez', 'A a', null)]);
      expect(catalog.search('nautilo'), isEmpty);
    });
  });
}

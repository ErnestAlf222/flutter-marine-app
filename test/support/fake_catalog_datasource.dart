import 'package:marine_app/domain/domain.dart';

// Base local en memoria con la misma semántica que la de Isar
class FakeCatalogDatasource implements CatalogDatasource {
  final rows = <String, FakeCatalogRow>{};
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
    for (int i = 0; i < items.length; i++) {
      final s = items[i];
      final row = rows.putIfAbsent(s.slug, FakeCatalogRow.new);
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

class FakeCatalogRow {
  Species? species;
  String? nameEn;
  int position = 0;
  int runId = 0;
}


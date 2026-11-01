import 'package:isar_community/isar.dart';

import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/datasources/isar_db.dart';
import 'package:marine_app/infrastructure/mappers/catalog_mapper.dart';
import 'package:marine_app/infrastructure/models/catalog_species_collection.dart';

class CatalogDatasourcesImpl implements CatalogDatasource {
  // Las páginas en español traen el listado completo; las demás, solo el nombre
  static const String _fullLang = 'es';

  @override
  Future<(List<CatalogEntry>?, String)> loadAll() async {
    try {
      final db = await IsarDb.open();
      final rows = await db.catalogSpeciesCollections
          .filter()
          .hasListingEqualTo(true)
          .sortByPosition()
          .findAll();
      return (rows.map(CatalogMapper.toEntry).toList(), '');
    } catch (_) {
      return (null, 'No se pudo leer el catálogo guardado.');
    }
  }

  @override
  Future<(bool?, String)> savePage(
    List<Species> items, {
    required String lang,
    required int firstPosition,
    required int runId,
  }) async {
    try {
      final db = await IsarDb.open();
      await db.writeTxn(() async {
        final table = db.catalogSpeciesCollections;

        for (var i = 0; i < items.length; i++) {
          final s = items[i];
          final existing = await table.getBySlug(s.slug);

          if (lang != _fullLang) {
            final row = existing ?? CatalogMapper.stub(s.slug, runId);
            await table.put(CatalogMapper.applyEnglishName(row, s, runId));
            continue;
          }

          final position = firstPosition + i;
          final unchanged =
              existing != null &&
              existing.hasListing &&
              s.updatedAt != null &&
              existing.updatedAt == s.updatedAt;

          if (unchanged) {
            // Sin cambios en la API: solo se anota que se vio en esta pasada
            if (existing.runId != runId || existing.position != position) {
              existing
                ..runId = runId
                ..position = position;
              await table.put(existing);
            }
            continue;
          }

          final row = existing ?? CatalogMapper.stub(s.slug, runId);
          await table.put(
            CatalogMapper.applyListing(row, s, position: position, runId: runId),
          );
        }
      });
      return (true, '');
    } catch (_) {
      return (null, 'No se pudo guardar el catálogo.');
    }
  }

  @override
  Future<(int?, String)> removeStale(int runId) async {
    try {
      final db = await IsarDb.open();
      final removed = await db.writeTxn(
        () => db.catalogSpeciesCollections.filter().not().runIdEqualTo(runId).deleteAll(),
      );
      return (removed, '');
    } catch (_) {
      return (null, 'No se pudo limpiar el catálogo.');
    }
  }

  @override
  Future<(CatalogSyncState?, String)> readSync() async {
    try {
      final db = await IsarDb.open();
      final row = await db.catalogSyncCollections.get(0);
      if (row == null) return (const CatalogSyncState(), '');

      return (
        CatalogSyncState(
          nextPage: row.nextPage,
          totalPages: row.totalPages,
          runId: row.runId,
          completedAt: row.completedAt,
        ),
        '',
      );
    } catch (_) {
      return (null, 'No se pudo leer el avance del catálogo.');
    }
  }

  @override
  Future<(bool?, String)> writeSync(CatalogSyncState state) async {
    try {
      final db = await IsarDb.open();
      await db.writeTxn(
        () => db.catalogSyncCollections.put(
          CatalogSyncCollection()
            ..id = 0
            ..nextPage = state.nextPage
            ..totalPages = state.totalPages
            ..runId = state.runId
            ..completedAt = state.completedAt,
        ),
      );
      return (true, '');
    } catch (_) {
      return (null, 'No se pudo guardar el avance del catálogo.');
    }
  }
}

import 'dart:convert';

import 'package:isar_community/isar.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/cache/eviction.dart';
import 'package:marine_app/infrastructure/datasources/isar_db.dart';
import 'package:marine_app/infrastructure/mappers/cache_mapper.dart';
import 'package:marine_app/infrastructure/models/detail_cache_collection.dart';
import 'package:marine_app/infrastructure/models/favorite_species_collection.dart';

class OfflineCacheDatasourceImpl implements OfflineCacheDatasource {
  Future<Isar> _db() => IsarDb.open();

  @override
  Future<SpeciesDetail?> detail(String slug) async {
    try {
      final db = await _db();
      final favorite = await db.favoriteSpeciesCollections.getBySlug(slug);
      final favoriteJson = favorite?.detailJson;
      if (favoriteJson != null) return CacheMapper.detailFromJson(favoriteJson);

      final row = await db.detailCacheCollections.getBySlug(slug);
      return row == null ? null : CacheMapper.detailFromJson(row.json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveDetail(SpeciesDetail detail, {required int limit}) async {
    try {
      final db = await _db();
      final json = CacheMapper.detailToJson(detail);

      await db.writeTxn(() async {
        await db.detailCacheCollections.put(
          DetailCacheCollection()
            ..slug = detail.slug
            ..json = json
            ..viewedAt = DateTime.now(),
        );

        // Si ya es favorito se refresca también su ficha
        final favorite = await db.favoriteSpeciesCollections.getBySlug(
          detail.slug,
        );
        if (favorite != null) {
          favorite.detailJson = json;
          await db.favoriteSpeciesCollections.put(favorite);
        }

        final rows = await db.detailCacheCollections.where().findAll();
        final favorites =
            (await db.favoriteSpeciesCollections.where().findAll())
                .map((f) => f.slug)
                .toSet();
        final evict = slugsToEvict(
          rows: [for (final r in rows) (r.slug, r.viewedAt)],
          favorites: favorites,
          limit: limit,
        );
        await db.detailCacheCollections.deleteAllBySlug(evict);
      });
    } catch (_) {
      // Guardar es una ayuda: si falla, la pantalla sigue con lo que ya tiene
    }
  }

  @override
  Future<bool> saveFavoriteDetail(SpeciesDetail detail) async {
    try {
      final db = await _db();
      return await db.writeTxn(() async {
        final favorite = await db.favoriteSpeciesCollections.getBySlug(
          detail.slug,
        );
        if (favorite == null) return false;
        favorite.detailJson = CacheMapper.detailToJson(detail);
        await db.favoriteSpeciesCollections.put(favorite);
        return true;
      });
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> favoritesWithoutDetail() async {
    try {
      final db = await _db();
      final rows = await db.favoriteSpeciesCollections
          .filter()
          .detailJsonIsNull()
          .findAll();
      return [for (final r in rows) r.slug];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<String>> favoritePhotoUrls() async {
    try {
      final db = await _db();
      final urls = <String>{};
      for (final f in await db.favoriteSpeciesCollections.where().findAll()) {
        final photo = f.primaryPhoto;
        if (photo != null) urls.add(photo);
        final json = f.detailJson;
        if (json != null) {
          urls.addAll(
            CacheMapper.detailFromJson(json).photos.map((p) => p.url),
          );
        }
      }
      return urls.toList();
    } catch (_) {
      return const [];
    }
  }

  Future<String?> _read(String key) async {
    try {
      final db = await _db();
      return (await db.jsonCacheCollections.getByKey(key))?.json;
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, String json) async {
    try {
      final db = await _db();
      await db.writeTxn(
        () => db.jsonCacheCollections.put(
          JsonCacheCollection()
            ..key = key
            ..json = json
            ..savedAt = DateTime.now(),
        ),
      );
    } catch (_) {
      // Ver saveDetail
    }
  }

  @override
  Future<List<Species>?> featured() async {
    final json = await _read(OfflineConstants.featuredKey);
    try {
      return json == null ? null : CacheMapper.speciesListFromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveFeatured(List<Species> species) => _write(
    OfflineConstants.featuredKey,
    CacheMapper.speciesListToJson(species),
  );

  @override
  Future<List<String>> heroSlugs() async {
    final json = await _read(OfflineConstants.heroSlugsKey);
    try {
      return json == null
          ? const []
          : [for (final slug in jsonDecode(json) as List) slug as String];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveHeroSlugs(List<String> slugs) =>
      _write(OfflineConstants.heroSlugsKey, jsonEncode(slugs));

  @override
  Future<List<OceanZone>?> zones() async {
    final json = await _read(OfflineConstants.zonesKey);
    try {
      return json == null ? null : CacheMapper.zonesFromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveZones(List<OceanZone> zones) =>
      _write(OfflineConstants.zonesKey, CacheMapper.zonesToJson(zones));
}

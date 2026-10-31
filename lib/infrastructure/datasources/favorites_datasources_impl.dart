import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/mappers/favorite_mapper.dart';
import 'package:marine_app/infrastructure/models/favorite_species_collection.dart';

class FavoritesDatasourcesImpl implements FavoritesDatasource {
  // Isar no admite abrir dos veces la misma base: una instancia compartida por toda la app
  static Future<Isar>? _instance;

  Future<Isar> _db() {
    return _instance ??= _open().catchError((Object e) {
      // Si falló, el siguiente intento vuelve a abrir en lugar de repetir el error
      _instance = null;
      throw e;
    });
  }

  static Future<Isar> _open() async {
    final existing = Isar.getInstance();
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    return Isar.open([FavoriteSpeciesCollectionSchema], directory: dir.path);
  }

  @override
  Future<(bool?, String)> saveFavorite(Species species) async {
    try {
      final db = await _db();
      await db.writeTxn(
        () => db.favoriteSpeciesCollections.put(
          FavoriteMapper.toCollection(species),
        ),
      );
      return (true, '');
    } catch (_) {
      return (null, 'No se pudo guardar el favorito.');
    }
  }

  @override
  Future<(bool?, String)> removeFavorite(String slug) async {
    try {
      final db = await _db();
      final removed = await db.writeTxn(
        () => db.favoriteSpeciesCollections.deleteBySlug(slug),
      );
      return (removed, '');
    } catch (_) {
      return (null, 'No se pudo quitar el favorito.');
    }
  }

  @override
  Future<(bool?, String)> isFavorite(String slug) async {
    try {
      final db = await _db();
      final found = await db.favoriteSpeciesCollections.getBySlug(slug);
      return (found != null, '');
    } catch (_) {
      return (null, 'No se pudo leer tus favoritos.');
    }
  }

  @override
  Stream<List<Species>> watchFavorites() async* {
    final db = await _db();
    yield* db.favoriteSpeciesCollections
        .where()
        .sortBySavedAtDesc()
        .watch(fireImmediately: true)
        .map((rows) => rows.map(FavoriteMapper.toEntity).toList());
  }
}

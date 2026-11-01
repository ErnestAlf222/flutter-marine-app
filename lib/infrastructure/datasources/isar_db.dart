import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:marine_app/infrastructure/models/catalog_species_collection.dart';
import 'package:marine_app/infrastructure/models/favorite_species_collection.dart';

/// La base local de la app. Isar no admite abrir dos veces la misma base, así que
/// favoritos y catálogo comparten esta instancia.
class IsarDb {
  static Future<Isar>? _instance;

  static Future<Isar> open() {
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
    return Isar.open(
      [
        FavoriteSpeciesCollectionSchema,
        CatalogSpeciesCollectionSchema,
        CatalogSyncCollectionSchema,
      ],
      directory: dir.path,
    );
  }
}

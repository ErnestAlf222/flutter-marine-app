import 'package:marine_app/domain/entities/catalog.dart';
import 'package:marine_app/domain/entities/species.dart';

// Catálogo guardado en el dispositivo. Cada método devuelve (dato, mensaje) como el resto
// de datasources.
abstract class CatalogDatasource {
  /// Todas las especies con su listado completo, en el orden del servidor
  Future<(List<CatalogEntry>?, String)> loadAll();

  /// Guarda una página. En español trae todos los campos; en inglés solo el nombre.
  /// [firstPosition] es el lugar de la primera especie en el orden del servidor y [runId]
  /// marca la pasada en que se vio. Lo que no cambió en `updated_at` no se reescribe.
  Future<(bool?, String)> savePage(
    List<Species> items, {
    required String lang,
    required int firstPosition,
    required int runId,
  });

  /// Borra lo que no se vio en la pasada [runId]; devuelve cuántas filas quitó
  Future<(int?, String)> removeStale(int runId);

  Future<(CatalogSyncState?, String)> readSync();

  Future<(bool?, String)> writeSync(CatalogSyncState state);
}

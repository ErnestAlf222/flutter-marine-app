import 'package:marine_app/domain/entities/catalog.dart';
import 'package:marine_app/domain/entities/species.dart';

abstract class CatalogRepository {
  /// Ya hay un catálogo completo en memoria para buscar
  bool get isReady;

  /// Carga el catálogo guardado en memoria. Devuelve si está completo y listo para buscar.
  Future<bool> prepare();

  /// Baja el catálogo (primera vez, continuación o actualización) y emite el avance. No hace
  /// nada si ya está al día. Con baja prioridad: cede el paso a lo que ve el usuario.
  Stream<CatalogProgress> sync();

  /// Busca en el catálogo local: sin acentos ni mayúsculas, con plurales y varias palabras
  /// en cualquier orden, por relevancia. Sin texto devuelve todo en el orden del servidor.
  /// [filter] aplica los filtros de Explorar. Devuelve null si el catálogo aún no está listo,
  /// y entonces quien llama usa el servidor.
  Future<List<Species>?> search({required String query, bool Function(Species)? filter});
}

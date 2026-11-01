import 'package:marine_app/domain/entities/species.dart';

/// Una especie del catálogo local: el listado en español más su nombre en inglés, que se
/// usa para buscar (la búsqueda del servidor también encuentra por nombres en otros idiomas).
class CatalogEntry {
  final Species species;
  final String? nameEn;

  const CatalogEntry({required this.species, this.nameEn});
}

/// Dónde va la sincronización del catálogo. `nextPage` permite continuar si se interrumpe;
/// `completedAt` solo existe cuando el catálogo ya se bajó entero al menos una vez.
class CatalogSyncState {
  final int nextPage;
  final int totalPages;
  // Identifica la pasada en curso: lo que no se vio en ella ya no existe en el servidor
  final int runId;
  final DateTime? completedAt;

  const CatalogSyncState({
    this.nextPage = 1,
    this.totalPages = 0,
    this.runId = 0,
    this.completedAt,
  });

  bool get isComplete => completedAt != null;

  /// Hay una pasada a medias (primera sincronización o actualización interrumpida)
  bool get isInProgress => nextPage > 1;

  CatalogSyncState copyWith({
    int? nextPage,
    int? totalPages,
    int? runId,
    DateTime? completedAt,
  }) => CatalogSyncState(
    nextPage: nextPage ?? this.nextPage,
    totalPages: totalPages ?? this.totalPages,
    runId: runId ?? this.runId,
    completedAt: completedAt ?? this.completedAt,
  );
}

/// Avance de la sincronización: "[step] de [total]" páginas
class CatalogProgress {
  final int step;
  final int total;

  const CatalogProgress(this.step, this.total);
}

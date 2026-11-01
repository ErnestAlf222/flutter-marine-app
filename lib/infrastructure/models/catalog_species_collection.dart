import 'package:isar_community/isar.dart';

part 'catalog_species_collection.g.dart';

// Fila del catálogo local: el listado de una especie con sus nombres normalizados
@collection
class CatalogSpeciesCollection {
  Id id = Isar.autoIncrement;

  // Único con reemplazo: guardar dos veces la misma especie no la duplica
  @Index(unique: true, replace: true)
  late String slug;

  // Lugar en el orden del servidor, para mostrar el catálogo sin buscar en ese orden
  late int position;

  // Pasada de sincronización en que se vio por última vez
  late int runId;

  // La fila nace con el nombre en inglés (página en) o con el listado (página es): solo
  // las que ya tienen el listado completo forman parte del catálogo
  late bool hasListing;

  late String speciesId;
  late String scientificName;
  late String commonName;
  String? nameEn;

  // Los tres nombres sin acentos ni mayúsculas
  late String foldedEs;
  late String foldedEn;
  late String foldedScientific;

  late String category;
  String? conservationStatus;
  String? dangerLevel;
  double? sizeMinCm;
  double? sizeMaxCm;
  double? depthMinM;
  double? depthMaxM;
  late List<String> habitats;
  late List<String> behaviors;
  String? primaryPhoto;
  late bool featured;
  String? updatedAt;
}

// Una sola fila (id 0) con el avance de la sincronización
@collection
class CatalogSyncCollection {
  Id id = 0;

  late int nextPage;
  late int totalPages;
  late int runId;
  DateTime? completedAt;
}

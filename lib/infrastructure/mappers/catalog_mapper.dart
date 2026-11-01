import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/models/catalog_species_collection.dart';

class CatalogMapper {
  // Fila vacía para una especie de la que solo llegó (aún) el nombre en inglés
  static CatalogSpeciesCollection stub(String slug, int runId) =>
      CatalogSpeciesCollection()
        ..slug = slug
        ..position = 0
        ..runId = runId
        ..hasListing = false
        ..speciesId = ''
        ..scientificName = ''
        ..commonName = ''
        ..foldedEs = ''
        ..foldedEn = ''
        ..foldedScientific = ''
        ..category = ''
        ..habitats = []
        ..behaviors = []
        ..featured = false;

  /// Copia el listado en español sobre [row] (que conserva su nombre en inglés)
  static CatalogSpeciesCollection applyListing(
    CatalogSpeciesCollection row,
    Species s, {
    required int position,
    required int runId,
  }) {
    return row
      ..slug = s.slug
      ..position = position
      ..runId = runId
      ..hasListing = true
      ..speciesId = s.id
      ..scientificName = s.scientificName
      ..commonName = s.commonName
      ..foldedEs = TextUtils.fold(s.commonName)
      ..foldedScientific = TextUtils.fold(s.scientificName)
      ..category = s.category
      ..conservationStatus = s.conservationStatus
      ..dangerLevel = s.dangerLevel
      ..sizeMinCm = s.sizeMinCm
      ..sizeMaxCm = s.sizeMaxCm
      ..depthMinM = s.depthMinM
      ..depthMaxM = s.depthMaxM
      ..habitats = s.habitats
      ..behaviors = s.behaviors
      ..primaryPhoto = s.primaryPhoto
      ..featured = s.featured
      ..updatedAt = s.updatedAt;
  }

  static CatalogSpeciesCollection applyEnglishName(
    CatalogSpeciesCollection row,
    Species s,
    int runId,
  ) {
    return row
      ..nameEn = s.commonName
      ..foldedEn = TextUtils.fold(s.commonName)
      ..runId = runId;
  }

  static CatalogEntry toEntry(CatalogSpeciesCollection c) => CatalogEntry(
    nameEn: c.nameEn,
    species: Species(
      id: c.speciesId,
      slug: c.slug,
      scientificName: c.scientificName,
      commonName: c.commonName,
      category: c.category,
      conservationStatus: c.conservationStatus,
      dangerLevel: c.dangerLevel,
      sizeMinCm: c.sizeMinCm,
      sizeMaxCm: c.sizeMaxCm,
      depthMinM: c.depthMinM,
      depthMaxM: c.depthMaxM,
      habitats: c.habitats,
      behaviors: c.behaviors,
      primaryPhoto: c.primaryPhoto,
      featured: c.featured,
      updatedAt: c.updatedAt,
    ),
  );
}

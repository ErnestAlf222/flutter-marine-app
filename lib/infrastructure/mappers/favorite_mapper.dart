import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/models/favorite_species_collection.dart';

class FavoriteMapper {
  static FavoriteSpeciesCollection toCollection(Species s) =>
      FavoriteSpeciesCollection()
        ..slug = s.slug
        ..speciesId = s.id
        ..scientificName = s.scientificName
        ..commonName = s.commonName
        ..category = s.category
        ..conservationStatus = s.conservationStatus
        ..primaryPhoto = s.primaryPhoto
        ..savedAt = DateTime.now();

  // Los campos que la copia no guarda quedan vacíos; la cuadrícula no los usa
  static Species toEntity(FavoriteSpeciesCollection c) => Species(
    id: c.speciesId,
    slug: c.slug,
    scientificName: c.scientificName,
    commonName: c.commonName,
    category: c.category,
    conservationStatus: c.conservationStatus,
    primaryPhoto: c.primaryPhoto,
  );
}

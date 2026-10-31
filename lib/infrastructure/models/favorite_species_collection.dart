import 'package:isar_community/isar.dart';

part 'favorite_species_collection.g.dart';

// Copia mínima de la especie: basta para pintar la cuadrícula sin red
@collection
class FavoriteSpeciesCollection {
  Id id = Isar.autoIncrement;

  // Único con reemplazo: guardar dos veces la misma especie no la duplica
  @Index(unique: true, replace: true)
  late String slug;

  late String speciesId;
  late String scientificName;
  late String commonName;
  late String category;
  String? conservationStatus;
  String? primaryPhoto;

  // Define el orden de la cuadrícula: la más reciente primero
  late DateTime savedAt;
}

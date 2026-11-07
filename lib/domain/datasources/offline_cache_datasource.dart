import 'package:marine_app/domain/entities/ocean_zone.dart';
import 'package:marine_app/domain/entities/species.dart';
import 'package:marine_app/domain/entities/species_detail.dart';

// Lo que se guarda en el dispositivo para verlo sin conexión. Guardar es una ayuda: nunca
// debe romper la pantalla, así que los fallos se tragan (leer devuelve null, guardar no hace nada).
abstract class OfflineCacheDatasource {
  /// Detalle guardado: primero el de los favoritos, luego el de los últimos vistos
  Future<SpeciesDetail?> detail(String slug);

  /// Guarda un detalle visto (expulsando los más viejos que no sean favoritos) y, si es
  /// favorito, actualiza también su ficha
  Future<void> saveDetail(SpeciesDetail detail, {required int limit});

  /// Guarda la ficha completa de un favorito; devuelve false si ya no es favorito
  Future<bool> saveFavoriteDetail(SpeciesDetail detail);

  /// Slugs de favoritos que todavía no tienen ficha guardada
  Future<List<String>> favoritesWithoutDetail();

  /// Fotos (tarjeta y galería) de todos los favoritos
  Future<List<String>> favoritePhotoUrls();

  Future<List<Species>?> featured();
  Future<void> saveFeatured(List<Species> species);

  /// Slugs de las destacadas del héroe en el arranque anterior (vacío si no hay)
  Future<List<String>> heroSlugs();
  Future<void> saveHeroSlugs(List<String> slugs);

  Future<List<OceanZone>?> zones();
  Future<void> saveZones(List<OceanZone> zones);
}

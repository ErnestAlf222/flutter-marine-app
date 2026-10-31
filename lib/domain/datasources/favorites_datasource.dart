import 'package:marine_app/domain/entities/species.dart';

abstract class FavoritesDatasource {
  Future<(bool?, String)> saveFavorite(Species species);

  Future<(bool?, String)> removeFavorite(String slug);

  Future<(bool?, String)> isFavorite(String slug);

  // Se emite de nuevo con cada cambio; ordenada por savedAt descendente
  Stream<List<Species>> watchFavorites();
}

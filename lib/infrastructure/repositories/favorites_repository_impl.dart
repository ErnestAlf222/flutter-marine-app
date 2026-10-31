import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/datasources/favorites_datasources_impl.dart';

class FavoritesRepositoryImpl extends FavoritesRepository {
  final FavoritesDatasource datasource;

  // Sin datasource inyectado se usa el de Isar, como en la referencia
  FavoritesRepositoryImpl({FavoritesDatasource? datasource})
    : datasource = datasource ?? FavoritesDatasourcesImpl();

  @override
  Future<(bool?, String)> saveFavorite(Species species) =>
      datasource.saveFavorite(species);

  @override
  Future<(bool?, String)> removeFavorite(String slug) =>
      datasource.removeFavorite(slug);

  @override
  Future<(bool?, String)> isFavorite(String slug) =>
      datasource.isFavorite(slug);

  @override
  Stream<List<Species>> watchFavorites() => datasource.watchFavorites();
}

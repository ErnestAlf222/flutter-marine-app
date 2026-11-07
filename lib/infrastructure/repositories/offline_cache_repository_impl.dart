import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/datasources/offline_cache_datasource_impl.dart';

class OfflineCacheRepositoryImpl extends OfflineCacheRepository {
  final OfflineCacheDatasource datasource;

  OfflineCacheRepositoryImpl({OfflineCacheDatasource? datasource})
    : datasource = datasource ?? OfflineCacheDatasourceImpl();

  @override
  Future<SpeciesDetail?> detail(String slug) => datasource.detail(slug);

  @override
  Future<void> saveDetail(SpeciesDetail detail, {required int limit}) =>
      datasource.saveDetail(detail, limit: limit);

  @override
  Future<bool> saveFavoriteDetail(SpeciesDetail detail) =>
      datasource.saveFavoriteDetail(detail);

  @override
  Future<List<String>> favoritesWithoutDetail() =>
      datasource.favoritesWithoutDetail();

  @override
  Future<List<String>> favoritePhotoUrls() => datasource.favoritePhotoUrls();

  @override
  Future<List<Species>?> featured() => datasource.featured();

  @override
  Future<void> saveFeatured(List<Species> species) =>
      datasource.saveFeatured(species);

  @override
  Future<List<String>> heroSlugs() => datasource.heroSlugs();

  @override
  Future<void> saveHeroSlugs(List<String> slugs) =>
      datasource.saveHeroSlugs(slugs);

  @override
  Future<List<OceanZone>?> zones() => datasource.zones();

  @override
  Future<void> saveZones(List<OceanZone> zones) => datasource.saveZones(zones);
}

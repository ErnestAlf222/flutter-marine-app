import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';
import 'package:marine_app/presentation/provider/providers.dart';

// Lo guardado en memoria: mismas reglas que Isar (límite y favoritos a salvo) sin base de datos
class InMemoryOfflineCache extends OfflineCacheRepository {
  final Map<String, SpeciesDetail> seen = {};
  final Map<String, DateTime> viewedAt = {};
  // Ficha completa de cada favorito (null = favorito sin ficha todavía)
  final Map<String, SpeciesDetail?> favorites = {};
  List<Species>? featuredList;
  List<String> heroList = [];
  List<OceanZone>? zoneList;
  int _clock = 0;

  // Reloj propio: dos guardados seguidos no comparten fecha
  DateTime _tick() => DateTime(2026).add(Duration(seconds: _clock++));

  @override
  Future<SpeciesDetail?> detail(String slug) async => favorites[slug] ?? seen[slug];

  @override
  Future<void> saveDetail(SpeciesDetail detail, {required int limit}) async {
    seen[detail.slug] = detail;
    viewedAt[detail.slug] = _tick();
    if (favorites.containsKey(detail.slug)) favorites[detail.slug] = detail;

    final evict = slugsToEvict(
      rows: [for (final e in viewedAt.entries) (e.key, e.value)],
      favorites: favorites.keys.toSet(),
      limit: limit,
    );
    for (final slug in evict) {
      seen.remove(slug);
      viewedAt.remove(slug);
    }
  }

  @override
  Future<bool> saveFavoriteDetail(SpeciesDetail detail) async {
    if (!favorites.containsKey(detail.slug)) return false;
    favorites[detail.slug] = detail;
    return true;
  }

  @override
  Future<List<String>> favoritesWithoutDetail() async => [
    for (final e in favorites.entries)
      if (e.value == null) e.key,
  ];

  @override
  Future<List<String>> favoritePhotoUrls() async => [
    for (final d in favorites.values)
      if (d != null) ...d.photos.map((p) => p.url),
  ];

  @override
  Future<List<Species>?> featured() async => featuredList;

  @override
  Future<void> saveFeatured(List<Species> species) async => featuredList = species;

  @override
  Future<List<String>> heroSlugs() async => heroList;

  @override
  Future<void> saveHeroSlugs(List<String> slugs) async => heroList = slugs;

  @override
  Future<List<OceanZone>?> zones() async => zoneList;

  @override
  Future<void> saveZones(List<OceanZone> zones) async => zoneList = zones;
}

// Catálogo local falso: con [ready] responde con [items] en su orden; sin él, como si no existiera
class FakeCatalogRepository extends CatalogRepository {
  final List<Species> items;
  final bool ready;
  int searches = 0;

  FakeCatalogRepository({this.items = const [], this.ready = false});

  @override
  bool get isReady => ready;

  @override
  Future<bool> prepare() async => ready;

  @override
  Stream<CatalogProgress> sync() => const Stream.empty();

  @override
  Future<List<Species>?> search({required String query, bool Function(Species)? filter}) async {
    searches++;
    if (!ready) return null;
    return [
      for (final s in items)
        if (filter == null || filter(s)) s,
    ];
  }
}

// Conexión falsa: el estado cambia cuando la prueba lo dice
class FakeConnectivity extends ConnectivityRepository {
  bool online;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  FakeConnectivity({this.online = true});

  void set(bool value) {
    online = value;
    _changes.add(value);
  }

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> watchOnline() => _changes.stream;
}

/// Lo que cada prueba que monta pantallas necesita: nada de Isar ni de plugins, y el pez
/// de la primera carga sin espera
List<Override> offlineOverrides({
  OfflineCacheRepository? cache,
  ConnectivityRepository? connectivity,
  CatalogRepository? catalog,
}) => [
  // Sin catálogo listo por defecto: Inicio sigue con la lista guardada o el servidor
  catalogRepositoryProvider.overrideWithValue(catalog ?? FakeCatalogRepository()),
  offlineCacheRepositoryProvider.overrideWithValue(cache ?? InMemoryOfflineCache()),
  connectivityRepositoryProvider.overrideWithValue(connectivity ?? FakeConnectivity()),
  firstLoadMinimumProvider.overrideWithValue(Duration.zero),
];

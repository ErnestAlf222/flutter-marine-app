import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';
import 'package:marine_app/presentation/provider/offline/offline_provider.dart';
import 'package:marine_app/presentation/provider/species/species_provider.dart';

// Único punto donde presentation conoce el repositorio impl de favoritos
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl();
});

// La base local es la única fuente: la cuadrícula y los corazones salen de esta lista
final favoritesProvider = StreamProvider<List<Species>>((ref) {
  return ref.watch(favoritesRepositoryProvider).watchFavorites().map((items) {
    // Sus fotos se leen de la caché propia, que no las expulsa por las demás
    FavoritePhotoCache.register([
      for (final s in items)
        if (s.primaryPhoto != null) s.primaryPhoto!,
    ]);
    return items;
  });
});

// Estado de una especie, derivado de la misma lista para que nunca se desincronice
final isFavoriteProvider = Provider.family<bool, String>((ref, slug) {
  final favorites = ref.watch(favoritesProvider).asData?.value ?? const [];
  return favorites.any((s) => s.slug == slug);
});

final favoriteActionsProvider = Provider<FavoriteActions>((ref) {
  return FavoriteActions(
    ref.watch(favoritesRepositoryProvider),
    // Perezoso: solo se necesita si hay que descargar la ficha de un favorito
    () => ref.read(speciesRepositoryProvider),
    ref.watch(offlineCacheRepositoryProvider),
  );
});

class FavoriteActions {
  final FavoritesRepository _repository;
  final SpeciesRepository Function() _species;
  final OfflineCacheRepository _cache;

  const FavoriteActions(this._repository, this._species, this._cache);

  /// Devuelve el mensaje de error, o null si salió bien
  Future<String?> add(Species species) async {
    final (ok, error) = await _repository.saveFavorite(species);
    if (ok == null) return error;

    // La ficha completa y las fotos se guardan sin hacer esperar al usuario
    unawaited(_storeOffline(species));
    return null;
  }

  // Ficha completa: la que ya está cargada o la guardada de los últimos vistos; si no, se
  // descarga con baja prioridad. Sin red queda pendiente: la migración la completa después.
  Future<void> _storeOffline(Species species) async {
    try {
      await _storeOfflineUnsafe(species);
    } catch (_) {
      // Es una ayuda: si falla queda pendiente y la migración lo completa
    }
  }

  Future<void> _storeOfflineUnsafe(Species species) async {
    final photo = species.primaryPhoto;
    if (photo != null) unawaited(FavoritePhotoCache.download([photo]));

    SpeciesDetail? detail = species is SpeciesDetail ? species : null;
    detail ??= await _cache.detail(species.slug);
    detail ??= await RequestPriority.runLow(() async {
      final (fetched, _) = await _species().getSpeciesBySlug(
        slug: species.slug,
        lang: ApiConstants.appLang,
      );
      return fetched;
    });
    if (detail == null) return;

    if (await _cache.saveFavoriteDetail(detail)) {
      await FavoritePhotoCache.download([
        if (detail.primaryPhoto != null) detail.primaryPhoto!,
        for (final p in detail.photos) p.url,
      ]);
    }
  }

  Future<String?> remove(String slug) async {
    // Sus fotos salen de la caché de favoritos: ya nada las protege
    final saved = await _cache.detail(slug);
    final photos = [
      if (saved?.primaryPhoto != null) saved!.primaryPhoto!,
      for (final p in saved?.photos ?? const <SpeciesPhoto>[]) p.url,
    ];

    final (ok, error) = await _repository.removeFavorite(slug);
    if (ok == null) return error;

    FavoritePhotoCache.unregister(photos);
    for (final url in photos) {
      unawaited(
        FavoritePhotoCache.manager.removeFile(url).catchError((Object _) {}),
      );
    }
    return null;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';

// Único punto donde presentation conoce el repositorio impl de favoritos
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl();
});

// La base local es la única fuente: la cuadrícula y los corazones salen de esta lista
final favoritesProvider = StreamProvider<List<Species>>((ref) {
  return ref.watch(favoritesRepositoryProvider).watchFavorites();
});

// Estado de una especie, derivado de la misma lista para que nunca se desincronice
final isFavoriteProvider = Provider.family<bool, String>((ref, slug) {
  final favorites = ref.watch(favoritesProvider).asData?.value ?? const [];
  return favorites.any((s) => s.slug == slug);
});

final favoriteActionsProvider = Provider<FavoriteActions>((ref) {
  return FavoriteActions(ref.watch(favoritesRepositoryProvider));
});

class FavoriteActions {
  final FavoritesRepository _repository;

  const FavoriteActions(this._repository);

  /// Devuelve el mensaje de error, o null si salió bien
  Future<String?> add(Species species) async {
    final (ok, error) = await _repository.saveFavorite(species);
    return ok == null ? error : null;
  }

  Future<String?> remove(String slug) async {
    final (ok, error) = await _repository.removeFavorite(slug);
    return ok == null ? error : null;
  }
}

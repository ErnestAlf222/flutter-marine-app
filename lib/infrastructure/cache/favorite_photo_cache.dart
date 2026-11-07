import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:marine_app/config/config.dart';

/// Caché propia de las fotos de favoritos. La de por defecto de cached_network_image guarda
/// 200 fotos y 30 días y expulsa por menos usada, así que las fotos de un favorito podían
/// perderse al navegar; esta tiene un límite muy alto y solo recibe fotos de favoritos.
class FavoritePhotoCache {
  static final CacheManager manager = CacheManager(
    Config(
      OfflineConstants.favoritePhotoCacheKey,
      stalePeriod: OfflineConstants.favoritePhotoStale,
      maxNrOfCacheObjects: OfflineConstants.favoritePhotoMaxObjects,
    ),
  );

  // URLs que ya son de favoritos: las fotos que las usan se leen de esta caché
  static final Set<String> _urls = <String>{};

  static bool contains(String url) => _urls.contains(url);

  static void register(Iterable<String> urls) => _urls.addAll(urls);

  static void unregister(Iterable<String> urls) => _urls.removeAll(urls);

  /// Descarga las fotos a la caché de favoritos (las que ya están no se piden otra vez),
  /// de pocas en pocas y sin lanzar errores: sin red quedan para otra vez.
  static Future<void> download(Iterable<String> urls) async {
    register(urls);
    final pending = urls.toList();
    int next = 0;

    Future<void> worker() async {
      while (next < pending.length) {
        final url = pending[next++];
        try {
          await manager.getSingleFile(url);
        } catch (_) {
          // Sin red o foto rota: se reintenta en la próxima apertura o al volver la conexión
        }
      }
    }

    await Future.wait([
      for (int i = 0; i < OfflineConstants.photoPrefetchConcurrency; i++)
        worker(),
    ]);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';
import 'package:marine_app/presentation/provider/species/species_provider.dart';

// Único punto donde presentation conoce los repositorios de conexión y de lo guardado
final connectivityRepositoryProvider = Provider<ConnectivityRepository>((ref) {
  return ConnectivityRepositoryImpl();
});

final offlineCacheRepositoryProvider = Provider<OfflineCacheRepository>((ref) {
  return OfflineCacheRepositoryImpl();
});

/// Hay red ahora; emite cada cambio. Es la red del dispositivo, no del servidor: un 5xx con
/// red sigue siendo "servidor con problemas".
final onlineProvider = StreamProvider<bool>((ref) async* {
  final repository = ref.watch(connectivityRepositoryProvider);
  yield await repository.isOnline();
  yield* repository.watchOnline();
});

/// Contenido guardado que se está mostrando en lugar del de la red; con el dispositivo sin
/// conexión, la franja "mostrando lo guardado" depende de que haya alguno
class SavedContentNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void mark(String source) {
    if (!state.contains(source)) state = {...state, source};
  }

  void clear() {
    if (state.isNotEmpty) state = <String>{};
  }
}

final savedContentProvider =
    NotifierProvider<SavedContentNotifier, Set<String>>(
      SavedContentNotifier.new,
    );

/// La franja se ve solo sin conexión y con algo guardado en pantalla
final showSavedStripProvider = Provider<bool>((ref) {
  final online = ref.watch(onlineProvider).asData?.value ?? true;
  return !online && ref.watch(savedContentProvider).isNotEmpty;
});

/// Providers que terminaron en error y qué hacer para recargarlos. Al volver la conexión
/// se recargan solo ellos: los que tienen datos no se tocan.
class ReconnectRegistry {
  final Map<Object, void Function()> _failed = <Object, void Function()>{};

  int get length => _failed.length;

  void track(Ref ref) {
    final key = Object();
    _failed[key] = ref.invalidateSelf;
    // Si el provider se recarga o se libera antes, ya no hay nada que reintentar
    ref.onDispose(() => _failed.remove(key));
  }

  void retryAll() {
    final retries = [..._failed.values];
    _failed.clear();
    for (final retry in retries) {
      retry();
    }
  }
}

final reconnectRegistryProvider = Provider<ReconnectRegistry>(
  (ref) => ReconnectRegistry(),
);

/// Ejecuta [run]; si falla, anota al provider para recargarlo al volver la conexión
Future<T> trackFailure<T>(Ref ref, Future<T> Function() run) async {
  try {
    return await run();
  } catch (_) {
    if (ref.mounted) ref.read(reconnectRegistryProvider).track(ref);
    rethrow;
  }
}

/// Cuántas veces volvió la conexión: el Shell lo escucha para mostrar "De vuelta en línea"
class BackOnlineNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void announce() => state++;
}

final backOnlineProvider = NotifierProvider<BackOnlineNotifier, int>(
  BackOnlineNotifier.new,
);

/// Al volver la conexión: recarga lo que estaba en error, reintenta las fotos que no
/// llegaron, retoma la descarga de favoritos y avisa. Se mantiene vivo desde el Shell.
final connectionWatcherProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<bool>>(onlineProvider, (previous, next) {
    final wasOnline = previous?.asData?.value;
    if (wasOnline == false && next.asData?.value == true) {
      ref.read(savedContentProvider.notifier).clear();
      ref.read(reconnectRegistryProvider).retryAll();
      PhotoRetry.retryAll();
      ref.invalidate(favoritesBackfillProvider);
      ref.read(backOnlineProvider.notifier).announce();
    }
  });
});

/// Migración y reintento de favoritos: los que no tienen ficha completa la descargan en
/// segundo plano y con baja prioridad, y las fotos de todos pasan a su caché propia.
final favoritesBackfillProvider = FutureProvider<void>((ref) async {
  final cache = ref.read(offlineCacheRepositoryProvider);
  // Las fotos ya guardadas se leen de la caché de favoritos aunque no haya red
  FavoritePhotoCache.register(await cache.favoritePhotoUrls());
  if (!(ref.read(onlineProvider).asData?.value ??
      await ref.read(connectivityRepositoryProvider).isOnline())) {
    return;
  }

  final repository = ref.read(speciesRepositoryProvider);
  await RequestPriority.runLow(() async {
    for (final slug in await cache.favoritesWithoutDetail()) {
      final (detail, error) = await repository.getSpeciesBySlug(
        slug: slug,
        lang: ApiConstants.appLang,
      );
      if (detail != null) {
        await cache.saveFavoriteDetail(detail);
      } else if (failureKindOf(error) == FailureKind.offline) {
        return;
      }
    }
  });
  await FavoritePhotoCache.download(await cache.favoritePhotoUrls());
});

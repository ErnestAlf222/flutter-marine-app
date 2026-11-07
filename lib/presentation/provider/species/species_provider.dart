import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';
import 'package:marine_app/presentation/provider/catalog/catalog_provider.dart';
import 'package:marine_app/presentation/provider/offline/offline_provider.dart';

// Único punto donde presentation conoce el repositorio impl
final speciesRepositoryProvider = Provider<SpeciesRepository>((ref) {
  return SpeciesRepositoryImpl();
});

final speciesDetailProvider = FutureProvider.family<SpeciesDetail, String>((
  ref,
  slug,
) {
  return trackFailure(ref, () async {
    final repository = ref.watch(speciesRepositoryProvider);
    final cache = ref.watch(offlineCacheRepositoryProvider);
    final (detail, error) = await repository.getSpeciesBySlug(
      slug: slug,
      lang: ApiConstants.appLang,
    );

    if (detail != null) {
      // Se guarda sin esperar: los últimos vistos y, si es favorito, su ficha
      unawaited(
        cache.saveDetail(detail, limit: OfflineConstants.detailCacheLimit),
      );
      return detail;
    }

    // Sin red o con el servidor caído se abre lo guardado; un 404 es definitivo
    if (failureKindOf(error) != FailureKind.notFound) {
      final saved = await cache.detail(slug);
      if (saved != null) {
        if (ref.mounted) {
          ref
              .read(savedContentProvider.notifier)
              .mark(OfflineConstants.savedDetail(slug));
        }
        return saved;
      }
    }

    // La pantalla muestra el mensaje con AsyncValue.when
    throw error;
  });
});

// Trae una página al azar para que cada visita muestre especies distintas
Future<List<Species>> randomSpeciesPage(
  SpeciesRepository repository, {
  required int perPage,
  bool? featured,
  Random? random,
}) async {
  // La primera página da el total y sirve de resultado si el azar elige la 1
  final (first, error) = await repository.getSpecies(
    lang: ApiConstants.appLang,
    page: 1,
    perPage: perPage,
    featured: featured,
  );
  if (first == null) throw error;

  final pages = (first.total / perPage).ceil();
  final page = pages <= 1 ? 1 : (random ?? Random()).nextInt(pages) + 1;
  if (page == 1) return first.items;

  final (picked, pickedError) = await repository.getSpecies(
    lang: ApiConstants.appLang,
    page: page,
    perPage: perPage,
    featured: featured,
  );
  if (picked == null) throw pickedError;
  return picked.items;
}

// Primera carga de la sesión: sin catálogo ni lista guardada, el pez se queda al menos
// [firstLoadMinimumProvider]
class SessionBoot {
  bool _featuredPending = true;

  /// true solo la primera vez que se pide en la sesión
  bool takeFeaturedFirstLoad() {
    final first = _featuredPending;
    _featuredPending = false;
    return first;
  }
}

final sessionBootProvider = Provider<SessionBoot>((ref) => SessionBoot());

// Las pruebas lo ponen en cero para no esperar el pez
final firstLoadMinimumProvider = Provider<Duration>(
  (ref) => OfflineConstants.firstLoadMinimum,
);

// Azar de la selección del héroe; las pruebas lo cambian por uno con semilla
final heroRandomProvider = Provider<Random>((ref) => Random());

// Espera a que el catálogo local diga si está listo (unos ms); con tope, por si no responde
Future<void> _awaitCatalogDecision(Ref ref) async {
  if (ref.read(catalogSyncProvider).prepared) return;
  final decided = Completer<void>();
  final subscription = ref.listen(catalogSyncProvider, (_, status) {
    if (status.prepared && !decided.isCompleted) decided.complete();
  });
  try {
    await decided.future.timeout(OfflineConstants.catalogWait);
  } on TimeoutException {
    // Sin respuesta se sigue con el servidor
  } finally {
    subscription.close();
  }
}

// Destacadas del héroe. Con el catálogo local completo se eligen al instante y sin red, otras
// cada arranque (sin las del anterior); sin catálogo se muestra la lista guardada y se pide
// una nueva al servidor en ese mismo arranque. Se calcula una vez por proceso: solo el
// pull-to-refresh o un reintento la cambian.
final featuredSpeciesProvider = StreamProvider<List<Species>>((ref) async* {
  try {
    yield* _featured(ref);
  } catch (_) {
    if (ref.mounted) ref.read(reconnectRegistryProvider).track(ref);
    rethrow;
  }
});

Stream<List<Species>> _featured(Ref ref) async* {
  final repository = ref.read(speciesRepositoryProvider);
  final cache = ref.read(offlineCacheRepositoryProvider);
  final catalog = ref.read(catalogRepositoryProvider);
  final first = ref.read(sessionBootProvider).takeFeaturedFirstLoad();
  final minimum = ref.read(firstLoadMinimumProvider);

  // Del catálogo local: sin red y sin pez
  await _awaitCatalogDecision(ref);
  if (catalog.isReady) {
    final all = await catalog.search(query: '', filter: (s) => s.featured);
    if (all != null && all.isNotEmpty) {
      final previous = (await cache.heroSlugs()).toSet();
      final picked = pickHeroSpecies(
        featured: all,
        slugOf: (s) => s.slug,
        previous: previous,
        random: ref.read(heroRandomProvider),
        count: ApiConstants.featuredPerPage,
      );
      // Lo de este arranque es lo que se recuerda: para evitarlo la próxima vez y para sin red
      unawaited(cache.saveHeroSlugs([for (final s in picked) s.slug]));
      unawaited(cache.saveFeatured(picked));
      yield picked;
      return;
    }
  }

  Future<List<Species>> fetch() async {
    final fresh = await randomSpeciesPage(
      repository,
      perPage: ApiConstants.featuredPerPage,
      featured: true,
    );
    if (fresh.isNotEmpty) unawaited(cache.saveFeatured(fresh));
    return fresh;
  }

  void markSaved() {
    if (ref.mounted) {
      ref.read(savedContentProvider.notifier).mark(OfflineConstants.savedFeatured);
    }
  }

  final saved = first ? await cache.featured() : null;
  if (saved != null && saved.isNotEmpty) {
    // Lo guardado se ve de inmediato; el servidor la renueva en este mismo arranque
    markSaved();
    yield saved;
    try {
      final fresh = await fetch();
      if (fresh.isNotEmpty) yield fresh;
    } catch (_) {
      // Sin red se queda lo guardado; al volver la conexión se vuelve a pedir
      if (ref.mounted) ref.read(reconnectRegistryProvider).track(ref);
    }
    return;
  }

  final hold = first && minimum > Duration.zero
      ? Future<void>.delayed(minimum)
      : Future<void>.value();
  try {
    final fresh = await fetch();
    await hold;
    yield fresh;
  } catch (_) {
    final fallback = await cache.featured();
    if (fallback == null || fallback.isEmpty) rethrow;
    markSaved();
    yield fallback;
  }
}

// Total de especies del catálogo, leído de la paginación (per_page=1): nada escrito a mano
final catalogTotalProvider = FutureProvider<int>((ref) {
  return trackFailure(ref, () async {
    final (page, error) = await ref
        .watch(speciesRepositoryProvider)
        .getSpecies(lang: ApiConstants.appLang, page: 1, perPage: 1);

    if (page == null) throw error;
    return page.total;
  });
});

// Cuántas especies tiene una colección de Inicio: se lee del total de la paginación
// con per_page=1, así no hay ningún número escrito a mano
final collectionCountProvider = FutureProvider.family<int, String>((ref, id) {
  return trackFailure(ref, () async {
    final collection = CollectionConstants.byId(id);
    final (page, error) = await ref
        .watch(speciesRepositoryProvider)
        .getSpecies(
          lang: ApiConstants.appLang,
          page: 1,
          perPage: 1,
          sizeMin: collection.sizeMinCm,
          dangerLevel: collection.dangerLevel,
          conservationStatus: collection.conservationStatus,
        );

    if (page == null) throw error;
    return page.total;
  });
});

// "Sorpréndeme": una especie cualquiera. Con per_page=1 sobre el total, elegir una
// página al azar es elegir una especie al azar.
final surpriseSpeciesProvider = Provider<Future<Species> Function()>((ref) {
  return () async {
    final picked = await randomSpeciesPage(
      ref.read(speciesRepositoryProvider),
      perPage: 1,
    );
    if (picked.isEmpty) throw ApiConstants.noSpeciesMessage;
    return picked.first;
  };
});

// Mosaico "Descubre más": especies al azar sin repetir las del héroe, porque el
// slug es el tag del Hero y no puede haber dos iguales en pantalla
final discoverSpeciesProvider = FutureProvider<List<Species>>((ref) {
  return trackFailure(ref, () async {
    final repository = ref.watch(speciesRepositoryProvider);
    final featured = await ref.watch(featuredSpeciesProvider.future);
    final shown = featured.map((s) => s.slug).toSet();

    final picked = await randomSpeciesPage(
      repository,
      perPage: DesignConstants.discoverFetch,
    );
    return picked
        .where((s) => !shown.contains(s.slug))
        .take(DesignConstants.discoverCount)
        .toList();
  });
});

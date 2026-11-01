import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/catalog/catalog_provider.dart';
import 'package:marine_app/presentation/provider/species/explore_seed_provider.dart';
import 'package:marine_app/presentation/provider/species/species_filters_provider.dart';
import 'package:marine_app/presentation/provider/species/species_provider.dart';

class SpeciesListState {
  final List<Species> items;
  final int page;
  final bool hasNextPage;
  final bool isLoadingMore;
  // Un fallo al pedir más no debe borrar lo ya cargado, por eso va aparte
  final String? loadMoreError;
  // La búsqueda por texto llegó al tope de la API (50): puede haber más coincidencias
  final bool searchCapped;

  const SpeciesListState({
    required this.items,
    required this.page,
    required this.hasNextPage,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.searchCapped = false,
  });

  SpeciesListState copyWith({
    List<Species>? items,
    int? page,
    bool? hasNextPage,
    bool? isLoadingMore,
    String? Function()? loadMoreError,
  }) {
    return SpeciesListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError != null
          ? loadMoreError()
          : this.loadMoreError,
      searchCapped: searchCapped,
    );
  }
}

class SpeciesListNotifier extends AsyncNotifier<SpeciesListState> {
  // Semilla del orden (null si hay texto o filtros) y, sin catálogo, por dónde empieza el
  // círculo de páginas y cuántas son
  int? _seed;
  int _start = 1;
  int _pages = 1;

  // Explorar sin texto ni filtros: el único caso en que el orden se baraja
  static bool _isBrowsing(SpeciesFilters f) =>
      !f.hasQuery && f.query.trim().isEmpty && f.activeCount == 0 && f.zone == null;

  // Al cambiar los filtros, build se vuelve a ejecutar y la lista vuelve a la página 1
  @override
  Future<SpeciesListState> build() async {
    final filters = ref.watch(speciesFiltersProvider);
    // Cuando el catálogo local queda listo, la lista se rehace con él
    ref.watch(catalogSyncProvider.select((s) => s.ready));
    // Sin texto ni filtros el orden se baraja con la semilla; con ellos, la semilla no pinta
    _seed = _isBrowsing(filters) ? ref.watch(exploreSeedProvider) : null;
    _start = 1;
    _pages = 1;
    final page = await _fetchPage(filters, 1);

    return SpeciesListState(
      items: page.items,
      page: page.page,
      hasNextPage: page.hasNextPage,
      searchCapped: page.searchCapped,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || !current.hasNextPage || current.isLoadingMore) {
      return;
    }

    final filters = ref.read(speciesFiltersProvider);
    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreError: () => null),
    );

    try {
      final page = await _fetchPage(filters, current.page + 1);

      // Si los filtros cambiaron mientras se esperaba, esta página ya no corresponde
      if (!ref.mounted || !identical(filters, ref.read(speciesFiltersProvider))) {
        return;
      }

      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          page: page.page,
          hasNextPage: page.hasNextPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (!ref.mounted || !identical(filters, ref.read(speciesFiltersProvider))) {
        return;
      }
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: () => '$e'),
      );
    }
  }

  // Busca por texto. El servidor solo entiende una cadena y distingue acentos ("tiburon toro"
  // no devuelve nada), así que se le pide la palabra más larga y el cliente exige que TODAS
  // las palabras coincidan, por raíz y sin acentos, en el nombre común o el científico.
  // Si la palabra vuelve vacía se prueba su raíz sin plural y prefijos más cortos.
  Future<(List<Species>, bool)> _search(
    SpeciesRepository repository,
    String query,
  ) async {
    final words = TextUtils.tokens(query);
    if (words.isEmpty) return (const <Species>[], false);
    final primary = words.reduce((a, b) => b.length > a.length ? b : a);
    final severalWords = words.length > 1;

    final (items, error) = await repository.searchSpecies(
      query: primary,
      lang: ApiConstants.appLang,
    );
    if (items == null) throw error;

    bool matches(Species s) =>
        TextUtils.matchesQuery(query, '${s.commonName} ${s.scientificName}');

    final capped = items.length >= ApiConstants.searchResultCap;
    // Con una sola palabra el servidor ya acertó (también por nombres en otros idiomas);
    // con varias solo trajo la más larga y falta exigir las demás
    if (items.isNotEmpty) {
      return (severalWords ? items.where(matches).toList() : items, capped);
    }
    // Con acentos escritos no hay nada que arreglar
    if (TextUtils.hasDiacritics(primary)) return (items, capped);

    final stemmed = TextUtils.stem(primary);
    final attempts = <String>{
      if (stemmed != primary) stemmed,
      for (
        int length = primary.length - ApiConstants.searchFallbackTrim;
        length >= ApiConstants.searchFallbackMinLength;
        length -= ApiConstants.searchFallbackTrim
      )
        primary.substring(0, length),
    }.take(ApiConstants.searchFallbackMaxRequests);

    for (final attempt in attempts) {
      final (shorter, shorterError) = await repository.searchSpecies(
        query: attempt,
        lang: ApiConstants.appLang,
      );
      if (shorter == null) throw shorterError;

      final found = shorter.where(matches).toList();
      if (found.isNotEmpty) {
        return (found, shorter.length >= ApiConstants.searchResultCap);
      }
    }
    return (items, capped);
  }

  // Sin catálogo: se empieza en una página al azar (según la semilla) y se sigue en círculo
  // hasta cubrirlas todas, así que no hay especies repetidas. [n] cuenta las páginas ya
  // pedidas, no el número de página de la API.
  Future<SpeciesPage> _fetchShuffledPage(
    SpeciesRepository repository,
    SpeciesFilters filters,
    int n,
    int seed,
  ) async {
    Future<SpeciesPage> request(int apiPage) async {
      final (result, error) = await repository.getSpecies(
        lang: ApiConstants.appLang,
        page: apiPage,
        perPage: ApiConstants.defaultPerPage,
      );
      if (result == null) throw error;
      return result;
    }

    if (n == 1) {
      // La primera página da el total; si el azar no elige la 1, se pide la elegida
      final first = await request(1);
      _pages = (first.total / ApiConstants.defaultPerPage).ceil().clamp(1, 1 << 20);
      _start = Random(seed).nextInt(_pages) + 1;
      final page = _start == 1 ? first : await request(_start);
      return SpeciesPage(items: page.items, page: 1, perPage: page.perPage, total: page.total);
    }

    final apiPage = (_start - 1 + (n - 1)) % _pages + 1;
    final page = await request(apiPage);
    return SpeciesPage(items: page.items, page: n, perPage: page.perPage, total: page.total);
  }

  Future<SpeciesPage> _fetchPage(SpeciesFilters filters, int page) async {
    // Con el catálogo listo, búsqueda y filtros se resuelven en el dispositivo y sin tope;
    // la zona solo existe en el servidor. Si el catálogo no está, se sigue como siempre
    if (filters.zone == null) {
      final local = await ref.read(catalogRepositoryProvider).search(
        query: filters.query.trim(),
        filter: filters.matches,
      );
      if (local != null) {
        // Misma semilla, mismo orden: así volver del Detalle o recargar no cambia nada
        final seed = _seed;
        final items = seed == null ? local : ([...local]..shuffle(Random(seed)));
        return SpeciesPage(
          items: items,
          page: 1,
          perPage: local.length,
          total: local.length,
        );
      }
    }

    final repository = ref.read(speciesRepositoryProvider);
    final seed = _seed;
    if (seed != null) return _fetchShuffledPage(repository, filters, page, seed);

    if (filters.hasQuery) {
      final (items, capped) = await _search(repository, filters.query.trim());

      // /search no admite filtros: se aplican aquí. Devuelve todo de una vez (hasta su
      // tope de 50), así que se presenta como página única
      final filtered = items.where(filters.matches).toList();
      return SpeciesPage(
        items: filtered,
        page: 1,
        perPage: filtered.length,
        total: filtered.length,
        // Si la búsqueda llegó al tope puede haber coincidencias que no se trajeron
        searchCapped: capped,
      );
    }

    final (result, error) = await repository.getSpecies(
      lang: ApiConstants.appLang,
      page: page,
      perPage: ApiConstants.defaultPerPage,
      zone: filters.zone,
      category: filters.category,
      conservationStatus: filters.conservationStatus,
      dangerLevel: filters.dangerLevel,
      sizeMin: filters.sizeMin,
      sizeMax: filters.sizeMax,
      depthMin: filters.depthMin,
      depthMax: filters.depthMax,
    );
    if (result == null) throw error;
    return result;
  }
}

final speciesListProvider =
    AsyncNotifierProvider<SpeciesListNotifier, SpeciesListState>(
      SpeciesListNotifier.new,
    );

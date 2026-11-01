import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
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
  // Al cambiar los filtros, build se vuelve a ejecutar y la lista vuelve a la página 1
  @override
  Future<SpeciesListState> build() async {
    final filters = ref.watch(speciesFiltersProvider);
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

  // Busca por texto. El servidor distingue acentos, así que si "tiburon" vuelve vacío se
  // prueba con prefijos más cortos ("tibur") y se queda con lo que coincide sin acentos
  Future<(List<Species>, bool)> _search(
    SpeciesRepository repository,
    String query,
  ) async {
    final (items, error) = await repository.searchSpecies(
      query: query,
      lang: ApiConstants.appLang,
    );
    if (items == null) throw error;

    final capped = items.length >= ApiConstants.searchResultCap;
    // Con acentos escritos el servidor ya acertó; con resultados no hay nada que arreglar
    if (items.isNotEmpty || TextUtils.hasDiacritics(query)) return (items, capped);

    final wanted = TextUtils.fold(query);
    var length = query.length;
    for (var i = 0; i < ApiConstants.searchFallbackMaxRequests; i++) {
      length -= ApiConstants.searchFallbackTrim;
      if (length < ApiConstants.searchFallbackMinLength) break;

      final (shorter, shorterError) = await repository.searchSpecies(
        query: query.substring(0, length),
        lang: ApiConstants.appLang,
      );
      if (shorter == null) throw shorterError;

      final matches = shorter
          .where(
            (s) => TextUtils.fold('${s.commonName} ${s.scientificName}').contains(wanted),
          )
          .toList();
      if (matches.isNotEmpty) {
        return (matches, shorter.length >= ApiConstants.searchResultCap);
      }
    }
    return (items, capped);
  }

  Future<SpeciesPage> _fetchPage(SpeciesFilters filters, int page) async {
    final repository = ref.read(speciesRepositoryProvider);

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

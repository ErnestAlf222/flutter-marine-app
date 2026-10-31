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

  const SpeciesListState({
    required this.items,
    required this.page,
    required this.hasNextPage,
    this.isLoadingMore = false,
    this.loadMoreError,
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

  Future<SpeciesPage> _fetchPage(SpeciesFilters filters, int page) async {
    final repository = ref.read(speciesRepositoryProvider);

    if (filters.hasQuery) {
      final (items, error) = await repository.searchSpecies(
        query: filters.query.trim(),
        lang: ApiConstants.appLang,
      );
      if (items == null) throw error;

      // /search devuelve todo de una vez: se presenta como página única
      return SpeciesPage(
        items: items,
        page: 1,
        perPage: items.length,
        total: items.length,
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

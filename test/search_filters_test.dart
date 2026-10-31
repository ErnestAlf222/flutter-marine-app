import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'support/fake_ui_repository.dart';

Species _species({
  String category = 'fish',
  String? status = 'LC',
  String? danger = 'harmless',
  double? depthMax = 20,
  double? sizeMax = 100,
}) => Species(
  id: 'id',
  slug: 'slug',
  scientificName: 'Species',
  commonName: 'Especie',
  category: category,
  conservationStatus: status,
  dangerLevel: danger,
  depthMaxM: depthMax,
  sizeMaxCm: sizeMax,
);

ProviderContainer _container(SpeciesRepository repository) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [speciesRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('búsqueda por texto', () {
    test('exige al menos 2 caracteres: con uno /search no devuelve nada', () {
      expect(const SpeciesFilters(query: 'a').hasQuery, isFalse);
      expect(const SpeciesFilters(query: ' a ').hasQuery, isFalse);
      expect(const SpeciesFilters(query: 'pe').hasQuery, isTrue);
      expect(const SpeciesFilters(query: '  pez ').hasQuery, isTrue);
    });
  });

  group('filtros aplicados en el cliente', () {
    test('sin filtros pasa todo', () {
      expect(const SpeciesFilters().matches(_species()), isTrue);
    });

    test('categoría, estado UICN y peligrosidad deben coincidir', () {
      expect(const SpeciesFilters(category: 'fish').matches(_species()), isTrue);
      expect(const SpeciesFilters(category: 'coral').matches(_species()), isFalse);
      expect(const SpeciesFilters(conservationStatus: 'CR').matches(_species()), isFalse);
      expect(const SpeciesFilters(dangerLevel: 'venomous').matches(_species()), isFalse);
      expect(
        const SpeciesFilters(dangerLevel: 'venomous').matches(_species(danger: 'venomous')),
        isTrue,
      );
    });

    test('profundidad es "llega al menos a": cuenta la profundidad máxima de la especie', () {
      // La especie llega a 20 m
      expect(const SpeciesFilters(depthMin: 20).matches(_species()), isTrue);
      expect(const SpeciesFilters(depthMin: 10).matches(_species()), isTrue);
      expect(const SpeciesFilters(depthMin: 25).matches(_species()), isFalse);
    });

    test('tamaño es "alcanza al menos": cuenta la talla máxima de la especie', () {
      expect(const SpeciesFilters(sizeMin: 100).matches(_species()), isTrue);
      expect(const SpeciesFilters(sizeMin: 101).matches(_species()), isFalse);
    });

    test('sin dato de profundidad o tamaño no puede cumplir ese filtro', () {
      expect(const SpeciesFilters(depthMin: 10).matches(_species(depthMax: null)), isFalse);
      expect(const SpeciesFilters(sizeMin: 10).matches(_species(sizeMax: null)), isFalse);
      // Pero sin filtro no importa
      expect(const SpeciesFilters().matches(_species(depthMax: null, sizeMax: null)), isTrue);
    });

    test('todos los filtros a la vez se combinan con Y', () {
      const filters = SpeciesFilters(category: 'fish', depthMin: 10, sizeMin: 50);
      expect(filters.matches(_species()), isTrue);
      expect(filters.matches(_species(category: 'coral')), isFalse);
      expect(filters.matches(_species(depthMax: 5)), isFalse);
    });
  });

  group('lista con texto y filtros', () {
    test('filtra los resultados de /search en el cliente', () async {
      final repository = FakeUiRepository(count: 6, searchCount: 6);
      final container = _container(repository);

      container.read(speciesFiltersProvider.notifier)
        ..setQuery('especie')
        ..setCategory('coral');
      final state = await container.read(speciesListProvider.future);

      // Las pares son coral: 2, 4 y 6
      expect(state.items.map((s) => s.slug), ['especie-2', 'especie-4', 'especie-6']);
      expect(repository.searchQueries, ['especie']);
      expect(state.hasNextPage, isFalse);
    });

    test('profundidad y tamaño "al menos" también se aplican sobre /search', () async {
      final container = _container(FakeUiRepository(count: 6, searchCount: 6));

      container.read(speciesFiltersProvider.notifier)
        ..setQuery('especie')
        ..setDepthRange(40, null)
        ..setSizeRange(500, null);
      final state = await container.read(speciesListProvider.future);

      // Profundidad máxima = n*10 (>= 40) y talla = n*100 (>= 500): n = 5 y 6
      expect(state.items.map((s) => s.slug), ['especie-5', 'especie-6']);
    });

    test('si /search llega a su tope de 50 se avisa de que puede haber más', () async {
      final capped = _container(FakeUiRepository(count: 6, searchCount: 50));
      capped.read(speciesFiltersProvider.notifier).setQuery('pe');
      expect((await capped.read(speciesListProvider.future)).searchCapped, isTrue);

      final normal = _container(FakeUiRepository(count: 6, searchCount: 7));
      normal.read(speciesFiltersProvider.notifier).setQuery('pe');
      expect((await normal.read(speciesListProvider.future)).searchCapped, isFalse);
    });

    test('el aviso de tope vale aunque los filtros dejen pocos resultados', () async {
      final container = _container(FakeUiRepository(count: 6, searchCount: 50));

      container.read(speciesFiltersProvider.notifier)
        ..setQuery('pe')
        ..setCategory('coral');
      final state = await container.read(speciesListProvider.future);

      expect(state.items.length, lessThan(50));
      expect(state.searchCapped, isTrue);
    });

    test('con un solo carácter no se usa /search: se lista con /species', () async {
      final repository = FakeUiRepository(count: 6);
      final container = _container(repository);

      container.read(speciesFiltersProvider.notifier).setQuery('a');
      final state = await container.read(speciesListProvider.future);

      expect(repository.searchQueries, isEmpty);
      expect(state.items, hasLength(6));
    });
  });

  test('el tope de la API está en una constante', () {
    expect(ApiConstants.searchResultCap, 50);
    expect(ApiConstants.minSearchLength, 2);
  });
}

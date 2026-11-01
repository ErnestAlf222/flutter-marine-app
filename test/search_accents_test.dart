import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';

import 'support/fake_ui_repository.dart';

Species _species(
  String common, {
  String scientific = 'Species sp.',
  String category = 'fish',
}) => Species(
  id: common,
  slug: common.toLowerCase().replaceAll(' ', '-'),
  scientificName: scientific,
  commonName: common,
  category: category,
);

// Imita al servidor real: busca por subcadena y distingue acentos ("tiburon" no encuentra
// "Tiburón"), como se midió con curl
class _AccentSensitiveRepository extends FakeUiRepository {
  final List<Species> catalog;

  _AccentSensitiveRepository(this.catalog);

  @override
  Future<(List<Species>?, String)> searchSpecies({
    required String query,
    required String lang,
  }) async {
    searchQueries.add(query);
    final q = query.toLowerCase();
    return (
      catalog
          .where(
            (s) =>
                s.commonName.toLowerCase().contains(q) ||
                s.scientificName.toLowerCase().contains(q),
          )
          .toList(),
      '',
    );
  }
}

final _catalog = [
  _species('Tiburón ballena', scientific: 'Rhincodon typus'),
  _species('Tiburón nodriza', scientific: 'Ginglymostoma cirratum'),
  _species(
    'Tiburcio rayado',
  ), // empieza igual que "tibur" pero no es un tiburón
  _species('Coral Tiburón', category: 'coral'),
];

ProviderContainer _container(SpeciesRepository repository) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [speciesRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

Future<List<String>> _search(
  ProviderContainer container,
  String text, {
  String? category,
}) async {
  final filters = container.read(speciesFiltersProvider.notifier)
    ..setQuery(text);
  if (category != null) filters.setCategory(category);
  final state = await container.read(speciesListProvider.future);
  return state.items.map((s) => s.commonName).toList();
}

void main() {
  group('TextUtils', () {
    test('fold quita acentos, eñes y mayúsculas', () {
      expect(TextUtils.fold('Tiburón'), 'tiburon');
      expect(TextUtils.fold('PEZ ÁNGEL'), 'pez angel');
      expect(TextUtils.fold('Español'), 'espanol');
      expect(TextUtils.fold('Pingüino'), 'pinguino');
    });

    test('hasDiacritics distingue si el texto trae acentos', () {
      expect(TextUtils.hasDiacritics('tiburón'), isTrue);
      expect(TextUtils.hasDiacritics('Tiburon'), isFalse);
      expect(TextUtils.hasDiacritics('ÑANDÚ'), isTrue);
    });
  });

  group('búsqueda sin acentos', () {
    test('"tiburon" vacío en el servidor se reintenta con "tibur" y se filtra sin acentos', () async {
      final repository = _AccentSensitiveRepository(_catalog);
      final names = await _search(_container(repository), 'tiburon');

      expect(repository.searchQueries, ['tiburon', 'tibur']);
      expect(names, ['Tiburón ballena', 'Tiburón nodriza', 'Coral Tiburón']);
      expect(names, isNot(contains('Tiburcio rayado')));
    });

    test('con mayúscula inicial también ("Tiburon")', () async {
      final repository = _AccentSensitiveRepository(_catalog);
      final names = await _search(_container(repository), 'Tiburon');

      expect(repository.searchQueries, ['Tiburon', 'Tibur']);
      expect(names, hasLength(3));
    });

    test(
      'con acentos escritos el servidor acierta y no hay peticiones extra',
      () async {
        final repository = _AccentSensitiveRepository(_catalog);
        final names = await _search(_container(repository), 'tiburón');

        expect(repository.searchQueries, ['tiburón']);
        expect(names, hasLength(3));
      },
    );

    test('si el servidor ya devuelve algo no se reintenta', () async {
      final repository = _AccentSensitiveRepository([
        ..._catalog,
        _species('Pez tiburonado'),
      ]);
      final names = await _search(_container(repository), 'tiburon');

      expect(repository.searchQueries, ['tiburon']);
      expect(names, ['Pez tiburonado']);
    });

    test('compara también contra el nombre científico', () async {
      final repository = _AccentSensitiveRepository([
        _species('Pez con latín raro', scientific: 'Tiburón raro'),
        _species('Pez sin relación', scientific: 'Carcharhinus tibur'),
      ]);
      // "tiburon" no coincide con nada (el servidor distingue acentos); "tibur" trae los dos
      // y solo el primero tiene "tiburon" al comparar sin acentos
      final names = await _search(_container(repository), 'tiburon');

      expect(repository.searchQueries, ['tiburon', 'tibur']);
      expect(names, ['Pez con latín raro']);
    });

    test('como mucho 2 peticiones extra: prefijos sin los 2 últimos caracteres cada vez', () async {
      final repository = _AccentSensitiveRepository(_catalog);
      final names = await _search(_container(repository), 'abcdefghi');

      expect(repository.searchQueries, ['abcdefghi', 'abcdefg', 'abcde']);
      expect(
        repository.searchQueries.length - 1,
        ApiConstants.searchFallbackMaxRequests,
      );
      expect(names, isEmpty);
    });

    test('el prefijo nunca baja de 3 caracteres', () async {
      // 4 caracteres: quitar 2 dejaría 2, menos que el mínimo: sin reintento
      final short = _AccentSensitiveRepository(_catalog);
      await _search(_container(short), 'abcd');
      expect(short.searchQueries, ['abcd']);

      // 5 caracteres: un solo reintento, con 3
      final five = _AccentSensitiveRepository(_catalog);
      await _search(_container(five), 'abcde');
      expect(five.searchQueries, ['abcde', 'abc']);
    });

    test(
      'los filtros se siguen aplicando a lo que devuelve el reintento',
      () async {
        final repository = _AccentSensitiveRepository(_catalog);
        final names = await _search(
          _container(repository),
          'tiburon',
          category: 'coral',
        );

        expect(names, ['Coral Tiburón']);
      },
    );

    test('el aviso de tope sale de los resultados del reintento', () async {
      final many = [for (var i = 0; i < 60; i++) _species('Tiburón $i')];
      final repository = _AccentSensitiveRepository(many);
      final container = _container(repository);
      container.read(speciesFiltersProvider.notifier).setQuery('tiburon');
      final state = await container.read(speciesListProvider.future);

      // El servidor devuelve 60 en bruto, pero /search real corta en 50: aquí 60 >= 50
      expect(state.searchCapped, isTrue);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';

import 'support/fake_ui_repository.dart';

Species _species(String common, String scientific) => Species(
  id: common,
  slug: common.toLowerCase().replaceAll(' ', '-'),
  scientificName: scientific,
  commonName: common,
  category: 'fish',
);

// Imita al servidor real: subcadena sobre nombre común y científico, distingue acentos
// y no entiende plurales ("calamares" no devuelve nada), como se midió con curl
class _ServerLikeRepository extends FakeUiRepository {
  final List<Species> catalog;

  _ServerLikeRepository(this.catalog);

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
  _species('Calamar común', 'Loligo vulgaris'),
  _species('Calamar del arrecife gigante', 'Sepioteuthis lessoniana'),
  _species('Erizo cebra', 'Echinothrix calamaris'),
  _species('Pez ángel', 'Pomacanthus imperator'),
  _species('Pez león', 'Pterois volitans'),
  _species('Pulpo común', 'Octopus vulgaris'),
  _species('Pulpo mímico', 'Thaumoctopus mimicus'),
  _species('Tiburón ballena', 'Rhincodon typus'),
  _species('Tiburón toro', 'Carcharias taurus'),
  _species('Tiburón blanco', 'Carcharodon carcharias'),
  _species('Pez toro', 'Taurus piscis'),
  _species('Tortuga verde', 'Chelonia mydas'),
  _species('Tortuga carey', 'Eretmochelys imbricata'),
];

Future<(List<String>, List<String>)> _search(String text) async {
  final repository = _ServerLikeRepository(_catalog);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [speciesRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  container.read(speciesFiltersProvider.notifier).setQuery(text);
  final state = await container.read(speciesListProvider.future);
  return (
    state.items.map((s) => s.commonName).toList(),
    repository.searchQueries,
  );
}

void main() {
  group('TextUtils.stem', () {
    test('quita plurales con reglas simples del español', () {
      expect(TextUtils.stem('peces'), 'pez');
      expect(TextUtils.stem('calamares'), 'calamar');
      expect(TextUtils.stem('pulpos'), 'pulpo');
      expect(TextUtils.stem('tortugas'), 'tortuga');
      expect(TextUtils.stem('Tiburones'), 'Tiburon');
    });

    test('una palabra corta no se recorta', () {
      expect(TextUtils.stem('mas'), 'mas');
      expect(TextUtils.stem('res'), 'res');
      expect(TextUtils.stem('pez'), 'pez');
      // 4 letras sí se recortan, pero la raíz no baja de 3
      expect(TextUtils.stem('ases'), 'ases');
      expect(TextUtils.matchesQuery('mas', 'Mas rayado'), isTrue);
      expect(TextUtils.matchesQuery('mas', 'Ma rayado'), isFalse);
    });

    test('compara por prefijo, sin acentos ni mayúsculas', () {
      expect(TextUtils.matchesQuery('TIBURONES', 'Tiburón ballena'), isTrue);
      expect(TextUtils.matchesQuery('calamares', 'Echinothrix calamaris'), isTrue);
      expect(TextUtils.matchesQuery('pulpo común', 'Pulpo común'), isTrue);
      expect(TextUtils.matchesQuery('pulpo gris', 'Pulpo común'), isFalse);
    });
  });

  group('búsqueda con plurales', () {
    test('"calamares" muestra los calamares (y el erizo, que también empieza por calamar)', () async {
      final (names, queries) = await _search('calamares');

      // El prefijo "calamar" también abre "calamaris": no se puede excluir al erizo
      expect(names, [
        'Calamar común',
        'Calamar del arrecife gigante',
        'Erizo cebra',
      ]);
      expect(queries, ['calamares', 'calamar']);
    });

    test('"calamar" ya acierta en el servidor, sin peticiones extra', () async {
      final (names, queries) = await _search('calamar');

      expect(names, hasLength(3));
      expect(queries, ['calamar']);
    });

    test('"peces" llega a "Pez" por la regla ces -> z', () async {
      final (names, queries) = await _search('peces');

      expect(names, ['Pez ángel', 'Pez león', 'Pez toro']);
      expect(queries, ['peces', 'pez']);
    });

    test('"pulpos" y "tortugas"', () async {
      expect((await _search('pulpos')).$1, ['Pulpo común', 'Pulpo mímico']);
      expect((await _search('tortugas')).$1, ['Tortuga verde', 'Tortuga carey']);
    });

    test('"tiburon" sin acento sigue funcionando', () async {
      final (names, queries) = await _search('tiburon');

      expect(names, ['Tiburón ballena', 'Tiburón toro', 'Tiburón blanco']);
      expect(queries, ['tiburon', 'tibur']);
    });
  });

  group('búsqueda de varias palabras', () {
    test('"tiburon toro" sin acentos: pide "tiburon", reintenta "tibur" y exige ambas', () async {
      final (names, queries) = await _search('tiburon toro');

      expect(names, ['Tiburón toro']);
      expect(queries, ['tiburon', 'tibur']);
    });

    test('el orden de las palabras no importa', () async {
      final (names, queries) = await _search('toro tiburon');

      expect(names, ['Tiburón toro']);
      expect(queries, ['tiburon', 'tibur']);
    });

    test('"tiburon blanco" no trae los otros tiburones', () async {
      final (names, _) = await _search('tiburon blanco');

      expect(names, ['Tiburón blanco']);
    });

    test('con acentos acierta a la primera y también filtra', () async {
      final (names, queries) = await _search('tiburón toro');

      expect(names, ['Tiburón toro']);
      expect(queries, ['tiburón']);
    });

    test('una consulta sin resultados queda vacía y respeta el máximo de peticiones', () async {
      final (names, queries) = await _search('manta fantasma');

      expect(names, isEmpty);
      // La palabra más larga más como mucho 2 intentos extra
      expect(queries.length, lessThanOrEqualTo(3));
    });

    test('todas las palabras deben coincidir', () async {
      final (names, _) = await _search('tiburon cebra');

      expect(names, isEmpty);
    });
  });
}

import 'dart:math';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';

import 'catalog_file.dart';

/// Prueba de aceptación de la búsqueda, reutilizable con cualquier buscador: para una
/// muestra del catálogo real busca cada especie de varias maneras y exige que aparezca.
/// Ningún nombre está escrito a mano: todo sale de tool/catalog.
typedef SearchFn = Future<List<Species>> Function(String query);

class AcceptanceFailure {
  final String slug;
  final String variant;
  final String query;
  final int results;

  const AcceptanceFailure(this.slug, this.variant, this.query, this.results);

  @override
  String toString() => '$slug [$variant] "$query" -> $results resultados, sin la especie';
}

class AcceptanceResult {
  int searches = 0;
  final failures = <AcceptanceFailure>[];
  final timesMicros = <int>[];

  double get passRate => searches == 0 ? 1 : 1 - failures.length / searches;

  double get meanMs =>
      timesMicros.isEmpty ? 0 : timesMicros.reduce((a, b) => a + b) / timesMicros.length / 1000;

  double get maxMs => timesMicros.isEmpty ? 0 : timesMicros.reduce(max) / 1000;
}

// Plural del español con reglas sencillas: vocal + s, z -> ces, consonante + es
String pluralOf(String word) {
  final lower = word.toLowerCase();
  if (lower.endsWith('s')) return word;
  if (lower.endsWith('z')) return '${word.substring(0, word.length - 1)}ces';
  const vowels = 'aeiouáéíóú';
  return vowels.contains(lower[lower.length - 1]) ? '${word}s' : '${word}es';
}

/// Variantes de búsqueda de una especie: [nombre completo, cada palabra, sin acentos,
/// plural, mayúsculas]; el plural solo se prueba en palabras de al menos 3 letras
Iterable<(String, String)> queryVariants(Species species) sync* {
  final name = species.commonName;
  yield ('nombre completo', name);
  yield ('nombre científico', species.scientificName);
  yield ('sin acentos', TextUtils.fold(name));
  yield ('mayúsculas', name.toUpperCase());

  final words = TextUtils.tokens(name);
  for (final word in words) {
    yield ('palabra', word);
  }
  final long = words.where((w) => w.length >= 3).toList();
  if (long.isNotEmpty) {
    // Plural de la última palabra larga, con el resto del nombre tal cual
    final last = long.last;
    yield ('plural', name.replaceFirst(RegExp('${RegExp.escape(last)}(?!.*${RegExp.escape(last)})'), pluralOf(last)));
  }
}

/// Muestra de [size] especies del catálogo real, siempre la misma para una [seed]
List<Species> acceptanceSample({int size = 300, int seed = 2026}) {
  final all = CatalogFile.species('es');
  return ([...all]..shuffle(Random(seed))).take(size).toList();
}

Future<AcceptanceResult> runAcceptance(SearchFn search, List<Species> sample) async {
  final result = AcceptanceResult();

  for (final species in sample) {
    for (final (variant, query) in queryVariants(species)) {
      final clock = Stopwatch()..start();
      final found = await search(query);
      clock.stop();

      result.searches++;
      result.timesMicros.add(clock.elapsedMicroseconds);
      if (!found.any((s) => s.slug == species.slug)) {
        result.failures.add(AcceptanceFailure(species.slug, variant, query, found.length));
      }
    }
  }
  return result;
}

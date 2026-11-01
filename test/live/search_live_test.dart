@Timeout(Duration(minutes: 15))
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/presentation/provider/providers.dart';

import '../support/catalog_file.dart';

// Mide la búsqueda real de la app (repositorio real y limitador) contra el servidor.
// Solo corre con LIVE_SEARCH=1; usa la red, así que no forma parte de la suite normal:
//   LIVE_SEARCH=1 flutter test test/live/search_live_test.dart
void main() {
  final enabled = Platform.environment['LIVE_SEARCH'] == '1';

  test(
    'rendimiento de la búsqueda real por nombre común en español',
    () async {
      dotenv.loadFromString(envString: File('.env').readAsStringSync());
      final catalog = CatalogFile.species('es');
      final sample = ([...catalog]..shuffle(Random(2026))).take(60).toList();

      final container = ProviderContainer(retry: (_, _) => null);
      addTearDown(container.dispose);

      final latencies = <int>[];
      final failures = <String>[];
      for (final species in sample) {
        final clock = Stopwatch()..start();
        container.read(speciesFiltersProvider.notifier).setQuery(species.commonName);
        try {
          final state = await container.read(speciesListProvider.future);
          clock.stop();
          latencies.add(clock.elapsedMilliseconds);
          if (!state.items.any((s) => s.slug == species.slug)) {
            failures.add('"${species.commonName}" (${species.slug}): ${state.items.length} resultados, sin la especie');
          }
        } catch (e) {
          clock.stop();
          latencies.add(clock.elapsedMilliseconds);
          failures.add('"${species.commonName}" (${species.slug}): error $e');
        }
      }

      final hits = sample.length - failures.length;
      final mean = latencies.reduce((a, b) => a + b) / latencies.length;
      final sorted = [...latencies]..sort();
      // ignore: avoid_print
      print(
        'ACEPTACIÓN (servidor): $hits/${sample.length} = ${(100 * hits / sample.length).toStringAsFixed(1)} %\n'
        'latencia media ${mean.toStringAsFixed(0)} ms, mediana ${sorted[sorted.length ~/ 2]} ms, peor ${sorted.last} ms\n'
        'fallos (${failures.length}):\n${failures.join('\n')}',
      );
    },
    skip: !enabled
        ? 'Define LIVE_SEARCH=1 para medir contra el servidor'
        : !CatalogFile.exists
        ? CatalogFile.missingReason
        : false,
  );
}

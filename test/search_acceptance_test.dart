import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';

import 'support/catalog_file.dart';
import 'support/search_acceptance.dart';

// Aceptación de la búsqueda local sobre el catálogo real (tool/catalog). Se salta si el
// archivo no existe: se crea con `python tool/download_catalog.py`.
CatalogIndex _realIndex() {
  final en = {for (final s in CatalogFile.species('en')) s.slug: s.commonName};
  return CatalogIndex([
    for (final s in CatalogFile.species('es')) CatalogEntry(species: s, nameEn: en[s.slug]),
  ]);
}

void main() {
  final skip = CatalogFile.exists ? null : CatalogFile.missingReason;

  group('búsqueda local sobre el catálogo real', () {
    test(
      'el catálogo trae las 1,505 especies sin tope de resultados',
      () {
        final index = _realIndex();
        expect(index.length, CatalogFile.raw('es').length);
        // Sin texto ni filtros devuelve todo, no 50 ni 100
        expect(index.search('').length, index.length);
      },
      skip: skip,
    );

    test(
      'cada especie de la muestra aparece por nombre, palabras, sin acentos, plural, mayúsculas y científico',
      () async {
        final index = _realIndex();
        final result = await runAcceptance(
          (q) async => index.search(q),
          acceptanceSample(),
        );

        // ignore: avoid_print
        print(
          'ACEPTACIÓN (local): ${result.searches - result.failures.length}/${result.searches} '
          '= ${(100 * result.passRate).toStringAsFixed(2)} %, '
          'media ${result.meanMs.toStringAsFixed(2)} ms, peor ${result.maxMs.toStringAsFixed(2)} ms',
        );
        expect(result.failures, isEmpty, reason: result.failures.take(20).join('\n'));
      },
      skip: skip,
    );

    test(
      'responde en menos de 100 ms con el catálogo cargado',
      () async {
        final index = _realIndex();
        final result = await runAcceptance(
          (q) async => index.search(q),
          acceptanceSample(size: 100),
        );

        expect(result.maxMs, lessThan(100));
      },
      skip: skip,
    );

    test(
      'con el filtro de Explorar también responde rápido y respeta el filtro',
      () {
        final index = _realIndex();
        final clock = Stopwatch()..start();
        final fish = index.search('pez', filter: (s) => s.category == 'fish');
        clock.stop();

        expect(fish, isNotEmpty);
        expect(fish.every((s) => s.category == 'fish'), isTrue);
        expect(clock.elapsedMilliseconds, lessThan(100));
      },
      skip: skip,
    );
  });
}

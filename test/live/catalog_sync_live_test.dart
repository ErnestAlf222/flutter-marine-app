@Timeout(Duration(minutes: 15))
library;

import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/infrastructure/infrastructure.dart';

import '../support/fake_catalog_datasource.dart';

// Mide cuánto dura la primera sincronización real del catálogo (el tiempo que el "x de 16"
// está en pantalla). Solo con LIVE_SEARCH=1; usa la red:
//   LIVE_SEARCH=1 flutter test test/live/catalog_sync_live_test.dart
void main() {
  test(
    'duración de la primera sincronización real',
    () async {
      dotenv.loadFromString(envString: File('.env').readAsStringSync());
      final repository = CatalogRepositoryImpl(local: FakeCatalogDatasource());

      final clock = Stopwatch()..start();
      final marks = <String>[];
      await for (final p in repository.sync()) {
        marks.add('${p.step}/${p.total} a los ${(clock.elapsedMilliseconds / 1000).toStringAsFixed(1)} s');
      }
      clock.stop();

      // ignore: avoid_print
      print('SINCRONIZACIÓN: ${(clock.elapsedMilliseconds / 1000).toStringAsFixed(1)} s en total\n${marks.join('\n')}');
      expect(repository.isReady, isTrue);
    },
    skip: Platform.environment['LIVE_SEARCH'] == '1' ? false : 'Define LIVE_SEARCH=1',
  );
}

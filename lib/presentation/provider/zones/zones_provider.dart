import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/species/species_provider.dart';

final zonesProvider = FutureProvider<List<OceanZone>>((ref) async {
  final repository = ref.watch(speciesRepositoryProvider);
  final (zones, error) = await repository.getZones(lang: ApiConstants.appLang);

  if (zones == null) throw error;
  return zones;
});

// Destacadas de una zona. El servidor falla con 6 de 7 zonas (500), así que el
// error es un estado esperado y la hoja lo muestra como una nota neutra
final zoneTopSpeciesProvider = FutureProvider.family<List<Species>, String>((
  ref,
  zone,
) async {
  final repository = ref.watch(speciesRepositoryProvider);
  final (species, error) = await repository.getZoneTopSpecies(
    zone: zone,
    lang: ApiConstants.appLang,
    limit: ApiConstants.zoneTopLimit,
  );

  if (species == null) throw error;
  return species;
});

// Muestra de una zona que se va armando: [done] es false mientras falten detalles por procesar
class ZoneSample {
  final List<Species> items;
  final bool done;

  const ZoneSample(this.items, {required this.done});
}

// Muestra de especies de una zona armada desde los detalles, para cuando top-species falla.
// Toma una página al azar de destacadas y pide el detalle de varias, de pocas en pocas y con
// baja prioridad (ceden el paso a lo que ve el usuario), hasta juntar las que traen la zona
// en zones[]. Cada coincidencia se emite en cuanto llega, sin esperar a las demás.
Stream<ZoneSample> sampleZoneSpecies(
  SpeciesRepository repository,
  String zone, {
  Random? random,
}) {
  final controller = StreamController<ZoneSample>();
  final found = <Species>[];

  void emit({required bool done}) {
    if (!controller.isClosed) controller.add(ZoneSample([...found], done: done));
  }

  Future<void> run() async {
    // Sin esperar nada ya se sabe que está en marcha: la hoja muestra el pez
    emit(done: false);

    final pool = await randomSpeciesPage(
      repository,
      perPage: ApiConstants.zoneSamplePool,
      featured: true,
      random: random,
    );
    final candidates = ([...pool]..shuffle(random))
        .take(ApiConstants.zoneSampleMaxDetails)
        .toList();

    var next = 0;
    var failures = 0;

    // Cada trabajador toma el siguiente candidato en cuanto termina el suyo, así nunca hay
    // más de zoneSampleConcurrency detalles a la vez
    Future<void> worker() async {
      while (next < candidates.length &&
          found.length < ApiConstants.zoneSampleSize &&
          failures < ApiConstants.zoneSampleMaxFailures &&
          !controller.isClosed) {
        final species = candidates[next++];
        final (detail, _) = await repository.getSpeciesBySlug(
          slug: species.slug,
          lang: ApiConstants.appLang,
        );

        if (detail == null) {
          failures++;
        } else if (detail.zones.contains(zone) &&
            found.length < ApiConstants.zoneSampleSize) {
          found.add(species);
          emit(done: false);
        }
      }
    }

    await Future.wait([
      for (var i = 0; i < ApiConstants.zoneSampleConcurrency; i++) worker(),
    ]);
  }

  // Todo corre con baja prioridad: la página de destacadas y cada detalle
  RequestPriority.runLow(() => run()).then(
    (_) {
      emit(done: true);
      controller.close();
    },
    onError: (Object error, StackTrace stack) {
      controller.addError(error, stack);
      controller.close();
    },
  );

  return controller.stream;
}

// Una vez por zona y sesión: el proveedor no se libera, así que sirve de caché
final zoneSampleProvider = StreamProvider.family<ZoneSample, String>((ref, zone) {
  return sampleZoneSpecies(ref.watch(speciesRepositoryProvider), zone);
});

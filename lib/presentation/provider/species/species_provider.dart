import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';

// Único punto donde presentation conoce el repositorio impl
final speciesRepositoryProvider = Provider<SpeciesRepository>((ref) {
  return SpeciesRepositoryImpl();
});

final speciesDetailProvider = FutureProvider.family<SpeciesDetail, String>((
  ref,
  slug,
) async {
  final repository = ref.watch(speciesRepositoryProvider);
  final (detail, error) = await repository.getSpeciesBySlug(
    slug: slug,
    lang: ApiConstants.appLang,
  );

  // La pantalla muestra el mensaje con AsyncValue.when
  if (detail == null) throw error;
  return detail;
});

// Trae una página al azar para que cada visita muestre especies distintas
Future<List<Species>> randomSpeciesPage(
  SpeciesRepository repository, {
  required int perPage,
  bool? featured,
  Random? random,
}) async {
  // La primera página da el total y sirve de resultado si el azar elige la 1
  final (first, error) = await repository.getSpecies(
    lang: ApiConstants.appLang,
    page: 1,
    perPage: perPage,
    featured: featured,
  );
  if (first == null) throw error;

  final pages = (first.total / perPage).ceil();
  final page = pages <= 1 ? 1 : (random ?? Random()).nextInt(pages) + 1;
  if (page == 1) return first.items;

  final (picked, pickedError) = await repository.getSpecies(
    lang: ApiConstants.appLang,
    page: page,
    perPage: perPage,
    featured: featured,
  );
  if (picked == null) throw pickedError;
  return picked.items;
}

// Hay cientos de destacadas (838 al probar): se muestra una página al azar para variar
final featuredSpeciesProvider = FutureProvider<List<Species>>((ref) {
  return randomSpeciesPage(
    ref.watch(speciesRepositoryProvider),
    perPage: ApiConstants.featuredPerPage,
    featured: true,
  );
});

// Total de especies del catálogo, leído de la paginación (per_page=1): nada escrito a mano
final catalogTotalProvider = FutureProvider<int>((ref) async {
  final (page, error) = await ref.watch(speciesRepositoryProvider).getSpecies(
    lang: ApiConstants.appLang,
    page: 1,
    perPage: 1,
  );

  if (page == null) throw error;
  return page.total;
});

// Cuántas especies tiene una colección de Inicio: se lee del total de la paginación
// con per_page=1, así no hay ningún número escrito a mano
final collectionCountProvider = FutureProvider.family<int, String>((
  ref,
  id,
) async {
  final collection = CollectionConstants.byId(id);
  final (page, error) = await ref.watch(speciesRepositoryProvider).getSpecies(
    lang: ApiConstants.appLang,
    page: 1,
    perPage: 1,
    sizeMin: collection.sizeMinCm,
    dangerLevel: collection.dangerLevel,
    conservationStatus: collection.conservationStatus,
  );

  if (page == null) throw error;
  return page.total;
});

// "Sorpréndeme": una especie cualquiera. Con per_page=1 sobre el total, elegir una
// página al azar es elegir una especie al azar.
final surpriseSpeciesProvider = Provider<Future<Species> Function()>((ref) {
  return () async {
    final picked = await randomSpeciesPage(
      ref.read(speciesRepositoryProvider),
      perPage: 1,
    );
    if (picked.isEmpty) throw 'No se encontró ninguna especie.';
    return picked.first;
  };
});

// Mosaico "Descubre más": especies al azar sin repetir las del héroe, porque el
// slug es el tag del Hero y no puede haber dos iguales en pantalla
final discoverSpeciesProvider = FutureProvider<List<Species>>((ref) async {
  final repository = ref.watch(speciesRepositoryProvider);
  final featured = await ref.watch(featuredSpeciesProvider.future);
  final shown = featured.map((s) => s.slug).toSet();

  final picked = await randomSpeciesPage(
    repository,
    perPage: DesignConstants.discoverFetch,
  );
  return picked
      .where((s) => !shown.contains(s.slug))
      .take(DesignConstants.discoverCount)
      .toList();
});

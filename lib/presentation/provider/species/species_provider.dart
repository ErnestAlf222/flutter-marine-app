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

// Hay cientos de destacadas (838 al probar): se muestra una página al azar para variar
final featuredSpeciesProvider = FutureProvider<List<Species>>((ref) async {
  final repository = ref.watch(speciesRepositoryProvider);

  // La primera página da el total y sirve de resultado si el azar elige la 1
  final (first, error) = await repository.getSpecies(
    lang: ApiConstants.appLang,
    page: 1,
    perPage: ApiConstants.featuredPerPage,
    featured: true,
  );
  if (first == null) throw error;

  final pages = (first.total / ApiConstants.featuredPerPage).ceil();
  final page = pages <= 1 ? 1 : Random().nextInt(pages) + 1;
  if (page == 1) return first.items;

  final (picked, pickedError) = await repository.getSpecies(
    lang: ApiConstants.appLang,
    page: page,
    perPage: ApiConstants.featuredPerPage,
    featured: true,
  );
  if (picked == null) throw pickedError;
  return picked.items;
});

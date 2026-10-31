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

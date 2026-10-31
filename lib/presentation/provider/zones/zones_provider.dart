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

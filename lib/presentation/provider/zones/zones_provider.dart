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

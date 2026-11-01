import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/widgets/shared/open_species.dart';

// Cómo se abre el Detalle desde la hoja de zona. Va en un provider para poder comprobar los
// toques en las pruebas sin montar el router.
final openSpeciesProvider = Provider<void Function(BuildContext, Species)>(
  (ref) => openSpecies,
);

// Azar de "Sorpréndeme en esta zona"; las pruebas lo cambian por uno con semilla
final zoneRandomProvider = Provider<Random>((ref) => Random());

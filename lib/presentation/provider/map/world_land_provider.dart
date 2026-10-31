import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/ocean_map_geometry.dart';

// El GeoJSON se lee una sola vez y se interpreta en otro hilo, sin bloquear la interfaz.
// El Path proyectado lo construye el mapa según su tamaño.
final worldLandProvider = FutureProvider<List<Float64List>>((ref) async {
  final source = await rootBundle.loadString(MapConstants.landAsset);
  return compute(parseLandGeoJson, source);
});

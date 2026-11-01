import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';

class SpeciesFilters {
  // Con texto se usa /search, que no admite filtros ni pagina: los filtros se aplican
  // en el cliente sobre sus resultados (ver [matches])
  final String query;
  final String? category;
  final String? zone;
  final String? conservationStatus;
  final String? dangerLevel;
  final double? sizeMin;
  final double? sizeMax;
  final double? depthMin;
  final double? depthMax;

  const SpeciesFilters({
    this.query = '',
    this.category,
    this.zone,
    this.conservationStatus,
    this.dangerLevel,
    this.sizeMin,
    this.sizeMax,
    this.depthMin,
    this.depthMax,
  });

  // Igualdad por valor: aplicar filtros idénticos a los que ya hay no es un cambio, y sin esto
  // Riverpod trata cualquier copia como estado nuevo y la lista se recarga desde el inicio
  @override
  bool operator ==(Object other) =>
      other is SpeciesFilters &&
      other.query == query &&
      other.category == category &&
      other.zone == zone &&
      other.conservationStatus == conservationStatus &&
      other.dangerLevel == dangerLevel &&
      other.sizeMin == sizeMin &&
      other.sizeMax == sizeMax &&
      other.depthMin == depthMin &&
      other.depthMax == depthMax;

  @override
  int get hashCode => Object.hash(
    query,
    category,
    zone,
    conservationStatus,
    dangerLevel,
    sizeMin,
    sizeMax,
    depthMin,
    depthMax,
  );

  // Con un solo carácter /search no devuelve nada, así que aún no cuenta como búsqueda
  bool get hasQuery => query.trim().length >= ApiConstants.minSearchLength;

  /// Aplica los filtros a una especie en el cliente, con la misma semántica que el
  /// servidor: profundidad y tamaño son "al menos" (el rango llega a ese valor o más).
  /// Una especie sin ese dato no puede cumplir el filtro.
  bool matches(Species s) {
    if (category != null && s.category != category) return false;
    if (conservationStatus != null && s.conservationStatus != conservationStatus) {
      return false;
    }
    if (dangerLevel != null && s.dangerLevel != dangerLevel) return false;

    final depth = depthMin;
    if (depth != null && (s.depthMaxM == null || s.depthMaxM! < depth)) return false;

    final size = sizeMin;
    if (size != null && (s.sizeMaxCm == null || s.sizeMaxCm! < size)) return false;

    return true;
  }

  // Solo cuenta los filtros que Explorar muestra (la zona no se ofrece: el servidor falla)
  int get activeCount => [
    category,
    conservationStatus,
    dangerLevel,
    sizeMin,
    depthMin,
  ].where((f) => f != null).length;

  // Los campos se pasan como función para poder volver a null (quitar un filtro)
  SpeciesFilters copyWith({
    String? query,
    String? Function()? category,
    String? Function()? zone,
    String? Function()? conservationStatus,
    String? Function()? dangerLevel,
    double? Function()? sizeMin,
    double? Function()? sizeMax,
    double? Function()? depthMin,
    double? Function()? depthMax,
  }) {
    return SpeciesFilters(
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      zone: zone != null ? zone() : this.zone,
      conservationStatus: conservationStatus != null
          ? conservationStatus()
          : this.conservationStatus,
      dangerLevel: dangerLevel != null ? dangerLevel() : this.dangerLevel,
      sizeMin: sizeMin != null ? sizeMin() : this.sizeMin,
      sizeMax: sizeMax != null ? sizeMax() : this.sizeMax,
      depthMin: depthMin != null ? depthMin() : this.depthMin,
      depthMax: depthMax != null ? depthMax() : this.depthMax,
    );
  }
}

// Cambiar un filtro crea un estado nuevo; la lista lo observa y reinicia la paginación
class SpeciesFiltersNotifier extends Notifier<SpeciesFilters> {
  @override
  SpeciesFilters build() => const SpeciesFilters();

  // Aplica varios filtros de una vez para no disparar una petición por cada uno
  void apply(SpeciesFilters next) => state = next;

  void setQuery(String value) => state = state.copyWith(query: value);

  void setCategory(String? value) =>
      state = state.copyWith(category: () => value);

  void setZone(String? value) => state = state.copyWith(zone: () => value);

  void setConservationStatus(String? value) =>
      state = state.copyWith(conservationStatus: () => value);

  void setDangerLevel(String? value) =>
      state = state.copyWith(dangerLevel: () => value);

  void setSizeRange(double? min, double? max) =>
      state = state.copyWith(sizeMin: () => min, sizeMax: () => max);

  void setDepthRange(double? min, double? max) =>
      state = state.copyWith(depthMin: () => min, depthMax: () => max);

  void clear() => state = const SpeciesFilters();
}

final speciesFiltersProvider =
    NotifierProvider<SpeciesFiltersNotifier, SpeciesFilters>(
      SpeciesFiltersNotifier.new,
    );

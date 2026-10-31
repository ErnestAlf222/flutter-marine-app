import 'package:marine_app/domain/entities/species.dart';

class SpeciesPhoto {
  final String url;
  // El crédito se muestra en el detalle por la licencia de las fotos
  final String? credit;
  final bool isPrimary;

  const SpeciesPhoto({required this.url, this.credit, this.isPrimary = false});
}

class SpeciesTaxonomy {
  final String? kingdom;
  final String? phylum;
  final String? taxonomicClass;
  final String? order;
  final String? family;
  final String? genus;

  const SpeciesTaxonomy({
    this.kingdom,
    this.phylum,
    this.taxonomicClass,
    this.order,
    this.family,
    this.genus,
  });
}

// Extiende Species para poder marcar como favorita desde el detalle sin convertir
class SpeciesDetail extends Species {
  final String? fullDescription;
  final SpeciesTaxonomy taxonomy;
  final List<SpeciesPhoto> photos;
  final List<String> zones;

  const SpeciesDetail({
    required super.id,
    required super.slug,
    required super.scientificName,
    required super.commonName,
    required super.category,
    super.conservationStatus,
    super.dangerLevel,
    super.sizeMinCm,
    super.sizeMaxCm,
    super.depthMinM,
    super.depthMaxM,
    super.habitats,
    super.behaviors,
    super.shortDescription,
    super.primaryPhoto,
    super.featured,
    this.fullDescription,
    this.taxonomy = const SpeciesTaxonomy(),
    this.photos = const [],
    this.zones = const [],
  });
}

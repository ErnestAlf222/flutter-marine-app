import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/models/species_detail_response.dart';
import 'package:marine_app/infrastructure/models/species_response.dart';
import 'package:marine_app/infrastructure/models/zones_response.dart';

class SpeciesMapper {
  static Species speciesToEntity(SpeciesResponse r) => Species(
    id: r.id,
    slug: r.slug,
    scientificName: r.scientificName,
    // Sin nombre común, la ficha muestra el científico en lugar de un hueco
    commonName: r.commonName ?? r.scientificName,
    category: r.category,
    conservationStatus: r.conservationStatus,
    dangerLevel: r.dangerLevel,
    sizeMinCm: r.sizeMinCm,
    sizeMaxCm: r.sizeMaxCm,
    depthMinM: r.depthMinM,
    depthMaxM: r.depthMaxM,
    habitats: r.habitats,
    behaviors: r.behaviors,
    shortDescription: r.shortDescription,
    primaryPhoto: r.primaryPhoto,
    featured: r.featured,
    updatedAt: r.updatedAt,
  );

  // /search no trae `pagination`: se tolera con valores que no inviten a pedir más
  static SpeciesPage pageToEntity(SpeciesListResponse r) {
    final pagination = r.pagination;

    return SpeciesPage(
      items: r.data.map(speciesToEntity).toList(),
      page: pagination?.page ?? 1,
      perPage: pagination?.perPage ?? r.data.length,
      total: pagination?.total ?? r.data.length,
    );
  }

  static SpeciesDetail detailToEntity(SpeciesDetailResponse r, String lang) {
    final translation = _pickTranslation(r.translations, lang);
    final primary =
        r.photos.where((p) => p.isPrimary).firstOrNull ?? r.photos.firstOrNull;

    return SpeciesDetail(
      id: r.id,
      slug: r.slug,
      scientificName: r.scientificName,
      commonName: translation?.commonName ?? r.scientificName,
      category: r.category,
      conservationStatus: r.conservationStatus,
      dangerLevel: r.dangerLevel,
      sizeMinCm: r.sizeMinCm,
      sizeMaxCm: r.sizeMaxCm,
      depthMinM: r.depthMinM,
      depthMaxM: r.depthMaxM,
      habitats: r.habitats,
      behaviors: r.behaviors,
      shortDescription: translation?.shortDescription,
      primaryPhoto: primary?.url,
      featured: r.featured,
      fullDescription: translation?.fullDescription,
      taxonomy: SpeciesTaxonomy(
        kingdom: r.taxonomy.kingdom,
        phylum: r.taxonomy.phylum,
        taxonomicClass: r.taxonomy.taxonomicClass,
        order: r.taxonomy.order,
        family: r.taxonomy.family,
        genus: r.taxonomy.genus,
      ),
      photos: r.photos
          .map(
            (p) => SpeciesPhoto(
              url: p.url,
              credit: p.credit,
              isPrimary: p.isPrimary,
            ),
          )
          .toList(),
      zones: r.zones,
    );
  }

  static OceanZone zoneToEntity(ZoneResponse r, String lang) {
    final translations = r.translations;
    final t =
        translations.where((t) => t.language == lang).firstOrNull ??
        translations
            .where((t) => t.language == ApiConstants.fallbackLang)
            .firstOrNull ??
        translations.firstOrNull;

    final center = boundsCenter(r.bounds);

    return OceanZone(
      id: r.id,
      speciesCount: r.speciesCount,
      name: t?.name ?? r.id,
      description: t?.description ?? '',
      lat: center.lat,
      lon: center.lon,
    );
  }

  /// Centro de una zona: el que trae la API o, si solo hay límites, el punto medio
  /// de la caja. Sin datos queda en (0, 0) para que la zona siga siendo visible.
  static ({double lat, double lon}) boundsCenter(ZoneBoundsResponse? b) {
    if (b == null) return (lat: 0, lon: 0);

    final cLat = b.centerLat;
    final cLon = b.centerLon;
    if (cLat != null && cLon != null) return (lat: cLat, lon: cLon);

    final latMin = b.latMin;
    final latMax = b.latMax;
    final lonMin = b.lonMin;
    final lonMax = b.lonMax;
    if (latMin == null || latMax == null || lonMin == null || lonMax == null) {
      return (lat: 0, lon: 0);
    }

    // Una caja que cruza el antimeridiano (lon_min > lon_max) se mide por el lado corto
    final east = lonMax < lonMin ? lonMax + 360 : lonMax;
    var lon = (lonMin + east) / 2;
    if (lon > 180) lon -= 360;
    return (lat: (latMin + latMax) / 2, lon: lon);
  }

  // Idioma pedido, luego el de respaldo, luego cualquiera
  static TranslationResponse? _pickTranslation(
    List<TranslationResponse> translations,
    String lang,
  ) {
    return translations.where((t) => t.language == lang).firstOrNull ??
        translations
            .where((t) => t.language == ApiConstants.fallbackLang)
            .firstOrNull ??
        translations.firstOrNull;
  }
}

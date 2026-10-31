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

    return OceanZone(
      id: r.id,
      speciesCount: r.speciesCount,
      name: t?.name ?? r.id,
      description: t?.description ?? '',
    );
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

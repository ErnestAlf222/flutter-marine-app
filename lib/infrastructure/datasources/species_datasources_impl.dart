import 'package:dio/dio.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/mappers/species_mapper.dart';
import 'package:marine_app/infrastructure/models/species_detail_response.dart';
import 'package:marine_app/infrastructure/models/species_response.dart';
import 'package:marine_app/infrastructure/models/zones_response.dart';

class SpeciesDatasourcesImpl extends SpeciesDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ),
  );

  @override
  Future<(SpeciesPage?, String)> getSpecies({
    required String lang,
    required int page,
    required int perPage,
    String? zone,
    String? category,
    String? conservationStatus,
    String? dangerLevel,
    double? sizeMin,
    double? sizeMax,
    double? depthMin,
    double? depthMax,
    bool? featured,
  }) async {
    try {
      // Solo se envían los filtros activos: un parámetro vacío podría filtrar a cero
      final response = await _dio.get(
        ApiConstants.speciesPath,
        queryParameters: {
          'lang': lang,
          'page': page,
          'per_page': perPage.clamp(1, ApiConstants.maxPerPage),
          'zone': ?zone,
          'category': ?category,
          'conservation_status': ?conservationStatus,
          'danger_level': ?dangerLevel,
          'size_min': ?sizeMin,
          'size_max': ?sizeMax,
          'depth_min': ?depthMin,
          'depth_max': ?depthMax,
          'featured': ?featured,
        },
      );

      final data = SpeciesListResponse.fromJson(response.data);
      return (SpeciesMapper.pageToEntity(data), '');
    } catch (e) {
      return (null, _errorMessage(e));
    }
  }

  @override
  Future<(List<Species>?, String)> searchSpecies({
    required String query,
    required String lang,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchPath,
        queryParameters: {'q': query, 'lang': lang},
      );

      final data = SpeciesListResponse.fromJson(response.data);
      return (data.data.map(SpeciesMapper.speciesToEntity).toList(), '');
    } catch (e) {
      return (null, _errorMessage(e));
    }
  }

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.speciesBySlugPath}/$slug',
        queryParameters: {'lang': lang},
      );

      final data = SpeciesDetailResponse.fromJson(response.data);
      return (SpeciesMapper.detailToEntity(data, lang), '');
    } catch (e) {
      return (null, _errorMessage(e));
    }
  }

  @override
  Future<(List<OceanZone>?, String)> getZones({required String lang}) async {
    try {
      final response = await _dio.get(
        ApiConstants.zonesPath,
        queryParameters: {'lang': lang},
      );

      final data = ZonesResponse.fromJson(response.data);
      final zones = [...data.data]
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return (
        zones.map((z) => SpeciesMapper.zoneToEntity(z, lang)).toList(),
        '',
      );
    } catch (e) {
      return (null, _errorMessage(e));
    }
  }

  @override
  Future<(List<Species>?, String)> getZoneTopSpecies({
    required String zone,
    required String lang,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.zonesPath}/$zone/${ApiConstants.zoneTopSpeciesSegment}',
        queryParameters: {'lang': lang, 'limit': limit},
      );

      final data = SpeciesListResponse.fromJson(response.data);
      return (data.data.map(SpeciesMapper.speciesToEntity).toList(), '');
    } catch (e) {
      return (null, _errorMessage(e));
    }
  }

  // Mensajes en español para mostrar tal cual en la pantalla
  String _errorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'La conexión tardó demasiado. Inténtalo de nuevo.';
        case DioExceptionType.connectionError:
          return 'Sin conexión a internet.';
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode ?? 0;
          if (status == 404) return ApiConstants.notFoundMessage;
          if (status == 429) {
            return 'Demasiadas peticiones. Espera un momento e inténtalo de nuevo.';
          }
          if (status >= 500) {
            return 'El servidor tuvo un problema. Inténtalo más tarde.';
          }
          return 'La solicitud no se pudo completar (error $status).';
        default:
          return 'No se pudo completar la solicitud.';
      }
    }
    // Un tipo inesperado al leer el JSON indica que la API cambió de formato
    if (error is TypeError || error is FormatException) {
      return 'La respuesta del servidor no tiene el formato esperado.';
    }
    return 'Ocurrió un error inesperado.';
  }
}

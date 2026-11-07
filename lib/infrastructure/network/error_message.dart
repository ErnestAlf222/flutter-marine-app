import 'package:dio/dio.dart';

import 'package:marine_app/config/config.dart';

/// Convierte un fallo de Dio en uno de los tres mensajes que la presentación distingue:
/// sin conexión, no encontrado o servidor con problemas.
/// - Sin respuesta (error de conexión o tiempo de conexión/envío agotado): sin conexión.
/// - Con respuesta (5xx, 429, otros) o tiempo de espera de la respuesta, o JSON raro: servidor.
String errorMessageFor(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return ApiConstants.offlineMessage;
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 404) {
          return ApiConstants.notFoundMessage;
        }
        return ApiConstants.serverMessage;
      default:
        return ApiConstants.serverMessage;
    }
  }
  // Un tipo inesperado al leer el JSON indica que la API cambió de formato
  return ApiConstants.serverMessage;
}

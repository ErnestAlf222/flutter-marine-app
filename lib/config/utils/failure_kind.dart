import 'package:marine_app/config/constants/api_constants.dart';

/// Tipos de fallo que la presentación distingue. El datasource ya devuelve un mensaje por
/// tipo; esta función lo convierte sin cambiar el patrón (dato, mensaje) del resto del código.
enum FailureKind { offline, server, notFound, empty }

FailureKind failureKindOf(Object? error) {
  if (error == ApiConstants.offlineMessage) return FailureKind.offline;
  if (error == ApiConstants.notFoundMessage) return FailureKind.notFound;
  // Todo lo demás (5xx, 429, formato raro, errores inesperados) se cuenta como servidor
  return FailureKind.server;
}

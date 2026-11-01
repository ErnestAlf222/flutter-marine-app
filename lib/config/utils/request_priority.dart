import 'dart:async';

/// Prioridad de las peticiones. Lo que se ejecuta dentro de [runLow] (la muestra de
/// especies de una zona) cede el paso al resto de peticiones cuando se acerca el límite.
/// Viaja en la Zone de Dart para no tener que pasar un parámetro por cada capa.
class RequestPriority {
  static const Symbol _key = #marineAppLowPriority;

  static bool get isLow => Zone.current[_key] == true;

  static T runLow<T>(T Function() body) =>
      Zone.current.fork(zoneValues: {_key: true}).run(body);
}

import 'package:marine_app/config/utils/failure_kind.dart';

/// Textos y medidas de los estados amigables (sin conexión, servidor, no encontrado, vacío).
/// Tono ligero y breve, sin culpar a quien usa la app.
class FriendlyConstants {
  static const Map<FailureKind, String> messages = {
    FailureKind.offline: 'Sin señal bajo el agua. Revisa tu conexión; tus favoritos siguen aquí.',
    FailureKind.server:
        'speCies.blue se tomó un descanso. Prueba en un momento.',
    FailureKind.notFound: 'Esta especie se nos escapó. Ya no está disponible.',
    FailureKind.empty: 'Aquí todavía no hay nada.',
  };

  static const String retry = 'Reintentar';
  static const String seeFavorites = 'Ver mis favoritos';
  static const String back = 'Volver';

  // Medidas del pez: alto normal y compacto (hoja de zona, filas), y su movimiento suave
  static const double fishHeight = 88;
  static const double fishCompactHeight = 44;
  static const double fishWidthFactor = 1.7;
  static const double bobAmount = 4;
  static const int bobCycles = 3;
  static const Duration bobCycle = Duration(milliseconds: 2800);
  static const double gap = 16;
  static const double buttonGap = 8;
}

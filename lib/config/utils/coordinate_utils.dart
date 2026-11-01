/// Coordenadas en texto: "28.5° N, 16.0° O" (O = oeste, como se escribe en español).
class CoordinateUtils {
  static String format(double lat, double lon) {
    final ns = lat < 0 ? 'S' : 'N';
    final eo = lon < 0 ? 'O' : 'E';
    return '${lat.abs().toStringAsFixed(1)}° $ns, ${lon.abs().toStringAsFixed(1)}° $eo';
  }
}

/// Fotos que no llegaron: cada una se anota aquí mientras muestra su marcador de error y,
/// al volver la conexión, se les pide que lo intenten otra vez. Solo Dart: no sabe de widgets.
class PhotoRetry {
  static final Set<void Function()> _failed = <void Function()>{};

  static int get pending => _failed.length;

  static void add(void Function() retry) => _failed.add(retry);

  static void remove(void Function() retry) => _failed.remove(retry);

  /// Llama a todos los reintentos anotados (cada foto se quita al reintentar)
  static void retryAll() {
    for (final retry in [..._failed]) {
      retry();
    }
  }
}

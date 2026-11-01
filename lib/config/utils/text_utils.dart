/// Utilidades de texto para comparar sin acentos ni mayúsculas.
class TextUtils {
  static const Map<String, String> _folds = {
    'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', 'å': 'a',
    'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
    'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
    'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o',
    'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
    'ñ': 'n', 'ç': 'c',
  };

  /// Minúsculas y sin acentos: "Tiburón" -> "tiburon"
  static String fold(String text) {
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_folds[char] ?? char);
    }
    return buffer.toString();
  }

  /// ¿Lleva letras con acento o eñe? Una búsqueda sin ellas puede ser de alguien que no
  /// los escribió.
  static bool hasDiacritics(String text) {
    final lower = text.toLowerCase();
    return lower.runes.any((r) => _folds.containsKey(String.fromCharCode(r)));
  }
}

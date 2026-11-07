import 'package:marine_app/config/constants/api_constants.dart';

/// Utilidades de texto para comparar sin acentos ni mayúsculas.
class TextUtils {
  static const Map<String, String> _folds = {
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'ã': 'a',
    'å': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'ñ': 'n',
    'ç': 'c',
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

  /// Raíz de una palabra sin plural, con reglas simples del español: "ces" pasa a "z"
  /// (peces -> pez) y se quitan "es" y "s" finales (calamares -> calamar, pulpos -> pulpo).
  /// Las palabras cortas no se tocan.
  static String stem(String word) {
    if (word.length < ApiConstants.searchStemMinWord) return word;
    final lower = word.toLowerCase();

    final String root;
    if (lower.endsWith('ces')) {
      root = '${word.substring(0, word.length - 3)}z';
    } else if (lower.endsWith('es')) {
      root = word.substring(0, word.length - 2);
    } else if (lower.endsWith('s')) {
      root = word.substring(0, word.length - 1);
    } else {
      return word;
    }
    return root.length < ApiConstants.searchStemMinRoot ? word : root;
  }

  /// [stem] aplicado a cada palabra de una búsqueda
  static String stemQuery(String query) => tokens(query).map(stem).join(' ');

  /// ¿Cada palabra de [query] (sin plural) es el comienzo de alguna palabra de [text]?
  /// Sin acentos ni mayúsculas: "calamares" coincide con "Calamar común".
  static bool matchesQuery(String query, String text) {
    final wanted = TextUtils.words(stemQuery(query));
    final candidates = TextUtils.words(text);
    return wanted.every((w) => candidates.any((t) => t.startsWith(w)));
  }

  /// Palabras de una búsqueda tal como se escribieron: se separa por cualquier símbolo
  /// ("Indo-Pacífico (Mar)" -> Indo, Pacífico, Mar)
  static List<String> tokens(String text) => text
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((t) => t.isNotEmpty)
      .toList();

  /// Palabras en minúsculas y sin acentos, para comparar
  static List<String> words(String text) =>
      fold(text)
          .split(RegExp(r'[^a-z0-9]+'))
          .where((t) => t.isNotEmpty)
          .toList();
}

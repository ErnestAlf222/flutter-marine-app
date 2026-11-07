import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';

// Palabra normalizada y su raíz sin plural
typedef _Word = ({String text, String stem});

List<_Word> _wordsOf(String? text) => [
  for (final w in TextUtils.words(text ?? ''))
    (text: w, stem: TextUtils.stem(w)),
];

class _Row {
  final Species species;
  final List<_Word> es;
  final List<_Word> en;
  final List<_Word> scientific;

  _Row(CatalogEntry entry)
    : species = entry.species,
      es = _wordsOf(entry.species.commonName),
      en = _wordsOf(entry.nameEn),
      scientific = _wordsOf(entry.species.scientificName);
}

/// Índice en memoria del catálogo: una búsqueda recorre las ~1,500 filas en pocos
/// milisegundos. Sin acentos ni mayúsculas, con plurales, varias palabras en cualquier
/// orden (todas deben coincidir) y ordenado por relevancia.
class CatalogIndex {
  final List<_Row> _rows;

  CatalogIndex(List<CatalogEntry> entries)
    : _rows = entries.map(_Row.new).toList();

  int get length => _rows.length;

  List<Species> search(String query, {bool Function(Species)? filter}) {
    final wanted = TextUtils.words(query);
    final allowed = [
      for (final row in _rows)
        if (filter == null || filter(row.species)) row,
    ];
    // Sin texto no hay relevancia: se conserva el orden del servidor
    if (wanted.isEmpty) return [for (final row in allowed) row.species];

    final stems = [for (final w in wanted) TextUtils.stem(w)];
    final scored = <({double score, int order, Species species})>[];

    for (int i = 0; i < allowed.length; i++) {
      final row = allowed[i];
      double total = 0.0;
      bool matchedAll = true;

      for (int w = 0; w < wanted.length; w++) {
        final score = _wordScore(row, wanted[w], stems[w]);
        if (score == 0) {
          matchedAll = false;
          break;
        }
        total += score;
      }
      if (!matchedAll) continue;

      // A igual puntaje gana el nombre más corto (más específico)
      total -= CatalogConstants.extraWordPenalty * row.es.length;
      scored.add((score: total, order: i, species: row.species));
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.order.compareTo(b.order);
    });
    return [for (final s in scored) s.species];
  }

  // Mejor coincidencia de una palabra en cualquiera de los tres nombres (0 = ninguna)
  double _wordScore(_Row row, String word, String stem) {
    // "ces" -> "z" acierta con peces/pez pero falla con alces/alce: también se prueba
    // quitar solo la s
    final single =
        word.length >= ApiConstants.searchStemMinWord && word.endsWith('s')
        ? word.substring(0, word.length - 1)
        : word;
    const c = CatalogConstants.exactCommonEs;
    double best = _fieldScore(
      row.es,
      word,
      stem,
      single,
      c,
      CatalogConstants.prefixCommonEs,
    );
    if (best >= c) return best;

    best = _max(
      best,
      _fieldScore(
        row.en,
        word,
        stem,
        single,
        CatalogConstants.exactCommonEn,
        CatalogConstants.prefixCommonEn,
      ),
    );
    return _max(
      best,
      _fieldScore(
        row.scientific,
        word,
        stem,
        single,
        CatalogConstants.exactScientific,
        CatalogConstants.prefixScientific,
      ),
    );
  }

  double _max(double a, double b) => a > b ? a : b;

  double _fieldScore(
    List<_Word> words,
    String word,
    String stem,
    String single,
    double exact,
    double prefix,
  ) {
    double best = 0.0;
    for (final w in words) {
      // Palabra completa: igual, o igual una vez quitado el plural ("calamares" ~ "calamar")
      if (w.text == word ||
          w.text == stem ||
          w.text == single ||
          w.stem == stem) {
        return exact;
      }
      if (best < prefix &&
          (w.text.startsWith(stem) ||
              w.text.startsWith(word) ||
              w.text.startsWith(single))) {
        best = prefix;
      }
    }
    return best;
  }
}

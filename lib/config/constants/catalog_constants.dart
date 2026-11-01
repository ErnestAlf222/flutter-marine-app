/// Catálogo local: de cuánto en cuánto se baja, cuándo se actualiza y cómo se puntúa
/// la búsqueda.
class CatalogConstants {
  // La API recorta a 100 por página; con 1,505 especies son 16 páginas y la 17 da 500,
  // así que se para en la última según el total que devuelve la propia API
  static const int perPage = 100;

  // Pasado este tiempo desde la última sincronización completa se vuelve a bajar en
  // segundo plano y solo se reescribe lo que cambió en updated_at
  static const Duration refreshAfter = Duration(days: 7);

  // Relevancia por palabra de la búsqueda: palabra completa antes que prefijo y el
  // nombre común (español, luego inglés) antes que el científico
  static const double exactCommonEs = 100;
  static const double prefixCommonEs = 80;
  static const double exactCommonEn = 60;
  static const double prefixCommonEn = 50;
  static const double exactScientific = 40;
  static const double prefixScientific = 30;
  // Desempate: a igual puntaje, el nombre con menos palabras (más específico) primero
  static const double extraWordPenalty = 0.01;

  // Indicador de la primera sincronización en Explorar
  static const String preparing = 'Preparando el catálogo';
  static String progress(int step, int total) => '$preparing… $step de $total';
}

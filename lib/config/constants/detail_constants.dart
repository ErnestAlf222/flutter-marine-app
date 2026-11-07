/// Textos del Detalle de especie: botón de la foto, clasificación y créditos.
class DetailConstants {
  // Botón de la foto: etiqueta visible y tooltip según el modo al que lleva
  static const String showWhole = 'Ver completa';
  static const String showWholeTooltip = 'Ver la foto entera';
  static const String fillFrame = 'Llenar';
  static const String fillFrameTooltip = 'Llenar el marco';

  // Galería de fotos
  static const String swipeHint = 'Desliza para ver más fotos';
  static String photoCounter(int current, int total) => '$current/$total';

  // Clasificación científica
  static const String taxonomyTitle = 'Clasificación';
  static const String taxonomyIntro =
      'Así se agrupa esta especie en la ciencia';
  static const String taxonomyExpand = 'Ver clasificación completa';
  static const String taxonomyCollapse = 'Ver menos';
  static const String uncertainPosition = '(posición incierta)';
  static const String uncertainMarker = 'incertae sedis';

  static const String kingdom = 'Reino';
  static const String phylum = 'Filo';
  static const String taxonomicClass = 'Clase';
  static const String order = 'Orden';
  static const String family = 'Familia';
  static const String genus = 'Género';

  // Botón y hoja de créditos: sin crédito de foto solo queda la atribución de los datos
  static const String creditsButton = 'Créditos';
  static const String creditsTitle = 'Créditos';
  static const String photoCreditTitle = 'Crédito de la foto';
  static const String dataCredit = 'Datos: speCies.blue (CC BY-SA 4.0)';
  static const String openLinkError = 'No se pudo abrir el enlace.';
}

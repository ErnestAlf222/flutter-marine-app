/// Medidas del mapa de zonas dibujado por nosotros (sin teselas).
class MapConstants {
  static const String landAsset = 'assets/geo/ne_110m_land.geojson';

  // Franja de latitudes que se dibuja: sin la Antártida ni el extremo ártico
  static const double latMin = -58;
  static const double latMax = 78;

  // Latitud y longitud sobre las que se centra la vista inicial. Las siete zonas
  // van de -130° a 135° de longitud: ese es el tramo que debe caber de entrada
  static const double initialCenterLat = 20;
  static const double initialCenterLon = 2.5;

  // Ancho del mundo respecto al del marco: 1.25 deja ver ~300° de longitud
  static const double worldWidthFactor = 1.25;

  // Zoom del mapa completo y del mini mapa
  static const double minScale = 1;
  static const double maxScale = 5;

  // Altura del mapa completo como fracción de la pantalla
  static const double panelHeightFraction = 0.42;
  static const double compactHeight = 160;

  // Círculos: radio entre mínimo y máximo según species_count; al acercar crecen
  // poco (exponente < 1) y con tope, para que no tapen el mapa
  static const double circleMinRadius = 11;
  static const double circleMaxRadius = 26;
  static const double zoomGrowthExponent = 0.35;
  static const double zoomGrowthMax = 1.5;
  static const double compactRadius = 9;

  // Toque: distancia extra al borde del círculo que aún cuenta como acierto
  static const double hitSlop = 24;

  // Etiquetas
  static const double labelGap = 6;
  static const double labelFontSize = 11;

  // Mini mapa: margen alrededor de las zonas resaltadas y mínimo de grados que se muestran
  static const double compactLonPadding = 28;
  static const double compactLatPadding = 20;
  static const double compactMinLonSpan = 80;
  static const double compactMinLatSpan = 40;
  static const double compactDimmedAlpha = 0.28;

  // Brillo de los círculos
  static const double glowAlpha = 0.85;
  static const double coreRadiusFactor = 0.32;
}

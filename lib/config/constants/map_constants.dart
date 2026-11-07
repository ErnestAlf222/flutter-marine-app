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

  // Hoja de una zona: arranca baja para dejar ver el mapa y se arrastra hasta casi toda
  // la pantalla
  static const double sheetInitialFraction = 0.30;
  static const double sheetMaxFraction = 0.85;

  // Al abrir una zona el mapa se acerca a este zoom (si estaba más lejos) y la centra en
  // la parte que la hoja deja libre. Si la hoja sube tanto que casi no deja mapa, se
  // centra como si quedaran al menos estos dp libres
  static const double focusScale = 2.2;
  static const double minFreeHeight = 40;
  // Las demás zonas se atenúan mientras hay una seleccionada
  static const double unselectedAlpha = 0.5;
  static const double selectedRingWidth = 3;

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

  // Hoja de una zona
  static const String sampleTitle = 'Muestra de especies de esta zona';
  static const String centerLabel = 'Centro aproximado';
  // Lo que se calcula con las especies que ya llegaron (sin peticiones extra)
  static String basedOnSample(int n) => n == 1
      ? 'Según una muestra de 1 especie'
      : 'Según una muestra de $n especies';
  static String basedOnFeatured(int n) => n == 1
      ? 'Según la única especie destacada'
      : 'Según las $n especies destacadas';
  static const String recordsTitle = 'Récords de la zona';
  static const String recordLargest = 'Más grande';
  static const String recordDeepest = 'Llega más profundo';
  static const String recordThreatened = 'Más amenazada';
  static const String groupsTitle = 'Grupos en la muestra';
  static const String surpriseLabel = 'Sorpréndeme en esta zona';
  static const double recordCardPhotoHeight = 84;
  static const double recordCardGap = 10;

  static const double shareBarHeight = 6;
  static const double shareTrackAlpha = 0.15;
}

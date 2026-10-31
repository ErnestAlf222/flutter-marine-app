/// Medidas del lenguaje visual: fotos a sangre, héroe cover-flow y mosaico.
class DesignConstants {
  static const double cardRadius = 28;
  static const double tileRadius = 20;

  // Marco vertical 4:5 de las tarjetas de foto (ancho / alto)
  static const double photoAspect = 4 / 5;

  static const double pagePadding = 20;
  static const double sectionGap = 32;

  // Tamaño máximo en memoria de las fotos; las originales pueden ser enormes
  static const int heroPhotoCacheWidth = 900;
  static const int tilePhotoCacheWidth = 600;
  static const int backdropCacheWidth = 160;

  // Texto sobre foto: el degradado oscuro cubre la parte baja
  static const double scrimCoverage = 0.55;
  static const double scrimAlpha = 0.88;

  // Tarjeta del héroe: lleva más texto, así que el tramo totalmente oscuro es más
  // alto. Con alfa 0.88 el sobretítulo conserva más de 8:1 sobre una foto blanca
  static const double heroScrimSolid = 0.55;
  static const double heroScrimCoverage = 0.9;

  // Detalle: la foto ocupa más de la mitad y el degradado cubre el bloque de nombres
  static const double detailHeaderFraction = 0.62;
  static const double detailScrimSolid = 0.3;

  // Fondo borroso del héroe
  static const double backdropBlur = 28;
  static const double backdropDim = 0.55;

  // Botón de vidrio
  static const double glassBlur = 14;
  static const double glassAlpha = 0.32;
  static const double glassSize = 48;

  // Héroe de destacadas
  static const double heroHeightFraction = 0.6;
  static const double heroViewportFraction = 0.72;
  static const double heroSideAngle = 0.7; // radianes de giro en Y
  static const double heroPerspective = 0.0015;
  static const double heroSideScale = 0.82;
  static const double heroSideOpacity = 0.55;

  // "Aguas profundas": el atajo abre Explorar con depth_min en este valor (metros)
  static const double deepWaterMinM = 100;

  // Scroll infinito: se pide la página siguiente a esta distancia del final (px)
  static const double loadMoreExtent = 600;

  // Fichas de grupo
  static const double categoryTileHeight = 92;
  static const double gridGap = 12;

  // Mosaico "Descubre más": cuántas especies se muestran y proporciones que se
  // repiten para dar alturas variadas (ancho / alto)
  static const int discoverCount = 8;
  static const int discoverFetch = 12;
  static const List<double> mosaicAspects = [
    0.8,
    1.05,
    0.9,
    0.72,
    1.0,
    0.85,
    0.7,
    1.1,
  ];
}

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

  // Burbuja de filtros: círculo de 56 dp que se pega a un borde y, sin uso, se
  // minimiza a una pestaña de 24 dp de ancho
  static const double bubbleSize = 56;
  static const double bubbleMargin = 12;
  static const double bubbleTabWidth = 24;
  // Altura inicial como fracción del recorrido (0 arriba, 1 abajo)
  static const double bubbleStartY = 0.78;

  // Pez cargador: alto por defecto y cuánto más ancho es su recorrido
  static const double fishSize = 40;
  static const double fishTrackFactor = 3;
  // Más pequeño sobre las fotos que cargan
  static const double fishPhotoSize = 22;

  // Detalle: la foto se recorta (cover) salvo que el recorte sea extremo, es decir,
  // que se pierda más de esta fracción (0.45 = 45 %) del ancho o del alto de la foto.
  // Solo entonces se muestra entera sobre un fondo borroso.
  static const double maxCropLoss = 0.45;

  // Visor de foto a pantalla completa: se decodifica más grande para poder acercar
  static const int viewerCacheWidth = 2000;
  static const double viewerMaxScale = 5;

  // Corazón de favorito (círculo e icono): 48/30 dp en las tarjetas y 56/34 dp en el
  // héroe de Inicio y el Detalle. Ninguno baja del mínimo táctil de 48 dp
  // Escala de conservación: nivel normal y nivel activo (más alto)
  static const double scaleHeight = 34;
  static const double scaleActiveHeight = 46;

  static const double favoriteTileSize = 48;
  static const double favoriteTileIcon = 30;
  static const double favoriteLargeSize = 56;
  static const double favoriteLargeIcon = 34;

  // Botón del crédito: más pequeño que el resto de botones de vidrio
  static const double creditButtonSize = 40;

  // Fondo borroso del héroe
  static const double backdropBlur = 28;
  static const double backdropDim = 0.55;

  // Botón de vidrio
  static const double glassBlur = 14;
  static const double glassAlpha = 0.32;
  static const double glassSize = 48;
  // Borde fino y luz suave del cristal
  static const double glassBorderAlpha = 0.18;
  static const double glassBorderWidth = 1;
  static const double glassLightAlpha = 0.14;
  // Hojas y chips grandes llevan más tinte para que el texto siga legible
  static const double glassSheetAlpha = 0.55;

  // Cabecera de Inicio sobre el héroe: nombre (~28) + espacio + buscador (56) + márgenes
  static const double homeHeaderHeight = 132;

  // Hoja de filtros de Explorar: fracción del alto de pantalla que ocupa
  static const double filterSheetHeightFraction = 0.85;

  // Espacio al final de las listas para que el botón flotante no tape la última fila
  static const double fabClearance = 96;

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

  // Tarjetas de especies destacadas en la hoja de una zona
  static const double zoneTileWidth = 160;
  static const double zoneTileHeight = 210;

  // Colecciones de Inicio
  static const double collectionCardHeight = 104;

  // Parallax de la foto dentro de las tarjetas: cuántos px se desplaza hacia cada lado
  static const double parallaxTravel = 18;

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

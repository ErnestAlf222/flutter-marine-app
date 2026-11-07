/// Valores del modo sin conexión: qué se guarda, cuánto y los avisos.
class OfflineConstants {
  // Últimos detalles vistos que se conservan (los favoritos no cuentan ni se expulsan)
  static const int detailCacheLimit = 100;

  // Clave de la caché de fotos de favoritos: otra carpeta y otra base que la de por defecto
  // (200 objetos y 30 días, expulsando por menos usado), para que otras fotos no las saquen
  static const String favoritePhotoCacheKey = 'favoritePhotos';
  static const int favoritePhotoMaxObjects = 5000;
  static const Duration favoritePhotoStale = Duration(days: 3650);

  // Claves de lo guardado en la tabla genérica
  static const String featuredKey = 'featured';
  static const String zonesKey = 'zones';
  // Slugs de las 8 destacadas del héroe del arranque anterior
  static const String heroSlugsKey = 'heroSlugs';

  // Cuánto se espera a que el catálogo local diga si está listo antes de usar el servidor
  static const Duration catalogWait = Duration(seconds: 3);

  // Tiempo mínimo del pez de la primera carga de Inicio, para que no parpadee
  static const Duration firstLoadMinimum = Duration(milliseconds: 600);
  // Con datos guardados llegan en pocos ms: el pez espera un poco antes de aparecer
  static const Duration firstLoadFishDelay = Duration(milliseconds: 150);

  // Avisos
  static const String savedStrip = 'Sin conexión · mostrando lo guardado';
  static const String backOnline = 'De vuelta en línea';
  static const Duration backOnlineDuration = Duration(seconds: 2);

  // Etiquetas de contenido guardado que se está mostrando (para la franja)
  static const String savedFeatured = 'featured';
  static const String savedZones = 'zones';
  static const String savedCatalog = 'catalog';
  static String savedDetail(String slug) => 'detail:$slug';

  // Tope de descargas de fotos de favoritos a la vez
  static const int photoPrefetchConcurrency = 3;
}

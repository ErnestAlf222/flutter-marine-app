/// Rutas de la app. Centralizadas para que router, shell y pantallas
/// no dependan de textos sueltos.
class RouteConstants {
  static const String home = '/';
  static const String explore = '/explore';
  static const String favorites = '/favorites';
  static const String about = '/about';

  // El slug identifica la especie en la URL y es el tag del Hero
  static const String speciesParam = 'slug';
  static const String species = '/species/:$speciesParam';

  static String speciesLocation(String slug) => '/species/$slug';
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Valores de la API. La URL base sale del .env para no escribirla en las capas.
class ApiConstants {
  // Nombre de la variable en el .env; se aísla aquí para que no se repita como texto suelto
  static const String _baseUrlKey = 'API_BASE_URL';

  // `dotenv.get` lanza error si falta la variable: preferible a una URL vacía
  // que fallaría más tarde con un mensaje confuso de Dio.
  static String get baseUrl => dotenv.get(_baseUrlKey);

  // Rutas relativas a la URL base
  static const String speciesPath = '/species';
  static const String searchPath = '/search';
  static const String zonesPath = '/zones';
  static const String speciesBySlugPath = '/species/by-slug';

  // El servidor recorta a 100 sin avisar, así que el tope se respeta aquí
  static const int defaultPerPage = 20;
  static const int maxPerPage = 100;

  // Tamaño de la página de destacadas que muestra el carrusel de Inicio
  static const int featuredPerPage = 8;

  // El detalle lo compara para distinguir un 404 de otros errores
  static const String notFoundMessage = 'No se encontró lo que buscabas.';

  // Idioma fijo de la app en la v1; los providers lo pasan como `lang`
  static const String appLang = 'es';

  // Si falta la traducción pedida se usa este idioma
  static const String fallbackLang = 'en';

  // Pausa tras la última tecla antes de buscar: el límite es de 100 peticiones por minuto
  static const Duration searchDebounce = Duration(milliseconds: 600);

  // Holgados: la API llega a tardar 5 s por petición
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

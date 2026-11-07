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
  // /zones/{slug}/top-species: destacadas de una zona
  static const String zoneTopSpeciesSegment = 'top-species';
  static const int zoneTopLimit = 12;
  // Tras un "Reintentar" que también falla se dice con claridad, sin ofrecer otro intento
  static const String zoneRetryFailedMessage =
      'Probamos de nuevo y el servidor de speCies.blue sigue sin responder.';

  // Muestra de una zona armada desde los detalles (top-species falla en 6 de 7 zonas):
  // se mide con curl que ~1 de cada 3 destacadas trae una zona cualquiera. Hasta 8 especies,
  // 4 detalles a la vez y como mucho 24 detalles por zona (25 peticiones con la página de
  // destacadas); si fallan 4 detalles se deja de insistir
  static const int zoneSampleSize = 8;
  static const int zoneSampleConcurrency = 4;
  static const int zoneSampleMaxDetails = 24;
  static const int zoneSampleMaxFailures = 4;
  static const int zoneSamplePool = 100;
  static const String speciesBySlugPath = '/species/by-slug';

  // El servidor recorta a 100 sin avisar, así que el tope se respeta aquí
  static const int defaultPerPage = 20;
  static const int maxPerPage = 100;

  // Tamaño de la página de destacadas que muestra el carrusel de Inicio
  static const int featuredPerPage = 8;

  // El detalle lo compara para distinguir un 404 de otros errores
  static const String notFoundMessage = 'No se encontró lo que buscabas.';

  // Los otros dos tipos de fallo, que la presentación convierte en estados amigables:
  // sin conexión (no hubo respuesta) y servidor con problemas (5xx, 429 o respuesta rara)
  static const String offlineMessage = 'Sin conexión a internet.';
  static const String serverMessage =
      'El servidor tuvo un problema. Inténtalo más tarde.';
  static const String unexpectedMessage = 'Ocurrió un error inesperado.';
  static const String noSpeciesMessage = 'No se encontró ninguna especie.';

  // Idioma fijo de la app en la v1; los providers lo pasan como `lang`
  static const String appLang = 'es';

  // Si falta la traducción pedida se usa este idioma
  static const String fallbackLang = 'en';

  // /search devuelve como máximo 50 resultados (medido con varias consultas) y con un solo
  // carácter no devuelve nada, así que la búsqueda por texto exige al menos 2
  static const int searchResultCap = 50;
  static const int minSearchLength = 2;

  // El servidor distingue acentos: "tiburon" no devuelve nada y "tibur" devuelve 45 "Tiburón…"
  // (medido con curl). Si una búsqueda sin acentos vuelve vacía se reintenta con prefijos más
  // cortos —sin los dos últimos caracteres cada vez, con este mínimo— y se filtra en el cliente.
  // Como mucho 2 peticiones extra por búsqueda, por el límite de 100 por minuto.
  static const int searchFallbackTrim = 2;
  static const int searchFallbackMinLength = 3;
  static const int searchFallbackMaxRequests = 2;

  // Plurales del español: solo se recortan palabras de al menos 4 letras y la raíz
  // resultante conserva al menos 3 ("peces" -> "pez", "mas" se queda igual)
  static const int searchStemMinWord = 4;
  static const int searchStemMinRoot = 3;

  // Pausa tras la última tecla antes de buscar: el límite es de 100 peticiones por minuto
  static const Duration searchDebounce = Duration(milliseconds: 600);

  // Límite anónimo: 100 peticiones por minuto. Cerca del límite (por defecto 90) las demás
  // se ponen en cola en vez de dispararse, para esperar un poco y no recibir errores. Las de
  // baja prioridad (la muestra de zonas) ceden el paso a las de la pantalla que se ve y solo
  // salen mientras haya menos de rateLimitLowThreshold en la ventana, dejando holgura
  static const int rateLimit = 100;
  static const int rateLimitThreshold = 90;
  static const int rateLimitLowThreshold = 60;
  static const Duration rateLimitWindow = Duration(minutes: 1);

  // Holgados: la API llega a tardar 5 s por petición
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

import 'package:material_ui/material_ui.dart';

/// Movimiento de la app: una sola curva y duraciones entre 350 y 500 ms.
class MotionConstants {
  static const Curve curve = Curves.easeOutCubic;

  // Excepción a la curva única: el rebote del corazón necesita elasticidad
  static const Curve bounce = Curves.elasticOut;

  // El mapa se acerca y centra la zona seleccionada
  static const Duration mapFocus = Duration(milliseconds: 650);

  // Carrusel del héroe de Inicio: cada cuánto avanza solo, cuánto dura el desplazamiento
  // y cuánto espera para reanudar tras soltarlo
  static const Duration heroAutoAdvance = Duration(seconds: 3);
  static const Duration heroAdvance = Duration(milliseconds: 700);
  static const Duration heroResumeDelay = Duration(seconds: 5);

  // Burbujas que suben desde el corazón al marcar un favorito (duran `long`)
  static const int bubbleCount = 6;
  static const double bubbleRise = 72;
  static const double bubbleDrift = 18;
  static const double bubbleMinSize = 4;
  static const double bubbleMaxSize = 9;

  // Cambio de pestaña: la que entra sube este tanto (px) mientras se desvanece
  static const double tabShift = 12;

  // Escala a la que se encoge una tarjeta al quitarla de favoritos
  static const double removeScale = 0.8;

  static const Duration short =Duration(milliseconds: 350);
  static const Duration medium = Duration(milliseconds: 450);
  static const Duration long = Duration(milliseconds: 500);

  // Entrada escalonada: cada elemento espera un paso más que el anterior,
  // con tope para que los últimos de una lista larga no tarden en aparecer
  static const Duration staggerStep = Duration(milliseconds: 60);
  static const int staggerMaxIndex = 8;

  // Ida y vuelta completa del pez cargador
  static const Duration fishCycle = Duration(milliseconds: 2400);

  // Ciclo del brillo de los esqueletos de carga
  static const Duration shimmer = Duration(milliseconds: 1400);

  // Desplazamiento vertical inicial de la entrada escalonada (fracción del alto)
  static const double enterSlide = 0.08;

  // Salir del Detalle: la pantalla se encoge a esta escala mientras se desvanece y el fondo
  // se oscurece hasta este alfa
  static const double minimizeScale = 0.85;
  static const double minimizeDim = 0.6;

  // Arrastrar hacia abajo para cerrar el Detalle: el recorrido completo es esta fracción del
  // alto de pantalla; a ese recorrido la escala llega a pullMinScale. Se cierra al soltar
  // pasado el umbral (fracción del recorrido) o con un tirón rápido (px/s); si no, vuelve
  // con un resorte
  static const double pullMinScale = 0.85;
  static const double pullRange = 0.4;
  static const double pullDismissAt = 0.3;
  static const double pullFlingVelocity = 700;
  static const double pullSlop = 8;
  static const double pullSpringStiffness = 300;
  static const double pullSpringDamping = 0.7;

  // Ampliar la foto (ver completa / llenar y el visor): solo un fundido corto, sin escalas
  // llamativas ni rebotes
  static const Duration photoFade = Duration(milliseconds: 200);
  static const Curve photoFadeCurve = Curves.easeOut;

  // Recorrer la foto en "Llenar": la barrita de posición se desvanece al segundo de soltar y
  // el arrastre cuenta como horizontal pasados pocos píxeles
  static const Duration panBarHide = Duration(seconds: 1);
  static const double panSlop = 6;
  static const double panMinFling = 50;

  // Aviso "Desliza para ver más fotos": cuánto se queda antes de desvanecerse
  static const Duration galleryHint = Duration(seconds: 3);
}

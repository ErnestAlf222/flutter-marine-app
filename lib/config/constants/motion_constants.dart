import 'package:material_ui/material_ui.dart';

/// Movimiento de la app: una sola curva y duraciones entre 350 y 500 ms.
class MotionConstants {
  static const Curve curve = Curves.easeOutCubic;

  // Excepción a la curva única: el rebote del corazón necesita elasticidad
  static const Curve bounce = Curves.elasticOut;

  // Escala a la que se encoge una tarjeta al quitarla de favoritos
  static const double removeScale = 0.8;

  static const Duration short =Duration(milliseconds: 350);
  static const Duration medium = Duration(milliseconds: 450);
  static const Duration long = Duration(milliseconds: 500);

  // Entrada escalonada: cada elemento espera un paso más que el anterior,
  // con tope para que los últimos de una lista larga no tarden en aparecer
  static const Duration staggerStep = Duration(milliseconds: 60);
  static const int staggerMaxIndex = 8;

  // Ciclo del brillo de los esqueletos de carga
  static const Duration shimmer = Duration(milliseconds: 1400);

  // Desplazamiento vertical inicial de la entrada escalonada (fracción del alto)
  static const double enterSlide = 0.08;
}

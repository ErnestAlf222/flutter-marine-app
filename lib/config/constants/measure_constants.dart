import 'package:material_ui/material_ui.dart';

/// Objeto cotidiano que sirve de referencia en la barra de tamaño.
class SizeReference {
  final String label;
  final double cm;
  final IconData icon;

  const SizeReference({
    required this.label,
    required this.cm,
    required this.icon,
  });
}

/// Escalas del medidor de profundidad y de la barra de tamaño del detalle.
class MeasureConstants {
  // Anchura disponible desde la que ambas tarjetas van en fila; por debajo se apilan
  static const double sideBySideWidth = 600;

  // El máximo de la escala de profundidad es el primer paso que alcanza a la especie
  static const List<double> depthScaleSteps = [
    10,
    20,
    50,
    100,
    200,
    500,
    1000,
    2500,
  ];

  // La talla va de 3 cm a 30 m: una escala lineal aplastaría casi todo, así que es logarítmica
  static const double sizeScaleMinCm = 1;
  static const double sizeScaleMaxCm = 3000;

  // Pasos de los controles de Explorar; 0 significa "sin filtro". Los filtros de la
  // API son por solapamiento hacia un solo lado: depth_min = "llega al menos a X m"
  // y size_min = "alcanza al menos X cm" (medido contra el servidor)
  static const List<double> depthFilterSteps = [0, 10, 25, 50, 100, 200, 500, 1000, 2000];
  static const List<double> sizeFilterSteps = [0, 10, 25, 50, 100, 200, 500, 1000];

  // Textos de las tarjetas: qué rango se muestra y qué significan los extremos
  static const String depthQuestion = 'Entre qué profundidades se le encuentra';
  static const String sizeQuestion = 'Entre qué tamaños se le encuentra';
  static const String surfaceLabel = 'Superficie';
  // "Hasta N m": el final de la escala de la especie, no el fondo del mar
  static const String untilLabel = 'Hasta';
  static const String smallLabel = 'Más pequeño';
  static const String largeLabel = 'Más grande';

  static const List<SizeReference> sizeReferences = [
    SizeReference(label: 'Moneda', cm: 2.5, icon: Icons.monetization_on_outlined),
    SizeReference(label: 'Mano', cm: 18, icon: Icons.back_hand_outlined),
    SizeReference(label: 'Persona', cm: 170, icon: Icons.person_outline),
    SizeReference(label: 'Autobús', cm: 1200, icon: Icons.directions_bus_outlined),
  ];
}

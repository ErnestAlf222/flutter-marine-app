import 'dart:ui';

import 'package:marine_app/config/constants/design_constants.dart';

// Lógica pura de la burbuja que se arrastra y se pega a un borde (sin widgets).

/// Dónde está la burbuja: a qué lado, a qué altura (0 = tope, 1 = fondo del recorrido)
/// y si está minimizada como una pestaña pegada al borde.
class BubblePlacement {
  final bool onRight;
  final double yFraction;
  final bool minimized;

  const BubblePlacement({
    this.onRight = true,
    this.yFraction = DesignConstants.bubbleStartY,
    this.minimized = false,
  });

  BubblePlacement copyWith({bool? onRight, double? yFraction, bool? minimized}) =>
      BubblePlacement(
        onRight: onRight ?? this.onRight,
        yFraction: yFraction ?? this.yFraction,
        minimized: minimized ?? this.minimized,
      );

  @override
  bool operator ==(Object other) =>
      other is BubblePlacement &&
      other.onRight == onRight &&
      other.yFraction == yFraction &&
      other.minimized == minimized;

  @override
  int get hashCode => Object.hash(onRight, yFraction, minimized);
}

/// Alto mínimo y máximo (esquina superior) por los que puede moverse la burbuja.
/// [area] es la zona visible sobre la barra de navegación, así que nunca queda debajo de ella.
({double min, double max}) bubbleTravel({
  required Size area,
  required double topInset,
  double size = DesignConstants.bubbleSize,
  double margin = DesignConstants.bubbleMargin,
}) {
  final min = topInset + margin;
  final max = area.height - size - margin;
  // Con un área muy baja (teclado abierto) el recorrido se reduce a un punto
  return (min: min, max: max < min ? min : max);
}

/// Esquina superior izquierda de la burbuja para una ubicación dada.
Offset bubbleOrigin({
  required BubblePlacement placement,
  required Size area,
  required double topInset,
  double size = DesignConstants.bubbleSize,
  double margin = DesignConstants.bubbleMargin,
  double tabWidth = DesignConstants.bubbleTabWidth,
}) {
  final travel = bubbleTravel(area: area, topInset: topInset, size: size, margin: margin);
  final top = travel.min + (travel.max - travel.min) * placement.yFraction;

  final double left;
  if (placement.minimized) {
    left = placement.onRight ? area.width - tabWidth : 0;
  } else {
    left = placement.onRight ? area.width - margin - size : margin;
  }
  return Offset(left, top);
}

/// Al soltar: se pega al borde más cercano y recuerda la altura (limitada al recorrido).
BubblePlacement snapBubble({
  required Offset topLeft,
  required Size area,
  required double topInset,
  double size = DesignConstants.bubbleSize,
  double margin = DesignConstants.bubbleMargin,
}) {
  final travel = bubbleTravel(area: area, topInset: topInset, size: size, margin: margin);
  final span = travel.max - travel.min;
  final fraction = span <= 0 ? 0.0 : ((topLeft.dy - travel.min) / span).clamp(0.0, 1.0);

  return BubblePlacement(
    onRight: topLeft.dx + size / 2 > area.width / 2,
    yFraction: fraction,
  );
}

/// Posición durante el arrastre: sigue al dedo sin salirse del área visible.
Offset clampBubble({
  required Offset topLeft,
  required Size area,
  required double topInset,
  double size = DesignConstants.bubbleSize,
  double margin = DesignConstants.bubbleMargin,
}) {
  final travel = bubbleTravel(area: area, topInset: topInset, size: size, margin: margin);
  return Offset(
    topLeft.dx.clamp(margin, area.width - margin - size).toDouble(),
    topLeft.dy.clamp(travel.min, travel.max).toDouble(),
  );
}

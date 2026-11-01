import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Opacidad del degradado a [distance] (0 en el borde oscuro, 1 en el opuesto).
double scrimAlphaAt(
  double distance, {
  required double solid,
  required double coverage,
  double strength = 1,
}) {
  final fade = ((distance - solid) / (coverage - solid)).clamp(0.0, 1.0);
  return DesignConstants.scrimAlpha * strength * (1 - fade);
}

// Degradado oscuro para que el texto sobre una foto se lea; va dentro de un Stack
class PhotoScrim extends StatelessWidget {
  // Lado donde el degradado es más oscuro
  final Alignment begin;
  // 0 a 1: escala la opacidad máxima
  final double strength;
  // Fracción del alto que cubre el degradado hasta desvanecerse
  final double coverage;
  // Fracción del alto donde la opacidad se mantiene al máximo antes de desvanecerse
  final double solid;

  const PhotoScrim({
    super.key,
    this.begin = Alignment.bottomCenter,
    this.strength = 1,
    this.coverage = DesignConstants.scrimCoverage,
    this.solid = 0,
  });

  @override
  Widget build(BuildContext context) {
    final ink = OceanPalette.of(context).ink;
    final alpha = DesignConstants.scrimAlpha * strength;

    return SizedBox.expand(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: Alignment(-begin.x, -begin.y),
              stops: [0, solid, coverage],
              colors: [
                ink.withValues(alpha: alpha),
                ink.withValues(alpha: alpha),
                ink.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Barra horizontal en escala logarítmica con objetos de referencia para dar idea de talla
class SizeBar extends StatelessWidget {
  final double? minCm;
  final double? maxCm;

  const SizeBar({super.key, required this.minCm, required this.maxCm});

  static const double _trackTop = 40;
  static const double _trackHeight = 12;
  static const double _labelWidth = 64;

  // "20 cm" por debajo del metro y "1,2 m" desde ahí, con coma decimal
  static String format(double cm) {
    String trim(double v) {
      final text = v.toStringAsFixed(1);
      return (text.endsWith('.0') ? text.substring(0, text.length - 2) : text)
          .replaceAll('.', ',');
    }

    return cm < 100 ? '${trim(cm)} cm' : '${trim(cm / 100)} m';
  }

  // Posición 0 a 1 sobre la escala logarítmica
  static double _position(double cm) {
    const lo = MeasureConstants.sizeScaleMinCm;
    const hi = MeasureConstants.sizeScaleMaxCm;
    final v = cm.clamp(lo, hi);
    return (log(v) - log(lo)) / (log(hi) - log(lo));
  }

  @override
  Widget build(BuildContext context) {
    if (minCm == null && maxCm == null) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    // Con un solo dato se dibuja una marca puntual
    final a = minCm ?? maxCm!;
    final b = maxCm ?? minCm!;
    final lo = min(a, b);
    final hi = max(a, b);
    final rangeText = lo == hi ? format(lo) : '${format(lo)} – ${format(hi)}';

    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: 'Tamaño: $rangeText',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.deep.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(DesignConstants.tileRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TAMAÑO', style: textTheme.overline.copyWith(color: accent)),
                const SizedBox(height: 6),
                Text(
                  rangeText,
                  style: textTheme.headlineSmall?.copyWith(color: palette.paper),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 88,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final xLo = _position(lo) * width;
                      final xHi = _position(hi) * width;
                      // Una marca puntual conserva un ancho mínimo para verse
                      final span = max(xHi - xLo, 10.0);

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: animate ? 0 : 1, end: 1),
                        duration: animate ? MotionConstants.long : Duration.zero,
                        curve: MotionConstants.curve,
                        builder: (context, fill, _) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: _trackTop,
                              height: _trackHeight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: palette.abyss,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            for (final ref in MeasureConstants.sizeReferences)
                              _mark(context, ref, width),
                            Positioned(
                              left: min(xLo, width - span),
                              top: _trackTop - 4,
                              width: span * fill,
                              height: _trackHeight + 8,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: palette.paper, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Icono arriba, marca que cruza la barra y etiqueta debajo
  Widget _mark(BuildContext context, SizeReference ref, double width) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final x = _position(ref.cm) * width;
    // Las etiquetas de los extremos no deben salirse de la tarjeta
    final left = (x - _labelWidth / 2)
        .clamp(0.0, max(0.0, width - _labelWidth))
        .toDouble();
    final color = palette.paper.withValues(alpha: 0.75);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: left,
          width: _labelWidth,
          top: 0,
          child: Icon(ref.icon, size: 20, color: color),
        ),
        Positioned(
          left: x - 0.5,
          width: 1,
          top: 24,
          height: 36,
          child: ColoredBox(color: color),
        ),
        Positioned(
          left: left,
          width: _labelWidth,
          top: 62,
          child: Text(
            '${ref.label}\n${format(ref.cm)}',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(color: color, height: 1.25),
          ),
        ),
      ],
    );
  }
}

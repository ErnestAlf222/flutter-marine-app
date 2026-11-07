import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Medidor vertical: 0 m arriba, el máximo de la escala abajo y el rango de la especie resaltado
class DepthGauge extends StatelessWidget {
  final double? minM;
  final double? maxM;
  final double height;

  const DepthGauge({
    super.key,
    required this.minM,
    required this.maxM,
    this.height = 240,
  });

  static const double _trackWidth = 28;

  // Sin decimales cuando el valor es entero
  static String _fmt(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  // Primer paso de la escala que alcanza la profundidad; si ninguno, ella misma
  static double _scaleMax(double deepest) => MeasureConstants.depthScaleSteps
      .firstWhere((s) => s >= deepest, orElse: () => deepest);

  // Nombre del extremo y su medida debajo
  static Widget _end(
    TextTheme textTheme,
    OceanPalette palette,
    String name, {
    String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: textTheme.labelMedium?.copyWith(color: palette.paper),
        ),
        if (value != null)
          Text(
            value,
            style: textTheme.labelSmall?.copyWith(
              color: palette.paper.withValues(alpha: 0.75),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (minM == null && maxM == null) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    // Con un solo dato se dibuja una marca puntual
    final a = minM ?? maxM!;
    final b = maxM ?? minM!;
    final lo = a < b ? a : b;
    final hi = a < b ? b : a;
    final scaleMax = _scaleMax(hi);
    final rangeText = lo == hi ? '${_fmt(lo)} m' : '${_fmt(lo)}–${_fmt(hi)} m';

    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label:
          'Profundidad, entre qué profundidades se le encuentra: $rangeText. De la superficie hasta ${_fmt(scaleMax)} metros',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.deep.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(DesignConstants.tileRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 96,
                  height: height,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: animate ? 0 : 1, end: 1),
                    duration: animate ? MotionConstants.long : Duration.zero,
                    curve: MotionConstants.curve,
                    builder: (context, fill, _) {
                      final top = lo / scaleMax * height;
                      // Una marca puntual conserva un alto mínimo para verse
                      final span = ((hi - lo) / scaleMax * height)
                          .clamp(8.0, height)
                          .toDouble();
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            width: _trackWidth,
                            top: 0,
                            bottom: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  _trackWidth / 2,
                                ),
                                gradient: palette.depthGradient,
                              ),
                            ),
                          ),
                          // El rango sobresale de la columna para leerse como resaltado
                          Positioned(
                            left: -4,
                            width: _trackWidth + 8,
                            top: top.clamp(0.0, height - span).toDouble(),
                            height: span * fill,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: accent.withValues(alpha: 0.85),
                                border: Border.all(
                                  color: palette.paper,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Extremos de la pista: arriba la superficie y abajo el fondo, con una flecha
                SizedBox(
                  height: height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _end(
                        textTheme,
                        palette,
                        MeasureConstants.surfaceLabel,
                        value: '0 m',
                      ),
                      Icon(Icons.arrow_downward, size: 20, color: accent),
                      _end(
                        textTheme,
                        palette,
                        '${MeasureConstants.untilLabel} ${_fmt(scaleMax)} m',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROFUNDIDAD',
                        style: textTheme.overline.copyWith(color: accent),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        MeasureConstants.depthQuestion,
                        style: textTheme.bodyMedium?.copyWith(
                          color: palette.paper,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rangeText,
                        style: textTheme.headlineSmall?.copyWith(
                          color: palette.paper,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // La escala cambia de una especie a otra, así que se dice con claridad
                      Text(
                        'Escala hasta ${_fmt(scaleMax)} m',
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.paper.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

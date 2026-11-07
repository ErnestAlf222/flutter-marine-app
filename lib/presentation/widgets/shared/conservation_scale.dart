import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// "Estado de conservación": la escala de 7 niveles de la UICN con el nivel de la especie
// resaltado, su nombre en español y una frase. DD y NE no son un nivel de riesgo, así que
// se muestran aparte, sin escala.
class ConservationScale extends StatelessWidget {
  final String? status;

  const ConservationScale({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final code = status;
    if (code == null) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final label = ConservationConstants.labels[code] ?? code;
    final phrase = ConservationConstants.phrases[code];
    final offScale = ConservationConstants.offScale.contains(code);

    return Semantics(
      container: true,
      label: 'Estado de conservación: $label. ${phrase ?? ''}',
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
                Text(
                  'ESTADO DE CONSERVACIÓN',
                  style: textTheme.overline.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                if (!offScale) ...[
                  Row(
                    children: [
                      for (final level in ConservationConstants.scale)
                        Expanded(
                          child: _Level(code: level, active: level == code),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    if (offScale)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.help_outline,
                          size: 20,
                          color: palette.paper,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        label,
                        style: textTheme.titleMedium?.copyWith(
                          color: palette.paper,
                        ),
                      ),
                    ),
                  ],
                ),
                if (phrase != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    phrase,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.paper.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Un nivel de la escala: el activo va con su color y más alto; los demás, atenuados
class _Level extends StatelessWidget {
  final String code;
  final bool active;

  const _Level({required this.code, required this.active});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final color = palette.uicnColor(code);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedContainer(
        duration: MotionConstants.medium,
        curve: MotionConstants.curve,
        height: active
            ? DesignConstants.scaleActiveHeight
            : DesignConstants.scaleHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(8),
          border: active ? Border.all(color: palette.paper, width: 2) : null,
        ),
        child: Text(
          code,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: active
                ? palette.onColor(color)
                : palette.paper.withValues(alpha: 0.8),
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

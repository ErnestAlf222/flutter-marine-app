import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// "Peligrosidad": icono, nombre del nivel y una frase. El coral solo aparece cuando
// hay algo de qué cuidarse.
class DangerInfo extends StatelessWidget {
  final String? level;

  const DangerInfo({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final id = level;
    if (id == null) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final alert = TraitConstants.dangerous.contains(id);
    final background = alert ? palette.coral : palette.reef;
    final name = TraitConstants.danger(id);
    final phrase = TraitConstants.dangerPhrase(id);

    return Semantics(
      container: true,
      label: 'Peligrosidad: $name. ${phrase ?? ''}',
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      alert
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      size: 24,
                      color: palette.onColor(background),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PELIGROSIDAD',
                        style: textTheme.overline.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: textTheme.titleMedium?.copyWith(
                          color: palette.paper,
                        ),
                      ),
                      if (phrase != null) ...[
                        const SizedBox(height: 4),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

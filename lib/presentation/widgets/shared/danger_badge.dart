import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Insignia de peligrosidad: el coral solo aparece cuando hay algo de qué cuidarse
class DangerBadge extends StatelessWidget {
  final String? level;

  const DangerBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final id = level;
    if (id == null) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);
    final alert = TraitConstants.dangerous.contains(id);
    final background = alert ? palette.coral : palette.reef;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              alert ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              size: 14,
              color: palette.onColor(background),
            ),
            const SizedBox(width: 6),
            Text(
              TraitConstants.danger(id),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.onColor(background),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

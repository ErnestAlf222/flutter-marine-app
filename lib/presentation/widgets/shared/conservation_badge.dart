import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Insignia del estado UICN: código y, si no es compacta, la etiqueta en español
class ConservationBadge extends StatelessWidget {
  final String? status;
  final bool compact;

  const ConservationBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final code = status;
    if (code == null) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);
    final background = palette.uicnColor(code);
    final label = ConservationConstants.labels[code];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          compact || label == null ? code : '$code · $label',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.onColor(background),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

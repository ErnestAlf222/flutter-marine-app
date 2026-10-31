import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/glass_surface.dart';

// Botón circular de vidrio: desenfoca lo que hay detrás, ideal sobre fotos
class GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  // Para el favorito marcado: el icono pasa al coral de acento
  final bool selected;
  final IconData? selectedIcon;
  final double size;

  const GlassButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
    this.selectedIcon,
    this.size = DesignConstants.glassSize,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Tooltip(
      message: tooltip ?? '',
      child: GlassSurface(
        circle: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: AnimatedSwitcher(
                duration: MotionConstants.short,
                switchInCurve: MotionConstants.curve,
                child: Icon(
                  selected ? (selectedIcon ?? icon) : icon,
                  key: ValueKey(selected),
                  color: selected ? palette.coral : palette.paper,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

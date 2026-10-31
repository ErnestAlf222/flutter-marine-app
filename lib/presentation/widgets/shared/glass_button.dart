import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Botón circular de vidrio: desenfoca lo que hay detrás, ideal sobre fotos
class GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  // Para el favorito marcado: el icono pasa al coral de acento
  final bool selected;
  final IconData? selectedIcon;

  const GlassButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
    this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Tooltip(
      message: tooltip ?? '',
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: DesignConstants.glassBlur,
            sigmaY: DesignConstants.glassBlur,
          ),
          child: Material(
            color: palette.ink.withValues(alpha: DesignConstants.glassAlpha),
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: DesignConstants.glassSize,
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
      ),
    );
  }
}

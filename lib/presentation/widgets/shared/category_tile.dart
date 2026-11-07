import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Ficha de grupo: color propio, icono y etiqueta completa
class CategoryTile extends StatelessWidget {
  final String categoryId;
  final VoidCallback onTap;
  // Versión en píldora para el panel de filtros
  final bool compact;
  final bool selected;

  const CategoryTile({
    super.key,
    required this.categoryId,
    required this.onTap,
    this.compact = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final background = palette.categoryColor(categoryId);
    final foreground = palette.onColor(background);
    final label = CategoryConstants.labels[categoryId] ?? categoryId;
    final icon =
        CategoryConstants.icons[categoryId] ?? CategoryConstants.fallbackIcon;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(
      compact ? 999 : DesignConstants.tileRadius,
    );

    // La selección se marca con un borde claro, sin cambiar el color del grupo
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: selected
          ? BorderSide(color: palette.paper, width: 2.5)
          : BorderSide.none,
    );

    if (compact) {
      return Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? Icons.check : icon,
                  size: 18,
                  color: foreground,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: background,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: foreground),
              // Si la etiqueta no cabe se reduce en vez de recortarse
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  style: textTheme.titleMedium?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

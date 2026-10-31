import 'package:material_ui/material_ui.dart';

// Rango de profundidad en texto corto, por ejemplo "0–15 m"
class DepthRangeLabel extends StatelessWidget {
  final double? minM;
  final double? maxM;
  final Color? color;

  const DepthRangeLabel({super.key, required this.minM, required this.maxM, this.color});

  // Sin decimales cuando el valor es entero
  static String _fmt(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  @override
  Widget build(BuildContext context) {
    final min = minM;
    final max = maxM;
    if (min == null && max == null) return const SizedBox.shrink();

    final text = min != null && max != null
        ? '${_fmt(min)}–${_fmt(max)} m'
        : '${_fmt((min ?? max)!)} m';
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.arrow_downward, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: style),
      ],
    );
  }
}

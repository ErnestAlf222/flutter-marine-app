import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Esqueleto con brillo en lugar de un spinner; ocupa todo el espacio que le den
class SkeletonBox extends StatelessWidget {
  final BorderRadius borderRadius;

  const SkeletonBox({super.key, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return DecoratedBox(
          decoration: BoxDecoration(
            color: palette.deep,
            borderRadius: borderRadius,
          ),
          child: const SizedBox.expand(),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: MotionConstants.shimmer,
          color: palette.paper.withValues(alpha: 0.12),
        );
  }
}

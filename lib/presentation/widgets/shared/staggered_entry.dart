import 'dart:math';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Entrada escalonada: desvanece y sube el hijo con un retraso según su posición
class StaggeredEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const StaggeredEntry({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    // Respeta la preferencia del sistema de reducir animaciones
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final step = min(index, MotionConstants.staggerMaxIndex);
    return child
        .animate(delay: MotionConstants.staggerStep * step)
        .fadeIn(duration: MotionConstants.medium, curve: MotionConstants.curve)
        .slideY(
          begin: MotionConstants.enterSlide,
          end: 0,
          duration: MotionConstants.medium,
          curve: MotionConstants.curve,
        );
  }
}

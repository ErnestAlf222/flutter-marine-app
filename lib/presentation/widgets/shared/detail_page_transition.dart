import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Transición de la ruta del Detalle. Al entrar: desvanecido y deslizamiento (el Hero lleva
/// la foto). Al salir: la pantalla se encoge y se desvanece hacia su tarjeta, con esquinas
/// redondeadas y el fondo oscureciéndose. Con animaciones reducidas solo hay desvanecido.
class DetailPageTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const DetailPageTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final curved = CurvedAnimation(
      parent: animation,
      curve: MotionConstants.curve,
    );

    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        final t = curved.value;

        if (animation.status == AnimationStatus.reverse && !reduce) {
          final palette = OceanPalette.of(context);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Oscurece la pantalla de atrás a medida que esta se aleja
              IgnorePointer(
                child: ColoredBox(
                  color: palette.ink.withValues(
                    alpha: MotionConstants.minimizeDim * t,
                  ),
                ),
              ),
              Opacity(
                opacity: t,
                child: Transform.scale(
                  scale:
                      MotionConstants.minimizeScale +
                      (1 - MotionConstants.minimizeScale) * t,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      DesignConstants.cardRadius * (1 - t),
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          );
        }

        return Opacity(
          opacity: t,
          child: reduce
              ? child
              : FractionalTranslation(
                  translation: Offset(0, MotionConstants.enterSlide * (1 - t)),
                  child: child,
                ),
        );
      },
    );
  }
}

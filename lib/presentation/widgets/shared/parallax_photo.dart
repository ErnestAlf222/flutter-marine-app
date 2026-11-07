import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Desplaza la foto dentro de su marco mientras la tarjeta cruza la pantalla.
/// La foto se pinta un poco más alta que el marco y se mueve entre sus extremos
/// según la posición de la tarjeta en el viewport. Solo actúa dentro de un scroll
/// vertical; en cualquier otro caso (o con animaciones reducidas) deja la foto quieta.
class ParallaxPhoto extends StatelessWidget {
  final Widget child;

  const ParallaxPhoto({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context);
    final vertical =
        scrollable != null &&
        (scrollable.axisDirection == AxisDirection.down ||
            scrollable.axisDirection == AxisDirection.up);
    if (!vertical || MediaQuery.disableAnimationsOf(context)) return child;

    return Flow(
      delegate: _ParallaxDelegate(scrollable: scrollable, itemContext: context),
      children: [child],
    );
  }
}

class _ParallaxDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext itemContext;

  // Se repinta con el scroll, sin reconstruir widgets
  _ParallaxDelegate({required this.scrollable, required this.itemContext})
    : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
      height: constraints.maxHeight + DesignConstants.parallaxTravel * 2,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollBox = scrollable.context.findRenderObject();
    final itemBox = itemContext.findRenderObject();
    if (scrollBox is! RenderBox || itemBox is! RenderBox) return;

    // Centro vertical de la tarjeta respecto al viewport: 0 arriba, 1 abajo
    final itemCenter = itemBox.localToGlobal(
      itemBox.size.centerLeft(Offset.zero),
      ancestor: scrollBox,
    );
    final fraction = (itemCenter.dy / scrollable.position.viewportDimension)
        .clamp(0.0, 1.0);

    // Con la tarjeta arriba se ve la parte baja de la foto, y al revés
    final childSize = Size(
      context.size.width,
      context.size.height + DesignConstants.parallaxTravel * 2,
    );
    final rect = Alignment(
      0,
      fraction * 2 - 1,
    ).inscribe(childSize, Offset.zero & context.size);
    context.paintChild(0, transform: Matrix4.translationValues(0, rect.top, 0));
  }

  @override
  bool shouldRepaint(_ParallaxDelegate old) =>
      old.scrollable != scrollable || old.itemContext != itemContext;
}

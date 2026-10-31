import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/edge_bubble_geometry.dart';
import 'package:marine_app/presentation/widgets/shared/glass_surface.dart';

/// Burbuja de cristal que se arrastra con el dedo y al soltar se pega al borde izquierdo
/// o derecho. Tras unos segundos sin usarla se minimiza a una pestaña pegada al borde;
/// al tocar la pestaña vuelve a su sitio. Va dentro de un Stack que ocupe la zona visible.
class EdgeBubble extends StatefulWidget {
  final BubblePlacement placement;
  final ValueChanged<BubblePlacement> onPlacementChanged;
  final IconData icon;
  // Número que se muestra sobre la burbuja (por ejemplo, filtros aplicados); 0 lo oculta
  final int badge;
  final String label;
  final VoidCallback onTap;
  // Mientras algo (una hoja) depende de la burbuja no debe minimizarse
  final bool pauseIdle;
  final Duration idle;

  const EdgeBubble({
    super.key,
    required this.placement,
    required this.onPlacementChanged,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.pauseIdle = false,
    this.idle = MotionConstants.bubbleIdle,
  });

  @override
  State<EdgeBubble> createState() => _EdgeBubbleState();
}

class _EdgeBubbleState extends State<EdgeBubble> {
  // Esquina superior izquierda mientras el dedo la arrastra; null en reposo
  Offset? _drag;
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _restartIdle();
  }

  @override
  void didUpdateWidget(EdgeBubble old) {
    super.didUpdateWidget(old);
    if (old.pauseIdle != widget.pauseIdle ||
        old.placement.minimized != widget.placement.minimized) {
      _restartIdle();
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _restartIdle() {
    _idleTimer?.cancel();
    if (widget.placement.minimized || widget.pauseIdle) return;

    _idleTimer = Timer(widget.idle, () {
      if (!mounted || _drag != null || widget.pauseIdle) return;
      widget.onPlacementChanged(widget.placement.copyWith(minimized: true));
    });
  }

  void _restore() {
    widget.onPlacementChanged(widget.placement.copyWith(minimized: false));
    _restartIdle();
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = OceanPalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final area = constraints.biggest;
        final topInset = MediaQuery.paddingOf(context).top;
        final placement = widget.placement;

        final origin = _drag ??
            bubbleOrigin(placement: placement, area: area, topInset: topInset);

        final minimized = placement.minimized && _drag == null;

        // El Stack ocupa toda el área pero solo la burbuja recibe toques
        return Stack(
          children: [
            AnimatedPositioned(
              // Sigue al dedo sin retraso; al soltar, se desliza hasta el borde
              duration: _drag != null || !animate
                  ? Duration.zero
                  : MotionConstants.medium,
              curve: MotionConstants.curve,
              left: origin.dx,
              top: origin.dy,
              width: minimized
                  ? DesignConstants.bubbleTabWidth
                  : DesignConstants.bubbleSize,
              height: DesignConstants.bubbleSize,
              child: Semantics(
                button: true,
                label: widget.label,
                onTap: minimized ? _restore : widget.onTap,
                child: ExcludeSemantics(
                  child: AnimatedSwitcher(
                    duration: animate ? MotionConstants.short : Duration.zero,
                    switchInCurve: MotionConstants.curve,
                    child: minimized
                        ? _tab(scheme, palette, placement.onRight)
                        : _circle(scheme, palette, area, topInset, origin),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _circle(
    ColorScheme scheme,
    OceanPalette palette,
    Size area,
    double topInset,
    Offset origin,
  ) {
    return GestureDetector(
      key: const ValueKey('circle'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _restartIdle();
        widget.onTap();
      },
      onPanStart: (_) {
        _idleTimer?.cancel();
        setState(() => _drag = origin);
      },
      onPanUpdate: (details) {
        final current = _drag;
        if (current == null) return;
        setState(
          () => _drag = clampBubble(
            topLeft: current + details.delta,
            area: area,
            topInset: topInset,
          ),
        );
      },
      onPanEnd: (_) => _drop(area, topInset),
      onPanCancel: () => _drop(area, topInset),
      child: GlassSurface(
        circle: true,
        // El acento del tema tiñe el cristal para que se vea sobre fondos casi negros
        tint: scheme.primary,
        tintAlpha: 0.32,
        borderAlpha: 0.5,
        child: Center(
          child: Badge(
            isLabelVisible: widget.badge > 0,
            label: Text('${widget.badge}'),
            child: Icon(widget.icon, color: palette.paper, size: 26),
          ),
        ),
      ),
    );
  }

  void _drop(Size area, double topInset) {
    final dropped = _drag;
    if (dropped == null) return;

    widget.onPlacementChanged(
      snapBubble(topLeft: dropped, area: area, topInset: topInset),
    );
    setState(() => _drag = null);
    _restartIdle();
  }

  // Pestaña pegada al borde: redondeada solo del lado que mira al interior
  Widget _tab(ColorScheme scheme, OceanPalette palette, bool onRight) {
    const radius = Radius.circular(DesignConstants.bubbleTabWidth);

    return GestureDetector(
      key: const ValueKey('tab'),
      behavior: HitTestBehavior.opaque,
      onTap: _restore,
      child: GlassSurface(
        borderRadius: BorderRadius.horizontal(
          left: onRight ? radius : Radius.zero,
          right: onRight ? Radius.zero : radius,
        ),
        tint: scheme.primary,
        tintAlpha: 0.32,
        borderAlpha: 0.5,
        child: Center(
          child: Icon(
            onRight ? Icons.chevron_left : Icons.chevron_right,
            color: palette.paper,
            size: 20,
          ),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Burbujas que suben desde un widget (el corazón) al marcar un favorito.
/// Se pintan en el Overlay para no quedar recortadas por la tarjeta que contiene al corazón.
class FavoriteBubbles {
  static void show(BuildContext context, {required Color color}) {
    if (MediaQuery.disableAnimationsOf(context)) return;

    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final origin = box.localToGlobal(box.size.center(Offset.zero));

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) =>
          BubbleBurst(origin: origin, color: color, onDone: entry.remove),
    );
    overlay.insert(entry);
  }
}

class _Bubble {
  final double drift;
  final double size;
  final double rise;
  // Fracción de la animación que espera antes de salir, para que no suban todas juntas
  final double delay;

  const _Bubble(this.drift, this.size, this.rise, this.delay);
}

class BubbleBurst extends StatefulWidget {
  final Offset origin;
  final Color color;
  final VoidCallback onDone;
  // Solo para pruebas: resultado repetible
  final Random? random;

  const BubbleBurst({
    super.key,
    required this.origin,
    required this.color,
    required this.onDone,
    this.random,
  });

  @override
  State<BubbleBurst> createState() => _BubbleBurstState();
}

class _BubbleBurstState extends State<BubbleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionConstants.long,
  );
  late final List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    final random = widget.random ?? Random();
    _bubbles = List.generate(MotionConstants.bubbleCount, (_) {
      return _Bubble(
        (random.nextDouble() * 2 - 1) * MotionConstants.bubbleDrift,
        MotionConstants.bubbleMinSize +
            random.nextDouble() *
                (MotionConstants.bubbleMaxSize - MotionConstants.bubbleMinSize),
        MotionConstants.bubbleRise * (0.7 + random.nextDouble() * 0.3),
        random.nextDouble() * 0.35,
      );
    });

    _controller
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Stack(
          children: [for (final b in _bubbles) _bubble(b, _controller.value)],
        ),
      ),
    );
  }

  Widget _bubble(_Bubble b, double value) {
    final t = ((value - b.delay) / (1 - b.delay)).clamp(0.0, 1.0);
    final eased = MotionConstants.curve.transform(t);
    // Aparece de golpe y se desvanece en la segunda mitad del recorrido
    final opacity = t == 0 ? 0.0 : (1 - t).clamp(0.0, 1.0);

    return Positioned(
      left: widget.origin.dx + b.drift * eased - b.size / 2,
      top: widget.origin.dy - b.rise * eased - b.size / 2,
      child: Opacity(
        opacity: opacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.35),
            border: Border.all(color: widget.color, width: 1),
          ),
          child: SizedBox.square(dimension: b.size),
        ),
      ),
    );
  }
}

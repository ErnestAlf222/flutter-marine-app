import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Arrastrar hacia abajo para cerrar. Solo con el scroll arriba del todo: el contenido se
/// encoge (hasta [MotionConstants.pullMinScale]) siguiendo el dedo. Al soltar pasado el
/// umbral, o con un tirón rápido, llama a [onDismiss]; si no, vuelve con un resorte.
///
/// Escucha los punteros sin competir en la arena de gestos: el scroll normal sigue igual y,
/// en cuanto el arrastre se activa, el scroll se bloquea para que no se mueva a la vez.
class PullToDismiss extends StatefulWidget {
  final VoidCallback onDismiss;
  // El contenido recibe el controlador y la física que debe usar su scroll
  final Widget Function(
    BuildContext context,
    ScrollController controller,
    ScrollPhysics physics,
  )
  builder;

  const PullToDismiss({super.key, required this.onDismiss, required this.builder});

  @override
  State<PullToDismiss> createState() => _PullToDismissState();
}

class _PullToDismissState extends State<PullToDismiss>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final AnimationController _spring = AnimationController.unbounded(vsync: this)
    ..addListener(() => setState(() => _drag = _spring.value));

  double _drag = 0;
  bool _engaged = false;
  int? _pointer;
  // Solo cuenta el gesto que empezó con el scroll arriba del todo: uno que llega arriba a
  // media caricia (un tirón para volver al inicio) es de scroll, no de cierre
  bool _startedAtTop = false;
  Offset _travel = Offset.zero;
  VelocityTracker? _tracker;

  @override
  void dispose() {
    _spring.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _atTop => !_scroll.hasClients || _scroll.offset <= 0;

  void _down(PointerDownEvent e) {
    if (_pointer != null) return;
    _pointer = e.pointer;
    _spring.stop();
    _startedAtTop = _atTop;
    _travel = Offset.zero;
    _tracker = VelocityTracker.withKind(e.kind)..addPosition(e.timeStamp, e.position);
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    _tracker?.addPosition(e.timeStamp, e.position);

    if (!_engaged) {
      // Con el contenido desplazado, el gesto es de scroll: se vuelve a contar desde cero
      if (!_startedAtTop || !_atTop) {
        _travel = Offset.zero;
        return;
      }
      _travel = Offset(
        _travel.dx + e.delta.dx,
        (_travel.dy + e.delta.dy).clamp(0, double.infinity),
      );
      if (_travel.dy > MotionConstants.pullSlop && _travel.dy > _travel.dx.abs()) {
        setState(() => _engaged = true);
      }
      return;
    }

    setState(() => _drag = (_drag + e.delta.dy).clamp(0, double.infinity));
  }

  void _end(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    final velocity = _tracker?.getVelocity().pixelsPerSecond.dy ?? 0;
    _tracker = null;
    if (!_engaged) return;

    final dismiss =
        _progress(context) >= MotionConstants.pullDismissAt ||
        velocity > MotionConstants.pullFlingVelocity;
    setState(() => _engaged = false);

    if (e is PointerUpEvent && dismiss) {
      widget.onDismiss();
    } else if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _drag = 0);
    } else {
      final spring = SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: MotionConstants.pullSpringStiffness,
        ratio: MotionConstants.pullSpringDamping,
      );
      _spring.animateWith(SpringSimulation(spring, _drag, 0, 0));
    }
  }

  // 0 a 1: cuánto del recorrido completo se lleva arrastrado
  double _progress(BuildContext context) {
    final range = MediaQuery.sizeOf(context).height * MotionConstants.pullRange;
    return range <= 0 ? 0 : (_drag / range).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress(context);
    final scale = 1 - (1 - MotionConstants.pullMinScale) * progress;
    final palette = OceanPalette.of(context);

    return Listener(
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: _end,
      onPointerCancel: _end,
      child: ColoredBox(
        // Lo que asoma alrededor de la pantalla encogida
        color: palette.abyss,
        child: Transform.translate(
          offset: Offset(0, _drag),
          child: Transform.scale(
            scale: scale,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignConstants.cardRadius * progress),
              clipBehavior: _drag > 0 ? Clip.antiAlias : Clip.none,
              child: widget.builder(
                context,
                _scroll,
                // Mientras se arrastra para cerrar, el scroll no debe moverse
                _engaged
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

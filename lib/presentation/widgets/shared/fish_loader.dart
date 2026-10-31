import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Reloj único para todos los peces pequeños (marcadores de foto): una cuadrícula con
/// decenas de fotos cargando mueve un solo controlador en vez de uno por foto.
/// Cuenta quién lo usa: corre mientras haya al menos un pez y se detiene al irse el último,
/// para no pedir cuadros a la pantalla sin necesidad.
class FishClock implements TickerProvider {
  FishClock._();
  static final FishClock instance = FishClock._();

  AnimationController? _controller;
  int _users = 0;

  /// Cuántos peces lo están usando (para las pruebas)
  int get users => _users;

  /// El controlador compartido; solo es válido mientras se ha llamado a [acquire]
  Animation<double> get animation => _controller!;

  void acquire() {
    _controller ??= AnimationController(vsync: this, duration: MotionConstants.fishCycle);
    if (_users++ == 0) _controller!.repeat();
  }

  void release() {
    if (--_users == 0) _controller!.stop();
  }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

/// Cargador: un pez que nada de un lado a otro, dibujado en código con colores de la paleta.
/// Con animaciones reducidas queda quieto.
class FishLoader extends StatefulWidget {
  // Alto del pez; el recorrido es más ancho (DesignConstants.fishTrackFactor)
  final double size;
  // Los pequeños (fotos) comparten un solo reloj; los grandes llevan el suyo
  final bool shared;

  const FishLoader({super.key, this.size = DesignConstants.fishSize}) : shared = false;

  /// Pez de marcador de foto: usa el reloj compartido [FishClock]
  const FishLoader.small({super.key, this.size = DesignConstants.fishPhotoSize})
    : shared = true;

  @override
  State<FishLoader> createState() => _FishLoaderState();
}

class _FishLoaderState extends State<FishLoader> with SingleTickerProviderStateMixin {
  // Solo los peces con reloj propio crean controlador
  late final AnimationController? _own = widget.shared
      ? null
      : AnimationController(vsync: this, duration: MotionConstants.fishCycle);
  bool _holdsShared = false;

  Animation<double> get _progress => _holdsShared
      ? FishClock.instance.animation
      : _own ?? const AlwaysStoppedAnimation(0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (widget.shared) {
      if (still && _holdsShared) {
        FishClock.instance.release();
        _holdsShared = false;
      } else if (!still && !_holdsShared) {
        FishClock.instance.acquire();
        _holdsShared = true;
      }
    } else if (still) {
      _own!.stop();
    } else if (!_own!.isAnimating) {
      _own.repeat();
    }
  }

  @override
  void dispose() {
    if (_holdsShared) FishClock.instance.release();
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Cargando',
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(
              widget.size * DesignConstants.fishTrackFactor,
              widget.size,
            ),
            painter: _FishPainter(
              progress: _progress,
              body: scheme.primary,
              fin: palette.paper.withValues(alpha: 0.85),
              eye: palette.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  final Animation<double> progress;
  final Color body;
  final Color fin;
  final Color eye;

  _FishPainter({
    required this.progress,
    required this.body,
    required this.fin,
    required this.eye,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    // Va y vuelve: 0 -> 1 -> 0 con un suavizado en los extremos
    final lap = t < 0.5 ? t * 2 : (1 - t) * 2;
    final eased = MotionConstants.curve.transform(lap);
    final facingRight = t < 0.5;

    final fishLength = size.height * 1.5;
    final travel = size.width - fishLength;
    final x = fishLength / 2 + travel * eased;
    // Sube y baja un poco mientras nada, y la cola se mueve más rápido
    final y = size.height / 2 + sin(t * 2 * pi * 3) * size.height * 0.08;
    final wag = sin(t * 2 * pi * 8) * size.height * 0.12;

    canvas.save();
    canvas.translate(x, y);
    if (!facingRight) canvas.scale(-1, 1);

    final h = size.height;
    final bodyPaint = Paint()..color = body;

    // Cola
    final tail = Path()
      ..moveTo(-fishLength * 0.28, 0)
      ..lineTo(-fishLength * 0.5, -h * 0.28 + wag)
      ..lineTo(-fishLength * 0.46, 0)
      ..lineTo(-fishLength * 0.5, h * 0.28 + wag)
      ..close();
    canvas.drawPath(tail, Paint()..color = fin);

    // Aleta superior
    final dorsal = Path()
      ..moveTo(-fishLength * 0.05, -h * 0.2)
      ..quadraticBezierTo(fishLength * 0.02, -h * 0.5, fishLength * 0.12, -h * 0.2)
      ..close();
    canvas.drawPath(dorsal, Paint()..color = fin);

    // Cuerpo
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: fishLength * 0.7, height: h * 0.55),
      bodyPaint,
    );

    // Ojo
    canvas.drawCircle(Offset(fishLength * 0.16, -h * 0.05), h * 0.05, Paint()..color = eye);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FishPainter old) =>
      old.body != body || old.fin != fin || old.eye != eye;
}

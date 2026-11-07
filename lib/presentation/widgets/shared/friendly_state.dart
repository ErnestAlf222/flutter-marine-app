import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

/// Estado amigable para sin conexión, servidor con problemas, no encontrado y vacío:
/// el pez de la app con una expresión por tipo, un texto breve que no culpa a nadie y
/// las acciones que correspondan. Con animaciones reducidas el pez queda quieto.
class FriendlyState extends StatelessWidget {
  final FailureKind kind;
  // Reemplaza el texto del tipo (por ejemplo, un vacío con un motivo concreto)
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;
  // Acción extra; con sin conexión suele ser "Ver mis favoritos"
  final VoidCallback? onSecondary;
  final String? secondaryLabel;
  // Versión baja para hojas y filas
  final bool compact;

  const FriendlyState({
    super.key,
    required this.kind,
    this.message,
    this.onRetry,
    this.retryLabel = FriendlyConstants.retry,
    this.onSecondary,
    this.secondaryLabel,
    this.compact = false,
  });

  /// Deduce el tipo del mensaje que devolvió el datasource. Sin conexión ofrece además
  /// ir a los favoritos, salvo que quien lo usa ya esté en ellos.
  factory FriendlyState.forError(
    BuildContext context,
    Object? error, {
    VoidCallback? onRetry,
    String retryLabel = FriendlyConstants.retry,
    bool offerFavorites = true,
    bool compact = false,
  }) {
    final kind = failureKindOf(error);
    final showFavorites = kind == FailureKind.offline && offerFavorites;

    return FriendlyState(
      kind: kind,
      onRetry: onRetry,
      retryLabel: retryLabel,
      onSecondary: showFavorites
          ? () => context.go(RouteConstants.favorites)
          : null,
      secondaryLabel: showFavorites ? FriendlyConstants.seeFavorites : null,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final text = message ?? FriendlyConstants.messages[kind]!;
    final hasSecondary = onSecondary != null && secondaryLabel != null;

    // Compacto (hoja de zona, filas): el pez al lado del texto, para no ocupar alto
    if (compact) {
      return Semantics(
        container: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: FriendlyConstants.buttonGap),
          child: Row(
            children: [
              ExcludeSemantics(
                child: FriendlyFish(kind: kind, height: FriendlyConstants.fishCompactHeight),
              ),
              const SizedBox(width: FriendlyConstants.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.paper),
                    ),
                    Wrap(
                      children: [
                        if (onRetry != null)
                          TextButton(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            onPressed: onRetry,
                            child: Text(retryLabel),
                          ),
                        if (hasSecondary)
                          TextButton(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            onPressed: onSecondary,
                            child: Text(secondaryLabel!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignConstants.pagePadding * 2),
          // Con poco alto (el héroe en una pantalla chica) se puede desplazar en vez de cortarse
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: FriendlyFish(kind: kind, height: FriendlyConstants.fishHeight),
                ),
                const SizedBox(height: FriendlyConstants.gap),
                Text(text, textAlign: TextAlign.center, style: TextStyle(color: palette.paper)),
                if (onRetry != null) ...[
                  const SizedBox(height: FriendlyConstants.gap),
                  FilledButton.tonal(onPressed: onRetry, child: Text(retryLabel)),
                ],
                if (hasSecondary) ...[
                  const SizedBox(height: FriendlyConstants.buttonGap),
                  TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// El pez de la app en reposo, con la expresión del tipo de fallo
class FriendlyFish extends StatefulWidget {
  final FailureKind kind;
  final double height;

  const FriendlyFish({super.key, required this.kind, required this.height});

  @override
  State<FriendlyFish> createState() => _FriendlyFishState();
}

class _FriendlyFishState extends State<FriendlyFish>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: FriendlyConstants.bobCycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      // Unos pocos vaivenes y queda quieto: no gasta batería ni mantiene la pantalla animándose
      _controller.repeat(count: FriendlyConstants.bobCycles);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return RepaintBoundary(
      child: CustomPaint(
        size: Size(
          widget.height * FriendlyConstants.fishWidthFactor,
          widget.height,
        ),
        painter: _FriendlyFishPainter(
          progress: _controller,
          kind: widget.kind,
          body: Theme.of(context).colorScheme.primary,
          fin: palette.paper.withValues(alpha: 0.85),
          ink: palette.ink,
          mark: palette.paper.withValues(alpha: 0.8),
          accent: palette.coral,
        ),
      ),
    );
  }
}

class _FriendlyFishPainter extends CustomPainter {
  final Animation<double> progress;
  final FailureKind kind;
  final Color body;
  final Color fin;
  final Color ink;
  final Color mark;
  final Color accent;

  _FriendlyFishPainter({
    required this.progress,
    required this.kind,
    required this.body,
    required this.fin,
    required this.ink,
    required this.mark,
    required this.accent,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    // Sube y baja un poco, como flotando
    final bob =
        sin(progress.value * 2 * pi) *
        FriendlyConstants.bobAmount *
        (h / FriendlyConstants.fishHeight);

    canvas.save();
    canvas.translate(size.width / 2, h * 0.6 + bob);

    final length = h * 1.15;
    final fill = Paint()..color = body;
    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.035
      ..strokeCap = StrokeCap.round;

    // Cola
    final tail = Path()
      ..moveTo(-length * 0.3, 0)
      ..lineTo(-length * 0.52, -h * 0.26)
      ..lineTo(-length * 0.47, 0)
      ..lineTo(-length * 0.52, h * 0.26)
      ..close();
    canvas.drawPath(tail, Paint()..color = fin);

    // Aleta superior
    final dorsal = Path()
      ..moveTo(-length * 0.05, -h * 0.22)
      ..quadraticBezierTo(length * 0.02, -h * 0.5, length * 0.13, -h * 0.22)
      ..close();
    canvas.drawPath(dorsal, Paint()..color = fin);

    // Cuerpo
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: length * 0.72,
        height: h * 0.58,
      ),
      fill,
    );

    _face(canvas, h, length, line);
    _extras(canvas, h, length);
    canvas.restore();
  }

  // La expresión: ojo y boca según el tipo
  void _face(Canvas canvas, double h, double length, Paint line) {
    final eye = Offset(length * 0.17, -h * 0.07);
    final mouth = Offset(length * 0.3, h * 0.07);

    switch (kind) {
      case FailureKind.offline:
        // Ojo grande y boca triste
        canvas.drawCircle(eye, h * 0.065, Paint()..color = ink);
        canvas.drawArc(
          Rect.fromCenter(
            center: mouth.translate(0, h * 0.05),
            width: h * 0.12,
            height: h * 0.08,
          ),
          pi,
          pi,
          false,
          line,
        );
      case FailureKind.server:
        // Ojo cerrado, durmiendo
        canvas.drawArc(
          Rect.fromCenter(center: eye, width: h * 0.14, height: h * 0.1),
          0,
          pi,
          false,
          line,
        );
      case FailureKind.notFound:
        // Ojo curioso y una ceja inclinada
        canvas.drawCircle(eye, h * 0.05, Paint()..color = ink);
        canvas.drawLine(
          eye.translate(-h * 0.07, -h * 0.1),
          eye.translate(h * 0.07, -h * 0.14),
          line,
        );
      case FailureKind.empty:
        // Ojo tranquilo y sonrisa
        canvas.drawCircle(eye, h * 0.05, Paint()..color = ink);
        canvas.drawArc(
          Rect.fromCenter(center: mouth, width: h * 0.14, height: h * 0.1),
          0,
          pi,
          false,
          line,
        );
    }
  }

  // Lo que flota sobre el pez: sin señal, zzz, una interrogación o burbujas
  void _extras(Canvas canvas, double h, double length) {
    final stroke = Paint()
      ..color = mark
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.04
      ..strokeCap = StrokeCap.round;

    switch (kind) {
      case FailureKind.offline:
        final origin = Offset(length * 0.34, -h * 0.55);
        for (int i = 1; i <= 3; i++) {
          canvas.drawArc(
            Rect.fromCenter(
              center: origin,
              width: h * 0.16 * i,
              height: h * 0.16 * i,
            ),
            pi * 1.25,
            pi * 0.5,
            false,
            stroke,
          );
        }
        canvas.drawCircle(origin, h * 0.025, Paint()..color = mark);
        // La raya que tacha la señal
        canvas.drawLine(
          origin.translate(-h * 0.2, -h * 0.02),
          origin.translate(h * 0.2, h * 0.14),
          stroke..color = accent,
        );
      case FailureKind.server:
        for (int i = 0; i < 3; i++) {
          final size = h * (0.07 + 0.03 * i);
          final at = Offset(
            length * 0.3 + h * 0.12 * i,
            -h * 0.4 - h * 0.14 * i,
          );
          final z = Path()
            ..moveTo(at.dx - size, at.dy - size)
            ..lineTo(at.dx + size, at.dy - size)
            ..lineTo(at.dx - size, at.dy + size)
            ..lineTo(at.dx + size, at.dy + size);
          canvas.drawPath(z, stroke);
        }
      case FailureKind.notFound:
        final painter = TextPainter(
          text: TextSpan(
            text: '?',
            style: TextStyle(
              color: mark,
              fontSize: h * 0.42,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(canvas, Offset(length * 0.28, -h * 0.85));
      case FailureKind.empty:
        final fillMark = Paint()..color = mark.withValues(alpha: 0.5);
        canvas.drawCircle(Offset(length * 0.34, -h * 0.4), h * 0.05, fillMark);
        canvas.drawCircle(Offset(length * 0.4, -h * 0.58), h * 0.035, fillMark);
        canvas.drawCircle(
          Offset(length * 0.36, -h * 0.72),
          h * 0.025,
          fillMark,
        );
    }
  }

  @override
  bool shouldRepaint(_FriendlyFishPainter old) =>
      old.kind != kind ||
      old.body != body ||
      old.fin != fin ||
      old.ink != ink ||
      old.mark != mark;
}

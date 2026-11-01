import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/glass_surface.dart';
import 'package:marine_app/presentation/widgets/shared/species_photo.dart';

/// Fracción (0 a 1) de la foto que se pierde al recortarla con cover en un marco:
/// la del eje que más se corta.
double photoCropLoss({
  required double imageAspect,
  required double frameAspect,
}) {
  return 1 - min(imageAspect / frameAspect, frameAspect / imageAspect);
}

/// El recorte es extremo si se pierde más de [DesignConstants.maxCropLoss].
bool isExtremeCrop({
  required double imageAspect,
  required double frameAspect,
}) =>
    photoCropLoss(imageAspect: imageAspect, frameAspect: frameAspect) >
    DesignConstants.maxCropLoss;

/// Cuánto de la foto queda fuera del marco por los lados al llenarlo (cover); 0 si no se
/// recorta a los lados (se recorta arriba y abajo, o no se recorta)
double panOverflow({required double imageAspect, required Size frame}) =>
    max(0, frame.height * imageAspect - frame.width);

/// Fracción (0 a 1) del ancho de la foto que se ve dentro del marco
double panVisibleFraction({required double overflow, required Size frame}) =>
    frame.width / (frame.width + overflow);

/// Acuerdo entre la foto y la galería sobre quién se queda con un arrastre horizontal: la
/// foto lo reclama mientras todavía puede recorrerse en esa dirección y entonces la galería
/// no se mueve; en el borde lo suelta y el siguiente arrastre pasa a la galería.
class PhotoPanLock {
  bool consuming = false;
}

/// Física del PageView de la galería: ignora el arrastre mientras la foto lo reclama.
class PanAwarePagePhysics extends PageScrollPhysics {
  final PhotoPanLock lock;

  const PanAwarePagePhysics({required this.lock, super.parent});

  @override
  PanAwarePagePhysics applyTo(ScrollPhysics? ancestor) =>
      PanAwarePagePhysics(lock: lock, parent: buildParent(ancestor));

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) =>
      lock.consuming ? 0 : super.applyPhysicsToUserOffset(position, offset);
}

/// Lo que una foto cuenta a la cabecera sobre su botón de "ver completa / llenar": la
/// cabecera lo dibuja encima de los textos, así que la foto solo informa y obedece.
class PhotoFramingController extends ChangeNotifier {
  // Ya se conoce el tamaño de la foto, así que el botón tiene sentido
  bool available = false;
  bool whole = false;
  VoidCallback? toggle;

  void report({
    required bool available,
    required bool whole,
    required VoidCallback toggle,
  }) {
    this.toggle = toggle;
    if (available == this.available && whole == this.whole) return;
    this.available = available;
    this.whole = whole;
    notifyListeners();
  }
}

/// Una foto de la cabecera del Detalle. Entra igual que en las tarjetas (cover, para que el
/// Hero sea fluido). Solo si el recorte es extremo, y cuando el Hero ya terminó, se funde a
/// la foto entera sobre ella misma desenfocada. El botón para alternar a mano entre llenar
/// el marco y ver la foto entera lo dibuja la cabecera, que recibe el estado por [framing].
class DetailPhoto extends StatefulWidget {
  final String? url;
  final String category;
  // Solo la primera foto vuela con el Hero; las demás no tienen tarjeta de origen
  final String? heroTag;
  final PhotoFramingController? framing;
  // Con él, la foto se recorre de lado en "Llenar" cuando se recorta a los lados
  final PhotoPanLock? panLock;
  // Solo para pruebas: evita la red
  final ImageProvider? provider;

  const DetailPhoto({
    super.key,
    required this.url,
    required this.category,
    this.heroTag,
    this.framing,
    this.panLock,
    this.provider,
  });

  @override
  State<DetailPhoto> createState() => _DetailPhotoState();
}

// null = automático según el recorte; true/false = elección del usuario
typedef _Choice = bool?;

class _DetailPhotoState extends State<DetailPhoto>
    with SingleTickerProviderStateMixin {
  ImageProvider? _provider;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Size? _imageSize;

  Animation<double>? _routeAnimation;
  bool _settled = false;
  _Choice _whole;

  // Recorrido de lado: _pan son píxeles, positivo con la foto movida a la derecha
  double _pan = 0;
  double _overflow = 0;
  bool _panning = false;
  bool _barVisible = false;
  Timer? _barTimer;
  int? _pointer;
  Offset _travel = Offset.zero;
  VelocityTracker? _tracker;
  late final AnimationController _inertia = AnimationController.unbounded(
    vsync: this,
  )..addListener(_onInertia);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
    _watchRoute();
  }

  @override
  void didUpdateWidget(DetailPhoto old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _resolve();
  }

  @override
  void dispose() {
    _barTimer?.cancel();
    _inertia.dispose();
    _stopListening();
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    super.dispose();
  }

  ImageProvider? _build(int? width) {
    if (widget.provider != null) return widget.provider;
    final url = widget.url;
    return url == null
        ? null
        : CachedNetworkImageProvider(url, maxWidth: width);
  }

  // Lee el tamaño real de la foto en cuanto llega, sin retrasar su aparición
  void _resolve() {
    final next = _build(DesignConstants.heroPhotoCacheWidth);
    if (next == _provider) return;

    _stopListening();
    _provider = next;
    _imageSize = null;
    if (next == null) return;

    final stream = next.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener((info, synchronous) {
      final size = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
      if (synchronous) {
        _imageSize = size;
      } else if (mounted) {
        setState(() => _imageSize = size);
      }
    });
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  void _stopListening() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  // Espera a que termine la transición de la ruta, que es la del Hero
  void _watchRoute() {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == _routeAnimation) return;

    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = animation;
    _settled = animation == null;
    if (animation == null) return;

    animation.addStatusListener(_onRouteStatus);
    // En el primer build la animación de la ruta aún dice "completada" (todavía no
    // tiene el controlador real), así que el estado se confirma después del primer cuadro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && animation.status == AnimationStatus.completed) {
        setState(() => _settled = true);
      }
    });
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _settled = true);
    }
  }

  bool _showWhole(Size frame) {
    final size = _imageSize;
    if (size == null || frame.isEmpty || !frame.isFinite) return false;

    final choice = _whole;
    if (choice != null) return choice;
    return _settled &&
        isExtremeCrop(
          imageAspect: size.width / size.height,
          frameAspect: frame.width / frame.height,
        );
  }

  double get _limit => _overflow / 2;

  // ¿Puede recorrerse todavía en la dirección del dedo? (dedo a la derecha = foto a la derecha)
  bool _canPan(double dx) => dx > 0 ? _pan < _limit : _pan > -_limit;

  void _down(PointerDownEvent e) {
    if (_pointer != null) return;
    _pointer = e.pointer;
    _inertia.stop();
    _travel = Offset.zero;
    _panning = false;
    _tracker = VelocityTracker.withKind(e.kind)
      ..addPosition(e.timeStamp, e.position);
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer || _overflow <= 0) return;
    _tracker?.addPosition(e.timeStamp, e.position);

    if (_panning) {
      _setPan(_pan + e.delta.dx);
      return;
    }
    // La decisión se toma una vez por arrastre, con el primer movimiento claramente
    // horizontal: si la foto aún puede recorrerse así, el arrastre es suyo; si no, de la galería
    _travel += e.delta;
    if (_travel.dx.abs() > MotionConstants.panSlop &&
        _travel.dx.abs() > _travel.dy.abs()) {
      if (_canPan(_travel.dx) && widget.panLock != null) {
        _panning = true;
        widget.panLock!.consuming = true;
        _setPan(_pan + _travel.dx);
      } else {
        _pointer = null;
      }
    }
  }

  void _end(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    widget.panLock?.consuming = false;
    final velocity = _tracker?.getVelocity().pixelsPerSecond.dx ?? 0;
    _tracker = null;
    if (!_panning) return;
    _panning = false;

    // Inercia hasta los bordes; con animaciones reducidas la foto se queda donde se soltó
    if (!MediaQuery.disableAnimationsOf(context) &&
        velocity.abs() > MotionConstants.panMinFling) {
      _inertia.animateWith(
        ClampingScrollSimulation(position: _pan, velocity: velocity),
      );
    }
  }

  void _onInertia() => _setPan(_inertia.value);

  void _setPan(double value) {
    if (!mounted) return;
    setState(() {
      _pan = value.clamp(-_limit, _limit);
      _barVisible = true;
    });
    _barTimer?.cancel();
    _barTimer = Timer(MotionConstants.panBarHide, () {
      if (mounted) setState(() => _barVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final frame = constraints.biggest;
        final whole = _showWhole(frame);
        _report(whole);

        final size = _imageSize;
        _overflow = !whole && size != null && frame.isFinite && !frame.isEmpty
            ? panOverflow(imageAspect: size.width / size.height, frame: frame)
            : 0;
        if (_overflow <= 0) _pan = 0;
        _pan = _pan.clamp(-_limit, _limit);

        final photo = SpeciesPhotoView(
          url: widget.url,
          category: widget.category,
          cacheWidth: DesignConstants.heroPhotoCacheWidth,
          alignment: Alignment(_overflow > 0 ? -_pan / _limit : 0, 0),
        );
        final tag = widget.heroTag;

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _down,
          onPointerMove: _move,
          onPointerUp: _end,
          onPointerCancel: _end,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (tag != null) Hero(tag: tag, child: photo) else photo,
              // Fundido corto entre llenar el marco y ver la foto entera
              AnimatedSwitcher(
                duration: animate ? MotionConstants.photoFade : Duration.zero,
                switchInCurve: MotionConstants.photoFadeCurve,
                switchOutCurve: MotionConstants.photoFadeCurve,
                child: whole
                    ? _WholePhoto(
                        key: const ValueKey('whole'),
                        provider: _provider!,
                      )
                    : const SizedBox.shrink(key: ValueKey('fill')),
              ),
              if (_overflow > 0)
                _PanBar(
                  frame: frame,
                  overflow: _overflow,
                  pan: _pan,
                  visible: _barVisible,
                  animate: animate,
                ),
            ],
          ),
        );
      },
    );
  }

  // No se puede avisar durante el build: se hace al terminar el cuadro
  void _report(bool whole) {
    final framing = widget.framing;
    if (framing == null) return;

    final available = _imageSize != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      framing.report(
        available: available,
        whole: whole,
        toggle: () => setState(() => _whole = !whole),
      );
    });
  }
}

// Foto entera al centro; detrás, la misma foto ampliada, desenfocada y oscurecida
class _WholePhoto extends StatelessWidget {
  final ImageProvider provider;

  const _WholePhoto({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // El desenfoque es caro: se aísla para que no se repinte con el scroll
        RepaintBoundary(
          child: ClipRect(
            child: Transform.scale(
              scale: 1.3,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: DesignConstants.backdropBlur,
                  sigmaY: DesignConstants.backdropBlur,
                ),
                child: Image(image: provider, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        ColoredBox(
          color: palette.ink.withValues(
            alpha: DesignConstants.detailBackdropDim,
          ),
        ),
        Image(image: provider, fit: BoxFit.contain),
      ],
    );
  }
}

/// Píldora de cristal casi sólido, como la burbuja de filtros: icono y etiqueta corta
class PhotoToggleButton extends StatelessWidget {
  final bool whole;
  final VoidCallback onPressed;

  const PhotoToggleButton({
    super.key,
    required this.whole,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Tooltip(
      message: whole
          ? DetailConstants.fillFrameTooltip
          : DetailConstants.showWholeTooltip,
      child: GlassSurface(
        borderRadius: BorderRadius.circular(
          DesignConstants.photoToggleHeight / 2,
        ),
        // Discreto: semitransparente y sin borde, para no quitarle protagonismo a la foto
        tintAlpha: DesignConstants.photoToggleAlpha,
        borderAlpha: 0,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              height: DesignConstants.photoToggleHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      whole ? Icons.crop : Icons.fit_screen,
                      size: DesignConstants.photoToggleIcon,
                      color: palette.paper,
                    ),
                    const SizedBox(width: DesignConstants.photoToggleGap),
                    // Flexible: con letra muy grande la etiqueta se recorta en vez de desbordar
                    Flexible(
                      child: Text(
                        whole
                            ? DetailConstants.fillFrame
                            : DetailConstants.showWhole,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: palette.paper),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Barrita fina y translúcida que indica qué porción de la foto se ve; sale al recorrerla
class _PanBar extends StatelessWidget {
  final Size frame;
  final double overflow;
  final double pan;
  final bool visible;
  final bool animate;

  const _PanBar({
    required this.frame,
    required this.overflow,
    required this.pan,
    required this.visible,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final track = frame.width * DesignConstants.panBarLength;
    final thumb = track * panVisibleFraction(overflow: overflow, frame: frame);
    // 0 con la foto en su borde izquierdo (movida a la derecha), 1 en el derecho
    final position = (overflow / 2 - pan) / overflow;

    return Positioned(
      left: (frame.width - track) / 2,
      width: track,
      bottom: DesignConstants.panBarBottom,
      height: DesignConstants.panBarThickness,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: animate ? MotionConstants.photoFade : Duration.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.paper.withValues(
                      alpha: DesignConstants.panBarAlpha / 3,
                    ),
                    borderRadius: BorderRadius.circular(
                      DesignConstants.panBarThickness,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (track - thumb) * position,
                width: thumb,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.paper.withValues(
                      alpha: DesignConstants.panBarAlpha,
                    ),
                    borderRadius: BorderRadius.circular(
                      DesignConstants.panBarThickness,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

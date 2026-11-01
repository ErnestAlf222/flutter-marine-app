import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/glass_surface.dart';
import 'package:marine_app/presentation/widgets/shared/species_photo.dart';

/// Fracción (0 a 1) de la foto que se pierde al recortarla con cover en un marco:
/// la del eje que más se corta.
double photoCropLoss({required double imageAspect, required double frameAspect}) {
  return 1 - min(imageAspect / frameAspect, frameAspect / imageAspect);
}

/// El recorte es extremo si se pierde más de [DesignConstants.maxCropLoss].
bool isExtremeCrop({required double imageAspect, required double frameAspect}) =>
    photoCropLoss(imageAspect: imageAspect, frameAspect: frameAspect) >
    DesignConstants.maxCropLoss;

/// Lo que una foto cuenta a la cabecera sobre su botón de "ver completa / llenar": la
/// cabecera lo dibuja encima de los textos, así que la foto solo informa y obedece.
class PhotoFramingController extends ChangeNotifier {
  // Ya se conoce el tamaño de la foto, así que el botón tiene sentido
  bool available = false;
  bool whole = false;
  VoidCallback? toggle;

  void report({required bool available, required bool whole, required VoidCallback toggle}) {
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
  // Solo para pruebas: evita la red
  final ImageProvider? provider;

  const DetailPhoto({
    super.key,
    required this.url,
    required this.category,
    this.heroTag,
    this.framing,
    this.provider,
  });

  @override
  State<DetailPhoto> createState() => _DetailPhotoState();
}

// null = automático según el recorte; true/false = elección del usuario
typedef _Choice = bool?;

class _DetailPhotoState extends State<DetailPhoto> {
  ImageProvider? _provider;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Size? _imageSize;

  Animation<double>? _routeAnimation;
  bool _settled = false;
  _Choice _whole;

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
    _stopListening();
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    super.dispose();
  }

  ImageProvider? _build(int? width) {
    if (widget.provider != null) return widget.provider;
    final url = widget.url;
    return url == null ? null : CachedNetworkImageProvider(url, maxWidth: width);
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
      final size = Size(info.image.width.toDouble(), info.image.height.toDouble());
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

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final whole = _showWhole(constraints.biggest);
        _report(whole);

        final photo = SpeciesPhotoView(
          url: widget.url,
          category: widget.category,
          cacheWidth: DesignConstants.heroPhotoCacheWidth,
        );
        final tag = widget.heroTag;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (tag != null) Hero(tag: tag, child: photo) else photo,
            // Fundido corto entre llenar el marco y ver la foto entera
            AnimatedSwitcher(
              duration: animate ? MotionConstants.short : Duration.zero,
              switchInCurve: MotionConstants.curve,
              child: whole
                  ? _WholePhoto(key: const ValueKey('whole'), provider: _provider!)
                  : const SizedBox.shrink(key: ValueKey('fill')),
            ),
          ],
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
        ColoredBox(color: palette.ink.withValues(alpha: DesignConstants.detailBackdropDim)),
        Image(image: provider, fit: BoxFit.contain),
      ],
    );
  }
}

/// Píldora de cristal casi sólido, como la burbuja de filtros: icono y etiqueta corta
class PhotoToggleButton extends StatelessWidget {
  final bool whole;
  final VoidCallback onPressed;

  const PhotoToggleButton({super.key, required this.whole, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: whole
          ? DetailConstants.fillFrameTooltip
          : DetailConstants.showWholeTooltip,
      child: GlassSurface(
        borderRadius: BorderRadius.circular(DesignConstants.photoToggleHeight / 2),
        tintAlpha: DesignConstants.glassSolidAlpha,
        borderColor: accent,
        borderAlpha: DesignConstants.bubbleBorderAlpha,
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
                        whole ? DetailConstants.fillFrame : DetailConstants.showWhole,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: palette.paper,
                        ),
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

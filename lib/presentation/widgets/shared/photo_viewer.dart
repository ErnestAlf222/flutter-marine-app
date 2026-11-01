import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/glass_button.dart';
import 'package:marine_app/presentation/widgets/shared/glass_surface.dart';
import 'package:marine_app/presentation/widgets/shared/species_photo.dart';

/// Una foto del visor con su crédito y licencia
class ViewerPhoto {
  final String url;
  final String? credit;

  const ViewerPhoto({required this.url, this.credit});
}

// Visor a pantalla completa: galería con deslizamiento horizontal y, en cada foto, zoom de
// pellizco y arrastre. Mientras una foto está ampliada el deslizamiento se desactiva, para
// que arrastrar la mueva a ella y no cambie de foto.
class PhotoViewer extends StatefulWidget {
  final List<ViewerPhoto> photos;
  final int initialIndex;
  final String category;

  const PhotoViewer({
    super.key,
    required this.photos,
    required this.category,
    this.initialIndex = 0,
  });

  static Future<void> show(
    BuildContext context, {
    required List<ViewerPhoto> photos,
    required String category,
    int initialIndex = 0,
  }) {
    // Solo un fundido corto; sin animaciones del sistema, la pantalla aparece sin transición
    final fade = MediaQuery.disableAnimationsOf(context) ? Duration.zero : MotionConstants.photoFade;

    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: fade,
        reverseTransitionDuration: fade,
        pageBuilder: (_, _, _) => PhotoViewer(
          photos: photos,
          category: category,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: MotionConstants.curve,
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _zoomed = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final photos = widget.photos;
    final credit = photos[_index].credit;

    return Scaffold(
      backgroundColor: palette.abyss,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: photos.length,
            physics: _zoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (i) => setState(() {
              _index = i;
              _zoomed = false;
            }),
            itemBuilder: (context, i) => _ZoomablePhoto(
              photo: photos[i],
              category: widget.category,
              onZoomChanged: (zoomed) {
                if (i == _index && zoomed != _zoomed) {
                  setState(() => _zoomed = zoomed);
                }
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(DesignConstants.pagePadding),
                child: Row(
                  children: [
                    if (photos.length > 1)
                      GlassSurface(
                        borderRadius: BorderRadius.circular(
                          DesignConstants.galleryCounterHeight,
                        ),
                        tintAlpha: DesignConstants.glassSolidAlpha,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: SizedBox(
                          height: DesignConstants.galleryCounterHeight,
                          child: Center(
                            child: Text(
                              DetailConstants.photoCounter(
                                _index + 1,
                                photos.length,
                              ),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: palette.paper),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Mide 48 dp (glassSize), el mínimo táctil
                    GlassButton(
                      icon: Icons.close,
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (credit != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        palette.ink.withValues(
                          alpha: DesignConstants.scrimAlpha,
                        ),
                        palette.ink.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        DesignConstants.pagePadding,
                      ),
                      child: Text(
                        credit,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.paper.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Una foto con su propio zoom
class _ZoomablePhoto extends StatefulWidget {
  final ViewerPhoto photo;
  final String category;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomablePhoto({
    required this.photo,
    required this.category,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto> {
  final _transform = TransformationController();
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _onTransform() {
    final zoomed =
        _transform.value.getMaxScaleOnAxis() >
        DesignConstants.viewerZoomedAbove;
    if (zoomed == _zoomed) return;
    _zoomed = zoomed;
    widget.onZoomChanged(zoomed);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transform,
      maxScale: DesignConstants.viewerMaxScale,
      // Sin zoom, una foto no se arrastra: ese gesto es para pasar a la siguiente
      panEnabled: _zoomed,
      child: SpeciesPhotoView(
        url: widget.photo.url,
        category: widget.category,
        fit: BoxFit.contain,
        cacheWidth: DesignConstants.viewerCacheWidth,
        // Sin el color del grupo ni su fundido largo: la foto aparece con el mismo fundido corto
        neutralPlaceholder: true,
        fade: MotionConstants.photoFade,
      ),
    );
  }
}

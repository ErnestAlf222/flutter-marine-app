import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/detail_photo.dart';
import 'package:marine_app/presentation/widgets/shared/glass_surface.dart';
import 'package:marine_app/presentation/widgets/shared/photo_scrim.dart';

/// Una foto de la galería del Detalle con su crédito
class GalleryPhoto {
  final String? url;
  final String? credit;

  const GalleryPhoto({required this.url, this.credit});
}

/// Cabecera del Detalle: las fotos de la especie en un carrusel horizontal con puntos
/// indicadores y contador "1/3". Con una sola foto se ve como siempre, sin carrusel.
/// Los textos de abajo y el botón de "ver completa / llenar" son fijos: no se mueven con
/// el deslizamiento y el botón aplica a la foto que se está viendo.
class DetailGallery extends StatefulWidget {
  final List<GalleryPhoto> photos;
  final String category;
  // La primera foto vuela con el Hero hacia/desde su tarjeta
  final String heroTag;
  // Textos de la especie sobre la foto, abajo
  final Widget? footer;
  // false mientras el Detalle se arrastra para cerrarse: el deslizamiento no debe competir
  final bool swipeEnabled;
  // Muestra "Desliza para ver más fotos" 3 s; [onHintShown] avisa para no repetirlo
  final bool showHint;
  final VoidCallback? onHintShown;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onTap;
  // Solo para pruebas: fotos sin red
  final List<ImageProvider>? providers;

  const DetailGallery({
    super.key,
    required this.photos,
    required this.category,
    required this.heroTag,
    this.footer,
    this.swipeEnabled = true,
    this.showHint = false,
    this.onHintShown,
    this.onPageChanged,
    this.onTap,
    this.providers,
  });

  @override
  State<DetailGallery> createState() => _DetailGalleryState();
}

class _DetailGalleryState extends State<DetailGallery> {
  final _pages = PageController();
  // La foto y el PageView se ponen de acuerdo en quién recibe cada arrastre horizontal
  final _panLock = PhotoPanLock();
  late List<PhotoFramingController> _framings = _framingsFor(
    widget.photos.length,
  );
  int _index = 0;

  Timer? _hintTimer;
  bool _hintVisible = false;

  bool get _several => widget.photos.length > 1;

  List<PhotoFramingController> _framingsFor(int count) =>
      List.generate(count, (_) => PhotoFramingController());

  @override
  void initState() {
    super.initState();
    if (widget.showHint && _several) _startHint();
  }

  @override
  void didUpdateWidget(DetailGallery old) {
    super.didUpdateWidget(old);

    if (old.photos.length != widget.photos.length) {
      for (final framing in _framings) {
        framing.dispose();
      }
      _framings = _framingsFor(widget.photos.length);
      _index = _index.clamp(0, widget.photos.length - 1);
    }
    // Las fotos llegan con el detalle: el aviso nace cuando ya hay varias
    if (widget.showHint && _several && !_hintVisible && _hintTimer == null) {
      _startHint();
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _pages.dispose();
    for (final framing in _framings) {
      framing.dispose();
    }
    super.dispose();
  }

  void _startHint() {
    _hintVisible = true;
    // Avisar al estado de la app no se puede hacer durante el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onHintShown?.call();
    });
    _hintTimer = Timer(MotionConstants.galleryHint, () {
      if (mounted) setState(() => _hintVisible = false);
    });
  }

  void _changed(int index) {
    setState(() => _index = index);
    widget.onPageChanged?.call(index);
    // Deslizó: el aviso ya cumplió
    if (_hintVisible) {
      _hintTimer?.cancel();
      setState(() => _hintVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final photos = widget.photos;
    final framing = _framings[_index];
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: widget.onTap == null ? null : () => widget.onTap!(_index),
          child: PageView.builder(
            controller: _pages,
            itemCount: photos.length,
            physics: _several && widget.swipeEnabled
                ? PanAwarePagePhysics(lock: _panLock)
                : const NeverScrollableScrollPhysics(),
            onPageChanged: _changed,
            itemBuilder: (context, i) => DetailPhoto(
              url: photos[i].url,
              category: widget.category,
              heroTag: i == 0 ? widget.heroTag : null,
              framing: _framings[i],
              panLock: _panLock,
              provider: widget.providers?[i],
            ),
          ),
        ),
        // El degradado va sobre las fotos y bajo los textos
        const PhotoScrim(
          coverage: DesignConstants.detailScrimCoverage,
          solid: DesignConstants.detailScrimSolid,
        ),
        if (_several)
          Positioned(
            top: DesignConstants.galleryDotsTop,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: IgnorePointer(
                child: _Dots(count: photos.length, current: _index),
              ),
            ),
          ),
        Positioned(
          left: DesignConstants.pagePadding,
          right: DesignConstants.pagePadding,
          bottom: DesignConstants.photoToggleBottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // La fila se reserva desde el primer cuadro para que los textos no salten
              // cuando llega el tamaño de la foto
              if (photos[_index].url != null || widget.providers != null)
                SizedBox(
                  height: DesignConstants.photoToggleHeight,
                  width: double.infinity,
                  child: Row(
                    children: [
                      if (_several)
                        _Counter(current: _index + 1, total: photos.length),
                      // Ocupa el resto de la fila: si no cabe, el botón se encoge en vez de desbordar
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ListenableBuilder(
                            listenable: framing,
                            builder: (context, _) => framing.available
                                ? PhotoToggleButton(
                                    whole: framing.whole,
                                    onPressed: () => framing.toggle?.call(),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.footer != null)
                const SizedBox(height: DesignConstants.photoToggleGap),
              ?widget.footer,
            ],
          ),
        ),
        if (_several && widget.showHint)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: const Alignment(0, -0.2),
                child: AnimatedOpacity(
                  opacity: _hintVisible ? 1 : 0,
                  duration: animate ? MotionConstants.short : Duration.zero,
                  child: _hintVisible || animate
                      ? GlassSurface(
                          borderRadius: BorderRadius.circular(
                            DesignConstants.galleryCounterHeight,
                          ),
                          tintAlpha: DesignConstants.glassSolidAlpha,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swipe, size: 20, color: palette.paper),
                              const SizedBox(
                                width: DesignConstants.photoToggleGap,
                              ),
                              // Flexible: si el texto no cabe se recorta en vez de desbordar
                              Flexible(
                                child: Text(
                                  DetailConstants.swipeHint,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: palette.paper),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Un punto por foto; el de la foto actual se ve lleno y más ancho
class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: DetailConstants.photoCounter(current + 1, count),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < count; i++)
            AnimatedContainer(
              duration: animate ? MotionConstants.short : Duration.zero,
              curve: MotionConstants.curve,
              margin: const EdgeInsets.symmetric(
                horizontal: DesignConstants.galleryDotGap / 2,
              ),
              width: i == current
                  ? DesignConstants.galleryDot * 2.5
                  : DesignConstants.galleryDot,
              height: DesignConstants.galleryDot,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignConstants.galleryDot),
                color: palette.paper.withValues(alpha: i == current ? 1 : 0.5),
              ),
            ),
        ],
      ),
    );
  }
}

// Contador "1/3" en cristal
class _Counter extends StatelessWidget {
  final int current;
  final int total;

  const _Counter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return GlassSurface(
      borderRadius: BorderRadius.circular(DesignConstants.galleryCounterHeight),
      tintAlpha: DesignConstants.glassSolidAlpha,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        height: DesignConstants.galleryCounterHeight,
        child: Center(
          child: Text(
            DetailConstants.photoCounter(current, total),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: palette.paper),
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
// Único widget que conoce la caché de fotos de favoritos: decide de cuál leer cada foto
import 'package:marine_app/infrastructure/cache/favorite_photo_cache.dart';
import 'package:marine_app/presentation/widgets/shared/fish_loader.dart';

// Las fotos viven en hosts distintos, así que se usa la URL tal cual con caché.
// Siempre recorta (cover): es lo que ven las tarjetas y el Hero, sin saltos de encuadre.
// Se llama View para no chocar con la entidad SpeciesPhoto del domain
class SpeciesPhotoView extends StatefulWidget {
  final String? url;
  // El marcador toma el color del grupo en vez de un gris neutro
  final String category;
  final BoxFit fit;
  // Limita el tamaño decodificado: las fotos originales pueden ser enormes
  final int? cacheWidth;
  // Fundido con el que entra la foto al cargar
  final Duration fade;
  // Mientras carga, fondo neutro en vez del color del grupo (el visor a pantalla completa)
  final bool neutralPlaceholder;
  // Qué parte de la foto queda dentro del marco cuando se recorta (cover)
  final Alignment alignment;

  const SpeciesPhotoView({
    super.key,
    required this.url,
    required this.category,
    this.fit = BoxFit.cover,
    this.cacheWidth = DesignConstants.tilePhotoCacheWidth,
    this.fade = MotionConstants.short,
    this.neutralPlaceholder = false,
    this.alignment = Alignment.center,
  });

  @override
  State<SpeciesPhotoView> createState() => _SpeciesPhotoViewState();
}

class _SpeciesPhotoViewState extends State<SpeciesPhotoView> {
  // Cambia la clave de la foto para que vuelva a pedirse (al volver la conexión)
  int _attempt = 0;

  void _retry() {
    if (mounted) setState(() => _attempt++);
  }

  @override
  Widget build(BuildContext context) {
    final neutralPlaceholder = widget.neutralPlaceholder;
    final fade = widget.fade;
    final palette = OceanPalette.of(context);
    final base = neutralPlaceholder
        ? palette.abyss
        : palette.categoryColor(widget.category);

    // Mientras la foto carga, un pez pequeño nada sobre el color del grupo
    Widget placeholder([IconData? icon, bool loading = false]) => ColoredBox(
      color: base,
      child: loading
          ? const Center(child: FishLoader.small())
          : icon == null
          ? null
          : Center(
              child: Icon(
                icon,
                color: palette.paper.withValues(alpha: 0.7),
                size: 32,
              ),
            ),
    );

    final photoUrl = widget.url;
    if (photoUrl == null) {
      return placeholder(Icons.image_not_supported_outlined);
    }

    return CachedNetworkImage(
      key: ValueKey(_attempt),
      imageUrl: photoUrl,
      // Las fotos de favoritos viven en su propia caché, que las otras no expulsan
      cacheManager: FavoritePhotoCache.contains(photoUrl)
          ? FavoritePhotoCache.manager
          : null,
      fit: widget.fit,
      alignment: widget.alignment,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: widget.cacheWidth,
      // Con animaciones reducidas la foto entra sin fundido
      fadeInDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : fade,
      fadeInCurve: neutralPlaceholder
          ? MotionConstants.photoFadeCurve
          : MotionConstants.curve,
      // El visor también acorta la salida del marcador; las tarjetas siguen con la del paquete
      fadeOutDuration: neutralPlaceholder
          ? (MediaQuery.disableAnimationsOf(context) ? Duration.zero : fade)
          : const Duration(milliseconds: 1000),
      placeholder: (_, _) => placeholder(null, true),
      errorWidget: (_, _, _) => _FailedPhoto(
        onRetry: _retry,
        child: placeholder(Icons.broken_image_outlined),
      ),
    );
  }
}

// Marcador de una foto que no llegó: mientras está en pantalla pide que la reintenten
// cuando vuelva la conexión
class _FailedPhoto extends StatefulWidget {
  final VoidCallback onRetry;
  final Widget child;

  const _FailedPhoto({required this.onRetry, required this.child});

  @override
  State<_FailedPhoto> createState() => _FailedPhotoState();
}

class _FailedPhotoState extends State<_FailedPhoto> {
  void _retryNow() => widget.onRetry();

  @override
  void initState() {
    super.initState();
    PhotoRetry.add(_retryNow);
  }

  @override
  void dispose() {
    PhotoRetry.remove(_retryNow);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

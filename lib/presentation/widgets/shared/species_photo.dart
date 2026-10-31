import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Las fotos viven en hosts distintos, así que se usa la URL tal cual con caché
// Se llama View para no chocar con la entidad SpeciesPhoto del domain
class SpeciesPhotoView extends StatelessWidget {
  final String? url;
  // El marcador toma el color del grupo en vez de un gris neutro
  final String category;
  final BoxFit fit;
  // Limita el tamaño decodificado: las fotos originales pueden ser enormes
  final int? cacheWidth;

  const SpeciesPhotoView({
    super.key,
    required this.url,
    required this.category,
    this.fit = BoxFit.cover,
    this.cacheWidth = DesignConstants.tilePhotoCacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final base = palette.categoryColor(category);

    Widget placeholder([IconData? icon]) => ColoredBox(
      color: base,
      child: icon == null
          ? null
          : Center(
              child: Icon(
                icon,
                color: palette.paper.withValues(alpha: 0.7),
                size: 32,
              ),
            ),
    );

    final photoUrl = url;
    if (photoUrl == null) return placeholder(Icons.image_not_supported_outlined);

    return CachedNetworkImage(
      imageUrl: photoUrl,
      fit: fit,
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: cacheWidth,
      fadeInDuration: MotionConstants.short,
      fadeInCurve: MotionConstants.curve,
      placeholder: (_, _) => placeholder(),
      errorWidget: (_, _, _) => placeholder(Icons.broken_image_outlined),
    );
  }
}

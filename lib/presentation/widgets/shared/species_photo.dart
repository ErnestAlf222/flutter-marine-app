import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

// Las fotos viven en hosts distintos, así que se usa la URL tal cual con caché
// Se llama View para no chocar con la entidad SpeciesPhoto del domain
class SpeciesPhotoView extends StatelessWidget {
  final String? url;
  final BoxFit fit;

  const SpeciesPhotoView({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget placeholder(Widget child) => ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(child: child),
    );

    final photoUrl = url;
    if (photoUrl == null) {
      return placeholder(
        Icon(Icons.image_not_supported_outlined, color: colors.onSurfaceVariant),
      );
    }

    return CachedNetworkImage(
      imageUrl: photoUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => placeholder(const CircularProgressIndicator()),
      errorWidget: (_, _, _) => placeholder(
        Icon(Icons.broken_image_outlined, color: colors.onSurfaceVariant),
      ),
    );
  }
}

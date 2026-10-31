import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/widgets/shared/favorite_button.dart';
import 'package:marine_app/presentation/widgets/shared/parallax_photo.dart';
import 'package:marine_app/presentation/widgets/shared/photo_scrim.dart';
import 'package:marine_app/presentation/widgets/shared/species_photo.dart';

// Foto a sangre con el nombre encima; la comparten el mosaico de Inicio, Explorar y Favoritos
class SpeciesTile extends StatelessWidget {
  final Species species;
  // Ancho / alto; al variarla el mosaico gana ritmo
  final double aspectRatio;
  final VoidCallback? onTap;
  // Favoritos anima la salida antes de quitar; en el resto se quita al instante
  final Future<void> Function()? onRemoveFavorite;
  // La foto se desplaza dentro de la tarjeta al hacer scroll vertical (mosaico y cuadrículas)
  final bool parallax;

  const SpeciesTile({
    super.key,
    required this.species,
    this.aspectRatio = DesignConstants.photoAspect,
    this.onTap,
    this.onRemoveFavorite,
    this.parallax = false,
  });

  Widget _photo() {
    final photo = SpeciesPhotoView(
      url: species.primaryPhoto,
      category: species.category,
    );
    return parallax ? ParallaxPhoto(child: photo) : photo;
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(DesignConstants.cardRadius);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Las pestañas viven a la vez en un IndexedStack: solo la visible
            // participa en el Hero, o el mismo slug en dos pestañas lo rompería
            HeroMode(
              enabled: TickerMode.valuesOf(context).enabled,
              child: Hero(
                tag: species.slug,
                child: _photo(),
              ),
            ),
            const PhotoScrim(),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    species.commonName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(color: palette.paper),
                  ),
                  Text(
                    species.scientificName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.scientific.copyWith(
                      color: palette.paper.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ),
            // Después del InkWell para que el corazón reciba su propio toque
            Positioned(
              top: 12,
              right: 12,
              child: FavoriteButton(
                species: species,
                onRemove: onRemoveFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

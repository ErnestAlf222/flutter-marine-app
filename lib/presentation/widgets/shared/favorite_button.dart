import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/shared/favorite_bubbles.dart';

// Corazón de favorito sobre vidrio: coral solo cuando está marcado, con rebote al marcar
class FavoriteButton extends ConsumerStatefulWidget {
  final Species species;
  // Permite animar la salida antes de quitar (Favoritos); por defecto quita al instante
  final Future<void> Function()? onRemove;
  // Versión grande para el héroe de Inicio y el Detalle (56 dp, icono de 34)
  final bool large;

  const FavoriteButton({
    super.key,
    required this.species,
    this.onRemove,
    this.large = false,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: MotionConstants.long,
  );

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _toggle(bool isFavorite) async {
    final actions = ref.read(favoriteActionsProvider);

    if (isFavorite) {
      if (widget.onRemove != null) return widget.onRemove!();
      await _report(await actions.remove(widget.species.slug));
    } else {
      await _report(await actions.add(widget.species));
    }
  }

  Future<void> _report(String? error) async {
    if (error == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final slug = widget.species.slug;
    final isFavorite = ref.watch(isFavoriteProvider(slug));
    final size = widget.large
        ? DesignConstants.favoriteLargeSize
        : DesignConstants.favoriteTileSize;
    final iconSize = widget.large
        ? DesignConstants.favoriteLargeIcon
        : DesignConstants.favoriteTileIcon;

    // Rebota solo al marcar, no al pintar una tarjeta que ya era favorita. Se compara entre
    // dos listas ya cargadas: mientras la base local no ha respondido, isFavorite vale false
    // y, al llegar la lista, una especie ya guardada parecería recién marcada.
    ref.listen(favoritesProvider, (previous, next) {
      final before = previous?.asData?.value;
      final after = next.asData?.value;
      if (before == null || after == null) return;
      final added = !before.any((s) => s.slug == slug) && after.any((s) => s.slug == slug);
      if (added && !MediaQuery.disableAnimationsOf(context)) {
        _bounce.forward(from: 0);
        // Además del rebote, unas burbujas suben desde el corazón
        FavoriteBubbles.show(context, color: palette.coral);
      }
    });

    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1).animate(
        CurvedAnimation(parent: _bounce, curve: MotionConstants.bounce),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: DesignConstants.glassBlur,
            sigmaY: DesignConstants.glassBlur,
          ),
          child: ColoredBox(
            color: palette.ink.withValues(alpha: DesignConstants.glassAlpha),
            child: SizedBox.square(
              dimension: size,
              child: IconButton(
                isSelected: isFavorite,
                iconSize: iconSize,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: size, height: size),
                tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                icon: Icon(Icons.favorite_border, color: palette.paper),
                selectedIcon: Icon(Icons.favorite, color: palette.coral),
                onPressed: () => _toggle(isFavorite),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

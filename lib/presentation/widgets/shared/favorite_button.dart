import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';

// Corazón de favorito sobre vidrio: coral solo cuando está marcado, con rebote al marcar
class FavoriteButton extends ConsumerStatefulWidget {
  final Species species;
  // Permite animar la salida antes de quitar (Favoritos); por defecto quita al instante
  final Future<void> Function()? onRemove;

  const FavoriteButton({super.key, required this.species, this.onRemove});

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

    // Rebota solo al marcar, no al pintar una tarjeta que ya era favorita
    ref.listen(isFavoriteProvider(slug), (previous, next) {
      if (previous == false && next && !MediaQuery.disableAnimationsOf(context)) {
        _bounce.forward(from: 0);
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
              dimension: DesignConstants.glassSize,
              child: IconButton(
                isSelected: isFavorite,
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

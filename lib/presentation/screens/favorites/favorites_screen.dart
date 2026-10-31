import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Transparente para ver el degradado de profundidad del shell
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(bottom: false, child: FavoritesView()),
    );
  }
}

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView> {
  // Tarjetas que se están despidiendo: se desvanecen y encogen antes de borrarse
  final Set<String> _leaving = {};

  Future<void> _remove(Species species) async {
    setState(() => _leaving.add(species.slug));
    // Espera a que termine la animación de salida; con animaciones reducidas, no hay espera
    if (!MediaQuery.disableAnimationsOf(context)) {
      await Future<void>.delayed(MotionConstants.short);
    }
    final error = await ref.read(favoriteActionsProvider).remove(species.slug);

    if (!mounted) return;
    setState(() => _leaving.remove(species.slug));
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final count = favorites.asData?.value.length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignConstants.pagePadding,
              24,
              DesignConstants.pagePadding,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == null
                      ? 'GUARDADAS EN TU DISPOSITIVO'
                      : '$count ${count == 1 ? 'ESPECIE GUARDADA' : 'ESPECIES GUARDADAS'}',
                  style: textTheme.overline.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus favoritos',
                  style: textTheme.headlineMedium?.copyWith(color: palette.paper),
                ),
              ],
            ),
          ),
        ),
        favorites.when(
          loading: () => _skeleton(),
          error: (error, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: _Message(
              icon: Icons.error_outline,
              message: 'No se pudieron leer tus favoritos.',
              actionLabel: 'Reintentar',
              onAction: () => ref.invalidate(favoritesProvider),
            ),
          ),
          data: (items) => items.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Message(
                    icon: Icons.favorite_border,
                    message:
                        'Aún no tienes favoritos.\nToca el corazón de una especie para guardarla aquí. Se queda en tu dispositivo y se ve sin conexión.',
                    actionLabel: 'Explorar especies',
                    onAction: () => context.go(RouteConstants.explore),
                  ),
                )
              : _grid(items),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: DesignConstants.sectionGap)),
      ],
    );
  }

  Widget _grid(List<Species> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: DesignConstants.pagePadding),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: DesignConstants.gridGap,
        crossAxisSpacing: DesignConstants.gridGap,
        childCount: items.length,
        itemBuilder: (context, index) {
          final species = items[index];
          final leaving = _leaving.contains(species.slug);

          return KeyedSubtree(
            key: ValueKey(species.slug),
            child: StaggeredEntry(
              index: index,
              child: AnimatedOpacity(
                duration: MotionConstants.short,
                curve: MotionConstants.curve,
                opacity: leaving ? 0 : 1,
                child: AnimatedScale(
                  duration: MotionConstants.short,
                  curve: MotionConstants.curve,
                  scale: leaving ? MotionConstants.removeScale : 1,
                  child: SpeciesTile(
                    species: species,
                    aspectRatio: DesignConstants
                        .mosaicAspects[index % DesignConstants.mosaicAspects.length],
                    onTap: () => context.push(
                      RouteConstants.speciesLocation(species.slug),
                      extra: species,
                    ),
                    onRemoveFavorite: () => _remove(species),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _skeleton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: DesignConstants.pagePadding),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: DesignConstants.gridGap,
        crossAxisSpacing: DesignConstants.gridGap,
        childCount: 4,
        itemBuilder: (context, index) => AspectRatio(
          aspectRatio: DesignConstants
              .mosaicAspects[index % DesignConstants.mosaicAspects.length],
          child: SkeletonBox(
            borderRadius: BorderRadius.circular(DesignConstants.cardRadius),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _Message({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignConstants.pagePadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: palette.paper),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.paper),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

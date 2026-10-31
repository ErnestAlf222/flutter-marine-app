import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

// Espacio que ocupa la cabecera sobre el héroe (botón de vidrio más margen)
const double _headerHeight = 64;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Transparente para ver el degradado de profundidad del shell; sin SafeArea
    // porque el héroe pasa por debajo de la barra de estado
    return const Scaffold(backgroundColor: Colors.transparent, body: HomeView());
  }
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Inicio no lista resultados: deja los filtros listos y abre Explorar
  void _openExplore({String? query, String? category, double? depthMin}) {
    final filters = ref.read(speciesFiltersProvider.notifier)..clear();
    if (query != null) filters.setQuery(query);
    if (category != null) filters.setCategory(category);
    if (depthMin != null) filters.setDepthRange(depthMin, null);
    context.go(RouteConstants.explore);
  }

  void _search(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    _searchController.closeView('');
    _openExplore(query: query);
  }

  Future<void> _refresh() async {
    ref.invalidate(featuredSpeciesProvider);
    ref.invalidate(discoverSpeciesProvider);
    try {
      await ref.read(featuredSpeciesProvider.future);
    } catch (_) {
      // El error ya se muestra en el héroe
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      // Debajo de la cabecera, no tapado por la barra de estado
      edgeOffset: MediaQuery.paddingOf(context).top + _headerHeight,
      child: CustomScrollView(
        // Siempre desplazable para que el pull-to-refresh funcione con poco contenido
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _HeroSection(
              header: Row(
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: palette.paper,
                    ),
                  ),
                  const Spacer(),
                  SearchAnchor(
                    searchController: _searchController,
                    isFullScreen: true,
                    viewHintText: 'Buscar especies',
                    viewOnSubmitted: _search,
                    builder: (context, controller) => GlassButton(
                      icon: Icons.search,
                      tooltip: 'Buscar especies',
                      onPressed: controller.openView,
                    ),
                    suggestionsBuilder: (context, controller) {
                      final query = controller.text.trim();
                      if (query.isEmpty) return const <Widget>[];
                      return [
                        ListTile(
                          leading: const Icon(Icons.search),
                          title: Text('Buscar «$query»'),
                          onTap: () => _search(query),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignConstants.pagePadding,
                DesignConstants.sectionGap,
                DesignConstants.pagePadding,
                0,
              ),
              child: _DeepWaterTile(
                onTap: () =>
                    _openExplore(depthMin: DesignConstants.deepWaterMinM),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionHeader(
              overline: '${CategoryConstants.labels.length} GRUPOS',
              title: 'Por grupo',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignConstants.pagePadding,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: DesignConstants.gridGap,
                crossAxisSpacing: DesignConstants.gridGap,
                mainAxisExtent: DesignConstants.categoryTileHeight,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final id = CategoryConstants.ids[index];
                return StaggeredEntry(
                  index: index,
                  child: CategoryTile(
                    categoryId: id,
                    onTap: () => _openExplore(category: id),
                  ),
                );
              }, childCount: CategoryConstants.labels.length),
            ),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(overline: 'AL AZAR', title: 'Descubre más'),
          ),
          const _DiscoverSliver(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: DesignConstants.sectionGap,
              ),
              child: Center(
                child: FilledButton.tonal(
                  onPressed: _openExplore,
                  child: const Text('Ver más'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Atajo a las especies que llegan al abismo; el filtro es por solapamiento
// (depth_min=100), así que el texto dice "llegan" y no "viven a"
class _DeepWaterTile extends StatelessWidget {
  final VoidCallback onTap;

  const _DeepWaterTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      borderRadius: BorderRadius.circular(DesignConstants.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.deep, palette.abyss],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MÁS DE ${DesignConstants.deepWaterMinM.toInt()} M',
                        style: textTheme.overline.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Aguas profundas',
                        style: textTheme.titleLarge?.copyWith(
                          color: palette.paper,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Especies que llegan hasta el abismo',
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.paper.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.south, color: palette.paper),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String overline;
  final String title;

  const _SectionHeader({required this.overline, required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = OceanPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignConstants.pagePadding,
        DesignConstants.sectionGap,
        DesignConstants.pagePadding,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overline,
            style: textTheme.overline.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(color: palette.paper),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Héroe de destacadas
// ---------------------------------------------------------------------------

class _HeroSection extends ConsumerWidget {
  final Widget header;

  const _HeroSection({required this.header});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredSpeciesProvider);
    final height =
        MediaQuery.sizeOf(context).height * DesignConstants.heroHeightFraction;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          featured.when(
            // Al refrescar se conserva el héroe anterior mientras llega el nuevo
            skipLoadingOnReload: true,
            loading: () => const _HeroLoading(),
            // Los providers lanzan mensajes en español (String); cualquier otra
            // excepción es inesperada y no se vuelca cruda al usuario
            error: (error, _) => _HeroMessage(
              icon: Icons.error_outline,
              message: error is String
                  ? error
                  : 'Ocurrió un error inesperado.',
              onRetry: () => ref.invalidate(featuredSpeciesProvider),
            ),
            data: (species) => species.isEmpty
                ? const _HeroMessage(
                    icon: Icons.sailing_outlined,
                    message: 'No hay especies destacadas por ahora.',
                  )
                : _HeroCarousel(species: species),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignConstants.pagePadding,
                  vertical: 8,
                ),
                child: header,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reserva el hueco de la cabecera arriba y un margen abajo para las tarjetas
EdgeInsets _heroCardInsets(BuildContext context) => EdgeInsets.only(
  top: MediaQuery.paddingOf(context).top + _headerHeight,
  bottom: 24,
);

class _HeroCarousel extends StatefulWidget {
  final List<Species> species;

  const _HeroCarousel({required this.species});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  // Deja asomar las tarjetas vecinas, giradas, para invitar a deslizar
  final _controller = PageController(
    viewportFraction: DesignConstants.heroViewportFraction,
  );
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Página fraccionaria durante el deslizamiento; antes del primer layout aún no existe
  double get _page => _controller.hasClients &&
          _controller.position.haveDimensions
      ? _controller.page ?? _index.toDouble()
      : _index.toDouble();

  Widget _transformed(int index, Widget child) {
    final delta = (index - _page).clamp(-1.0, 1.0);
    final distance = delta.abs();

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, DesignConstants.heroPerspective)
        ..rotateY(-delta * DesignConstants.heroSideAngle)
        ..scaleByDouble(
          lerpDouble(1, DesignConstants.heroSideScale, distance)!,
          lerpDouble(1, DesignConstants.heroSideScale, distance)!,
          1,
          1,
        ),
      child: Opacity(
        opacity: lerpDouble(1, DesignConstants.heroSideOpacity, distance)!,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _HeroBackdrop(species: widget.species[_index]),
        Padding(
          padding: _heroCardInsets(context),
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.species.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, index) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => _transformed(index, child!),
              child: Center(
                child: _HeroCard(species: widget.species[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Foto de la especie activa, ampliada, desenfocada y oscurecida; se funde al deslizar
class _HeroBackdrop extends StatelessWidget {
  final Species species;

  const _HeroBackdrop({required this.species});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(DesignConstants.cardRadius),
      ),
      child: AnimatedSwitcher(
        duration: MotionConstants.long,
        switchInCurve: MotionConstants.curve,
        child: SizedBox.expand(
          key: ValueKey(species.slug),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // La escala evita que el desenfoque deje bordes transparentes
              Transform.scale(
                scale: 1.3,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: DesignConstants.backdropBlur,
                    sigmaY: DesignConstants.backdropBlur,
                  ),
                  child: SpeciesPhotoView(
                    url: species.primaryPhoto,
                    category: species.category,
                    cacheWidth: DesignConstants.backdropCacheWidth,
                  ),
                ),
              ),
              ColoredBox(
                color: palette.ink.withValues(alpha: DesignConstants.backdropDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Species species;

  const _HeroCard({required this.species});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: DesignConstants.photoAspect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignConstants.cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Solo la pestaña visible participa en el Hero (ver SpeciesTile)
            HeroMode(
              enabled: TickerMode.valuesOf(context).enabled,
              child: Hero(
                tag: species.slug,
                child: SpeciesPhotoView(
                  url: species.primaryPhoto,
                  category: species.category,
                  cacheWidth: DesignConstants.heroPhotoCacheWidth,
                ),
              ),
            ),
            // Tramo oscuro más alto: el sobretítulo queda sobre el degradado, no sobre la foto
            const PhotoScrim(
              solid: DesignConstants.heroScrimSolid,
              coverage: DesignConstants.heroScrimCoverage,
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ESPECIE DESTACADA',
                    style: textTheme.overline.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    species.commonName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith(
                      color: palette.paper,
                    ),
                  ),
                  Text(
                    species.scientificName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.scientific.copyWith(
                      color: palette.paper.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConservationBadge(
                        status: species.conservationStatus,
                        compact: true,
                      ),
                      DepthRangeLabel(
                        minM: species.depthMinM,
                        maxM: species.depthMaxM,
                        color: palette.paper,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => context.push(
                    RouteConstants.speciesLocation(species.slug),
                    extra: species,
                  ),
                ),
              ),
            ),
            // Después del InkWell para que el corazón reciba su propio toque
            Positioned(
              top: 16,
              right: 16,
              child: FavoriteButton(species: species),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroLoading extends StatelessWidget {
  const _HeroLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _heroCardInsets(context),
      child: Center(
        child: AspectRatio(
          aspectRatio: DesignConstants.photoAspect,
          child: SkeletonBox(
            borderRadius: BorderRadius.circular(DesignConstants.cardRadius),
          ),
        ),
      ),
    );
  }
}

class _HeroMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  // En el héroe deja libre la cabecera; fuera de él basta un margen simple
  final bool inHero;

  const _HeroMessage({
    required this.icon,
    required this.message,
    this.onRetry,
    this.inHero = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Padding(
      padding: (inHero ? _heroCardInsets(context) : const EdgeInsets.all(0))
          .copyWith(
            left: DesignConstants.pagePadding * 2,
            right: DesignConstants.pagePadding * 2,
          ),
      child: Center(
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
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mosaico "Descubre más"
// ---------------------------------------------------------------------------

class _DiscoverSliver extends ConsumerWidget {
  const _DiscoverSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discover = ref.watch(discoverSpeciesProvider);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignConstants.pagePadding,
      ),
      sliver: discover.when(
        skipLoadingOnReload: true,
        loading: () => SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: DesignConstants.gridGap,
          crossAxisSpacing: DesignConstants.gridGap,
          childCount: 4,
          itemBuilder: (context, index) => AspectRatio(
            aspectRatio:
                DesignConstants.mosaicAspects[index %
                    DesignConstants.mosaicAspects.length],
            child: SkeletonBox(
              borderRadius: BorderRadius.circular(DesignConstants.cardRadius),
            ),
          ),
        ),
        error: (error, _) => SliverToBoxAdapter(
          child: _HeroMessage(
            inHero: false,
            icon: Icons.error_outline,
            message: error is String ? error : 'Ocurrió un error inesperado.',
            onRetry: () => ref.invalidate(discoverSpeciesProvider),
          ),
        ),
        data: (species) => SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: DesignConstants.gridGap,
          crossAxisSpacing: DesignConstants.gridGap,
          childCount: species.length,
          itemBuilder: (context, index) => StaggeredEntry(
            index: index,
            child: SpeciesTile(
              species: species[index],
              onTap: () => context.push(
                RouteConstants.speciesLocation(species[index].slug),
                extra: species[index],
              ),
              aspectRatio:
                  DesignConstants.mosaicAspects[index %
                      DesignConstants.mosaicAspects.length],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

// La API puede tardar hasta 10 s en traer las destacadas: la altura es fija
// para que el estado de carga ocupe el mismo lugar que el carrusel
const double _carouselHeight = 380;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: HomeView()));
  }
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Inicio no lista resultados: deja los filtros listos y abre Explorar
  void _openExplore({String? query, String? category}) {
    final filters = ref.read(speciesFiltersProvider.notifier)..clear();
    if (query != null) filters.setQuery(query);
    if (category != null) filters.setCategory(category);
    context.go(RouteConstants.explore);
  }

  void _search(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    _openExplore(query: query);
    _searchController.clear();
  }

  Future<void> _refresh() async {
    ref.invalidate(featuredSpeciesProvider);
    try {
      await ref.read(featuredSpeciesProvider.future);
    } catch (_) {
      // El error ya se muestra en el carrusel
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        // Siempre desplazable para que el pull-to-refresh funcione con poco contenido
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Descubre la vida marina',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar especies',
              leading: const Icon(Icons.search),
              onSubmitted: _search,
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Categorías'),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final entry in CategoryConstants.labels.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(entry.value),
                      selected: false,
                      onSelected: (_) => _openExplore(category: entry.key),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Especies destacadas'),
          const SizedBox(height: 8),
          const _FeaturedSection(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FeaturedSection extends ConsumerWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredSpeciesProvider);

    return featured.when(
      // Al refrescar se conserva el carrusel anterior mientras llega el nuevo
      skipLoadingOnReload: true,
      loading: () => const _FeaturedLoading(),
      // Los providers lanzan mensajes en español (String); cualquier otra
      // excepción es inesperada y no se vuelca cruda al usuario
      error: (error, _) => _FeaturedError(
        message: error is String ? error : 'Ocurrió un error inesperado.',
        onRetry: () => ref.invalidate(featuredSpeciesProvider),
      ),
      data: (species) => species.isEmpty
          ? const _FeaturedMessage(
              icon: Icons.sailing_outlined,
              message: 'No hay especies destacadas por ahora.',
            )
          : _FeaturedCarousel(species: species),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  final List<Species> species;

  const _FeaturedCarousel({required this.species});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  // Deja asomar las tarjetas vecinas para invitar a deslizar
  final _controller = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _carouselHeight,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.species.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _FeaturedCard(species: widget.species[index]),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Species species;

  const _FeaturedCard({required this.species});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Sin onTap: el detalle se conecta cuando exista su ruta
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SpeciesPhotoView(url: species.primaryPhoto)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  species.commonName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  species.scientificName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedLoading extends StatelessWidget {
  const _FeaturedLoading();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: _carouselHeight,
        child: Card(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Buscando especies destacadas…',
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Puede tardar unos segundos',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FeaturedError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: _carouselHeight,
        child: Card(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _FeaturedMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

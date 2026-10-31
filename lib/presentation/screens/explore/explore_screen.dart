import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Transparente para ver el degradado de profundidad del shell
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(bottom: false, child: ExploreView()),
    );
  }
}

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({super.key});

  @override
  ConsumerState<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  late final TextEditingController _controller;
  Timer? _debounce;
  // Último texto enviado a los filtros; distingue lo escrito aquí de lo que deja Inicio
  late String _sentQuery;

  @override
  void initState() {
    super.initState();
    _sentQuery = ref.read(speciesFiltersProvider).query;
    _controller = TextEditingController(text: _sentQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(ApiConstants.searchDebounce, () => _commit(text));
  }

  void _commit(String text) {
    _debounce?.cancel();
    final query = text.trim();
    if (query == _sentQuery) return;
    _sentQuery = query;
    ref.read(speciesFiltersProvider.notifier).setQuery(query);
  }

  void _clearQuery() {
    _debounce?.cancel();
    _controller.clear();
    _commit('');
  }

  Future<void> _openFilters() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: OceanPalette.of(context).abyss,
      builder: (_) => const _FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final filters = ref.watch(speciesFiltersProvider);

    // Inicio deja categoría, texto o profundidad antes de abrir esta pestaña, que ya existe
    ref.listen(speciesFiltersProvider, (_, next) {
      if (next.query != _sentQuery) {
        _debounce?.cancel();
        _sentQuery = next.query;
        _controller.text = next.query;
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignConstants.pagePadding,
            12,
            DesignConstants.pagePadding,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => SearchBar(
                    controller: _controller,
                    hintText: 'Buscar especies',
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(palette.deep),
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(color: palette.paper),
                    ),
                    hintStyle: WidgetStatePropertyAll(
                      TextStyle(color: palette.paper.withValues(alpha: 0.6)),
                    ),
                    leading: Icon(Icons.search, color: palette.paper),
                    trailing: [
                      if (_controller.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.close, color: palette.paper),
                          tooltip: 'Borrar búsqueda',
                          onPressed: _clearQuery,
                        ),
                    ],
                    onChanged: _onChanged,
                    onSubmitted: _commit,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Badge(
                isLabelVisible: filters.activeCount > 0 && !filters.hasQuery,
                label: Text('${filters.activeCount}'),
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.tune),
                  tooltip: filters.hasQuery
                      ? 'Los filtros se desactivan mientras buscas por texto'
                      : 'Filtros',
                  // Con texto se usa /search, que no admite filtros
                  onPressed: filters.hasQuery ? null : _openFilters,
                ),
              ),
            ],
          ),
        ),
        _ActiveFilters(onClearQuery: _clearQuery),
        const Expanded(child: _Results()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Filtros activos
// ---------------------------------------------------------------------------

class _ActiveFilters extends ConsumerWidget {
  final VoidCallback onClearQuery;

  const _ActiveFilters({required this.onClearQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(speciesFiltersProvider);
    final notifier = ref.read(speciesFiltersProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final palette = OceanPalette.of(context);

    final chips = <Widget>[
      if (filters.category != null)
        _removable(
          CategoryConstants.labels[filters.category] ?? filters.category!,
          () => notifier.setCategory(null),
        ),
      if (filters.conservationStatus != null)
        _removable(
          '${filters.conservationStatus} · ${ConservationConstants.labels[filters.conservationStatus] ?? ''}',
          () => notifier.setConservationStatus(null),
        ),
      if (filters.dangerLevel != null)
        _removable(
          TraitConstants.danger(filters.dangerLevel!),
          () => notifier.setDangerLevel(null),
        ),
      if (filters.depthMin != null)
        _removable(
          'Llegan a ${_fmt(filters.depthMin!)} m o más',
          () => notifier.setDepthRange(null, null),
        ),
      if (filters.sizeMin != null)
        _removable(
          'Alcanzan ${SizeBar.format(filters.sizeMin!)} o más',
          () => notifier.setSizeRange(null, null),
        ),
    ];

    if (chips.isEmpty && !filters.hasQuery) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignConstants.pagePadding,
              ),
              children: [
                if (filters.hasQuery)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      label: Text('«${filters.query.trim()}»'),
                      onDeleted: onClearQuery,
                    ),
                  ),
                // Con texto los filtros no se aplican: se ven apagados y sin respuesta
                for (final chip in chips)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: filters.hasQuery
                        ? IgnorePointer(child: Opacity(opacity: 0.4, child: chip))
                        : chip,
                  ),
                if (chips.length > 1 && !filters.hasQuery)
                  ActionChip(
                    label: const Text('Quitar todos'),
                    onPressed: () =>
                        notifier.apply(SpeciesFilters(query: filters.query)),
                  ),
              ],
            ),
          ),
          if (filters.hasQuery && chips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignConstants.pagePadding,
                6,
                DesignConstants.pagePadding,
                0,
              ),
              child: Text(
                'Los filtros no se aplican mientras buscas por texto.',
                style: textTheme.bodySmall?.copyWith(
                  color: palette.paper.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _removable(String label, VoidCallback onRemove) =>
      InputChip(label: Text(label), onDeleted: onRemove);
}

// Sin decimales cuando el valor es entero
String _fmt(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

// ---------------------------------------------------------------------------
// Resultados
// ---------------------------------------------------------------------------

class _Results extends ConsumerWidget {
  const _Results();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(speciesListProvider);
    final filters = ref.watch(speciesFiltersProvider);

    // Cada estado tiene su propio scroll: el cambio es un fundido suave
    return AnimatedSwitcher(
      duration: MotionConstants.short,
      switchInCurve: MotionConstants.curve,
      child: list.when(
        loading: () => const _ResultsSkeleton(key: ValueKey('loading')),
        error: (error, _) => _ResultsMessage(
          key: const ValueKey('error'),
          icon: Icons.error_outline,
          message: error is String ? error : 'Ocurrió un error inesperado.',
          actionLabel: 'Reintentar',
          onAction: () => ref.invalidate(speciesListProvider),
        ),
        data: (state) => state.items.isEmpty
            ? _ResultsMessage(
                key: const ValueKey('empty'),
                icon: Icons.search_off,
                message: 'No encontramos especies con esa búsqueda.',
                actionLabel: filters.hasQuery || filters.activeCount > 0
                    ? 'Quitar filtros y búsqueda'
                    : null,
                onAction: () => ref
                    .read(speciesFiltersProvider.notifier)
                    .clear(),
              )
            : _ResultsGrid(key: const ValueKey('data'), state: state),
      ),
    );
  }
}

class _ResultsGrid extends ConsumerStatefulWidget {
  final SpeciesListState state;

  const _ResultsGrid({super.key, required this.state});

  @override
  ConsumerState<_ResultsGrid> createState() => _ResultsGridState();
}

class _ResultsGridState extends ConsumerState<_ResultsGrid> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scroll.position;
    if (position.extentAfter < DesignConstants.loadMoreExtent) {
      ref.read(speciesListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final palette = OceanPalette.of(context);

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            DesignConstants.pagePadding,
            16,
            DesignConstants.pagePadding,
            0,
          ),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: DesignConstants.gridGap,
            crossAxisSpacing: DesignConstants.gridGap,
            childCount: state.items.length,
            itemBuilder: (context, index) {
              final species = state.items[index];
              return StaggeredEntry(
                // Las páginas siguientes también entran en cascada, no todas con el mismo retraso
                index: index % ApiConstants.defaultPerPage % 6,
                child: SpeciesTile(
                  species: species,
                  aspectRatio: DesignConstants
                      .mosaicAspects[index % DesignConstants.mosaicAspects.length],
                  onTap: () => context.push(
                    RouteConstants.speciesLocation(species.slug),
                    extra: species,
                  ),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignConstants.pagePadding,
              vertical: DesignConstants.sectionGap,
            ),
            child: _footer(context, state, palette),
          ),
        ),
      ],
    );
  }

  Widget _footer(BuildContext context, SpeciesListState state, OceanPalette palette) {
    final radius = BorderRadius.circular(DesignConstants.tileRadius);

    if (state.isLoadingMore) {
      return SizedBox(height: 72, child: SkeletonBox(borderRadius: radius));
    }

    // Lo ya cargado se queda; solo el pie muestra el fallo y permite reintentar
    if (state.loadMoreError != null) {
      return Column(
        children: [
          Text(
            state.loadMoreError!,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.paper),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () =>
                ref.read(speciesListProvider.notifier).loadNextPage(),
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (!state.hasNextPage) {
      return Text(
        'Llegaste al final',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: palette.paper.withValues(alpha: 0.6),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            DesignConstants.pagePadding,
            16,
            DesignConstants.pagePadding,
            0,
          ),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: DesignConstants.gridGap,
            crossAxisSpacing: DesignConstants.gridGap,
            childCount: 6,
            itemBuilder: (context, index) => AspectRatio(
              aspectRatio: DesignConstants
                  .mosaicAspects[index % DesignConstants.mosaicAspects.length],
              child: SkeletonBox(
                borderRadius: BorderRadius.circular(DesignConstants.cardRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultsMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback onAction;

  const _ResultsMessage({
    super.key,
    required this.icon,
    required this.message,
    required this.onAction,
    this.actionLabel,
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
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panel de filtros
// ---------------------------------------------------------------------------

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  // Borrador: nada se pide al servidor hasta pulsar "Aplicar"
  late String? _category;
  late String? _status;
  late String? _danger;
  late double? _depthMin;
  late double? _sizeMin;

  @override
  void initState() {
    super.initState();
    final f = ref.read(speciesFiltersProvider);
    _category = f.category;
    _status = f.conservationStatus;
    _danger = f.dangerLevel;
    _depthMin = f.depthMin;
    _sizeMin = f.sizeMin;
  }

  void _clear() => setState(() {
    _category = null;
    _status = null;
    _danger = null;
    _depthMin = null;
    _sizeMin = null;
  });

  void _apply() {
    final current = ref.read(speciesFiltersProvider);
    ref.read(speciesFiltersProvider.notifier).apply(
      current.copyWith(
        category: () => _category,
        conservationStatus: () => _status,
        dangerLevel: () => _danger,
        depthMin: () => _depthMin,
        depthMax: () => null,
        sizeMin: () => _sizeMin,
        sizeMax: () => null,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              DesignConstants.pagePadding,
              0,
              DesignConstants.pagePadding,
              DesignConstants.pagePadding,
            ),
            children: [
              _SheetTitle('Grupo'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in CategoryConstants.ids)
                    CategoryTile(
                      categoryId: id,
                      compact: true,
                      selected: _category == id,
                      onTap: () => setState(
                        () => _category = _category == id ? null : id,
                      ),
                    ),
                ],
              ),
              _SheetTitle('Estado de conservación (UICN)'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final code in ConservationConstants.catalog)
                    FilterChip(
                      label: Text('$code · ${ConservationConstants.labels[code]}'),
                      selected: _status == code,
                      showCheckmark: false,
                      selectedColor: palette.uicnColor(code),
                      labelStyle: TextStyle(
                        color: _status == code
                            ? palette.onColor(palette.uicnColor(code))
                            : palette.paper,
                      ),
                      onSelected: (on) =>
                          setState(() => _status = on ? code : null),
                    ),
                ],
              ),
              _SheetTitle('Peligrosidad'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in TraitConstants.dangerLevels.entries)
                    FilterChip(
                      label: Text(entry.value),
                      selected: _danger == entry.key,
                      onSelected: (on) =>
                          setState(() => _danger = on ? entry.key : null),
                    ),
                ],
              ),
              _SheetTitle('Profundidad'),
              _StepSlider(
                steps: MeasureConstants.depthFilterSteps,
                value: _depthMin,
                format: (v) => '${_fmt(v)} m o más',
                summary: 'Llegan al menos a',
                hint:
                    'Muestra las especies cuyo rango llega a esa profundidad o más. No indica a qué profundidad viven.',
                onChanged: (v) => setState(() => _depthMin = v),
              ),
              _SheetTitle('Tamaño'),
              _StepSlider(
                steps: MeasureConstants.sizeFilterSteps,
                value: _sizeMin,
                format: (v) => '${SizeBar.format(v)} o más',
                summary: 'Alcanzan al menos',
                hint:
                    'Muestra las especies cuya talla máxima llega a esa medida o más. No indica cuánto miden los ejemplares.',
                onChanged: (v) => setState(() => _sizeMin = v),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(DesignConstants.pagePadding),
          child: Row(
            children: [
              TextButton(onPressed: _clear, child: const Text('Limpiar')),
              const Spacer(),
              FilledButton(onPressed: _apply, child: const Text('Aplicar')),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final String text;

  const _SheetTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DesignConstants.sectionGap - 8, bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.overline.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// Control de un solo extremo con pasos fijos; el paso 0 quita el filtro
class _StepSlider extends StatelessWidget {
  final List<double> steps;
  final double? value;
  final String Function(double) format;
  final String summary;
  final String hint;
  final ValueChanged<double?> onChanged;

  const _StepSlider({
    required this.steps,
    required this.value,
    required this.format,
    required this.summary,
    required this.hint,
    required this.onChanged,
  });

  int get _index {
    final v = value;
    if (v == null) return 0;
    var best = 0;
    for (var i = 1; i < steps.length; i++) {
      if ((steps[i] - v).abs() < (steps[best] - v).abs()) best = i;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = steps[_index];
    final label = current == 0 ? 'Cualquiera' : format(current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$summary: $label',
          style: textTheme.titleSmall?.copyWith(color: palette.paper),
        ),
        Slider(
          value: _index.toDouble(),
          min: 0,
          max: (steps.length - 1).toDouble(),
          divisions: steps.length - 1,
          label: label,
          onChanged: (v) {
            final step = steps[v.round()];
            onChanged(step == 0 ? null : step);
          },
        ),
        Text(
          hint,
          style: textTheme.bodySmall?.copyWith(
            color: palette.paper.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

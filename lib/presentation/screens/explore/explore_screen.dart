import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Transparente para ver el degradado de profundidad del shell. El botón de filtros es el
    // FAB estándar: el cuerpo de esta pantalla termina donde empieza la barra de navegación
    // del shell, así que nunca queda debajo de ella
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(bottom: false, child: ExploreView()),
      floatingActionButton: _FiltersButton(),
    );
  }
}

// Hoja de cristal: el contenido se pinta sobre una superficie translúcida con desenfoque
Future<void> _openFilters(BuildContext context) {
  // Si el buscador seguía enfocado (con el teclado ya oculto), al cerrar la hoja Flutter le
  // devolvía el foco y el teclado se abría solo: se suelta antes de abrirla, así no hay a
  // quién devolverlo
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FiltersSheet(),
  );
}

// Botón de filtros: FAB de Material 3 siempre visible y de color sólido (sin cristal ni
// transparencia). Con filtros aplicados se extiende y dice cuántos son.
class _FiltersButton extends ConsumerWidget {
  const _FiltersButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      speciesFiltersProvider.select((f) => f.activeCount),
    );
    final scheme = Theme.of(context).colorScheme;

    // primary da 11.3:1 contra el fondo oscuro y 7.7:1 con su texto (primaryContainer
    // solo llegaba a 2.1:1 contra el fondo)
    const heroTag = null;
    void open() => _openFilters(context);

    return count > 0
        ? FloatingActionButton.extended(
            heroTag: heroTag,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            tooltip: 'Filtros, $count aplicados',
            icon: const Icon(Icons.tune),
            label: Text('Filtros · $count'),
            onPressed: open,
          )
        : FloatingActionButton(
            heroTag: heroTag,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            tooltip: 'Filtros',
            onPressed: open,
            child: const Icon(Icons.tune),
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
  final _focusNode = FocusNode();
  Timer? _debounce;
  // Último texto enviado a los filtros; distingue lo escrito aquí de lo que deja Inicio
  late String _sentQuery;

  @override
  void initState() {
    super.initState();
    _sentQuery = ref.read(speciesFiltersProvider).query;
    _controller = TextEditingController(text: _sentQuery);
    // Si Inicio pidió el foco antes de que esta pestaña existiera
    if (ref.read(searchFocusRequestProvider)) _focusSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _focusPending = false;

  // Al salir de esta pestaña el buscador suelta el foco: un campo enfocado en una pestaña
  // oculta recuperaba el teclado al volver desde el Detalle (restauración de foco al hacer pop)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TickerMode.valuesOf(context).enabled) _focusNode.unfocus();
  }

  // Espera a que termine el cambio de pestaña: antes, el campo aún no puede recibir el
  // foco y el teclado no llega a abrirse
  void _focusSearch() {
    if (_focusPending) return;
    _focusPending = true;

    Future<void>.delayed(MotionConstants.medium, () {
      _focusPending = false;
      if (!mounted) return;

      ref.read(searchFocusRequestProvider.notifier).consume();
      if (TickerMode.valuesOf(context).enabled) _focusNode.requestFocus();
    });
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

  @override
  Widget build(BuildContext context) {
    // Inicio pide el foco cuando esta pestaña ya existe
    ref.listen(searchFocusRequestProvider, (_, requested) {
      if (requested) _focusSearch();
    });

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
          child: SpeciesSearchField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            onSubmitted: _commit,
            onClear: _clearQuery,
          ),
        ),
        const _CatalogProgress(),
        const _ActiveFilters(),
        const Expanded(child: _Results()),
      ],
    );
  }
}

// Primera sincronización del catálogo: el pez y "x de 16". Mientras tanto la búsqueda usa el
// servidor. La actualización posterior va en silencio y aquí no se ve. Durante una búsqueda
// no se muestra: ahí solo se ve el pez de los resultados, sin números.
class _CatalogProgress extends ConsumerWidget {
  const _CatalogProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(catalogSyncProvider);
    final searching = ref.watch(
      speciesFiltersProvider.select((f) => f.hasQuery),
    );
    if (!status.showProgress || searching) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignConstants.pagePadding,
        DesignConstants.filterChipGap,
        DesignConstants.pagePadding,
        0,
      ),
      child: Row(
        children: [
          const FishLoader.small(),
          const SizedBox(width: DesignConstants.filterChipGap),
          Expanded(
            child: Text(
              status.total == 0
                  ? '${CatalogConstants.preparing}…'
                  : CatalogConstants.progress(status.step, status.total),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: palette.paper.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filtros activos
// ---------------------------------------------------------------------------

// Una sola fila compacta bajo el buscador. El texto de búsqueda no se repite aquí: vive
// solo en la barra, que ya tiene su X
class _ActiveFilters extends ConsumerWidget {
  const _ActiveFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(speciesFiltersProvider);
    final notifier = ref.read(speciesFiltersProvider.notifier);
    final palette = OceanPalette.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    // Etiqueta, color del punto y cómo se quita
    final chips = <(String, Color, VoidCallback)>[
      if (filters.category != null)
        (
          CategoryConstants.labels[filters.category] ?? filters.category!,
          palette.categoryColor(filters.category!),
          () => notifier.setCategory(null),
        ),
      if (filters.conservationStatus != null)
        (
          '${filters.conservationStatus} · ${ConservationConstants.labels[filters.conservationStatus] ?? ''}',
          palette.uicnColor(filters.conservationStatus),
          () => notifier.setConservationStatus(null),
        ),
      if (filters.dangerLevel != null)
        (
          TraitConstants.danger(filters.dangerLevel!),
          palette.coral,
          () => notifier.setDangerLevel(null),
        ),
      if (filters.depthMin != null)
        (
          'Llegan a ${_fmt(filters.depthMin!)} m o más',
          accent,
          () => notifier.setDepthRange(null, null),
        ),
      if (filters.sizeMin != null)
        (
          'Alcanzan ${SizeBar.format(filters.sizeMin!)} o más',
          accent,
          () => notifier.setSizeRange(null, null),
        ),
    ];

    // Sin filtros la fila no ocupa espacio
    if (chips.isEmpty) return const SizedBox.shrink();

    final shown = chips.take(DesignConstants.filterChipsShown).toList();
    final extra = chips.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(top: DesignConstants.filterChipGap),
      child: SizedBox(
        height: DesignConstants.filterChipHeight,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  left: DesignConstants.pagePadding,
                ),
                children: [
                  for (final (label, color, onRemove) in shown)
                    _GlassChip(label: label, dot: color, onRemove: onRemove),
                ],
              ),
            ),
            // Fijo a la derecha: los demás filtros se ven y se quitan en la hoja
            Padding(
              padding: const EdgeInsets.only(
                right: DesignConstants.pagePadding,
              ),
              child: extra > 0
                  ? _GlassChip(
                      label: '+$extra',
                      onTap: () => _openFilters(context),
                    )
                  : const SizedBox(width: DesignConstants.pagePadding),
            ),
          ],
        ),
      ),
    );
  }
}

// Chip de cristal pequeño: punto de color, texto y, si se puede quitar, una X
class _GlassChip extends StatelessWidget {
  final String label;
  final Color? dot;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const _GlassChip({required this.label, this.dot, this.onRemove, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: DesignConstants.filterChipGap),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(DesignConstants.filterChipHeight),
        tintAlpha: DesignConstants.glassSolidAlpha,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onRemove ?? onTap,
            child: Padding(
              padding: EdgeInsets.only(
                left: DesignConstants.filterChipPad,
                right: onRemove != null ? 6 : DesignConstants.filterChipPad,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dot != null) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: dot,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(
                        dimension: DesignConstants.filterChipDot,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: palette.paper),
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.close,
                      size: DesignConstants.filterChipIcon,
                      semanticLabel: 'Quitar $label',
                      color: palette.paper,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
      child: list.whenRetry(
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
                onAction: () =>
                    ref.read(speciesFiltersProvider.notifier).clear(),
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
    // Tras un fallo el pie ofrece "Reintentar": el desplazamiento no lo repite por su cuenta
    // (al cambiar el pie, la lista se reajusta y volvía a pedir la página sin parar)
    final failed = ref.read(speciesListProvider).value?.loadMoreError != null;
    if (!failed && position.extentAfter < DesignConstants.loadMoreExtent) {
      ref.read(speciesListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final palette = OceanPalette.of(context);

    // Tirar hacia abajo baraja de nuevo (sin texto ni filtros); con ellos solo recarga
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(exploreSeedProvider.notifier).reshuffle();
        try {
          await ref.read(speciesListProvider.future);
        } catch (_) {
          // El error ya se muestra en la pantalla
        }
      },
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        // Al desplazar la lista el teclado se cierra
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    parallax: true,
                    species: species,
                    aspectRatio:
                        DesignConstants.mosaicAspects[index %
                            DesignConstants.mosaicAspects.length],
                    onTap: () => openSpecies(context, species),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              // El margen inferior deja espacio al botón de filtros, que flota sobre el final
              padding: const EdgeInsets.fromLTRB(
                DesignConstants.pagePadding,
                DesignConstants.sectionGap,
                DesignConstants.pagePadding,
                DesignConstants.sectionGap + DesignConstants.fabClearance,
              ),
              child: _footer(context, state, palette),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(
    BuildContext context,
    SpeciesListState state,
    OceanPalette palette,
  ) {
    // Cargar más resultados: un pez nada mientras llega la siguiente página
    if (state.isLoadingMore) {
      return const Center(child: FishLoader());
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
        // La búsqueda por texto no pasa de 50 resultados: se avisa que puede haber más
        state.searchCapped
            ? 'La búsqueda muestra hasta ${ApiConstants.searchResultCap} resultados y los filtros se aplican sobre ellos. Escribe algo más específico para afinarla.'
            : 'Llegaste al final',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: palette.paper.withValues(alpha: 0.6)),
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
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
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

// Cada fila del acordeón; solo una está abierta a la vez
enum _Section { group, status, danger, depth, size }

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  // Borrador: nada se pide al servidor hasta pulsar "Aplicar"; cerrar lo descarta
  late String? _category;
  late String? _status;
  late String? _danger;
  late double? _depthMin;
  late double? _sizeMin;
  _Section? _open;

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

  bool get _hasDraft =>
      _category != null ||
      _status != null ||
      _danger != null ||
      _depthMin != null ||
      _sizeMin != null;

  void _toggle(_Section section) =>
      setState(() => _open = _open == section ? null : section);

  void _clear() => setState(() {
    _category = null;
    _status = null;
    _danger = null;
    _depthMin = null;
    _sizeMin = null;
  });

  void _apply() {
    final current = ref.read(speciesFiltersProvider);
    final next = current.copyWith(
      category: () => _category,
      conservationStatus: () => _status,
      dangerLevel: () => _danger,
      depthMin: () => _depthMin,
      depthMax: () => null,
      sizeMin: () => _sizeMin,
      sizeMax: () => null,
    );
    // Con el borrador igual al estado actual no hay nada que aplicar: la lista no se toca
    if (next != current) {
      ref.read(speciesFiltersProvider.notifier).apply(next);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final divider = Divider(
      height: 1,
      color: palette.paper.withValues(alpha: 0.08),
    );

    return ConstrainedBox(
      // Se ajusta al contenido; solo si no cabe llega al tope y se desplaza
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height *
            DesignConstants.filterSheetMaxFraction,
      ),
      // Hoja de cristal: tinte oscuro casi sólido con desenfoque, borde fino y luz suave
      child: GlassSurface(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignConstants.cardRadius),
        ),
        tintAlpha: DesignConstants.glassSolidAlpha,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Asa para arrastrar, dibujada aquí porque la hoja no lleva la de Material
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.paper.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox(width: 36, height: 4),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignConstants.pagePadding,
                ),
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.paper.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(
                        DesignConstants.tileRadius,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        DesignConstants.tileRadius,
                      ),
                      child: Column(
                        children: [
                          _SelectorRow(
                            title: 'Grupo',
                            value: _category == null
                                ? 'Cualquiera'
                                : CategoryConstants.labels[_category] ??
                                      _category!,
                            open: _open == _Section.group,
                            onToggle: () => _toggle(_Section.group),
                            child: _OptionList(
                              options: [
                                for (final id in CategoryConstants.ids)
                                  _Option(
                                    id: id,
                                    label: CategoryConstants.labels[id] ?? id,
                                    dot: palette.categoryColor(id),
                                  ),
                              ],
                              selected: _category,
                              onSelected: (id) => setState(() {
                                _category = id;
                                _open = null;
                              }),
                            ),
                          ),
                          divider,
                          _SelectorRow(
                            title: 'Estado de conservación',
                            value: _status == null
                                ? 'Cualquiera'
                                : '$_status · ${ConservationConstants.labels[_status]}',
                            open: _open == _Section.status,
                            onToggle: () => _toggle(_Section.status),
                            child: _OptionList(
                              options: [
                                for (final code
                                    in ConservationConstants.catalog)
                                  _Option(
                                    id: code,
                                    label:
                                        '$code · ${ConservationConstants.labels[code]}',
                                    dot: palette.uicnColor(code),
                                  ),
                              ],
                              selected: _status,
                              onSelected: (code) => setState(() {
                                _status = code;
                                _open = null;
                              }),
                            ),
                          ),
                          divider,
                          _SelectorRow(
                            title: 'Peligrosidad',
                            value: _danger == null
                                ? 'Cualquiera'
                                : TraitConstants.danger(_danger!),
                            open: _open == _Section.danger,
                            onToggle: () => _toggle(_Section.danger),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: SegmentedButton<String>(
                                  emptySelectionAllowed: true,
                                  showSelectedIcon: false,
                                  segments: [
                                    for (final entry
                                        in TraitConstants.dangerLevels.entries)
                                      ButtonSegment(
                                        value: entry.key,
                                        label: Text(entry.value),
                                      ),
                                  ],
                                  selected: {?_danger},
                                  onSelectionChanged: (s) => setState(
                                    () => _danger = s.isEmpty ? null : s.first,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          divider,
                          _SelectorRow(
                            title: 'Profundidad',
                            value: _depthMin == null
                                ? 'Cualquiera'
                                : 'Llegan a ${_fmt(_depthMin!)} m o más',
                            open: _open == _Section.depth,
                            onToggle: () => _toggle(_Section.depth),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: _StepSlider(
                                steps: MeasureConstants.depthFilterSteps,
                                value: _depthMin,
                                format: (v) => '${_fmt(v)} m o más',
                                summary: 'Llegan al menos a',
                                hint: 'Muestra las especies cuyo rango llega a esa profundidad o más. No indica a qué profundidad viven.',
                                onChanged: (v) => setState(() => _depthMin = v),
                              ),
                            ),
                          ),
                          divider,
                          _SelectorRow(
                            title: 'Tamaño',
                            value: _sizeMin == null
                                ? 'Cualquiera'
                                : 'Alcanzan ${SizeBar.format(_sizeMin!)} o más',
                            open: _open == _Section.size,
                            onToggle: () => _toggle(_Section.size),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: _StepSlider(
                                steps: MeasureConstants.sizeFilterSteps,
                                value: _sizeMin,
                                format: (v) => '${SizeBar.format(v)} o más',
                                summary: 'Alcanzan al menos',
                                hint: 'Muestra las especies cuya talla máxima llega a esa medida o más. No indica cuánto miden los ejemplares.',
                                onChanged: (v) => setState(() => _sizeMin = v),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Dentro de la hoja y fijos abajo, aunque la lista se desplace
            Padding(
              padding: const EdgeInsets.all(DesignConstants.pagePadding),
              child: Row(
                children: [
                  // "Limpiar" solo tiene sentido cuando hay algo elegido
                  if (_hasDraft) ...[
                    Expanded(
                      child: SizedBox(
                        height: DesignConstants.filterButtonHeight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.paper,
                            side: BorderSide(
                              color: palette.paper.withValues(alpha: 0.6),
                            ),
                          ),
                          onPressed: _clear,
                          child: const Text('Limpiar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: DesignConstants.filterButtonHeight,
                      child: FilledButton(
                        onPressed: _apply,
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fila selectora: etiqueta, valor actual y flecha; al abrirse muestra su contenido debajo
class _SelectorRow extends StatelessWidget {
  final String title;
  final String value;
  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  const _SelectorRow({
    required this.title,
    required this.value,
    required this.open,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final duration = animate ? MotionConstants.short : Duration.zero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: DesignConstants.filterRowHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        color: palette.paper,
                        fontSize: DesignConstants.filterLabelSize,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: DesignConstants.filterValueSize,
                        color: value == 'Cualquiera'
                            ? palette.paper.withValues(
                                alpha: DesignConstants.glassMutedTextAlpha,
                              )
                            : accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: duration,
                    curve: MotionConstants.curve,
                    child: Icon(
                      Icons.expand_more,
                      size: DesignConstants.filterArrowSize,
                      color: palette.paper,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: duration,
          curve: MotionConstants.curve,
          alignment: Alignment.topCenter,
          child: open
              ? SizedBox(width: double.infinity, child: child)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _Option {
  final String id;
  final String label;
  final Color dot;

  const _Option({required this.id, required this.label, required this.dot});
}

// Lista de opciones con punto de color; tocar la elegida la quita
class _OptionList extends StatelessWidget {
  final List<_Option> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _OptionList({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    Widget tile({
      required String label,
      required bool isSelected,
      required VoidCallback onTap,
      Color? dot,
    }) {
      return InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: DesignConstants.filterOptionHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Mismo ancho con y sin punto para que las etiquetas queden alineadas
                SizedBox(
                  width: 12,
                  height: 12,
                  child: dot == null
                      ? null
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: dot,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.paper,
                      fontSize: DesignConstants.filterValueSize,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        tile(
          label: 'Cualquiera',
          isSelected: selected == null,
          onTap: () => onSelected(null),
        ),
        for (final option in options)
          tile(
            label: option.label,
            dot: option.dot,
            isSelected: selected == option.id,
            onTap: () => onSelected(selected == option.id ? null : option.id),
          ),
      ],
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
    int best = 0;
    for (int i = 1; i < steps.length; i++) {
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

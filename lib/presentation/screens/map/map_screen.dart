import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Transparente para ver el degradado de profundidad del shell
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(bottom: false, child: MapView()),
    );
  }
}

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  String? _selectedId;
  // Evita programar la apertura de la hoja más de una vez por aviso
  bool _openScheduled = false;
  // Para saber qué parte del mapa tapa la hoja
  final _mapKey = GlobalKey();
  double _inset = 0;

  // Cuántos px del borde inferior del mapa tapa una hoja que ocupa [extent] de la pantalla
  double _insetFor(double extent) {
    final box = _mapKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return 0;

    final mapBottom = box.localToGlobal(Offset.zero).dy + box.size.height;
    final sheetTop = MediaQuery.sizeOf(context).height * (1 - extent);
    return (mapBottom - sheetTop).clamp(0.0, box.size.height).toDouble();
  }

  Future<void> _openZone(OceanZone zone) async {
    setState(() {
      _selectedId = zone.id;
      _inset = _insetFor(MapConstants.sheetInitialFraction);
    });

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // Cubre también la barra de navegación del shell
      useRootNavigator: true,
      // El asa va dentro de la hoja (no la de Material, que suma 48 dp fuera de ella): así
      // la fracción de la pantalla que ocupa la hoja es exactamente la visible
      // Sin velo: el mapa se sigue viendo, con la zona seleccionada resaltada
      barrierColor: Colors.transparent,
      backgroundColor: OceanPalette.of(context).abyss,
      builder: (_) => NotificationListener<DraggableScrollableNotification>(
        // Al arrastrar la hoja el mapa vuelve a centrar la zona en lo que queda libre
        onNotification: (n) {
          final inset = _insetFor(n.extent);
          if (mounted && (inset - _inset).abs() > 0.5) {
            setState(() => _inset = inset);
          }
          return false;
        },
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: MapConstants.sheetInitialFraction,
          minChildSize: MapConstants.sheetInitialFraction,
          maxChildSize: MapConstants.sheetMaxFraction,
          snap: true,
          builder: (context, scroll) => _ZoneSheet(zone: zone, scroll: scroll),
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _selectedId = null;
        _inset = 0;
      });
    }
  }

  // El Detalle puede pedir abrir una zona; se espera a que las zonas estén cargadas
  void _openRequestedZone(List<OceanZone> zones) {
    final requested = ref.read(selectedZoneProvider);
    if (requested == null || _openScheduled) return;

    _openScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openScheduled = false;
      if (!mounted) return;

      ref.read(selectedZoneProvider.notifier).consume();
      final zone = zones.where((z) => z.id == requested).firstOrNull;
      if (zone != null) _openZone(zone);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final zones = ref.watch(zonesProvider);
    final land = ref.watch(worldLandProvider).asData?.value;
    final panelHeight =
        MediaQuery.sizeOf(context).height * MapConstants.panelHeightFraction;

    // Si el aviso llega con la pestaña ya abierta
    ref.listen(selectedZoneProvider, (_, requested) {
      final data = zones.asData?.value;
      if (requested != null && data != null) _openRequestedZone(data);
    });
    // Y si llegó antes de que las zonas terminaran de cargar
    final loaded = zones.asData?.value;
    if (loaded != null) _openRequestedZone(loaded);

    return ListView(
      padding: const EdgeInsets.only(bottom: DesignConstants.sectionGap),
      children: [
        Padding(
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
                '7 ZONAS OCEÁNICAS',
                style: textTheme.overline.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mapa',
                style: textTheme.headlineMedium?.copyWith(color: palette.paper),
              ),
            ],
          ),
        ),
        SizedBox(
          key: _mapKey,
          height: panelHeight,
          child: zones.whenRetry(
            skipLoadingOnReload: true,
            // Carga centrada: el pez nada en medio del mapa que aún no llega
            loading: () => const Center(child: FishLoader()),
            error: (error, _) => FriendlyState.forError(
              context,
              error,
              onRetry: () => ref.invalidate(zonesProvider),
            ),
            data: (data) => OceanMap(
              zones: data,
              land: land,
              selectedId: _selectedId,
              focusInset: _inset,
              onZoneTap: _openZone,
            ),
          ),
        ),
        // Lista equivalente al mapa: también sirve a quien no pueda apuntar a un círculo
        if (zones.asData?.value case final data?)
          for (final zone in data)
            _ZoneRow(zone: zone, onTap: () => _openZone(zone)),
      ],
    );
  }
}

class _ZoneRow extends StatelessWidget {
  final OceanZone zone;
  final VoidCallback onTap;

  const _ZoneRow({required this.zone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignConstants.pagePadding,
          vertical: 14,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.zoneColor(zone.id),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 12),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                zone.name,
                style: textTheme.titleSmall?.copyWith(color: palette.paper),
              ),
            ),
            Text(
              '${formatSpeciesCount(zone.speciesCount)} especies',
              style: textTheme.bodySmall?.copyWith(
                color: palette.paper.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: palette.paper.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

// Hoja de una zona: siempre nombre, descripción, conteo, proporción del catálogo y
// coordenadas; las destacadas se intentan cargar aparte porque el servidor falla con la
// mayoría de las zonas
class _ZoneSheet extends ConsumerWidget {
  final OceanZone zone;
  final ScrollController scroll;

  const _ZoneSheet({required this.zone, required this.scroll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(catalogTotalProvider).asData?.value;
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final color = palette.zoneColor(zone.id);

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(
        DesignConstants.pagePadding,
        0,
        DesignConstants.pagePadding,
        DesignConstants.sectionGap,
      ),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.paper.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const SizedBox(width: 36, height: 4),
            ),
          ),
        ),
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 10),
            ),
            const SizedBox(width: 8),
            Text(
              '${formatSpeciesCount(zone.speciesCount)} ESPECIES',
              style: textTheme.overline.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          zone.name,
          style: textTheme.headlineSmall?.copyWith(color: palette.paper),
        ),
        if (zone.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            zone.description,
            style: textTheme.bodyMedium?.copyWith(
              color: palette.paper.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
        // Si el total del catálogo no llega, la hoja sigue completa sin la proporción
        if (total != null && total > 0) ...[
          const SizedBox(height: 16),
          _CatalogShare(zone: zone, total: total, color: color),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 18,
              color: palette.paper.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${MapConstants.centerLabel}: ${CoordinateUtils.format(zone.lat, zone.lon)}',
                style: textTheme.bodySmall?.copyWith(
                  color: palette.paper.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TopSpecies(zoneId: zone.id),
      ],
    );
  }
}

// "535 de 1,505 especies" con una barra pequeña de la proporción
class _CatalogShare extends StatelessWidget {
  final OceanZone zone;
  final int total;
  final Color color;

  const _CatalogShare({
    required this.zone,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final fraction = (zone.speciesCount / total).clamp(0.0, 1.0);
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${formatSpeciesCount(zone.speciesCount)} de ${formatSpeciesCount(total)} especies',
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: palette.paper),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: animate ? 0 : fraction, end: fraction),
            duration: animate ? MotionConstants.long : Duration.zero,
            curve: MotionConstants.curve,
            builder: (context, value, _) => Stack(
              children: [
                SizedBox(
                  height: MapConstants.shareBarHeight,
                  width: double.infinity,
                  child: ColoredBox(
                    color: palette.paper.withValues(
                      alpha: MapConstants.shareTrackAlpha,
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: SizedBox(
                    height: MapConstants.shareBarHeight,
                    child: ColoredBox(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopSpecies extends ConsumerStatefulWidget {
  final String zoneId;

  const _TopSpecies({required this.zoneId});

  @override
  ConsumerState<_TopSpecies> createState() => _TopSpeciesState();
}

class _TopSpeciesState extends ConsumerState<_TopSpecies> {
  // Ya se pulsó "Reintentar": si vuelve a fallar se dice con claridad y no se ofrece otro
  bool _retried = false;

  void _retry() {
    setState(() => _retried = true);
    ref.invalidate(zoneTopSpeciesProvider(widget.zoneId));
    ref.invalidate(zoneSampleProvider(widget.zoneId));
  }

  @override
  Widget build(BuildContext context) {
    final zoneId = widget.zoneId;
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final species = ref.watch(zoneTopSpeciesProvider(zoneId));

    // Nota discreta, no una alarma: es un fallo conocido del servidor
    Widget note(String text, {VoidCallback? onRetry, bool oneLine = false}) =>
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: palette.paper.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                // Una sola línea cuando hay botón al lado: si no cabe, se recorta con puntos
                maxLines: oneLine ? 1 : null,
                overflow: oneLine ? TextOverflow.ellipsis : null,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.paper.withValues(alpha: 0.7),
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: textTheme.labelMedium,
                ),
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
          ],
        );

    // Al reintentar nada el pez; la primera carga conserva los esqueletos de las fichas
    Widget loading() => _retried
        ? const SizedBox(
            height: DesignConstants.zoneTileHeight,
            child: Center(child: FishLoader()),
          )
        : SizedBox(
            height: DesignConstants.zoneTileHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: DesignConstants.gridGap),
              itemBuilder: (_, _) => SizedBox(
                width: DesignConstants.zoneTileWidth,
                child: SkeletonBox(
                  borderRadius: BorderRadius.circular(
                    DesignConstants.cardRadius,
                  ),
                ),
              ),
            ),
          );

    // Con las especies, un encabezado y sus fichas; cuando faltan, una sola línea
    Widget section(Widget content, {String title = 'ESPECIES DESTACADAS'}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.overline.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        );

    // Sin conexión o con el servidor caído: el estado amigable, bajo y con su reintento. Si
    // el reintento también falla se dice con claridad y no se ofrece otro
    Widget unavailable([Object? error]) {
      final kind = failureKindOf(error);
      if (_retried && kind != FailureKind.offline) {
        return note(ApiConstants.zoneRetryFailedMessage);
      }
      return FriendlyState.forError(
        context,
        error,
        onRetry: _retry,
        compact: true,
      );
    }

    // [loading]: faltan detalles por procesar, el pez sigue al final de la fila
    Widget tiles(
      List<Species> items, {
      String title = 'ESPECIES DESTACADAS',
      bool loading = false,
      bool official = false,
    }) => _ZoneInsights(
      items: items,
      title: title,
      official: official,
      loading: loading,
    );

    // top-species falla en casi todas las zonas: en su lugar se arma una muestra desde los
    // detalles. Si tampoco hay muestra, queda la nota de siempre
    Widget fallback() {
      final sample = ref.watch(zoneSampleProvider(zoneId));
      final sampleTitle = MapConstants.sampleTitle.toUpperCase();

      return sample.when(
        skipLoadingOnReload: true,
        loading: () => section(
          const Column(
            children: [
              SizedBox(
                height: DesignConstants.zoneTileHeight,
                child: Center(child: FishLoader()),
              ),
              _SurpriseButton(onPressed: null),
            ],
          ),
          title: sampleTitle,
        ),
        error: (error, _) => unavailable(error),
        data: (state) {
          if (state.items.isEmpty) {
            // Sin coincidencias aún: el pez; sin coincidencias y ya terminó: la nota
            return state.done
                ? unavailable(ApiConstants.serverMessage)
                : section(
                    const Column(
                      children: [
                        SizedBox(
                          height: DesignConstants.zoneTileHeight,
                          child: Center(child: FishLoader()),
                        ),
                        _SurpriseButton(onPressed: null),
                      ],
                    ),
                    title: sampleTitle,
                  );
          }
          return tiles(state.items, title: sampleTitle, loading: !state.done);
        },
      );
    }

    return species.whenRetry(
      loading: () => section(loading()),
      // Sin conexión la muestra por detalles tampoco puede armarse: se dice de una vez
      error: (error, _) => failureKindOf(error) == FailureKind.offline
          ? unavailable(error)
          : fallback(),
      data: (items) => items.isEmpty
          ? note('Esta zona aún no tiene especies destacadas.')
          : tiles(items, official: true),
    );
  }
}

// Lo que se saca de las especies que ya llegaron, sin peticiones extra: récords, grupos,
// "Sorpréndeme" y la fila de fichas. Los bloques aparecen según llegan las especies.
class _ZoneInsights extends ConsumerStatefulWidget {
  final List<Species> items;
  final String title;
  // Viene de la lista oficial de destacadas y no de una muestra
  final bool official;
  // Faltan detalles por procesar: el pez sigue al final de la fila
  final bool loading;

  const _ZoneInsights({
    required this.items,
    required this.title,
    required this.official,
    required this.loading,
  });

  @override
  ConsumerState<_ZoneInsights> createState() => _ZoneInsightsState();
}

class _ZoneInsightsState extends ConsumerState<_ZoneInsights> {
  // Grupo elegido en los chips; tocarlo otra vez quita el filtro
  String? _group;

  void _open(Species species) =>
      ref.read(openSpeciesProvider)(context, species);

  void _surprise() {
    final items = widget.items;
    _open(items[ref.read(zoneRandomProvider).nextInt(items.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final items = widget.items;
    final records = ZoneStats.records(items);
    final groups = ZoneStats.groups(items);
    final shown = ZoneStats.inGroup(items, _group);

    Widget title(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: textTheme.overline.copyWith(color: accent),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.official
              ? MapConstants.basedOnFeatured(items.length)
              : MapConstants.basedOnSample(items.length),
          style: textTheme.bodySmall?.copyWith(
            color: palette.paper.withValues(alpha: 0.7),
          ),
        ),
        if (!records.isEmpty) ...[
          const SizedBox(height: 16),
          title(MapConstants.recordsTitle),
          _Records(records: records, onOpen: _open),
        ],
        const SizedBox(height: 24),
        title(MapConstants.groupsTitle),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (id, count) in groups)
              FilterChip(
                selected: _group == id,
                showCheckmark: false,
                onSelected: (_) =>
                    setState(() => _group = _group == id ? null : id),
                avatar: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.categoryColor(id),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 12),
                ),
                label: Text('${CategoryConstants.labels[id] ?? id} $count'),
                side: BorderSide.none,
                backgroundColor: palette.deep,
                selectedColor: palette.categoryColor(id),
                labelStyle: textTheme.labelLarge?.copyWith(
                  color: palette.paper,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _SurpriseButton(onPressed: items.isEmpty ? null : _surprise),
        const SizedBox(height: 24),
        title(widget.title),
        SizedBox(
          height: DesignConstants.zoneTileHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: shown.length + (widget.loading ? 1 : 0),
            separatorBuilder: (_, _) =>
                const SizedBox(width: DesignConstants.gridGap),
            itemBuilder: (context, index) => index == shown.length
                ? const SizedBox(
                    width: DesignConstants.zoneTileWidth / 2,
                    child: Center(child: FishLoader()),
                  )
                : SizedBox(
                    width: DesignConstants.zoneTileWidth,
                    child: SpeciesTile(
                      species: shown[index],
                      aspectRatio:
                          DesignConstants.zoneTileWidth /
                          DesignConstants.zoneTileHeight,
                      onTap: () => _open(shown[index]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// Hasta tres tarjetas tocables: la más grande, la que llega más profundo y la más amenazada
class _Records extends StatelessWidget {
  final ZoneRecords records;
  final ValueChanged<Species> onOpen;

  const _Records({required this.records, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final largest = records.largest;
    final deepest = records.deepest;
    final threatened = records.mostThreatened;

    final cards = <Widget>[
      if (largest != null)
        _RecordCard(
          label: MapConstants.recordLargest,
          species: largest,
          value: SizeBar.format(largest.sizeMaxCm!),
          color: palette.paper,
          onTap: () => onOpen(largest),
        ),
      if (deepest != null)
        _RecordCard(
          label: MapConstants.recordDeepest,
          species: deepest,
          value: '${formatSpeciesCount(deepest.depthMaxM!.round())} m',
          color: palette.paper,
          onTap: () => onOpen(deepest),
        ),
      if (threatened != null)
        _RecordCard(
          label: MapConstants.recordThreatened,
          species: threatened,
          value:
              ConservationConstants.labels[threatened.conservationStatus] ??
              threatened.conservationStatus!,
          color: palette.uicnColor(threatened.conservationStatus),
          onTap: () => onOpen(threatened),
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: MapConstants.recordCardGap),
          Expanded(child: cards[i]),
        ],
        // Con menos de tres tarjetas, el resto del ancho queda libre para que no se estiren
        for (int i = cards.length; i < 3; i++) ...[
          const SizedBox(width: MapConstants.recordCardGap),
          const Spacer(),
        ],
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final String label;
  final Species species;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _RecordCard({
    required this.label,
    required this.species,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(DesignConstants.tileRadius);

    return Semantics(
      button: true,
      label: '$label: ${species.commonName}, $value',
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: palette.deep,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MapConstants.recordCardPhotoHeight,
                  width: double.infinity,
                  child: SpeciesPhotoView(
                    url: species.primaryPhoto,
                    category: species.category,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.overline.copyWith(
                          color: palette.paper.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        species.commonName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          color: palette.paper,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// "Sorpréndeme en esta zona": deshabilitado hasta que llegue al menos una especie
class _SurpriseButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SurpriseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      icon: const Icon(Icons.casino_outlined),
      label: const Text(MapConstants.surpriseLabel),
      onPressed: onPressed,
    );
  }
}

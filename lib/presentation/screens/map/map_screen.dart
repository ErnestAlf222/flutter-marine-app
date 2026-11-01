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
            error: (error, _) => _MapMessage(
              message: error is String ? error : 'Ocurrió un error inesperado.',
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

class _MapMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MapMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignConstants.pagePadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: palette.paper),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.paper),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
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

// Hoja de una zona: siempre nombre, descripción y conteo; las destacadas se
// intentan cargar aparte porque el servidor falla con la mayoría de las zonas
class _ZoneSheet extends StatelessWidget {
  final OceanZone zone;
  final ScrollController scroll;

  const _ZoneSheet({required this.zone, required this.scroll});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 16),
        _TopSpecies(zoneId: zone.id),
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
    Widget section(Widget content) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESPECIES DESTACADAS',
          style: textTheme.overline.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );

    return species.whenRetry(
      loading: () => section(loading()),
      error: (_, _) => _retried
          ? note(ApiConstants.zoneRetryFailedMessage)
          : note('Destacadas no disponibles.', onRetry: _retry, oneLine: true),
      data: (items) => items.isEmpty
          ? note('Esta zona aún no tiene especies destacadas.')
          : section(
              SizedBox(
                height: DesignConstants.zoneTileHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: DesignConstants.gridGap),
                  itemBuilder: (context, index) => SizedBox(
                    width: DesignConstants.zoneTileWidth,
                    child: SpeciesTile(
                      species: items[index],
                      aspectRatio:
                          DesignConstants.zoneTileWidth /
                          DesignConstants.zoneTileHeight,
                      onTap: () => openSpecies(context, items[index]),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

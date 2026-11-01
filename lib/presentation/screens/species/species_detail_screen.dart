import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

class SpeciesDetailScreen extends StatelessWidget {
  final String slug;
  // Viene de la tarjeta tocada: permite pintar la foto y los nombres mientras
  // llega el detalle, y que el Hero tenga destino desde el primer cuadro
  final Species? preview;

  const SpeciesDetailScreen({super.key, required this.slug, this.preview});

  @override
  Widget build(BuildContext context) {
    // Esta ruta está fuera del shell, así que pinta su propio fondo de profundidad
    return Scaffold(
      body: OceanBackground(
        child: SpeciesDetailView(slug: slug, preview: preview),
      ),
    );
  }
}

class SpeciesDetailView extends ConsumerStatefulWidget {
  final String slug;
  final Species? preview;

  const SpeciesDetailView({super.key, required this.slug, this.preview});

  @override
  ConsumerState<SpeciesDetailView> createState() => _SpeciesDetailViewState();
}

class _SpeciesDetailViewState extends ConsumerState<SpeciesDetailView> {
  // Foto que se está viendo en la galería: de ella sale el crédito de la hoja de créditos
  int _photoIndex = 0;

  String get slug => widget.slug;

  void _back(BuildContext context) {
    // Con un enlace directo no hay pantalla anterior a la que volver
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteConstants.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(speciesDetailProvider(slug));
    final species = detail.asData?.value ?? widget.preview;
    final photos = _galleryOf(species, detail.asData?.value);
    final height = MediaQuery.sizeOf(context).height;

    return PullToDismiss(
      onDismiss: () => _back(context),
      builder: (context, scroll, physics) => Stack(
        children: [
          CustomScrollView(
            controller: scroll,
            physics: physics,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                expandedHeight: height * DesignConstants.detailHeaderFraction,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _DetailHeader(
                    species: species,
                    photos: photos,
                    loading: detail.isLoading,
                    // Mientras el Detalle se arrastra para cerrarse, las fotos no se deslizan
                    swipeEnabled: physics is! NeverScrollableScrollPhysics,
                    showHint: !ref.watch(galleryHintProvider),
                    onHintShown: () =>
                        ref.read(galleryHintProvider.notifier).markShown(),
                    onPageChanged: (i) => setState(() => _photoIndex = i),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  DesignConstants.pagePadding,
                  DesignConstants.sectionGap,
                  DesignConstants.pagePadding,
                  DesignConstants.sectionGap * 2,
                ),
                sliver: SliverToBoxAdapter(
                  child: detail.whenRetry(
                    skipLoadingOnReload: true,
                    loading: () => const _BodySkeleton(),
                    error: (error, _) => _DetailMessage(
                      notFound: error == ApiConstants.notFoundMessage,
                      message: error is String
                          ? error
                          : 'Ocurrió un error inesperado.',
                      onRetry: () =>
                          ref.invalidate(speciesDetailProvider(slug)),
                      onBack: () => _back(context),
                    ),
                    data: (data) =>
                        _DetailBody(detail: data, photoIndex: _photoIndex),
                  ),
                ),
              ),
            ],
          ),
          // Fijo: el botón de volver sigue a mano aunque la foto se desplace
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(DesignConstants.pagePadding),
                child: GlassButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Volver',
                  onPressed: () => _back(context),
                ),
              ),
            ),
          ),
          // Sin especie (enlace directo aún cargando) no hay nada que guardar
          if (species != null)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(DesignConstants.pagePadding),
                  // Arriba junto a la foto solo queda el corazón; el crédito va al final
                  child: FavoriteButton(species: species, large: true),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Fotos de la galería, la principal primero (el Hero es de la primera). Antes de que llegue
// el detalle solo se conoce la foto de la tarjeta.
List<GalleryPhoto> _galleryOf(Species? species, SpeciesDetail? detail) {
  final photos = detail?.photos ?? const <SpeciesPhoto>[];
  if (photos.isEmpty) return [GalleryPhoto(url: species?.primaryPhoto)];

  final primary = photos.indexWhere((p) => p.isPrimary);
  final ordered = [
    if (primary >= 0) photos[primary],
    for (int i = 0; i < photos.length; i++)
      if (i != primary) photos[i],
  ];
  return [
    for (final p in ordered)
      GalleryPhoto(url: p.url, credit: _cleanCredit(p.credit)),
  ];
}

String? _cleanCredit(String? credit) {
  final trimmed = credit?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

// Crédito de la foto que se está viendo
String? _creditOf(SpeciesDetail? detail, int index) {
  if (detail == null) return null;
  final photos = _galleryOf(detail, detail);
  return photos[index.clamp(0, photos.length - 1)].credit;
}

// La licencia suele venir entre paréntesis al final: "© Autor / iNaturalist (CC0)"
String? _licenseOf(String credit) =>
    RegExp(r'\(([^()]+)\)\s*$').firstMatch(credit)?.group(1);

// Un navegador ausente o una URL rechazada no deben dejar el enlace sin respuesta
Future<void> _openLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final opened = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);

  if (!opened) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(DetailConstants.openLinkError)),
      );
  }
}

Future<void> _showCredit(BuildContext context, String? credit) {
  final license = credit == null ? null : _licenseOf(credit);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: OceanPalette.of(context).abyss,
    builder: (context) {
      final palette = OceanPalette.of(context);
      final textTheme = Theme.of(context).textTheme;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignConstants.pagePadding,
            0,
            DesignConstants.pagePadding,
            DesignConstants.sectionGap,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (credit == null
                          ? DetailConstants.creditsTitle
                          : DetailConstants.photoCreditTitle)
                      .toUpperCase(),
                  style: textTheme.overline.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (credit != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    credit,
                    style: textTheme.bodyLarge?.copyWith(color: palette.paper),
                  ),
                ],
                if (license != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Licencia: $license',
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.paper.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                // Atribución de los datos (CC BY-SA 4.0), con enlace al proveedor
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text(DetailConstants.dataCredit),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _openLink(context, UrlConstants.speciesBlue),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DetailHeader extends StatelessWidget {
  final Species? species;
  final List<GalleryPhoto> photos;
  final bool loading;
  final bool swipeEnabled;
  final bool showHint;
  final VoidCallback onHintShown;
  final ValueChanged<int> onPageChanged;

  const _DetailHeader({
    required this.species,
    required this.photos,
    required this.loading,
    required this.swipeEnabled,
    required this.showHint,
    required this.onHintShown,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = species;

    if (current == null) {
      return loading
          ? const SkeletonBox(borderRadius: BorderRadius.zero)
          : ColoredBox(color: palette.deep);
    }

    return DetailGallery(
      photos: photos,
      category: current.category,
      heroTag: current.slug,
      swipeEnabled: swipeEnabled,
      showHint: showHint,
      onHintShown: onHintShown,
      onPageChanged: onPageChanged,
      // Tocar la foto la abre a pantalla completa, en la foto que se está viendo
      onTap: (index) {
        final withUrl = [
          for (final p in photos)
            if (p.url != null) p,
        ];
        if (photos[index].url == null) return;
        PhotoViewer.show(
          context,
          category: current.category,
          photos: [
            for (final p in withUrl) ViewerPhoto(url: p.url!, credit: p.credit),
          ],
          initialIndex: withUrl.indexOf(photos[index]),
        );
      },
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (CategoryConstants.labels[current.category] ?? current.category)
                .toUpperCase(),
            style: textTheme.overline.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            current.commonName,
            style: textTheme.headlineLarge?.copyWith(color: palette.paper),
          ),
          Text(
            current.scientificName,
            style: textTheme.scientific.copyWith(
              color: palette.paper.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final SpeciesDetail detail;
  final int photoIndex;

  const _DetailBody({required this.detail, required this.photoIndex});

  bool get _hasMeasures =>
      detail.depthMinM != null ||
      detail.depthMaxM != null ||
      detail.sizeMinCm != null ||
      detail.sizeMaxCm != null;

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final description = detail.fullDescription ?? detail.shortDescription;

    // Cada bloque entra escalonado; el índice sale del orden en que se agregan
    final blocks = <Widget>[
      TaxonomySection(taxonomy: detail.taxonomy),
      if (description != null && description.isNotEmpty)
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.paper.withValues(alpha: 0.9),
            height: 1.6,
          ),
        ),
      if (_hasMeasures) _Measures(detail: detail),
      if (detail.conservationStatus != null)
        ConservationScale(status: detail.conservationStatus),
      if (detail.dangerLevel != null) DangerInfo(level: detail.dangerLevel),
      if (detail.habitats.isNotEmpty)
        _TraitSection(
          title: 'Hábitats',
          icon: Icons.landscape_outlined,
          labels: detail.habitats.map(TraitConstants.habitat).toList(),
        ),
      if (detail.behaviors.isNotEmpty)
        _TraitSection(
          title: 'Comportamiento',
          icon: Icons.visibility_outlined,
          labels: detail.behaviors.map(TraitConstants.behavior).toList(),
        ),
      if (detail.zones.isNotEmpty) _WhereLives(slugs: detail.zones),
      // Al final de la página, discreto pero a la vista: abre los créditos (siempre, para
      // que la atribución de los datos no dependa de que la foto traiga crédito)
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.copyright, size: 18),
          label: const Text(DetailConstants.creditsButton),
          style: TextButton.styleFrom(
            foregroundColor: palette.paper.withValues(alpha: 0.75),
          ),
          onPressed: () => _showCredit(context, _creditOf(detail, photoIndex)),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < blocks.length; i++)
          StaggeredEntry(
            index: i,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: i == blocks.length - 1 ? 0 : DesignConstants.sectionGap,
              ),
              child: blocks[i],
            ),
          ),
      ],
    );
  }
}

// Profundidad y tamaño: apilados siempre, en fila solo si hay ancho de sobra
class _Measures extends StatelessWidget {
  final SpeciesDetail detail;

  const _Measures({required this.detail});

  @override
  Widget build(BuildContext context) {
    final depth = DepthGauge(minM: detail.depthMinM, maxM: detail.depthMaxM);
    final size = SizeBar(minCm: detail.sizeMinCm, maxCm: detail.sizeMaxCm);
    final hasDepth = detail.depthMinM != null || detail.depthMaxM != null;
    final hasSize = detail.sizeMinCm != null || detail.sizeMaxCm != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (hasDepth && hasSize) {
          if (constraints.maxWidth >= MeasureConstants.sideBySideWidth) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: depth),
                const SizedBox(width: DesignConstants.gridGap),
                Expanded(child: size),
              ],
            );
          }
          return Column(
            children: [
              depth,
              const SizedBox(height: DesignConstants.gridGap),
              size,
            ],
          );
        }
        return hasDepth ? depth : size;
      },
    );
  }
}

class _BlockTitle extends StatelessWidget {
  final String text;

  const _BlockTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.overline
            .copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _TraitSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> labels;

  const _TraitSection({
    required this.title,
    required this.icon,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockTitle(title),
        _ChipWrap(icon: icon, labels: labels),
      ],
    );
  }
}

class _ChipWrap extends StatelessWidget {
  final IconData icon;
  final List<String> labels;

  const _ChipWrap({required this.icon, required this.labels});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in labels)
          Chip(
            avatar: Icon(icon, size: 16, color: palette.paper),
            label: Text(label),
            side: BorderSide.none,
            backgroundColor: palette.deep,
            labelStyle: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: palette.paper),
          ),
      ],
    );
  }
}

// "Dónde vive": mini mapa informativo con las zonas de la especie resaltadas y, debajo,
// un chip por zona que abre la pestaña Mapa con esa zona seleccionada. Las zonas llegan
// como slugs; sus nombres y posiciones salen de /zones (si falla, se muestra el slug legible).
class _WhereLives extends ConsumerWidget {
  final List<String> slugs;

  const _WhereLives({required this.slugs});

  void _openOnMap(BuildContext context, WidgetRef ref, String slug) {
    ref.read(selectedZoneProvider.notifier).select(slug);
    context.go(RouteConstants.map);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = OceanPalette.of(context);
    final zones = ref.watch(zonesProvider).asData?.value;
    final land = ref.watch(worldLandProvider).asData?.value;
    final names = {
      for (final zone in zones ?? <OceanZone>[]) zone.id: zone.name,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BlockTitle('Dónde vive'),
        if (zones != null) ...[
          SizedBox(
            height: MapConstants.compactHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignConstants.tileRadius),
              child: OceanMap(
                compact: true,
                zones: zones,
                land: land,
                highlighted: slugs.toSet(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final slug in slugs)
              ActionChip(
                avatar: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.zoneColor(slug),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 12),
                ),
                label: Text(names[slug] ?? TraitConstants.readable(slug)),
                side: BorderSide.none,
                backgroundColor: palette.deep,
                labelStyle: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: palette.paper),
                onPressed: () => _openOnMap(context, ref, slug),
              ),
          ],
        ),
      ],
    );
  }
}

class _BodySkeleton extends StatelessWidget {
  const _BodySkeleton();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(DesignConstants.tileRadius);

    Widget block(double height) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        height: height,
        child: SkeletonBox(borderRadius: radius),
      ),
    );

    return Column(children: [block(32), block(20), block(120), block(72)]);
  }
}

class _DetailMessage extends StatelessWidget {
  final bool notFound;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _DetailMessage({
    required this.notFound,
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignConstants.sectionGap),
      child: Column(
        children: [
          Icon(
            notFound ? Icons.search_off : Icons.error_outline,
            size: 48,
            color: palette.paper,
          ),
          const SizedBox(height: 16),
          Text(
            notFound
                ? 'Esta especie no existe o ya no está disponible.'
                : message,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.paper),
          ),
          const SizedBox(height: 16),
          // Un 404 no se arregla reintentando: se ofrece volver
          FilledButton.tonal(
            onPressed: notFound ? onBack : onRetry,
            child: Text(notFound ? 'Volver' : 'Reintentar'),
          ),
        ],
      ),
    );
  }
}

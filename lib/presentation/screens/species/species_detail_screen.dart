import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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

class SpeciesDetailView extends ConsumerWidget {
  final String slug;
  final Species? preview;

  const SpeciesDetailView({super.key, required this.slug, this.preview});

  void _back(BuildContext context) {
    // Con un enlace directo no hay pantalla anterior a la que volver
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteConstants.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(speciesDetailProvider(slug));
    final species = detail.asData?.value ?? preview;
    final height = MediaQuery.sizeOf(context).height;

    return Stack(
      children: [
        CustomScrollView(
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
                  credit: detail.asData?.value == null
                      ? null
                      : _primaryCredit(detail.asData!.value),
                  loading: detail.isLoading,
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
                child: detail.when(
                  skipLoadingOnReload: true,
                  loading: () => const _BodySkeleton(),
                  error: (error, _) => _DetailMessage(
                    notFound: error == ApiConstants.notFoundMessage,
                    message: error is String
                        ? error
                        : 'Ocurrió un error inesperado.',
                    onRetry: () => ref.invalidate(speciesDetailProvider(slug)),
                    onBack: () => _back(context),
                  ),
                  data: (data) => _DetailBody(detail: data),
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
                child: FavoriteButton(species: species),
              ),
            ),
          ),
      ],
    );
  }

  // Crédito de la foto principal; si ninguna está marcada, el de la primera
  String? _primaryCredit(SpeciesDetail detail) {
    if (detail.photos.isEmpty) return null;
    final primary = detail.photos.firstWhere(
      (p) => p.isPrimary,
      orElse: () => detail.photos.first,
    );
    return primary.credit;
  }
}

class _DetailHeader extends StatelessWidget {
  final Species? species;
  final String? credit;
  final bool loading;

  const _DetailHeader({
    required this.species,
    required this.credit,
    required this.loading,
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

    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: current.slug,
          child: SpeciesPhotoView(
            url: current.primaryPhoto,
            category: current.category,
            cacheWidth: DesignConstants.heroPhotoCacheWidth,
          ),
        ),
        const PhotoScrim(
          coverage: DesignConstants.heroScrimCoverage,
          solid: DesignConstants.detailScrimSolid,
        ),
        Positioned(
          left: DesignConstants.pagePadding,
          right: DesignConstants.pagePadding,
          bottom: 24,
          child: Column(
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
        ),
        if (credit != null)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                // Deja libre la esquina para el corazón, que va fijo encima
                padding: const EdgeInsets.fromLTRB(
                  DesignConstants.pagePadding,
                  DesignConstants.pagePadding,
                  DesignConstants.pagePadding + DesignConstants.glassSize + 12,
                  DesignConstants.pagePadding,
                ),
                child: _CreditChip(text: credit!),
              ),
            ),
          ),
      ],
    );
  }
}

// Crédito de la foto en la esquina, exigido por la licencia de las imágenes
class _CreditChip extends StatelessWidget {
  final String text;

  const _CreditChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.ink.withValues(alpha: DesignConstants.glassAlpha * 1.6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.paper,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final SpeciesDetail detail;

  const _DetailBody({required this.detail});

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
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ConservationBadge(status: detail.conservationStatus),
          DangerBadge(level: detail.dangerLevel),
        ],
      ),
      TaxonomyCrumbs(taxonomy: detail.taxonomy),
      if (description != null && description.isNotEmpty)
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.paper.withValues(alpha: 0.9),
            height: 1.6,
          ),
        ),
      if (_hasMeasures) _Measures(detail: detail),
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
      if (detail.zones.isNotEmpty) _ZonesSection(slugs: detail.zones),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++)
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
        style: Theme.of(context).textTheme.overline.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
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
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: palette.paper,
            ),
          ),
      ],
    );
  }
}

// Las zonas llegan como slugs; sus nombres salen de /zones (si falla, se muestra el slug legible)
class _ZonesSection extends ConsumerWidget {
  final List<String> slugs;

  const _ZonesSection({required this.slugs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = {
      for (final zone in ref.watch(zonesProvider).asData?.value ?? <OceanZone>[])
        zone.id: zone.name,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BlockTitle('Zonas'),
        _ChipWrap(
          icon: Icons.public,
          labels: [
            for (final slug in slugs) names[slug] ?? TraitConstants.readable(slug),
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
      child: SizedBox(height: height, child: SkeletonBox(borderRadius: radius)),
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

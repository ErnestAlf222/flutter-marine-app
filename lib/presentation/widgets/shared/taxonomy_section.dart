import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';

/// Sección "Clasificación": de entrada solo Familia y Género; la clasificación completa
/// (de Reino a Género) se despliega con un control.
class TaxonomySection extends StatefulWidget {
  final SpeciesTaxonomy taxonomy;

  const TaxonomySection({super.key, required this.taxonomy});

  @override
  State<TaxonomySection> createState() => _TaxonomySectionState();
}

class _TaxonomySectionState extends State<TaxonomySection> {
  bool _expanded = false;

  // Etiqueta y valor; los rangos sin dato no se muestran
  List<(String, String)> _rows(List<(String, String?)> ranks) => [
    for (final (label, value) in ranks)
      if (value != null && value.trim().isNotEmpty) (label, _readable(value.trim())),
  ];

  // "incertae sedis" es latín técnico: se aclara en español
  static String _readable(String value) =>
      value.toLowerCase().contains(DetailConstants.uncertainMarker)
      ? '$value ${DetailConstants.uncertainPosition}'
      : value;

  @override
  Widget build(BuildContext context) {
    final t = widget.taxonomy;
    final short = _rows([
      (DetailConstants.family, t.family),
      (DetailConstants.genus, t.genus),
    ]);
    final full = _rows([
      (DetailConstants.kingdom, t.kingdom),
      (DetailConstants.phylum, t.phylum),
      (DetailConstants.taxonomicClass, t.taxonomicClass),
      (DetailConstants.order, t.order),
      (DetailConstants.family, t.family),
      (DetailConstants.genus, t.genus),
    ]);
    if (full.isEmpty) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DetailConstants.taxonomyTitle.toUpperCase(),
          style: textTheme.overline.copyWith(color: accent),
        ),
        const SizedBox(height: 6),
        Text(
          DetailConstants.taxonomyIntro,
          style: textTheme.bodyMedium?.copyWith(
            color: palette.paper.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: animate ? MotionConstants.short : Duration.zero,
          curve: MotionConstants.curve,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value) in _expanded ? full : short)
                _Rank(label: label, value: value),
            ],
          ),
        ),
        // Con solo Familia y Género no hay nada más que desplegar
        if (full.length > short.length)
          TextButton.icon(
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            label: Text(
              _expanded
                  ? DetailConstants.taxonomyCollapse
                  : DetailConstants.taxonomyExpand,
            ),
            style: TextButton.styleFrom(foregroundColor: accent),
            onPressed: () => setState(() => _expanded = !_expanded),
          ),
      ],
    );
  }
}

class _Rank extends StatelessWidget {
  final String label;
  final String value;

  const _Rank({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: DesignConstants.taxonomyLabelWidth,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.paper.withValues(alpha: 0.75),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyLarge?.copyWith(color: palette.paper),
            ),
          ),
        ],
      ),
    );
  }
}

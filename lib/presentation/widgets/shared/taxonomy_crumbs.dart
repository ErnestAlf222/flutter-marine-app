import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';

// Taxonomía como migas de pan: de reino a género
class TaxonomyCrumbs extends StatelessWidget {
  final SpeciesTaxonomy taxonomy;

  const TaxonomyCrumbs({super.key, required this.taxonomy});

  @override
  Widget build(BuildContext context) {
    final names = [
      taxonomy.kingdom,
      taxonomy.phylum,
      taxonomy.taxonomicClass,
      taxonomy.order,
      taxonomy.family,
      taxonomy.genus,
    ].whereType<String>().where((n) => n.isNotEmpty).toList();
    if (names.isEmpty) return const SizedBox.shrink();

    final palette = OceanPalette.of(context);
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: palette.paper.withValues(alpha: 0.8),
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < names.length; i++) ...[
          if (i > 0)
            Icon(
              Icons.chevron_right,
              size: 16,
              color: palette.paper.withValues(alpha: 0.5),
            ),
          Text(names[i], style: style),
        ],
      ],
    );
  }
}

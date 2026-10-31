import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Transparente para ver el degradado de profundidad del shell
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(bottom: false, child: AboutView()),
    );
  }
}

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    // Un navegador ausente o una URL rechazada no deben dejar al botón sin respuesta
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);

    if (!opened) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    final blocks = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACERCA DE', style: textTheme.overline.copyWith(color: accent)),
          const SizedBox(height: 4),
          Text(
            AppConstants.appName,
            style: textTheme.displaySmall?.copyWith(color: palette.paper),
          ),
          const SizedBox(height: 8),
          Text(
            'Guía de campo de la vida marina para buceadores: más de 1,500 especies con fotos, profundidad y tamaño.',
            style: textTheme.bodyLarge?.copyWith(
              color: palette.paper.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
      _InfoCard(
        icon: Icons.menu_book_outlined,
        title: 'Datos',
        body: 'Datos de speCies.blue, licencia CC BY-SA 4.0.',
        actions: [
          FilledButton.tonalIcon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('speCies.blue'),
            onPressed: () => _open(context, UrlConstants.speciesBlue),
          ),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('Licencia CC BY-SA 4.0'),
            onPressed: () => _open(context, UrlConstants.licenseCcBySa),
          ),
        ],
      ),
      const _InfoCard(
        icon: Icons.photo_camera_outlined,
        title: 'Fotos',
        body:
            'Las fotos provienen de distintas fuentes, como iNaturalist y Wikimedia Commons; cada foto muestra su crédito y licencia en la ficha de la especie.',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DesignConstants.pagePadding,
        24,
        DesignConstants.pagePadding,
        DesignConstants.sectionGap * 2,
      ),
      children: [
        for (var i = 0; i < blocks.length; i++)
          StaggeredEntry(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: DesignConstants.sectionGap),
              child: blocks[i],
            ),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.deep.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(DesignConstants.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: textTheme.overline.copyWith(color: accent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: textTheme.bodyLarge?.copyWith(
                color: palette.paper.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

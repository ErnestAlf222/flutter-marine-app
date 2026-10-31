import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:marine_app/config/config.dart';

/// Hoja de créditos: atribución de los datos, de las fotos y del mapa.
Future<void> showCreditsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: OceanPalette.of(context).abyss,
    builder: (_) => const _CreditsContent(),
  );
}

class _CreditsContent extends StatelessWidget {
  const _CreditsContent();

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
        ..showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        DesignConstants.pagePadding,
        0,
        DesignConstants.pagePadding,
        DesignConstants.sectionGap,
      ),
      children: [
        Text('CRÉDITOS', style: textTheme.overline.copyWith(color: accent)),
        const SizedBox(height: 4),
        Text(
          AppConstants.appName,
          style: textTheme.headlineMedium?.copyWith(color: palette.paper),
        ),
        const SizedBox(height: 8),
        Text(
          'Guía de campo de la vida marina para buceadores: más de 1,500 especies con fotos, profundidad y tamaño.',
          style: textTheme.bodyMedium?.copyWith(
            color: palette.paper.withValues(alpha: 0.85),
            height: 1.5,
          ),
        ),
        _Block(
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
        const _Block(
          icon: Icons.photo_camera_outlined,
          title: 'Fotos',
          body:
              'Las fotos provienen de distintas fuentes, como iNaturalist y Wikimedia Commons; cada foto muestra su crédito y licencia en la ficha de la especie.',
        ),
        _Block(
          icon: Icons.public,
          title: 'Mapa',
          // Cortesía: Natural Earth es de dominio público y no exige crédito
          body:
              'La tierra firme del mapa viene de Natural Earth, de dominio público.',
          actions: [
            FilledButton.tonalIcon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Natural Earth'),
              onPressed: () => _open(context, UrlConstants.naturalEarth),
            ),
          ],
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;

  const _Block({
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

    return Padding(
      padding: const EdgeInsets.only(top: DesignConstants.sectionGap - 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.deep.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(DesignConstants.tileRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 10),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.paper.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

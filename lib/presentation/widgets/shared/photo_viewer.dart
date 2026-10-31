import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/widgets/shared/glass_button.dart';
import 'package:marine_app/presentation/widgets/shared/species_photo.dart';

// Visor a pantalla completa: la foto entera, con zoom de pellizco y arrastre
class PhotoViewer extends StatelessWidget {
  final String url;
  final String category;
  // Crédito y licencia de la foto, siempre visibles al pie
  final String? credit;

  const PhotoViewer({
    super.key,
    required this.url,
    required this.category,
    this.credit,
  });

  static Future<void> show(
    BuildContext context, {
    required String url,
    required String category,
    String? credit,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: MotionConstants.medium,
        reverseTransitionDuration: MotionConstants.short,
        pageBuilder: (_, _, _) =>
            PhotoViewer(url: url, category: category, credit: credit),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: MotionConstants.curve),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = OceanPalette.of(context);
    final credit = this.credit;

    return Scaffold(
      backgroundColor: palette.abyss,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            maxScale: DesignConstants.viewerMaxScale,
            child: SpeciesPhotoView(
              url: url,
              category: category,
              fit: BoxFit.contain,
              cacheWidth: DesignConstants.viewerCacheWidth,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(DesignConstants.pagePadding),
                // Mide 48 dp (glassSize), el mínimo táctil
                child: GlassButton(
                  icon: Icons.close,
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          if (credit != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        palette.ink.withValues(alpha: DesignConstants.scrimAlpha),
                        palette.ink.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(DesignConstants.pagePadding),
                      child: Text(
                        credit,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.paper.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

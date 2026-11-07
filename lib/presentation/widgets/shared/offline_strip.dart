import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/shared/glass_surface.dart';

/// Franja discreta de cristal arriba: "Sin conexión · mostrando lo guardado". Solo aparece
/// sin conexión y cuando lo que se ve viene de lo guardado; no tapa los toques.
class OfflineStrip extends ConsumerWidget {
  const OfflineStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(showSavedStripProvider);
    final palette = OceanPalette.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: reduce ? Duration.zero : MotionConstants.short,
            child: !visible
                ? const SizedBox.shrink(key: ValueKey('hidden'))
                : Padding(
                    key: const ValueKey('strip'),
                    padding: const EdgeInsets.all(DesignConstants.stripMargin),
                    child: Center(
                      child: GlassSurface(
                        borderRadius: BorderRadius.circular(
                          DesignConstants.stripRadius,
                        ),
                        tintAlpha: DesignConstants.glassSolidAlpha,
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignConstants.stripPaddingX,
                          vertical: DesignConstants.stripPaddingY,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: DesignConstants.stripIcon,
                              color: palette.paper,
                            ),
                            const SizedBox(width: DesignConstants.stripGap),
                            Flexible(
                              child: Text(
                                OfflineConstants.savedStrip,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: palette.paper),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

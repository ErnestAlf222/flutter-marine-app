import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';

// Fondo en degradado vertical: la profundidad como hilo de toda la app
class OceanBackground extends StatelessWidget {
  final Widget child;

  const OceanBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: OceanPalette.of(context).depthGradient,
      ),
      child: child,
    );
  }
}

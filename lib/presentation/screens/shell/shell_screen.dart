import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

class ShellScreen extends ConsumerWidget {
  // Mantiene el estado de cada pestaña al cambiar entre ellas
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leerlo basta para que el catálogo local empiece a sincronizarse con la app
    ref.read(catalogSyncProvider);
    // Explorar se baraja al volver a la pestaña: el provider necesita saber en cuál se está
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(currentTabProvider.notifier).set(navigationShell.currentIndex),
    );

    return Scaffold(
      // El degradado de profundidad vive aquí; las pestañas usan Scaffold transparente
      body: OceanBackground(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // Tocar la pestaña activa vuelve a su raíz
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }
}

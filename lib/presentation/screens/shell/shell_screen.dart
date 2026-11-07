import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/providers.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

class ShellScreen extends ConsumerStatefulWidget {
  // Mantiene el estado de cada pestaña al cambiar entre ellas
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  void initState() {
    super.initState();
    // Migra los favoritos sin ficha y pasa sus fotos a su caché, en segundo plano
    Future.microtask(() {
      if (mounted) ref.read(favoritesBackfillProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Leerlo basta para que el catálogo local empiece a sincronizarse con la app
    ref.read(catalogSyncProvider);
    // Mientras el Shell vive, al volver la conexión se recarga lo que estaba en error
    ref.watch(connectionWatcherProvider);
    ref.listen<int>(backOnlineProvider, (_, _) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(OfflineConstants.backOnline),
            duration: OfflineConstants.backOnlineDuration,
          ),
        );
    });
    // Explorar se baraja al volver a la pestaña: el provider necesita saber en cuál se está
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(currentTabProvider.notifier)
          .set(navigationShell.currentIndex),
    );

    return Scaffold(
      // El degradado de profundidad vive aquí; las pestañas usan Scaffold transparente
      body: OceanBackground(
        child: Stack(children: [navigationShell, const OfflineStrip()]),
      ),
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

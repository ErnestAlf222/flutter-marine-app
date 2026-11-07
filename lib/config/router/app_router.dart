import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:marine_app/config/constants/motion_constants.dart';
import 'package:marine_app/config/constants/route_constants.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/screens/screens.dart';
import 'package:marine_app/presentation/widgets/widgets.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    // Fuera del shell para cubrir la barra inferior; entra con desvanecido y deslizamiento
    GoRoute(
      path: RouteConstants.species,
      pageBuilder: (context, state) {
        // Con animaciones reducidas la ruta entra y sale sin transición
        final reduce = MediaQuery.disableAnimationsOf(context);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: reduce ? Duration.zero : MotionConstants.long,
          reverseTransitionDuration: reduce
              ? Duration.zero
              : MotionConstants.medium,
          child: SpeciesDetailScreen(
            slug: state.pathParameters[RouteConstants.speciesParam]!,
            // La tarjeta pasa la especie para que el Hero tenga destino al instante
            preview: state.extra is Species ? state.extra as Species : null,
          ),
          // Entra con desvanecido y deslizamiento; sale encogiéndose hacia su tarjeta
          transitionsBuilder: (context, animation, secondary, child) =>
              DetailPageTransition(animation: animation, child: child),
        );
      },
    ),
    StatefulShellRoute(
      builder: (context, state, navigationShell) =>
          ShellScreen(navigationShell: navigationShell),
      // Igual que indexedStack (las pestañas conservan su estado), pero el cambio
      // entre ellas es un fundido con un leve desplazamiento vertical
      navigatorContainerBuilder: (context, navigationShell, children) =>
          BranchSwitcher(
            currentIndex: navigationShell.currentIndex,
            children: children,
          ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteConstants.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteConstants.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteConstants.favorites,
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteConstants.map,
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:marine_app/config/constants/route_constants.dart';

// Mínimo por ahora: las rutas reales se agregan en el paso 6 con cada pantalla
final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    // Ruta temporal de prueba, sin texto para no dejar cadenas sueltas
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
    ),
  ],
);

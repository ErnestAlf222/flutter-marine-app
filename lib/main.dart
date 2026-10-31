import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';

Future<void> main() async {
  // El .env viaja como asset, así que el binding debe existir antes de cargarlo
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // El héroe de Inicio pasa por debajo de la barra de estado: transparente y con iconos claros
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Sin reintentos: Riverpod repetiría hasta 10 veces un error como el 500 de la API
  // y la pantalla tardaría en mostrarlo
  runApp(ProviderScope(retry: (_, _) => null, child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: const AppTheme().getTheme(),
      // Tema oscuro forzado en la v1
      darkTheme: const AppTheme().getTheme(),
      themeMode: ThemeMode.dark,
    );
  }
}

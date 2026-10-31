import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Verde azulado de los mockups; único lugar donde vive el color semilla
  static const Color _seedColor = Color(0xFF2FD3C6);

  final Brightness brightness;

  const AppTheme({this.brightness = Brightness.light});

  ThemeData getTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);

    // Montserrat se aplica sobre el textTheme del base para heredar los colores de la semilla
    return base.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(base.textTheme),
    );
  }
}

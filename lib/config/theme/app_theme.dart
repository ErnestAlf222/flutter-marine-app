import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de la guía de campo: cuatro tonos de profundidad, la escala UICN,
/// un color por grupo y el coral de acento. Es el único lugar con colores
/// escritos a mano; los widgets los leen con `OceanPalette.of(context)`.
@immutable
class OceanPalette extends ThemeExtension<OceanPalette> {
  // Tonos de profundidad, de la superficie al abismo
  final Color surface;
  final Color reef;
  final Color deep;
  final Color abyss;

  // Solo para favorito y peligro
  final Color coral;

  // Texto sobre fondos oscuros y claros
  final Color paper;
  final Color ink;

  final Map<String, Color> uicn;
  final Color uicnUnknown;
  final Map<String, Color> categories;
  final Color categoryFallback;

  const OceanPalette({
    required this.surface,
    required this.reef,
    required this.deep,
    required this.abyss,
    required this.coral,
    required this.paper,
    required this.ink,
    required this.uicn,
    required this.uicnUnknown,
    required this.categories,
    required this.categoryFallback,
  });

  // Los colores de las fichas de grupo llegan a 4.7:1 o más con texto blanco,
  // y ninguno cae cerca del matiz del coral (~5°)
  static const OceanPalette dark = OceanPalette(
    surface: Color(0xFF1F7FA8),
    reef: Color(0xFF14587F),
    deep: Color(0xFF0B3256),
    abyss: Color(0xFF050E1F),
    coral: Color(0xFFFF6B5E),
    paper: Color(0xFFFFFFFF),
    ink: Color(0xFF06121F),
    uicn: {
      'LC': Color(0xFF4CAF7A),
      'NT': Color(0xFFA8C84A),
      'VU': Color(0xFFF2C94C),
      'EN': Color(0xFFF2994A),
      'CR': Color(0xFFE5484D),
      'EW': Color(0xFF9B5DE5),
      'EX': Color(0xFF6B7280),
    },
    uicnUnknown: Color(0xFF8FA3B5),
    categories: {
      'crustacean': Color(0xFF8F6B24),
      'sponge': Color(0xFF7A731F),
      'algae': Color(0xFF4F7E20),
      'reptile': Color(0xFF218331),
      'cnidarian': Color(0xFF207E5F),
      'fish': Color(0xFF227E87),
      'tunicate': Color(0xFF2C79AF),
      'mammal': Color(0xFF2E49B8),
      'coral': Color(0xFF492EB8),
      'mollusk': Color(0xFF7E2EB8),
      'worm': Color(0xFFB32EB8),
      'echinoderm': Color(0xFFB82E85),
      'other': Color(0xFF5B6B7B),
    },
    categoryFallback: Color(0xFF5B6B7B),
  );

  static OceanPalette of(BuildContext context) =>
      Theme.of(context).extension<OceanPalette>() ?? dark;

  /// Fondo de la app: de azul medio a casi negro, bajando
  LinearGradient get depthGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, reef, deep, abyss],
  );

  Color categoryColor(String id) => categories[id] ?? categoryFallback;

  Color uicnColor(String? code) => uicn[code] ?? uicnUnknown;

  /// Texto legible sobre [background]: el de mayor contraste entre tinta y papel
  Color onColor(Color background) {
    final bg = background.computeLuminance();
    double ratio(Color c) {
      final l = c.computeLuminance();
      return (l > bg ? l + 0.05 : bg + 0.05) / (l > bg ? bg + 0.05 : l + 0.05);
    }

    return ratio(ink) >= ratio(paper) ? ink : paper;
  }

  @override
  OceanPalette copyWith({Color? coral}) => OceanPalette(
    surface: surface,
    reef: reef,
    deep: deep,
    abyss: abyss,
    coral: coral ?? this.coral,
    paper: paper,
    ink: ink,
    uicn: uicn,
    uicnUnknown: uicnUnknown,
    categories: categories,
    categoryFallback: categoryFallback,
  );

  // Un solo tema oscuro en la v1: no hay nada que interpolar
  @override
  OceanPalette lerp(ThemeExtension<OceanPalette>? other, double t) => this;
}

/// Estilos de texto propios de la guía, además de los del tema.
extension OceanTextStyles on TextTheme {
  // Sobretítulo: mayúsculas con espaciado ancho (el texto se escribe ya en mayúsculas)
  TextStyle get overline => labelSmall!.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
  );

  // Nombre científico: cursiva ligera
  TextStyle get scientific =>
      bodyMedium!.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w300);
}

class AppTheme {
  // Verde azulado de los mockups; único lugar donde vive el color semilla
  static const Color _seedColor = Color(0xFF2FD3C6);

  final Brightness brightness;

  // La v1 es oscura: la profundidad del océano pide fondos casi negros
  const AppTheme({this.brightness = Brightness.dark});

  ThemeData getTheme() {
    const palette = OceanPalette.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    ).copyWith(surface: palette.abyss);
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);

    // Montserrat se aplica sobre el textTheme del base para heredar los colores de la semilla
    final montserrat = GoogleFonts.montserratTextTheme(base.textTheme);
    TextStyle? title(TextStyle? s) =>
        s?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6);

    return base.copyWith(
      textTheme: montserrat.copyWith(
        displayLarge: title(montserrat.displayLarge),
        displayMedium: title(montserrat.displayMedium),
        displaySmall: title(montserrat.displaySmall),
        headlineLarge: title(montserrat.headlineLarge),
        headlineMedium: title(montserrat.headlineMedium),
        headlineSmall: title(montserrat.headlineSmall),
        titleLarge: title(montserrat.titleLarge),
        titleMedium: title(montserrat.titleMedium),
      ),
      // Los Scaffold dejan ver el degradado de profundidad que pinta el shell
      scaffoldBackgroundColor: palette.abyss,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.abyss.withValues(alpha: 0.92),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.24),
      ),
      extensions: const [palette],
    );
  }
}

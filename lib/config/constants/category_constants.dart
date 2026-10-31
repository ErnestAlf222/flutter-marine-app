import 'package:material_ui/material_ui.dart';

/// Categorías válidas de la API (enum del OpenAPI) con su etiqueta en español.
/// Es lista fija porque /categories devuelve datos truncados y un valor
/// fuera del enum da 500.
class CategoryConstants {
  static const Map<String, String> labels = {
    'fish': 'Peces',
    'coral': 'Corales',
    'mollusk': 'Moluscos',
    'crustacean': 'Crustáceos',
    'echinoderm': 'Equinodermos',
    'reptile': 'Reptiles',
    'mammal': 'Mamíferos',
    'algae': 'Algas',
    'sponge': 'Esponjas',
    'cnidarian': 'Cnidarios',
    'worm': 'Gusanos',
    'tunicate': 'Tunicados',
    'other': 'Otros',
  };

  // Material no tiene iconos marinos: son aproximaciones
  static const Map<String, IconData> icons = {
    'fish': Icons.set_meal,
    'coral': Icons.park,
    'mollusk': Icons.rotate_right,
    'crustacean': Icons.pest_control,
    'echinoderm': Icons.star,
    'reptile': Icons.pets,
    'mammal': Icons.water,
    'algae': Icons.grass,
    'sponge': Icons.blur_on,
    'cnidarian': Icons.flare,
    'worm': Icons.gesture,
    'tunicate': Icons.bubble_chart,
    'other': Icons.category,
  };

  static const IconData fallbackIcon = Icons.category;

  static List<String> get ids => labels.keys.toList();
}

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

  static List<String> get ids => labels.keys.toList();
}

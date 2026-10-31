/// Categorías válidas de la API (enum del OpenAPI). Es lista fija porque
/// /categories devuelve datos truncados y un valor fuera del enum da 500.
class CategoryConstants {
  static const List<String> ids = [
    'fish',
    'coral',
    'mollusk',
    'crustacean',
    'echinoderm',
    'reptile',
    'mammal',
    'algae',
    'sponge',
    'cnidarian',
    'worm',
    'tunicate',
    'other',
  ];
}

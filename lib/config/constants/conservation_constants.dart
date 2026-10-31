/// Escala UICN. Los 7 niveles van de menor a mayor riesgo; DD y NE quedan
/// fuera de la escala porque no indican un nivel de riesgo.
class ConservationConstants {
  static const List<String> scale = ['LC', 'NT', 'VU', 'EN', 'CR', 'EW', 'EX'];

  // Estados que existen en el catálogo (censo de las 1,505 especies); el filtro de
  // Explorar solo ofrece estos. EW, EX y NE quedan únicamente en la escala del detalle
  static const List<String> catalog = ['LC', 'NT', 'VU', 'EN', 'CR', 'DD'];

  static const Map<String, String> labels = {
    'LC': 'Preocupación menor',
    'NT': 'Casi amenazada',
    'VU': 'Vulnerable',
    'EN': 'En peligro',
    'CR': 'En peligro crítico',
    'EW': 'Extinta en estado silvestre',
    'EX': 'Extinta',
    'DD': 'Datos insuficientes',
    'NE': 'No evaluada',
  };
}

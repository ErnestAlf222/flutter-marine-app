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

  // Frases cortas basadas en las definiciones oficiales de las Categorías y Criterios de la
  // Lista Roja de la UICN, versión 3.1 (portals.iucn.org, documento RL-2001-001-2nd)
  static const Map<String, String> phrases = {
    'LC': 'Evaluada y fuera de peligro: no cumple los criterios de ninguna categoría de '
        'amenaza ni de casi amenazada.',
    'NT': 'Aún no está amenazada, pero se acerca a estarlo o podría estarlo pronto.',
    'VU': 'Enfrenta un riesgo alto de extinción en estado silvestre.',
    'EN': 'Enfrenta un riesgo muy alto de extinción en estado silvestre.',
    'CR': 'Enfrenta un riesgo extremadamente alto de extinción en estado silvestre.',
    'EW': 'Solo sobrevive en cultivo, en cautiverio o en poblaciones naturalizadas '
        'lejos de su área original.',
    'EX': 'No hay duda razonable de que murió el último individuo.',
    'DD': 'No hay información suficiente para estimar su riesgo de extinción. '
        'No significa que esté a salvo.',
    'NE': 'Todavía no se ha evaluado con los criterios de la UICN.',
  };

  // Estados que no son un nivel de riesgo: se muestran aparte de la escala
  static const Set<String> offScale = {'DD', 'NE'};
}

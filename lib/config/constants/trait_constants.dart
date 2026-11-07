/// Etiquetas en español de hábitats, comportamientos y peligrosidad. Los ids
/// son los que devolvió la API; uno nuevo se muestra con el id legible.
class TraitConstants {
  static const Map<String, String> habitats = {
    'coral-reef': 'Arrecife de coral',
    'rocky-reef': 'Arrecife rocoso',
    'reef': 'Arrecife',
    'open-water': 'Aguas abiertas',
    'pelagic-zone': 'Zona pelágica',
    'sand': 'Arena',
    'sandy': 'Arenoso',
    'sandy-bottom': 'Fondo arenoso',
    'rocky': 'Rocoso',
    'mud': 'Fango',
    'muddy-bottom': 'Fondo fangoso',
    'seagrass': 'Pastos marinos',
    'seagrass-meadow': 'Pradera marina',
    'tidepool': 'Poza de marea',
    'tide-pool': 'Poza de marea',
    'cave': 'Cueva',
    'estuarine': 'Estuario',
    'coralligenous': 'Coralígeno',
    'wreck': 'Naufragio',
    'mangrove': 'Manglar',
    'kelp-forest': 'Bosque de kelp',
    'kelp': 'Kelp',
    'shore': 'Orilla',
    'coastal': 'Costero',
    'rubble': 'Escombros',
    'artificial': 'Arrecife artificial',
    'sponge': 'Esponjas',
    'surface': 'Superficie',
    'posidonia': 'Posidonia',
    'rocky wall': 'Pared rocosa',
    'rocky reef': 'Arrecife rocoso',
    'overhang': 'Saliente rocoso',
    'algae': 'Algas',
    'pelagic': 'Zona pelágica',
  };

  static const Map<String, String> behaviors = {
    'solitary': 'Solitario',
    'benthic': 'Bentónico',
    'schooling': 'En cardumen',
    'territorial': 'Territorial',
    'diurnal': 'Diurno',
    'nocturnal': 'Nocturno',
    'sessile': 'Sésil',
    'predator': 'Depredador',
    'fast-moving': 'Veloz',
    'fast-swimmer': 'Nadador veloz',
    'swimming': 'Nadador',
    'slow': 'Lento',
    'slow-mover': 'Lento',
    'pair': 'En pareja',
    'pair-forming': 'Forma parejas',
    'pair-bonding': 'Vínculo de pareja',
    'monogamous': 'Monógamo',
    'symbiotic': 'Simbiótico',
    'pelagic': 'Pelágico',
    'cryptic': 'Críptico',
    'camouflage': 'Camuflaje',
    'filter-feeder': 'Filtrador',
    'colonial': 'Colonial',
    'migratory': 'Migratorio',
    'venomous': 'Venenoso',
    'aggressive': 'Agresivo',
    'herbivorous': 'Herbívoro',
    'herbivore': 'Herbívoro',
    'omnivorous': 'Omnívoro',
    'omnivore': 'Omnívoro',
    'burrower': 'Excavador',
    'specialist-feeder': 'Alimentación especializada',
    'photosynthetic': 'Fotosintético',
    'grazer': 'Ramoneador',
    'scavenger': 'Carroñero',
    'detritivore': 'Detritívoro',
    'cleaner': 'Limpiador',
    'mouth-brooding': 'Incuba en la boca',
    'ambush-predator': 'Depredador al acecho',
    'ambush': 'Al acecho',
    'gregarious': 'Gregario',
    'curious': 'Curioso',
    'primary-producer': 'Productor primario',
    'sedentary': 'Sedentario',
    'wary': 'Cauteloso',
    'homing': 'Regresa a su refugio',
    'habitat-former': 'Forma hábitat',
    'drifting': 'A la deriva',
    'bioluminescent': 'Bioluminiscente',
    'burrowing': 'Excavador',
    'stinging-immune': 'Inmune a picaduras',
    'carnivore': 'Carnívoro',
    'commensal': 'Comensal',
    'colonial-like': 'Casi colonial',
    'parasitic': 'Parásito',
    'electric': 'Eléctrico',
    'spawning-aggregations': 'Agregaciones de desove',
    'juvenile-schooling': 'Juveniles en cardumen',
  };

  static const Map<String, String> dangerLevels = {
    'harmless': 'Inofensiva',
    'caution': 'Precaución',
    'venomous': 'Venenosa',
  };

  // La API no define qué significan exactamente estos niveles, así que se presentan como
  // su clasificación y no como una instrucción de seguridad
  static const Map<String, String> dangerPhrases = {
    'harmless':
        'Según speCies.blue, es inofensiva. Aun así, observa sin tocar.',
    'caution': 'Según speCies.blue, requiere precaución. Observa sin tocar.',
    'venomous': 'Según speCies.blue, es venenosa. Observa sin tocar.',
  };

  // Niveles que merecen el color de alerta; el resto se muestra neutro
  static const Set<String> dangerous = {'caution', 'venomous'};

  static String habitat(String id) => habitats[id] ?? _readable(id);

  static String behavior(String id) => behaviors[id] ?? _readable(id);

  static String danger(String id) => dangerLevels[id] ?? _readable(id);

  static String? dangerPhrase(String id) => dangerPhrases[id];

  // "reef-flat" -> "Reef flat"
  static String _readable(String id) {
    final text = id.replaceAll('-', ' ').replaceAll('_', ' ').trim();
    return text.isEmpty ? id : text[0].toUpperCase() + text.substring(1);
  }

  /// Misma conversión para ids de zona sin nombre disponible
  static String readable(String id) => _readable(id);
}

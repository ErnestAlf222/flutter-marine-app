import 'package:material_ui/material_ui.dart';

/// Colección de Inicio: un atajo a Explorar con un filtro aplicado.
/// Solo uno de los filtros viene definido.
class CollectionDef {
  final String id;
  final String label;
  final IconData icon;
  final double? sizeMinCm;
  final String? dangerLevel;
  final String? conservationStatus;

  const CollectionDef({
    required this.id,
    required this.label,
    required this.icon,
    this.sizeMinCm,
    this.dangerLevel,
    this.conservationStatus,
  });
}

class CollectionConstants {
  static const List<CollectionDef> items = [
    CollectionDef(
      id: 'giants',
      label: 'Gigantes del mar',
      icon: Icons.straighten,
      sizeMinCm: 1000,
    ),
    CollectionDef(
      id: 'venomous',
      label: 'Con veneno',
      icon: Icons.warning_amber_rounded,
      dangerLevel: 'venomous',
    ),
    CollectionDef(
      id: 'critical',
      label: 'En peligro crítico',
      icon: Icons.crisis_alert,
      conservationStatus: 'CR',
    ),
  ];

  static CollectionDef byId(String id) =>
      items.firstWhere((c) => c.id == id);
}

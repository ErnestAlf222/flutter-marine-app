class OceanZone {
  // Slug de la zona; es el valor del filtro `zone`
  final String id;
  final int speciesCount;
  // Nombre y descripción ya vienen en el idioma pedido
  final String name;
  final String description;

  const OceanZone({
    required this.id,
    required this.speciesCount,
    required this.name,
    required this.description,
  });
}

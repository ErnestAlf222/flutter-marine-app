class OceanZone {
  // Slug de la zona; es el valor del filtro `zone`
  final String id;
  final int speciesCount;
  // Nombre y descripción ya vienen en el idioma pedido
  final String name;
  final String description;
  // Centro de la zona en el mapa (grados)
  final double lat;
  final double lon;

  const OceanZone({
    required this.id,
    required this.speciesCount,
    required this.name,
    required this.description,
    required this.lat,
    required this.lon,
  });
}

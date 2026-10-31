import 'package:marine_app/domain/entities/species.dart';

// Una página de /species; /search no pagina y devuelve una lista simple
class SpeciesPage {
  final List<Species> items;
  final int page;
  final int perPage;
  final int total;

  const SpeciesPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  // El scroll infinito pide la siguiente página mientras queden especies por traer
  bool get hasNextPage => page * perPage < total;
}

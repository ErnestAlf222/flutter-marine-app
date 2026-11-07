/// Qué detalles guardados hay que expulsar: los más viejos, sin tocar los favoritos, hasta
/// que los que no son favoritos queden en [limit].
List<String> slugsToEvict({
  required List<(String slug, DateTime viewedAt)> rows,
  required Set<String> favorites,
  required int limit,
}) {
  final candidates = rows.where((r) => !favorites.contains(r.$1)).toList()
    ..sort((a, b) => a.$2.compareTo(b.$2));
  final excess = candidates.length - limit;
  if (excess <= 0) return const [];
  return [for (final r in candidates.take(excess)) r.$1];
}

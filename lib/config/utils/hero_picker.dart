import 'dart:math';

/// Elige las especies del héroe de Inicio: [count] al azar entre las destacadas, sin las del
/// arranque anterior ([previous], por slug). Si las demás no alcanzan, completa con las
/// anteriores; si aun así faltan, devuelve las que haya.
List<T> pickHeroSpecies<T>({
  required List<T> featured,
  required String Function(T) slugOf,
  required Set<String> previous,
  required Random random,
  required int count,
}) {
  final fresh = [
    for (final s in featured)
      if (!previous.contains(slugOf(s))) s,
  ]..shuffle(random);
  final picked = fresh.take(count).toList();
  if (picked.length >= count) return picked;

  final repeated = [
    for (final s in featured)
      if (previous.contains(slugOf(s))) s,
  ]..shuffle(random);
  return [...picked, ...repeated.take(count - picked.length)];
}

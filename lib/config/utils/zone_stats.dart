import 'package:marine_app/config/constants/category_constants.dart';
import 'package:marine_app/config/constants/conservation_constants.dart';
import 'package:marine_app/domain/domain.dart';

/// Récords de una zona calculados con las especies que ya llegaron. Cada uno es null si
/// ninguna especie trae ese dato.
class ZoneRecords {
  final Species? largest;
  final Species? deepest;
  final Species? mostThreatened;

  const ZoneRecords({this.largest, this.deepest, this.mostThreatened});

  bool get isEmpty =>
      largest == null && deepest == null && mostThreatened == null;
}

/// Estadísticas de una muestra de especies de una zona. Todo son funciones puras: sin red ni
/// estado, y en los empates gana la primera especie de la lista.
class ZoneStats {
  /// La más grande (size.max_cm), la que llega más profundo (depth.max_m) y la más amenazada
  /// (mayor riesgo en la escala UICN; DD, NE y sin dato no cuentan)
  static ZoneRecords records(List<Species> items) {
    Species? largest;
    Species? deepest;
    Species? threatened;
    int threatenedRank = -1;

    for (final s in items) {
      final size = s.sizeMaxCm;
      if (size != null && (largest == null || size > largest.sizeMaxCm!)) {
        largest = s;
      }

      final depth = s.depthMaxM;
      if (depth != null && (deepest == null || depth > deepest.depthMaxM!)) {
        deepest = s;
      }

      final rank = ConservationConstants.scale.indexOf(
        s.conservationStatus ?? '',
      );
      if (rank > threatenedRank) {
        threatenedRank = rank;
        threatened = s;
      }
    }
    return ZoneRecords(
      largest: largest,
      deepest: deepest,
      mostThreatened: threatened,
    );
  }

  /// Cuántas especies hay de cada grupo, de más a menos; a igual conteo, en el orden en que
  /// la app lista los grupos (los desconocidos al final)
  static List<(String, int)> groups(List<Species> items) {
    final counts = <String, int>{};
    for (final s in items) {
      counts.update(s.category, (n) => n + 1, ifAbsent: () => 1);
    }

    final order = CategoryConstants.ids;
    int position(String id) {
      final index = order.indexOf(id);
      return index < 0 ? order.length : index;
    }

    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0
            ? byCount
            : position(a.key).compareTo(position(b.key));
      });
    return [for (final e in entries) (e.key, e.value)];
  }

  /// Las especies de un grupo; sin grupo, todas
  static List<Species> inGroup(List<Species> items, String? group) =>
      group == null
      ? items
      : [
          for (final s in items)
            if (s.category == group) s,
        ];
}

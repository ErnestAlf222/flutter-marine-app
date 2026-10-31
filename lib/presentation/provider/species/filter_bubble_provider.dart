import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/presentation/widgets/shared/edge_bubble_geometry.dart';

// Dónde quedó la burbuja de filtros; se recuerda mientras la app esté abierta, aunque
// se cambie de pestaña
class FilterBubbleNotifier extends Notifier<BubblePlacement> {
  @override
  BubblePlacement build() => const BubblePlacement();

  void update(BubblePlacement placement) => state = placement;
}

final filterBubbleProvider =
    NotifierProvider<FilterBubbleNotifier, BubblePlacement>(
      FilterBubbleNotifier.new,
    );

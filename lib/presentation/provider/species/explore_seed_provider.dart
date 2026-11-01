import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/presentation/provider/shell/current_tab_provider.dart';

/// Semilla del orden de Explorar sin texto ni filtros. Cambia al reentrar a la pestaña y al
/// refrescar con el gesto de tirar hacia abajo; volver del Detalle, cerrar la hoja de filtros
/// o aplicar los mismos filtros no la tocan, así que la lista no se mueve.
class ExploreSeedNotifier extends Notifier<int> {
  // Se salió de la pestaña Explorar: la próxima vez que se entre, orden nuevo
  bool _left = false;

  @override
  int build() {
    ref.listen<int>(currentTabProvider, (previous, next) {
      if (previous == RouteConstants.exploreTab && next != RouteConstants.exploreTab) {
        _left = true;
      } else if (next == RouteConstants.exploreTab && _left) {
        _left = false;
        reshuffle();
      }
    });
    return _newSeed();
  }

  int _newSeed() => Random().nextInt(1 << 31);

  /// Nuevo orden; garantiza una semilla distinta de la actual
  void reshuffle() {
    int next = _newSeed();
    while (next == state) {
      next = _newSeed();
    }
    state = next;
  }
}

final exploreSeedProvider = NotifierProvider<ExploreSeedNotifier, int>(
  ExploreSeedNotifier.new,
);

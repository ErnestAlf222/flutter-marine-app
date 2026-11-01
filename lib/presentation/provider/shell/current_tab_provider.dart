import 'package:flutter_riverpod/flutter_riverpod.dart';

// Pestaña activa de la barra inferior. La fija el shell; abrir el Detalle encima no la cambia,
// y por eso volver de él no cuenta como "reentrar" a una pestaña.
class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) {
    if (index != state) state = index;
  }
}

final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(
  CurrentTabNotifier.new,
);

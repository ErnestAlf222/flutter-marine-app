import 'package:flutter_riverpod/flutter_riverpod.dart';

// Inicio pide que Explorar abra con el buscador enfocado y el teclado visible.
// Es un aviso que Explorar consume, porque su pestaña puede o no existir aún.
class SearchFocusRequestNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void request() => state = true;

  void consume() => state = false;
}

final searchFocusRequestProvider =
    NotifierProvider<SearchFocusRequestNotifier, bool>(
      SearchFocusRequestNotifier.new,
    );

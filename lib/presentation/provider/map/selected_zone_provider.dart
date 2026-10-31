import 'package:flutter_riverpod/flutter_riverpod.dart';

// El Detalle pide abrir el Mapa con una zona ya seleccionada y su hoja abierta.
// Es un aviso que el Mapa consume, porque su pestaña puede o no existir aún.
class SelectedZoneNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String zoneId) => state = zoneId;

  void consume() => state = null;
}

final selectedZoneProvider = NotifierProvider<SelectedZoneNotifier, String?>(
  SelectedZoneNotifier.new,
);

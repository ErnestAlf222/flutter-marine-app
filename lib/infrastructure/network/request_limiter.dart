import 'dart:async';
import 'dart:collection';

import 'package:marine_app/config/config.dart';

/// Limitador de ventana deslizante. Cuenta las peticiones de los últimos [window] y, cuando
/// ya hay [threshold], pone en cola las siguientes hasta que alguna salga de la ventana.
/// Las de baja prioridad solo salen con menos de [lowThreshold] en la ventana y siempre
/// después de las normales que estén esperando.
class RequestLimiter {
  /// El de la app: lo comparten todos los clientes HTTP
  static final RequestLimiter shared = RequestLimiter();

  final int threshold;
  final int lowThreshold;
  final Duration window;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _sleep;

  // Instantes de salida de las peticiones que siguen dentro de la ventana
  final _sent = Queue<DateTime>();
  final _high = Queue<Completer<void>>();
  final _low = Queue<Completer<void>>();
  bool _waking = false;

  /// [now] y [sleep] se inyectan para probar con un reloj falso
  RequestLimiter({
    this.threshold = ApiConstants.rateLimitThreshold,
    this.lowThreshold = ApiConstants.rateLimitLowThreshold,
    this.window = ApiConstants.rateLimitWindow,
    DateTime Function()? now,
    Future<void> Function(Duration)? sleep,
  }) : _now = now ?? DateTime.now,
       _sleep = sleep ?? Future<void>.delayed;

  /// Peticiones dentro de la ventana en este momento
  int get inWindow {
    _prune();
    return _sent.length;
  }

  /// Peticiones esperando su turno
  int get queued => _high.length + _low.length;

  /// Se completa cuando la petición puede salir
  Future<void> acquire({bool lowPriority = false}) {
    final turn = Completer<void>();
    (lowPriority ? _low : _high).add(turn);
    _pump();
    return turn.future;
  }

  void _prune() {
    final limit = _now().subtract(window);
    while (_sent.isNotEmpty && !_sent.first.isAfter(limit)) {
      _sent.removeFirst();
    }
  }

  void _pump() {
    _prune();

    while (_high.isNotEmpty || _low.isNotEmpty) {
      final isHigh = _high.isNotEmpty;
      final cap = isHigh ? threshold : lowThreshold;
      if (_sent.length >= cap) {
        _wakeWhenFree(cap);
        return;
      }
      _sent.add(_now());
      (isHigh ? _high : _low).removeFirst().complete();
    }
  }

  // Duerme hasta que salga de la ventana la petición que libera un hueco
  void _wakeWhenFree(int cap) {
    if (_waking) return;
    _waking = true;

    final freeing = _sent.elementAt(_sent.length - cap);
    final wait = freeing.add(window).difference(_now());
    _sleep(wait.isNegative ? Duration.zero : wait).then((_) {
      _waking = false;
      _pump();
    });
  }
}

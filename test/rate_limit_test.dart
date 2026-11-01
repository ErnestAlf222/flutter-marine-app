import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';

// Reloj falso: el tiempo solo avanza cuando la prueba lo pide y las esperas del limitador
// se despiertan en ese momento
class _FakeClock {
  DateTime now = DateTime(2026, 11, 1, 12);
  final sleeps = <Duration>[];
  final _sleepers = <(DateTime, Completer<void>)>[];

  Future<void> sleep(Duration duration) {
    sleeps.add(duration);
    final done = Completer<void>();
    _sleepers.add((now.add(duration), done));
    return done.future;
  }

  Future<void> advance(Duration duration) async {
    now = now.add(duration);
    final due = _sleepers.where((s) => !s.$1.isAfter(now)).toList();
    _sleepers.removeWhere((s) => !s.$1.isAfter(now));
    for (final (_, done) in due) {
      done.complete();
    }
    await flush();
  }

  // Deja correr los eventos pendientes; Dio tarda varios turnos en llegar al interceptor
  Future<void> flush() async {
    for (int i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

RequestLimiter _limiter(
  _FakeClock clock, {
  int threshold = 90,
  int lowThreshold = 60,
}) => RequestLimiter(
  threshold: threshold,
  lowThreshold: lowThreshold,
  window: const Duration(minutes: 1),
  now: () => clock.now,
  sleep: clock.sleep,
);

// Marca cuándo se completa cada petición
List<bool> _track(List<Future<void>> futures) {
  final done = List.filled(futures.length, false);
  for (int i = 0; i < futures.length; i++) {
    futures[i].then((_) => done[i] = true);
  }
  return done;
}

class _Adapter implements HttpClientAdapter {
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('los valores por defecto salen de las constantes', () {
    final limiter = RequestLimiter();
    expect(limiter.threshold, ApiConstants.rateLimitThreshold);
    expect(limiter.lowThreshold, ApiConstants.rateLimitLowThreshold);
    expect(limiter.window, ApiConstants.rateLimitWindow);
    expect(ApiConstants.rateLimitThreshold, lessThan(ApiConstants.rateLimit));
  });

  group('RequestLimiter', () {
    test('hasta el umbral salen al instante; la siguiente espera en cola', () async {
      final clock = _FakeClock();
      final limiter = _limiter(clock);

      final first = _track([for (int i = 0; i < 90; i++) limiter.acquire()]);
      final extra = _track([limiter.acquire()]);
      await clock.flush();

      expect(first.every((d) => d), isTrue);
      expect(extra.single, isFalse);
      expect(limiter.inWindow, 90);
      expect(limiter.queued, 1);
    });

    test('la cola sale cuando la petición más vieja abandona la ventana', () async {
      final clock = _FakeClock();
      final limiter = _limiter(clock);

      for (int i = 0; i < 90; i++) {
        limiter.acquire();
      }
      final extra = _track([limiter.acquire()]);
      await clock.flush();

      // Duerme exactamente lo que falta para que salga la primera de la ventana
      expect(clock.sleeps.single, const Duration(minutes: 1));

      await clock.advance(const Duration(seconds: 59));
      expect(extra.single, isFalse);

      await clock.advance(const Duration(seconds: 1));
      expect(extra.single, isTrue);
      expect(limiter.queued, 0);
    });

    test('la ventana es deslizante: las peticiones escalonadas liberan huecos de a una', () async {
      final clock = _FakeClock();
      final limiter = _limiter(clock, threshold: 3, lowThreshold: 3);

      limiter.acquire();
      await clock.advance(const Duration(seconds: 20));
      limiter.acquire();
      await clock.advance(const Duration(seconds: 20));
      limiter.acquire();
      final waiting = _track([limiter.acquire(), limiter.acquire()]);
      await clock.flush();
      expect(waiting, [false, false]);

      // A los 60 s sale de la ventana la primera: pasa una sola
      await clock.advance(const Duration(seconds: 20));
      expect(waiting, [true, false]);

      // 20 s después sale la segunda y pasa la otra
      await clock.advance(const Duration(seconds: 20));
      expect(waiting, [true, true]);
    });

    test('las de baja prioridad ceden el paso: la normal que llegó después sale primero', () async {
      final clock = _FakeClock();
      final limiter = _limiter(clock, threshold: 2, lowThreshold: 1);

      limiter.acquire();
      limiter.acquire();
      final low = _track([limiter.acquire(lowPriority: true)]);
      final high = _track([limiter.acquire()]);
      await clock.flush();
      expect(low.single || high.single, isFalse);

      await clock.advance(const Duration(minutes: 1));
      // Con la ventana vacía sale la normal; la baja espera su turno (solo cabe 1)
      expect(high.single, isTrue);
      expect(low.single, isFalse);

      await clock.advance(const Duration(minutes: 1));
      expect(low.single, isTrue);
    });

    test('las de baja prioridad dejan holgura: no se comen los últimos huecos', () async {
      final clock = _FakeClock();
      final limiter = _limiter(clock, threshold: 5, lowThreshold: 3);

      for (int i = 0; i < 3; i++) {
        limiter.acquire();
      }
      final low = _track([limiter.acquire(lowPriority: true)]);
      final high = _track([limiter.acquire()]);
      await clock.flush();

      // Con 3 en la ventana la baja ya no pasa, pero la normal sí
      expect(low.single, isFalse);
      expect(high.single, isTrue);
    });

    test('una baja sola sale de inmediato si hay holgura', () async {
      final clock = _FakeClock();
      final limiter = _limiter(clock);

      final low = _track([limiter.acquire(lowPriority: true)]);
      await clock.flush();

      expect(low.single, isTrue);
    });
  });

  group('prioridad por zona', () {
    test('solo es baja dentro de runLow, también tras un await', () async {
      expect(RequestPriority.isLow, isFalse);

      await RequestPriority.runLow(() async {
        expect(RequestPriority.isLow, isTrue);
        await Future<void>.delayed(Duration.zero);
        expect(RequestPriority.isLow, isTrue);
      });

      expect(RequestPriority.isLow, isFalse);
    });
  });

  group('RateLimitInterceptor con Dio', () {
    test('cerca del límite la petición espera en cola en vez de fallar', () async {
      final clock = _FakeClock();
      final adapter = _Adapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://prueba'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          RateLimitInterceptor(_limiter(clock, threshold: 2, lowThreshold: 2)),
        );

      await dio.get<dynamic>('/a');
      await dio.get<dynamic>('/b');
      final third = dio.get<dynamic>('/c');
      await clock.flush();
      expect(adapter.paths, ['/a', '/b']);

      await clock.advance(const Duration(minutes: 1));
      await third;
      expect(adapter.paths, ['/a', '/b', '/c']);
    });

    test('las peticiones de la muestra de zonas ceden el paso a las de la pantalla', () async {
      final clock = _FakeClock();
      final adapter = _Adapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://prueba'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          RateLimitInterceptor(_limiter(clock, threshold: 1, lowThreshold: 1)),
        );

      await dio.get<dynamic>('/primera');
      // La de la muestra se pide antes, pero la de la pantalla debe salir primero
      final sample = RequestPriority.runLow(() => dio.get<dynamic>('/muestra'));
      final screen = dio.get<dynamic>('/pantalla');
      await clock.flush();
      expect(adapter.paths, ['/primera']);

      await clock.advance(const Duration(minutes: 1));
      await screen;
      expect(adapter.paths, ['/primera', '/pantalla']);

      await clock.advance(const Duration(minutes: 1));
      await sample;
      expect(adapter.paths, ['/primera', '/pantalla', '/muestra']);
    });
  });
}

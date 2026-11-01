import 'package:dio/dio.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/infrastructure/network/request_limiter.dart';

/// Espera su turno en el [RequestLimiter] antes de enviar cada petición. Las que se lanzan
/// dentro de [RequestPriority.runLow] tienen baja prioridad.
class RateLimitInterceptor extends Interceptor {
  final RequestLimiter limiter;

  RateLimitInterceptor(this.limiter);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await limiter.acquire(lowPriority: RequestPriority.isLow);
    handler.next(options);
  }
}

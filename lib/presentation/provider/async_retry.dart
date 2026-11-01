import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncRetryX<T> on AsyncValue<T> {
  /// Igual que `when`, pero mientras se reintenta tras un error muestra [loading].
  /// Riverpod conserva el error anterior durante la recarga y `when` (incluso con
  /// `skipLoadingOnReload`) lo seguiría pintando, así que "Reintentar" parecería no hacer nada.
  /// Con `skipLoadingOnReload` sigue conservando los datos previos al refrescar.
  R whenRetry<R>({
    required R Function() loading,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function(T data) data,
    bool skipLoadingOnReload = false,
  }) {
    if (isLoading && hasError && !hasValue) return loading();
    return when(
      skipLoadingOnReload: skipLoadingOnReload,
      loading: loading,
      error: error,
      data: data,
    );
  }
}

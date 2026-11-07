import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';

// Único punto donde presentation conoce el repositorio impl del catálogo local
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepositoryImpl();
});

/// Estado del catálogo local: mientras no esté listo, la app usa el servidor
class CatalogStatus {
  final bool ready;
  // Ya se miró si hay un catálogo guardado completo (con o sin éxito)
  final bool prepared;
  // Hay una sincronización en marcha; solo se muestra si todavía no hay catálogo
  final bool syncing;
  final int step;
  final int total;

  const CatalogStatus({
    this.ready = false,
    this.prepared = false,
    this.syncing = false,
    this.step = 0,
    this.total = 0,
  });

  /// La primera sincronización es la única que se muestra: la actualización va en silencio
  bool get showProgress => !ready && syncing;

  CatalogStatus copyWith({
    bool? ready,
    bool? prepared,
    bool? syncing,
    int? step,
    int? total,
  }) =>
      CatalogStatus(
        ready: ready ?? this.ready,
        prepared: prepared ?? this.prepared,
        syncing: syncing ?? this.syncing,
        step: step ?? this.step,
        total: total ?? this.total,
      );
}

class CatalogSyncNotifier extends Notifier<CatalogStatus> {
  @override
  CatalogStatus build() {
    // Arranca solo, cuando la app ya está en marcha
    Future.microtask(start);
    return const CatalogStatus();
  }

  Future<void> start() async {
    final repository = ref.read(catalogRepositoryProvider);

    try {
      final ready = await repository.prepare();
      if (!ref.mounted) return;
      state = state.copyWith(ready: ready, prepared: true, syncing: true);

      await for (final progress in repository.sync()) {
        if (!ref.mounted) return;
        state = state.copyWith(step: progress.step, total: progress.total);
      }
      if (!ref.mounted) return;
      state = state.copyWith(ready: repository.isReady, syncing: false);
    } catch (_) {
      // Sin catálogo la app sigue funcionando con el servidor; se reintenta en la
      // próxima apertura (la sincronización continúa donde iba)
      if (ref.mounted) state = state.copyWith(prepared: true, syncing: false);
    }
  }
}

final catalogSyncProvider =
    NotifierProvider<CatalogSyncNotifier, CatalogStatus>(
      CatalogSyncNotifier.new,
    );

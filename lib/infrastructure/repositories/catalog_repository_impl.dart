import 'dart:async';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/catalog/catalog_index.dart';
import 'package:marine_app/infrastructure/datasources/catalog_datasources_impl.dart';
import 'package:marine_app/infrastructure/datasources/species_datasources_impl.dart';

class CatalogRepositoryImpl extends CatalogRepository {
  final CatalogDatasource local;
  final DateTime Function() _now;

  // Perezoso: el cliente HTTP necesita el .env y solo hace falta al sincronizar
  SpeciesDatasource? _remote;
  SpeciesDatasource get remote => _remote ??= SpeciesDatasourcesImpl();

  CatalogIndex? _index;
  bool _syncing = false;

  // Sin datasources inyectados se usan los reales, como en el resto de repositorios
  CatalogRepositoryImpl({
    CatalogDatasource? local,
    SpeciesDatasource? remote,
    DateTime Function()? now,
  }) : local = local ?? CatalogDatasourcesImpl(),
       // ignore: prefer_initializing_formals
       _remote = remote,
       _now = now ?? DateTime.now;

  @override
  bool get isReady => _index != null;

  @override
  Future<bool> prepare() async {
    final (state, error) = await local.readSync();
    if (state == null) throw error;
    if (!state.isComplete) return false;

    await _load();
    return true;
  }

  Future<void> _load() async {
    final (entries, error) = await local.loadAll();
    if (entries == null) throw error;
    _index = CatalogIndex(entries);
  }

  @override
  Stream<CatalogProgress> sync() {
    final controller = StreamController<CatalogProgress>();
    if (_syncing) {
      controller.close();
      return controller.stream;
    }
    _syncing = true;

    // Todo con baja prioridad: cede el paso a lo que el usuario tiene en pantalla
    RequestPriority.runLow(() => _run(controller)).whenComplete(() {
      _syncing = false;
      controller.close();
    });
    return controller.stream;
  }

  Future<void> _run(StreamController<CatalogProgress> out) async {
    try {
      final (state, stateError) = await local.readSync();
      if (state == null) throw stateError;

      final completedAt = state.completedAt;
      final outdated =
          completedAt == null ||
          _now().difference(completedAt) > CatalogConstants.refreshAfter;
      if (!outdated && !state.isInProgress) return;

      // Si quedó a medias se sigue en la misma pasada y en la misma página
      final runId = state.isInProgress && state.runId != 0
          ? state.runId
          : _now().millisecondsSinceEpoch;
      int page = state.isInProgress ? state.nextPage : 1;
      int totalPages = state.isInProgress ? state.totalPages : 0;

      while (totalPages == 0 || page <= totalPages) {
        final (es, esError) = await remote.getSpecies(
          lang: 'es',
          page: page,
          perPage: CatalogConstants.perPage,
        );
        if (es == null) throw esError;

        // El total lo dice la API: se para en la última página, nunca en la siguiente
        totalPages = (es.total / CatalogConstants.perPage).ceil();
        if (page > totalPages) break;

        final (en, enError) = await remote.getSpecies(
          lang: 'en',
          page: page,
          perPage: CatalogConstants.perPage,
        );
        if (en == null) throw enError;

        final first = (page - 1) * CatalogConstants.perPage;
        for (final (items, lang) in [(es.items, 'es'), (en.items, 'en')]) {
          final (saved, saveError) = await local.savePage(
            items,
            lang: lang,
            firstPosition: first,
            runId: runId,
          );
          if (saved == null) throw saveError;
        }

        // Cada página queda anotada: si la app se cierra aquí, continúa en la siguiente
        final (written, writeError) = await local.writeSync(
          CatalogSyncState(
            nextPage: page + 1,
            totalPages: totalPages,
            runId: runId,
            completedAt: completedAt,
          ),
        );
        if (written == null) throw writeError;

        out.add(CatalogProgress(page, totalPages));
        page++;
      }

      final (_, cleanError) = await local.removeStale(runId);
      if (cleanError.isNotEmpty) throw cleanError;

      final (done, doneError) = await local.writeSync(
        CatalogSyncState(
          totalPages: totalPages,
          runId: runId,
          completedAt: _now(),
        ),
      );
      if (done == null) throw doneError;

      await _load();
    } catch (e) {
      out.addError(e);
    }
  }

  @override
  Future<List<Species>?> search({
    required String query,
    bool Function(Species)? filter,
  }) async => _index?.search(query, filter: filter);
}

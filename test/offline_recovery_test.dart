import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/presentation/provider/providers.dart';

import 'support/fake_offline.dart';
import 'support/fake_ui_repository.dart';

const _zone = OceanZone(
  id: 'mediterranean',
  speciesCount: 10,
  name: 'Mediterráneo',
  description: 'Un mar casi cerrado.',
  lat: 35,
  lon: 18,
);

// Las zonas fallan sin conexión hasta que [online] pasa a true; el resto responde siempre
class _FlakyRepository extends FakeUiRepository {
  bool online = false;
  int zoneCalls = 0;

  @override
  Future<(List<OceanZone>?, String)> getZones({required String lang}) async {
    zoneCalls++;
    return online ? (<OceanZone>[_zone], '') : (null, ApiConstants.offlineMessage);
  }
}

ProviderContainer _container(_FlakyRepository repository, FakeConnectivity connectivity) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      ...offlineOverrides(connectivity: connectivity),
      speciesRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  // El Shell mantiene vivos al vigilante y a la conexión; aquí lo hace la prueba
  container.listen(connectionWatcherProvider, (_, _) {});
  container.listen(onlineProvider, (_, _) {});
  // Como la pantalla del Mapa, que está mirando las zonas
  container.listen(zonesProvider, (_, _) {});
  return container;
}

void main() {
  test('al volver la conexión recarga solo lo que estaba en error', () async {
    final repository = _FlakyRepository();
    final connectivity = FakeConnectivity(online: false);
    final container = _container(repository, connectivity);

    // Un provider con datos (el conteo de una colección) y otro en error (las zonas)
    await container.read(collectionCountProvider('giants').future);
    await expectLater(container.read(zonesProvider.future), throwsA(ApiConstants.offlineMessage));
    expect(repository.speciesCalls, 1);
    expect(repository.zoneCalls, 1);

    int photoRetries = 0;
    PhotoRetry.add(() => photoRetries++);
    addTearDown(() => PhotoRetry.retryAll());

    repository.online = true;
    connectivity.set(true);
    await pumpEventQueue();

    // Las zonas se pidieron otra vez y ya tienen datos; el conteo no se tocó
    expect(repository.zoneCalls, 2);
    expect(container.read(zonesProvider).value, [_zone]);
    expect(repository.speciesCalls, 1, reason: 'los providers con datos no se recargan');
    // Y las fotos que no llegaron se reintentan, con su aviso
    expect(photoRetries, 1);
    expect(container.read(backOnlineProvider), 1);
  });

  test('sin transición de desconectado a conectado no se recarga nada', () async {
    final repository = _FlakyRepository();
    final connectivity = FakeConnectivity(online: true);
    final container = _container(repository, connectivity);

    await expectLater(container.read(zonesProvider.future), throwsA(ApiConstants.offlineMessage));
    await pumpEventQueue();

    // Sigue conectado (la red cambia de wifi a datos): no hay "vuelta en línea"
    connectivity.set(true);
    await pumpEventQueue();
    expect(repository.zoneCalls, 1);
    expect(container.read(backOnlineProvider), 0);

    // Se cae y vuelve: ahora sí
    connectivity.set(false);
    await pumpEventQueue();
    repository.online = true;
    connectivity.set(true);
    await pumpEventQueue();
    expect(repository.zoneCalls, 2);
    expect(container.read(backOnlineProvider), 1);
  });

  test('un provider que se recarga solo antes de volver la red no se recarga dos veces', () async {
    final repository = _FlakyRepository();
    final connectivity = FakeConnectivity(online: false);
    final container = _container(repository, connectivity);

    await expectLater(container.read(zonesProvider.future), throwsA(ApiConstants.offlineMessage));
    // "Reintentar" a mano mientras sigue sin red: falla otra vez y queda anotado una sola vez
    container.invalidate(zonesProvider);
    await expectLater(container.read(zonesProvider.future), throwsA(ApiConstants.offlineMessage));
    expect(container.read(reconnectRegistryProvider).length, 1);

    repository.online = true;
    connectivity.set(true);
    await pumpEventQueue();
    expect(repository.zoneCalls, 3);
    expect(container.read(reconnectRegistryProvider).length, 0);
  });
}

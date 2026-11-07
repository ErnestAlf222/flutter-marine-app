import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marine_app/config/config.dart';
import 'package:marine_app/domain/domain.dart';
import 'package:marine_app/infrastructure/infrastructure.dart';
import 'package:marine_app/presentation/provider/providers.dart';

import 'support/fake_offline.dart';
import 'support/fake_ui_repository.dart';

SpeciesDetail _detail(int n, {String? description}) => SpeciesDetail(
  id: 'id-$n',
  slug: 'especie-$n',
  scientificName: 'Species $n',
  commonName: 'Especie $n',
  category: 'fish',
  conservationStatus: 'LC',
  sizeMaxCm: 12.5,
  habitats: const ['reef'],
  fullDescription: description,
  taxonomy: const SpeciesTaxonomy(kingdom: 'Animalia', family: 'Gobiidae'),
  photos: const [SpeciesPhoto(url: 'https://x/1.jpg', credit: '© A (CC0)', isPrimary: true)],
  zones: const ['mediterranean'],
);

// Repositorio que solo responde el detalle y puede dejar de hacerlo
class _DetailRepository extends FakeUiRepository {
  String? failWith;
  int calls = 0;

  @override
  Future<(SpeciesDetail?, String)> getSpeciesBySlug({
    required String slug,
    required String lang,
  }) async {
    calls++;
    if (failWith != null) return (null, failWith!);
    return (_detail(int.parse(slug.split('-').last), description: 'Vista en línea'), '');
  }
}

void main() {
  group('expulsión de detalles guardados', () {
    final base = DateTime(2026);

    test('expulsa los más viejos hasta quedar en el límite', () {
      final rows = [for (int i = 0; i < 6; i++) ('e$i', base.add(Duration(minutes: i)))];
      expect(slugsToEvict(rows: rows, favorites: {}, limit: 4), ['e0', 'e1']);
      expect(slugsToEvict(rows: rows, favorites: {}, limit: 6), isEmpty);
      expect(slugsToEvict(rows: rows, favorites: {}, limit: 0).length, 6);
    });

    test('los favoritos nunca se expulsan ni cuentan para el límite', () {
      final rows = [for (int i = 0; i < 6; i++) ('e$i', base.add(Duration(minutes: i)))];
      // e0 y e1 son los más viejos pero favoritos: se expulsan e2 y e3
      expect(slugsToEvict(rows: rows, favorites: {'e0', 'e1'}, limit: 2), ['e2', 'e3']);
    });

    test('guardar más de N deja N (más los favoritos) y conserva los recientes', () async {
      final cache = InMemoryOfflineCache()..favorites['especie-1'] = null;
      for (int n = 1; n <= 8; n++) {
        await cache.saveDetail(_detail(n), limit: 3);
      }

      // Los 3 más recientes y el favorito, aunque fuera el primero
      expect(cache.seen.keys.toSet(), {'especie-1', 'especie-6', 'especie-7', 'especie-8'});
      expect(await cache.detail('especie-2'), isNull);
      expect((await cache.detail('especie-8'))?.commonName, 'Especie 8');
    });

    test('volver a ver un detalle lo rejuvenece y no se expulsa', () async {
      final cache = InMemoryOfflineCache();
      for (int n = 1; n <= 3; n++) {
        await cache.saveDetail(_detail(n), limit: 3);
      }
      await cache.saveDetail(_detail(1), limit: 3);
      await cache.saveDetail(_detail(4), limit: 3);

      expect(cache.seen.keys.toSet(), {'especie-1', 'especie-3', 'especie-4'});
    });
  });

  test('el JSON guardado devuelve la ficha completa sin perder nada', () {
    final original = _detail(3, description: 'Texto largo');
    final copy = CacheMapper.detailFromJson(CacheMapper.detailToJson(original));

    expect(copy.slug, original.slug);
    expect(copy.commonName, original.commonName);
    expect(copy.sizeMaxCm, 12.5);
    expect(copy.habitats, ['reef']);
    expect(copy.fullDescription, 'Texto largo');
    expect(copy.taxonomy.family, 'Gobiidae');
    expect(copy.photos.single.url, 'https://x/1.jpg');
    expect(copy.photos.single.isPrimary, isTrue);
    expect(copy.zones, ['mediterranean']);

    final species = FakeUiRepository.species(3);
    final back = CacheMapper.speciesListFromJson(CacheMapper.speciesListToJson(species));
    expect(back.map((s) => s.slug), species.map((s) => s.slug));
    expect(back[1].depthMaxM, species[1].depthMaxM);

    const zones = [
      OceanZone(id: 'z', speciesCount: 3, name: 'Zona', description: 'D', lat: 1.5, lon: -2),
    ];
    final zonesBack = CacheMapper.zonesFromJson(CacheMapper.zonesToJson(zones));
    expect(zonesBack.single.name, 'Zona');
    expect(zonesBack.single.lon, -2);
  });

  group('detalle: lo visto se guarda y se abre sin conexión', () {
    ProviderContainer container(_DetailRepository repository, InMemoryOfflineCache cache) {
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          ...offlineOverrides(cache: cache),
          speciesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('con red se guarda; sin red se abre lo guardado y se marca', () async {
      final repository = _DetailRepository();
      final cache = InMemoryOfflineCache();
      final c = container(repository, cache);

      final online = await c.read(speciesDetailProvider('especie-4').future);
      expect(online.fullDescription, 'Vista en línea');
      await pumpEventQueue();
      expect(cache.seen.containsKey('especie-4'), isTrue);

      // Otra sesión, sin red: el mismo detalle sale de lo guardado
      repository.failWith = ApiConstants.offlineMessage;
      final offline = container(repository, cache);
      final saved = await offline.read(speciesDetailProvider('especie-4').future);
      expect(saved.commonName, 'Especie 4');
      expect(offline.read(savedContentProvider), contains(OfflineConstants.savedDetail('especie-4')));
    });

    test('una especie nunca vista sin conexión da el error de sin conexión', () async {
      final repository = _DetailRepository()..failWith = ApiConstants.offlineMessage;
      final c = container(repository, InMemoryOfflineCache());

      await expectLater(
        c.read(speciesDetailProvider('especie-9').future),
        throwsA(ApiConstants.offlineMessage),
      );
      expect(c.read(savedContentProvider), isEmpty);
    });

    test('un 404 no se tapa con lo guardado', () async {
      final repository = _DetailRepository()..failWith = ApiConstants.notFoundMessage;
      final cache = InMemoryOfflineCache();
      await cache.saveDetail(_detail(5), limit: 10);
      final c = container(repository, cache);

      await expectLater(
        c.read(speciesDetailProvider('especie-5').future),
        throwsA(ApiConstants.notFoundMessage),
      );
    });
  });

  group('destacadas y zonas guardadas', () {
    test('las destacadas se guardan y, sin red, se muestran las últimas que llegaron', () async {
      final repository = _DetailRepository();
      final cache = InMemoryOfflineCache();
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          ...offlineOverrides(cache: cache),
          speciesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(c.dispose);

      // Como Inicio, que está mirando el héroe (sin oyentes el stream queda en pausa)
      c.listen(featuredSpeciesProvider, (_, _) {});
      final fresh = await c.read(featuredSpeciesProvider.future);
      await pumpEventQueue();
      expect(cache.featuredList?.length, fresh.length);

      // La app se abre otra vez, ahora sin red: la lista guardada sale al instante
      final offline = _FailingSpecies();
      final c2 = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          ...offlineOverrides(cache: cache),
          speciesRepositoryProvider.overrideWithValue(offline),
        ],
      );
      addTearDown(c2.dispose);

      c2.listen(featuredSpeciesProvider, (_, _) {});
      final saved = await c2.read(featuredSpeciesProvider.future);
      expect(saved.map((s) => s.slug), fresh.map((s) => s.slug));
    });

    test('las zonas se guardan y el mapa se ve sin conexión', () async {
      final cache = InMemoryOfflineCache();
      const zone = OceanZone(id: 'z', speciesCount: 1, name: 'Zona', description: 'D', lat: 0, lon: 0);
      final online = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          ...offlineOverrides(cache: cache),
          speciesRepositoryProvider.overrideWithValue(_ZonesRepository(online: true, zone: zone)),
        ],
      );
      addTearDown(online.dispose);
      await online.read(zonesProvider.future);
      await pumpEventQueue();
      expect(cache.zoneList?.single.name, 'Zona');

      final offline = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          ...offlineOverrides(cache: cache),
          speciesRepositoryProvider.overrideWithValue(_ZonesRepository(online: false, zone: zone)),
        ],
      );
      addTearDown(offline.dispose);
      expect((await offline.read(zonesProvider.future)).single.name, 'Zona');
      expect(offline.read(savedContentProvider), contains(OfflineConstants.savedZones));
    });
  });
}

// Todo lo que pide la lista de Inicio falla sin conexión
class _FailingSpecies extends FakeUiRepository {
  @override
  Future<(SpeciesPage?, String)> getSpecies({
    required String lang,
    required int page,
    required int perPage,
    String? zone,
    String? category,
    String? conservationStatus,
    String? dangerLevel,
    double? sizeMin,
    double? sizeMax,
    double? depthMin,
    double? depthMax,
    bool? featured,
  }) async => (null, ApiConstants.offlineMessage);
}

class _ZonesRepository extends FakeUiRepository {
  final bool online;
  final OceanZone zone;

  _ZonesRepository({required this.online, required this.zone});

  @override
  Future<(List<OceanZone>?, String)> getZones({required String lang}) async =>
      online ? ([zone], '') : (null, ApiConstants.offlineMessage);
}

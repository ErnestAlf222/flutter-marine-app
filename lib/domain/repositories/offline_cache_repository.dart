import 'package:marine_app/domain/datasources/offline_cache_datasource.dart';

// Mismo contrato que el datasource: la caché local no tiene reglas propias en esta capa
abstract class OfflineCacheRepository extends OfflineCacheDatasource {}

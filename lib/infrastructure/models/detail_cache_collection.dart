import 'package:isar_community/isar.dart';

part 'detail_cache_collection.g.dart';

// Últimos detalles vistos: el JSON de la ficha y cuándo se vio por última vez
@collection
class DetailCacheCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String slug;

  late String json;

  // De él sale qué se expulsa primero
  @Index()
  late DateTime viewedAt;
}

// Tabla genérica de claves con JSON: destacadas de Inicio y zonas
@collection
class JsonCacheCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String json;

  late DateTime savedAt;
}

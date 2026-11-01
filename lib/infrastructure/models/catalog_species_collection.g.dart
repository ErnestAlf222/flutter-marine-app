// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_species_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetCatalogSpeciesCollectionCollection on Isar {
  IsarCollection<CatalogSpeciesCollection> get catalogSpeciesCollections =>
      this.collection();
}

const CatalogSpeciesCollectionSchema = CollectionSchema(
  name: r'CatalogSpeciesCollection',
  id: -8944968542121949488,
  properties: {
    r'behaviors': PropertySchema(
      id: 0,
      name: r'behaviors',
      type: IsarType.stringList,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'commonName': PropertySchema(
      id: 2,
      name: r'commonName',
      type: IsarType.string,
    ),
    r'conservationStatus': PropertySchema(
      id: 3,
      name: r'conservationStatus',
      type: IsarType.string,
    ),
    r'dangerLevel': PropertySchema(
      id: 4,
      name: r'dangerLevel',
      type: IsarType.string,
    ),
    r'depthMaxM': PropertySchema(
      id: 5,
      name: r'depthMaxM',
      type: IsarType.double,
    ),
    r'depthMinM': PropertySchema(
      id: 6,
      name: r'depthMinM',
      type: IsarType.double,
    ),
    r'featured': PropertySchema(id: 7, name: r'featured', type: IsarType.bool),
    r'foldedEn': PropertySchema(
      id: 8,
      name: r'foldedEn',
      type: IsarType.string,
    ),
    r'foldedEs': PropertySchema(
      id: 9,
      name: r'foldedEs',
      type: IsarType.string,
    ),
    r'foldedScientific': PropertySchema(
      id: 10,
      name: r'foldedScientific',
      type: IsarType.string,
    ),
    r'habitats': PropertySchema(
      id: 11,
      name: r'habitats',
      type: IsarType.stringList,
    ),
    r'hasListing': PropertySchema(
      id: 12,
      name: r'hasListing',
      type: IsarType.bool,
    ),
    r'nameEn': PropertySchema(id: 13, name: r'nameEn', type: IsarType.string),
    r'position': PropertySchema(id: 14, name: r'position', type: IsarType.long),
    r'primaryPhoto': PropertySchema(
      id: 15,
      name: r'primaryPhoto',
      type: IsarType.string,
    ),
    r'runId': PropertySchema(id: 16, name: r'runId', type: IsarType.long),
    r'scientificName': PropertySchema(
      id: 17,
      name: r'scientificName',
      type: IsarType.string,
    ),
    r'sizeMaxCm': PropertySchema(
      id: 18,
      name: r'sizeMaxCm',
      type: IsarType.double,
    ),
    r'sizeMinCm': PropertySchema(
      id: 19,
      name: r'sizeMinCm',
      type: IsarType.double,
    ),
    r'slug': PropertySchema(id: 20, name: r'slug', type: IsarType.string),
    r'speciesId': PropertySchema(
      id: 21,
      name: r'speciesId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 22,
      name: r'updatedAt',
      type: IsarType.string,
    ),
  },

  estimateSize: _catalogSpeciesCollectionEstimateSize,
  serialize: _catalogSpeciesCollectionSerialize,
  deserialize: _catalogSpeciesCollectionDeserialize,
  deserializeProp: _catalogSpeciesCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'slug': IndexSchema(
      id: 6169444064746062836,
      name: r'slug',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'slug',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _catalogSpeciesCollectionGetId,
  getLinks: _catalogSpeciesCollectionGetLinks,
  attach: _catalogSpeciesCollectionAttach,
  version: '3.4.1',
);

int _catalogSpeciesCollectionEstimateSize(
  CatalogSpeciesCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.behaviors.length * 3;
  {
    for (var i = 0; i < object.behaviors.length; i++) {
      final value = object.behaviors[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.commonName.length * 3;
  {
    final value = object.conservationStatus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dangerLevel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.foldedEn.length * 3;
  bytesCount += 3 + object.foldedEs.length * 3;
  bytesCount += 3 + object.foldedScientific.length * 3;
  bytesCount += 3 + object.habitats.length * 3;
  {
    for (var i = 0; i < object.habitats.length; i++) {
      final value = object.habitats[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.nameEn;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.primaryPhoto;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.scientificName.length * 3;
  bytesCount += 3 + object.slug.length * 3;
  bytesCount += 3 + object.speciesId.length * 3;
  {
    final value = object.updatedAt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _catalogSpeciesCollectionSerialize(
  CatalogSpeciesCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.behaviors);
  writer.writeString(offsets[1], object.category);
  writer.writeString(offsets[2], object.commonName);
  writer.writeString(offsets[3], object.conservationStatus);
  writer.writeString(offsets[4], object.dangerLevel);
  writer.writeDouble(offsets[5], object.depthMaxM);
  writer.writeDouble(offsets[6], object.depthMinM);
  writer.writeBool(offsets[7], object.featured);
  writer.writeString(offsets[8], object.foldedEn);
  writer.writeString(offsets[9], object.foldedEs);
  writer.writeString(offsets[10], object.foldedScientific);
  writer.writeStringList(offsets[11], object.habitats);
  writer.writeBool(offsets[12], object.hasListing);
  writer.writeString(offsets[13], object.nameEn);
  writer.writeLong(offsets[14], object.position);
  writer.writeString(offsets[15], object.primaryPhoto);
  writer.writeLong(offsets[16], object.runId);
  writer.writeString(offsets[17], object.scientificName);
  writer.writeDouble(offsets[18], object.sizeMaxCm);
  writer.writeDouble(offsets[19], object.sizeMinCm);
  writer.writeString(offsets[20], object.slug);
  writer.writeString(offsets[21], object.speciesId);
  writer.writeString(offsets[22], object.updatedAt);
}

CatalogSpeciesCollection _catalogSpeciesCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CatalogSpeciesCollection();
  object.behaviors = reader.readStringList(offsets[0]) ?? [];
  object.category = reader.readString(offsets[1]);
  object.commonName = reader.readString(offsets[2]);
  object.conservationStatus = reader.readStringOrNull(offsets[3]);
  object.dangerLevel = reader.readStringOrNull(offsets[4]);
  object.depthMaxM = reader.readDoubleOrNull(offsets[5]);
  object.depthMinM = reader.readDoubleOrNull(offsets[6]);
  object.featured = reader.readBool(offsets[7]);
  object.foldedEn = reader.readString(offsets[8]);
  object.foldedEs = reader.readString(offsets[9]);
  object.foldedScientific = reader.readString(offsets[10]);
  object.habitats = reader.readStringList(offsets[11]) ?? [];
  object.hasListing = reader.readBool(offsets[12]);
  object.id = id;
  object.nameEn = reader.readStringOrNull(offsets[13]);
  object.position = reader.readLong(offsets[14]);
  object.primaryPhoto = reader.readStringOrNull(offsets[15]);
  object.runId = reader.readLong(offsets[16]);
  object.scientificName = reader.readString(offsets[17]);
  object.sizeMaxCm = reader.readDoubleOrNull(offsets[18]);
  object.sizeMinCm = reader.readDoubleOrNull(offsets[19]);
  object.slug = reader.readString(offsets[20]);
  object.speciesId = reader.readString(offsets[21]);
  object.updatedAt = reader.readStringOrNull(offsets[22]);
  return object;
}

P _catalogSpeciesCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _catalogSpeciesCollectionGetId(CatalogSpeciesCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _catalogSpeciesCollectionGetLinks(
  CatalogSpeciesCollection object,
) {
  return [];
}

void _catalogSpeciesCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  CatalogSpeciesCollection object,
) {
  object.id = id;
}

extension CatalogSpeciesCollectionByIndex
    on IsarCollection<CatalogSpeciesCollection> {
  Future<CatalogSpeciesCollection?> getBySlug(String slug) {
    return getByIndex(r'slug', [slug]);
  }

  CatalogSpeciesCollection? getBySlugSync(String slug) {
    return getByIndexSync(r'slug', [slug]);
  }

  Future<bool> deleteBySlug(String slug) {
    return deleteByIndex(r'slug', [slug]);
  }

  bool deleteBySlugSync(String slug) {
    return deleteByIndexSync(r'slug', [slug]);
  }

  Future<List<CatalogSpeciesCollection?>> getAllBySlug(
    List<String> slugValues,
  ) {
    final values = slugValues.map((e) => [e]).toList();
    return getAllByIndex(r'slug', values);
  }

  List<CatalogSpeciesCollection?> getAllBySlugSync(List<String> slugValues) {
    final values = slugValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'slug', values);
  }

  Future<int> deleteAllBySlug(List<String> slugValues) {
    final values = slugValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'slug', values);
  }

  int deleteAllBySlugSync(List<String> slugValues) {
    final values = slugValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'slug', values);
  }

  Future<Id> putBySlug(CatalogSpeciesCollection object) {
    return putByIndex(r'slug', object);
  }

  Id putBySlugSync(CatalogSpeciesCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'slug', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySlug(List<CatalogSpeciesCollection> objects) {
    return putAllByIndex(r'slug', objects);
  }

  List<Id> putAllBySlugSync(
    List<CatalogSpeciesCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'slug', objects, saveLinks: saveLinks);
  }
}

extension CatalogSpeciesCollectionQueryWhereSort
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QWhere
        > {
  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CatalogSpeciesCollectionQueryWhere
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QWhereClause
        > {
  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterWhereClause
  >
  slugEqualTo(String slug) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'slug', value: [slug]),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterWhereClause
  >
  slugNotEqualTo(String slug) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'slug',
                lower: [],
                upper: [slug],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'slug',
                lower: [slug],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'slug',
                lower: [slug],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'slug',
                lower: [],
                upper: [slug],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension CatalogSpeciesCollectionQueryFilter
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QFilterCondition
        > {
  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'behaviors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'behaviors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'behaviors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'behaviors',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'behaviors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'behaviors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'behaviors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'behaviors',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'behaviors', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'behaviors', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'behaviors', length, true, length, true);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'behaviors', 0, true, 0, true);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'behaviors', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'behaviors', 0, true, length, include);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'behaviors', length, include, 999999, true);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  behaviorsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'behaviors',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'category',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'commonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'commonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'commonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'commonName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'commonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'commonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'commonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'commonName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'commonName', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  commonNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'commonName', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'conservationStatus'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'conservationStatus'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'conservationStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'conservationStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'conservationStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'conservationStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'conservationStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'conservationStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'conservationStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'conservationStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'conservationStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  conservationStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'conservationStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dangerLevel'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dangerLevel'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dangerLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dangerLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dangerLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dangerLevel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dangerLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dangerLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dangerLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dangerLevel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dangerLevel', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  dangerLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dangerLevel', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMaxMIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'depthMaxM'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMaxMIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'depthMaxM'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMaxMEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'depthMaxM',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMaxMGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'depthMaxM',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMaxMLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'depthMaxM',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMaxMBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'depthMaxM',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMinMIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'depthMinM'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMinMIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'depthMinM'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMinMEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'depthMinM',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMinMGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'depthMinM',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMinMLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'depthMinM',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  depthMinMBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'depthMinM',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  featuredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'featured', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'foldedEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'foldedEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'foldedEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'foldedEn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'foldedEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'foldedEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'foldedEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'foldedEn',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'foldedEn', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'foldedEn', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'foldedEs',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'foldedEs',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'foldedEs',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'foldedEs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'foldedEs',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'foldedEs',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'foldedEs',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'foldedEs',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'foldedEs', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedEsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'foldedEs', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'foldedScientific',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'foldedScientific',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'foldedScientific',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'foldedScientific',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'foldedScientific',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'foldedScientific',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'foldedScientific',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'foldedScientific',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'foldedScientific', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  foldedScientificIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'foldedScientific', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'habitats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'habitats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'habitats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'habitats',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'habitats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'habitats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'habitats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'habitats',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'habitats', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'habitats', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'habitats', length, true, length, true);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'habitats', 0, true, 0, true);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'habitats', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'habitats', 0, true, length, include);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'habitats', length, include, 999999, true);
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  habitatsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'habitats',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  hasListingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasListing', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'nameEn'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'nameEn'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nameEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameEn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nameEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nameEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nameEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nameEn',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameEn', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  nameEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameEn', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'position', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  positionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  positionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'position',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'primaryPhoto'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'primaryPhoto'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'primaryPhoto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'primaryPhoto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'primaryPhoto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'primaryPhoto',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'primaryPhoto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'primaryPhoto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'primaryPhoto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'primaryPhoto',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'primaryPhoto', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  primaryPhotoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'primaryPhoto', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  runIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'runId', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  runIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'runId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  runIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'runId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  runIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'runId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'scientificName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'scientificName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'scientificName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'scientificName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'scientificName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'scientificName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'scientificName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'scientificName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'scientificName', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  scientificNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'scientificName', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMaxCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sizeMaxCm'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMaxCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sizeMaxCm'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMaxCmEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sizeMaxCm',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMaxCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sizeMaxCm',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMaxCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sizeMaxCm',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMaxCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sizeMaxCm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMinCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sizeMinCm'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMinCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sizeMinCm'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMinCmEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sizeMinCm',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMinCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sizeMinCm',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMinCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sizeMinCm',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  sizeMinCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sizeMinCm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'slug',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'slug',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'slug',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'slug',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'slug',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'slug',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'slug',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'slug',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'slug', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  slugIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'slug', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'speciesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'speciesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'speciesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'speciesId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'speciesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'speciesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'speciesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'speciesId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'speciesId', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'speciesId', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'updatedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'updatedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'updatedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'updatedAt',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'updatedAt',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: ''),
      );
    });
  }

  QueryBuilder<
    CatalogSpeciesCollection,
    CatalogSpeciesCollection,
    QAfterFilterCondition
  >
  updatedAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'updatedAt', value: ''),
      );
    });
  }
}

extension CatalogSpeciesCollectionQueryObject
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QFilterCondition
        > {}

extension CatalogSpeciesCollectionQueryLinks
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QFilterCondition
        > {}

extension CatalogSpeciesCollectionQuerySortBy
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QSortBy
        > {
  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByCommonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonName', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByCommonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonName', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByConservationStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conservationStatus', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByConservationStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conservationStatus', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByDangerLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dangerLevel', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByDangerLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dangerLevel', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByDepthMaxM() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depthMaxM', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByDepthMaxMDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depthMaxM', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByDepthMinM() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depthMinM', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByDepthMinMDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depthMinM', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByFeatured() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featured', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByFeaturedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featured', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByFoldedEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedEn', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByFoldedEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedEn', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByFoldedEs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedEs', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByFoldedEsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedEs', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByFoldedScientific() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedScientific', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByFoldedScientificDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedScientific', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByHasListing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasListing', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByHasListingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasListing', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByPrimaryPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPhoto', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByPrimaryPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPhoto', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByRunIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByScientificName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByScientificNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortBySizeMaxCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeMaxCm', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortBySizeMaxCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeMaxCm', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortBySizeMinCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeMinCm', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortBySizeMinCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeMinCm', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortBySpeciesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortBySpeciesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CatalogSpeciesCollectionQuerySortThenBy
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QSortThenBy
        > {
  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByCommonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonName', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByCommonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonName', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByConservationStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conservationStatus', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByConservationStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conservationStatus', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByDangerLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dangerLevel', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByDangerLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dangerLevel', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByDepthMaxM() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depthMaxM', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByDepthMaxMDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depthMaxM', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByDepthMinM() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depthMinM', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByDepthMinMDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depthMinM', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByFeatured() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featured', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByFeaturedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featured', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByFoldedEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedEn', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByFoldedEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedEn', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByFoldedEs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedEs', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByFoldedEsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedEs', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByFoldedScientific() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedScientific', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByFoldedScientificDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foldedScientific', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByHasListing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasListing', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByHasListingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasListing', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEn', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByPrimaryPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPhoto', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByPrimaryPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPhoto', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByRunIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByScientificName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByScientificNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenBySizeMaxCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeMaxCm', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenBySizeMaxCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeMaxCm', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenBySizeMinCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeMinCm', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenBySizeMinCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeMinCm', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenBySpeciesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenBySpeciesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.desc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CatalogSpeciesCollectionQueryWhereDistinct
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QDistinct
        > {
  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByBehaviors() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'behaviors');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByCommonName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commonName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByConservationStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'conservationStatus',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByDangerLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dangerLevel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByDepthMaxM() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'depthMaxM');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByDepthMinM() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'depthMinM');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByFeatured() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'featured');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByFoldedEn({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foldedEn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByFoldedEs({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foldedEs', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByFoldedScientific({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'foldedScientific',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByHabitats() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitats');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByHasListing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasListing');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByNameEn({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameEn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByPrimaryPhoto({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryPhoto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'runId');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByScientificName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'scientificName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctBySizeMaxCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sizeMaxCm');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctBySizeMinCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sizeMinCm');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctBySlug({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slug', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctBySpeciesId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speciesId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CatalogSpeciesCollection, CatalogSpeciesCollection, QDistinct>
  distinctByUpdatedAt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt', caseSensitive: caseSensitive);
    });
  }
}

extension CatalogSpeciesCollectionQueryProperty
    on
        QueryBuilder<
          CatalogSpeciesCollection,
          CatalogSpeciesCollection,
          QQueryProperty
        > {
  QueryBuilder<CatalogSpeciesCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, List<String>, QQueryOperations>
  behaviorsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'behaviors');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String, QQueryOperations>
  categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String, QQueryOperations>
  commonNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commonName');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String?, QQueryOperations>
  conservationStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conservationStatus');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String?, QQueryOperations>
  dangerLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dangerLevel');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, double?, QQueryOperations>
  depthMaxMProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'depthMaxM');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, double?, QQueryOperations>
  depthMinMProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'depthMinM');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, bool, QQueryOperations>
  featuredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'featured');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String, QQueryOperations>
  foldedEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foldedEn');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String, QQueryOperations>
  foldedEsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foldedEs');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String, QQueryOperations>
  foldedScientificProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foldedScientific');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, List<String>, QQueryOperations>
  habitatsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitats');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, bool, QQueryOperations>
  hasListingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasListing');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String?, QQueryOperations>
  nameEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameEn');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, int, QQueryOperations>
  positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String?, QQueryOperations>
  primaryPhotoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryPhoto');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, int, QQueryOperations>
  runIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'runId');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String, QQueryOperations>
  scientificNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scientificName');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, double?, QQueryOperations>
  sizeMaxCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sizeMaxCm');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, double?, QQueryOperations>
  sizeMinCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sizeMinCm');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String, QQueryOperations>
  slugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slug');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String, QQueryOperations>
  speciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speciesId');
    });
  }

  QueryBuilder<CatalogSpeciesCollection, String?, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetCatalogSyncCollectionCollection on Isar {
  IsarCollection<CatalogSyncCollection> get catalogSyncCollections =>
      this.collection();
}

const CatalogSyncCollectionSchema = CollectionSchema(
  name: r'CatalogSyncCollection',
  id: 2357498628714451621,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'nextPage': PropertySchema(id: 1, name: r'nextPage', type: IsarType.long),
    r'runId': PropertySchema(id: 2, name: r'runId', type: IsarType.long),
    r'totalPages': PropertySchema(
      id: 3,
      name: r'totalPages',
      type: IsarType.long,
    ),
  },

  estimateSize: _catalogSyncCollectionEstimateSize,
  serialize: _catalogSyncCollectionSerialize,
  deserialize: _catalogSyncCollectionDeserialize,
  deserializeProp: _catalogSyncCollectionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _catalogSyncCollectionGetId,
  getLinks: _catalogSyncCollectionGetLinks,
  attach: _catalogSyncCollectionAttach,
  version: '3.4.1',
);

int _catalogSyncCollectionEstimateSize(
  CatalogSyncCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _catalogSyncCollectionSerialize(
  CatalogSyncCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeLong(offsets[1], object.nextPage);
  writer.writeLong(offsets[2], object.runId);
  writer.writeLong(offsets[3], object.totalPages);
}

CatalogSyncCollection _catalogSyncCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CatalogSyncCollection();
  object.completedAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.nextPage = reader.readLong(offsets[1]);
  object.runId = reader.readLong(offsets[2]);
  object.totalPages = reader.readLong(offsets[3]);
  return object;
}

P _catalogSyncCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _catalogSyncCollectionGetId(CatalogSyncCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _catalogSyncCollectionGetLinks(
  CatalogSyncCollection object,
) {
  return [];
}

void _catalogSyncCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  CatalogSyncCollection object,
) {
  object.id = id;
}

extension CatalogSyncCollectionQueryWhereSort
    on QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QWhere> {
  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CatalogSyncCollectionQueryWhere
    on
        QueryBuilder<
          CatalogSyncCollection,
          CatalogSyncCollection,
          QWhereClause
        > {
  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CatalogSyncCollectionQueryFilter
    on
        QueryBuilder<
          CatalogSyncCollection,
          CatalogSyncCollection,
          QFilterCondition
        > {
  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  completedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  completedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  nextPageEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nextPage', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  nextPageGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nextPage',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  nextPageLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nextPage',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  nextPageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nextPage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  runIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'runId', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  runIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'runId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  runIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'runId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  runIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'runId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  totalPagesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalPages', value: value),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  totalPagesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalPages',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  totalPagesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalPages',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CatalogSyncCollection,
    CatalogSyncCollection,
    QAfterFilterCondition
  >
  totalPagesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalPages',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CatalogSyncCollectionQueryObject
    on
        QueryBuilder<
          CatalogSyncCollection,
          CatalogSyncCollection,
          QFilterCondition
        > {}

extension CatalogSyncCollectionQueryLinks
    on
        QueryBuilder<
          CatalogSyncCollection,
          CatalogSyncCollection,
          QFilterCondition
        > {}

extension CatalogSyncCollectionQuerySortBy
    on QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QSortBy> {
  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  sortByNextPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPage', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  sortByNextPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPage', Sort.desc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  sortByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  sortByRunIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.desc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  sortByTotalPages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPages', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  sortByTotalPagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPages', Sort.desc);
    });
  }
}

extension CatalogSyncCollectionQuerySortThenBy
    on QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QSortThenBy> {
  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByNextPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPage', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByNextPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPage', Sort.desc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByRunIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runId', Sort.desc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByTotalPages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPages', Sort.asc);
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QAfterSortBy>
  thenByTotalPagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPages', Sort.desc);
    });
  }
}

extension CatalogSyncCollectionQueryWhereDistinct
    on QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QDistinct> {
  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QDistinct>
  distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QDistinct>
  distinctByNextPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextPage');
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QDistinct>
  distinctByRunId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'runId');
    });
  }

  QueryBuilder<CatalogSyncCollection, CatalogSyncCollection, QDistinct>
  distinctByTotalPages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPages');
    });
  }
}

extension CatalogSyncCollectionQueryProperty
    on
        QueryBuilder<
          CatalogSyncCollection,
          CatalogSyncCollection,
          QQueryProperty
        > {
  QueryBuilder<CatalogSyncCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CatalogSyncCollection, DateTime?, QQueryOperations>
  completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<CatalogSyncCollection, int, QQueryOperations>
  nextPageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextPage');
    });
  }

  QueryBuilder<CatalogSyncCollection, int, QQueryOperations> runIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'runId');
    });
  }

  QueryBuilder<CatalogSyncCollection, int, QQueryOperations>
  totalPagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPages');
    });
  }
}

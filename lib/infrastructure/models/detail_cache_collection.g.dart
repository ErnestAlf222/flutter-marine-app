// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_cache_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetDetailCacheCollectionCollection on Isar {
  IsarCollection<DetailCacheCollection> get detailCacheCollections =>
      this.collection();
}

const DetailCacheCollectionSchema = CollectionSchema(
  name: r'DetailCacheCollection',
  id: 1103247618552795054,
  properties: {
    r'json': PropertySchema(id: 0, name: r'json', type: IsarType.string),
    r'slug': PropertySchema(id: 1, name: r'slug', type: IsarType.string),
    r'viewedAt': PropertySchema(
      id: 2,
      name: r'viewedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _detailCacheCollectionEstimateSize,
  serialize: _detailCacheCollectionSerialize,
  deserialize: _detailCacheCollectionDeserialize,
  deserializeProp: _detailCacheCollectionDeserializeProp,
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
    r'viewedAt': IndexSchema(
      id: 1541624929386044767,
      name: r'viewedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'viewedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _detailCacheCollectionGetId,
  getLinks: _detailCacheCollectionGetLinks,
  attach: _detailCacheCollectionAttach,
  version: '3.4.1',
);

int _detailCacheCollectionEstimateSize(
  DetailCacheCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.json.length * 3;
  bytesCount += 3 + object.slug.length * 3;
  return bytesCount;
}

void _detailCacheCollectionSerialize(
  DetailCacheCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.json);
  writer.writeString(offsets[1], object.slug);
  writer.writeDateTime(offsets[2], object.viewedAt);
}

DetailCacheCollection _detailCacheCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DetailCacheCollection();
  object.id = id;
  object.json = reader.readString(offsets[0]);
  object.slug = reader.readString(offsets[1]);
  object.viewedAt = reader.readDateTime(offsets[2]);
  return object;
}

P _detailCacheCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _detailCacheCollectionGetId(DetailCacheCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _detailCacheCollectionGetLinks(
  DetailCacheCollection object,
) {
  return [];
}

void _detailCacheCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  DetailCacheCollection object,
) {
  object.id = id;
}

extension DetailCacheCollectionByIndex
    on IsarCollection<DetailCacheCollection> {
  Future<DetailCacheCollection?> getBySlug(String slug) {
    return getByIndex(r'slug', [slug]);
  }

  DetailCacheCollection? getBySlugSync(String slug) {
    return getByIndexSync(r'slug', [slug]);
  }

  Future<bool> deleteBySlug(String slug) {
    return deleteByIndex(r'slug', [slug]);
  }

  bool deleteBySlugSync(String slug) {
    return deleteByIndexSync(r'slug', [slug]);
  }

  Future<List<DetailCacheCollection?>> getAllBySlug(List<String> slugValues) {
    final values = slugValues.map((e) => [e]).toList();
    return getAllByIndex(r'slug', values);
  }

  List<DetailCacheCollection?> getAllBySlugSync(List<String> slugValues) {
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

  Future<Id> putBySlug(DetailCacheCollection object) {
    return putByIndex(r'slug', object);
  }

  Id putBySlugSync(DetailCacheCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'slug', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySlug(List<DetailCacheCollection> objects) {
    return putAllByIndex(r'slug', objects);
  }

  List<Id> putAllBySlugSync(
    List<DetailCacheCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'slug', objects, saveLinks: saveLinks);
  }
}

extension DetailCacheCollectionQueryWhereSort
    on QueryBuilder<DetailCacheCollection, DetailCacheCollection, QWhere> {
  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhere>
  anyViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'viewedAt'),
      );
    });
  }
}

extension DetailCacheCollectionQueryWhere
    on
        QueryBuilder<
          DetailCacheCollection,
          DetailCacheCollection,
          QWhereClause
        > {
  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
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

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
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

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  slugEqualTo(String slug) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'slug', value: [slug]),
      );
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
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

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  viewedAtEqualTo(DateTime viewedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'viewedAt', value: [viewedAt]),
      );
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  viewedAtNotEqualTo(DateTime viewedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'viewedAt',
                lower: [],
                upper: [viewedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'viewedAt',
                lower: [viewedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'viewedAt',
                lower: [viewedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'viewedAt',
                lower: [],
                upper: [viewedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  viewedAtGreaterThan(DateTime viewedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'viewedAt',
          lower: [viewedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  viewedAtLessThan(DateTime viewedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'viewedAt',
          lower: [],
          upper: [viewedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterWhereClause>
  viewedAtBetween(
    DateTime lowerViewedAt,
    DateTime upperViewedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'viewedAt',
          lower: [lowerViewedAt],
          includeLower: includeLower,
          upper: [upperViewedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DetailCacheCollectionQueryFilter
    on
        QueryBuilder<
          DetailCacheCollection,
          DetailCacheCollection,
          QFilterCondition
        > {
  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'json',
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
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'json',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'json', value: ''),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  jsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'json', value: ''),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
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
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  viewedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'viewedAt', value: value),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  viewedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'viewedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  viewedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'viewedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    DetailCacheCollection,
    DetailCacheCollection,
    QAfterFilterCondition
  >
  viewedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'viewedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DetailCacheCollectionQueryObject
    on
        QueryBuilder<
          DetailCacheCollection,
          DetailCacheCollection,
          QFilterCondition
        > {}

extension DetailCacheCollectionQueryLinks
    on
        QueryBuilder<
          DetailCacheCollection,
          DetailCacheCollection,
          QFilterCondition
        > {}

extension DetailCacheCollectionQuerySortBy
    on QueryBuilder<DetailCacheCollection, DetailCacheCollection, QSortBy> {
  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  sortByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  sortByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  sortBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  sortBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  sortByViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewedAt', Sort.asc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  sortByViewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewedAt', Sort.desc);
    });
  }
}

extension DetailCacheCollectionQuerySortThenBy
    on QueryBuilder<DetailCacheCollection, DetailCacheCollection, QSortThenBy> {
  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  thenByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  thenByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  thenBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  thenBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  thenByViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewedAt', Sort.asc);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QAfterSortBy>
  thenByViewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewedAt', Sort.desc);
    });
  }
}

extension DetailCacheCollectionQueryWhereDistinct
    on QueryBuilder<DetailCacheCollection, DetailCacheCollection, QDistinct> {
  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QDistinct>
  distinctByJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'json', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QDistinct>
  distinctBySlug({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slug', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailCacheCollection, DetailCacheCollection, QDistinct>
  distinctByViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewedAt');
    });
  }
}

extension DetailCacheCollectionQueryProperty
    on
        QueryBuilder<
          DetailCacheCollection,
          DetailCacheCollection,
          QQueryProperty
        > {
  QueryBuilder<DetailCacheCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DetailCacheCollection, String, QQueryOperations> jsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'json');
    });
  }

  QueryBuilder<DetailCacheCollection, String, QQueryOperations> slugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slug');
    });
  }

  QueryBuilder<DetailCacheCollection, DateTime, QQueryOperations>
  viewedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetJsonCacheCollectionCollection on Isar {
  IsarCollection<JsonCacheCollection> get jsonCacheCollections =>
      this.collection();
}

const JsonCacheCollectionSchema = CollectionSchema(
  name: r'JsonCacheCollection',
  id: 81315161284662547,
  properties: {
    r'json': PropertySchema(id: 0, name: r'json', type: IsarType.string),
    r'key': PropertySchema(id: 1, name: r'key', type: IsarType.string),
    r'savedAt': PropertySchema(
      id: 2,
      name: r'savedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _jsonCacheCollectionEstimateSize,
  serialize: _jsonCacheCollectionSerialize,
  deserialize: _jsonCacheCollectionDeserialize,
  deserializeProp: _jsonCacheCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _jsonCacheCollectionGetId,
  getLinks: _jsonCacheCollectionGetLinks,
  attach: _jsonCacheCollectionAttach,
  version: '3.4.1',
);

int _jsonCacheCollectionEstimateSize(
  JsonCacheCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.json.length * 3;
  bytesCount += 3 + object.key.length * 3;
  return bytesCount;
}

void _jsonCacheCollectionSerialize(
  JsonCacheCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.json);
  writer.writeString(offsets[1], object.key);
  writer.writeDateTime(offsets[2], object.savedAt);
}

JsonCacheCollection _jsonCacheCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = JsonCacheCollection();
  object.id = id;
  object.json = reader.readString(offsets[0]);
  object.key = reader.readString(offsets[1]);
  object.savedAt = reader.readDateTime(offsets[2]);
  return object;
}

P _jsonCacheCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _jsonCacheCollectionGetId(JsonCacheCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _jsonCacheCollectionGetLinks(
  JsonCacheCollection object,
) {
  return [];
}

void _jsonCacheCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  JsonCacheCollection object,
) {
  object.id = id;
}

extension JsonCacheCollectionByIndex on IsarCollection<JsonCacheCollection> {
  Future<JsonCacheCollection?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  JsonCacheCollection? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<JsonCacheCollection?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<JsonCacheCollection?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(JsonCacheCollection object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(JsonCacheCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<JsonCacheCollection> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<JsonCacheCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension JsonCacheCollectionQueryWhereSort
    on QueryBuilder<JsonCacheCollection, JsonCacheCollection, QWhere> {
  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension JsonCacheCollectionQueryWhere
    on QueryBuilder<JsonCacheCollection, JsonCacheCollection, QWhereClause> {
  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterWhereClause>
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

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterWhereClause>
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

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterWhereClause>
  keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterWhereClause>
  keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension JsonCacheCollectionQueryFilter
    on
        QueryBuilder<
          JsonCacheCollection,
          JsonCacheCollection,
          QFilterCondition
        > {
  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
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

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
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

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
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

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'json',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'json',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'json', value: ''),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  jsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'json', value: ''),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  savedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'savedAt', value: value),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  savedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'savedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  savedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'savedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterFilterCondition>
  savedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'savedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension JsonCacheCollectionQueryObject
    on
        QueryBuilder<
          JsonCacheCollection,
          JsonCacheCollection,
          QFilterCondition
        > {}

extension JsonCacheCollectionQueryLinks
    on
        QueryBuilder<
          JsonCacheCollection,
          JsonCacheCollection,
          QFilterCondition
        > {}

extension JsonCacheCollectionQuerySortBy
    on QueryBuilder<JsonCacheCollection, JsonCacheCollection, QSortBy> {
  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  sortByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  sortByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  sortBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  sortBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }
}

extension JsonCacheCollectionQuerySortThenBy
    on QueryBuilder<JsonCacheCollection, JsonCacheCollection, QSortThenBy> {
  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  thenByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  thenByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  thenBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QAfterSortBy>
  thenBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }
}

extension JsonCacheCollectionQueryWhereDistinct
    on QueryBuilder<JsonCacheCollection, JsonCacheCollection, QDistinct> {
  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QDistinct>
  distinctByJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'json', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QDistinct>
  distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JsonCacheCollection, JsonCacheCollection, QDistinct>
  distinctBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAt');
    });
  }
}

extension JsonCacheCollectionQueryProperty
    on QueryBuilder<JsonCacheCollection, JsonCacheCollection, QQueryProperty> {
  QueryBuilder<JsonCacheCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<JsonCacheCollection, String, QQueryOperations> jsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'json');
    });
  }

  QueryBuilder<JsonCacheCollection, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<JsonCacheCollection, DateTime, QQueryOperations>
  savedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAt');
    });
  }
}

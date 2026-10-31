// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_species_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetFavoriteSpeciesCollectionCollection on Isar {
  IsarCollection<FavoriteSpeciesCollection> get favoriteSpeciesCollections =>
      this.collection();
}

const FavoriteSpeciesCollectionSchema = CollectionSchema(
  name: r'FavoriteSpeciesCollection',
  id: 334317656153470032,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'commonName': PropertySchema(
      id: 1,
      name: r'commonName',
      type: IsarType.string,
    ),
    r'conservationStatus': PropertySchema(
      id: 2,
      name: r'conservationStatus',
      type: IsarType.string,
    ),
    r'primaryPhoto': PropertySchema(
      id: 3,
      name: r'primaryPhoto',
      type: IsarType.string,
    ),
    r'savedAt': PropertySchema(
      id: 4,
      name: r'savedAt',
      type: IsarType.dateTime,
    ),
    r'scientificName': PropertySchema(
      id: 5,
      name: r'scientificName',
      type: IsarType.string,
    ),
    r'slug': PropertySchema(id: 6, name: r'slug', type: IsarType.string),
    r'speciesId': PropertySchema(
      id: 7,
      name: r'speciesId',
      type: IsarType.string,
    ),
  },

  estimateSize: _favoriteSpeciesCollectionEstimateSize,
  serialize: _favoriteSpeciesCollectionSerialize,
  deserialize: _favoriteSpeciesCollectionDeserialize,
  deserializeProp: _favoriteSpeciesCollectionDeserializeProp,
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

  getId: _favoriteSpeciesCollectionGetId,
  getLinks: _favoriteSpeciesCollectionGetLinks,
  attach: _favoriteSpeciesCollectionAttach,
  version: '3.4.1',
);

int _favoriteSpeciesCollectionEstimateSize(
  FavoriteSpeciesCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.commonName.length * 3;
  {
    final value = object.conservationStatus;
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
  return bytesCount;
}

void _favoriteSpeciesCollectionSerialize(
  FavoriteSpeciesCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeString(offsets[1], object.commonName);
  writer.writeString(offsets[2], object.conservationStatus);
  writer.writeString(offsets[3], object.primaryPhoto);
  writer.writeDateTime(offsets[4], object.savedAt);
  writer.writeString(offsets[5], object.scientificName);
  writer.writeString(offsets[6], object.slug);
  writer.writeString(offsets[7], object.speciesId);
}

FavoriteSpeciesCollection _favoriteSpeciesCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FavoriteSpeciesCollection();
  object.category = reader.readString(offsets[0]);
  object.commonName = reader.readString(offsets[1]);
  object.conservationStatus = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.primaryPhoto = reader.readStringOrNull(offsets[3]);
  object.savedAt = reader.readDateTime(offsets[4]);
  object.scientificName = reader.readString(offsets[5]);
  object.slug = reader.readString(offsets[6]);
  object.speciesId = reader.readString(offsets[7]);
  return object;
}

P _favoriteSpeciesCollectionDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _favoriteSpeciesCollectionGetId(FavoriteSpeciesCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _favoriteSpeciesCollectionGetLinks(
  FavoriteSpeciesCollection object,
) {
  return [];
}

void _favoriteSpeciesCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  FavoriteSpeciesCollection object,
) {
  object.id = id;
}

extension FavoriteSpeciesCollectionByIndex
    on IsarCollection<FavoriteSpeciesCollection> {
  Future<FavoriteSpeciesCollection?> getBySlug(String slug) {
    return getByIndex(r'slug', [slug]);
  }

  FavoriteSpeciesCollection? getBySlugSync(String slug) {
    return getByIndexSync(r'slug', [slug]);
  }

  Future<bool> deleteBySlug(String slug) {
    return deleteByIndex(r'slug', [slug]);
  }

  bool deleteBySlugSync(String slug) {
    return deleteByIndexSync(r'slug', [slug]);
  }

  Future<List<FavoriteSpeciesCollection?>> getAllBySlug(
    List<String> slugValues,
  ) {
    final values = slugValues.map((e) => [e]).toList();
    return getAllByIndex(r'slug', values);
  }

  List<FavoriteSpeciesCollection?> getAllBySlugSync(List<String> slugValues) {
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

  Future<Id> putBySlug(FavoriteSpeciesCollection object) {
    return putByIndex(r'slug', object);
  }

  Id putBySlugSync(FavoriteSpeciesCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'slug', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySlug(List<FavoriteSpeciesCollection> objects) {
    return putAllByIndex(r'slug', objects);
  }

  List<Id> putAllBySlugSync(
    List<FavoriteSpeciesCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'slug', objects, saveLinks: saveLinks);
  }
}

extension FavoriteSpeciesCollectionQueryWhereSort
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QWhere
        > {
  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FavoriteSpeciesCollectionQueryWhere
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QWhereClause
        > {
  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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

extension FavoriteSpeciesCollectionQueryFilter
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QFilterCondition
        > {
  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterFilterCondition
  >
  savedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'savedAt', value: value),
      );
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
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
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterFilterCondition
  >
  speciesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'speciesId', value: ''),
      );
    });
  }
}

extension FavoriteSpeciesCollectionQueryObject
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QFilterCondition
        > {}

extension FavoriteSpeciesCollectionQueryLinks
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QFilterCondition
        > {}

extension FavoriteSpeciesCollectionQuerySortBy
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QSortBy
        > {
  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByCommonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonName', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByCommonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonName', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByConservationStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conservationStatus', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByConservationStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conservationStatus', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByPrimaryPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPhoto', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByPrimaryPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPhoto', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByScientificName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortByScientificNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortBySpeciesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  sortBySpeciesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.desc);
    });
  }
}

extension FavoriteSpeciesCollectionQuerySortThenBy
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QSortThenBy
        > {
  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByCommonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonName', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByCommonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonName', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByConservationStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conservationStatus', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByConservationStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conservationStatus', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByPrimaryPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPhoto', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByPrimaryPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryPhoto', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByScientificName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenByScientificNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenBySpeciesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.asc);
    });
  }

  QueryBuilder<
    FavoriteSpeciesCollection,
    FavoriteSpeciesCollection,
    QAfterSortBy
  >
  thenBySpeciesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.desc);
    });
  }
}

extension FavoriteSpeciesCollectionQueryWhereDistinct
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QDistinct
        > {
  QueryBuilder<FavoriteSpeciesCollection, FavoriteSpeciesCollection, QDistinct>
  distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, FavoriteSpeciesCollection, QDistinct>
  distinctByCommonName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commonName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, FavoriteSpeciesCollection, QDistinct>
  distinctByConservationStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'conservationStatus',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, FavoriteSpeciesCollection, QDistinct>
  distinctByPrimaryPhoto({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryPhoto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, FavoriteSpeciesCollection, QDistinct>
  distinctBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAt');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, FavoriteSpeciesCollection, QDistinct>
  distinctByScientificName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'scientificName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, FavoriteSpeciesCollection, QDistinct>
  distinctBySlug({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slug', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, FavoriteSpeciesCollection, QDistinct>
  distinctBySpeciesId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speciesId', caseSensitive: caseSensitive);
    });
  }
}

extension FavoriteSpeciesCollectionQueryProperty
    on
        QueryBuilder<
          FavoriteSpeciesCollection,
          FavoriteSpeciesCollection,
          QQueryProperty
        > {
  QueryBuilder<FavoriteSpeciesCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, String, QQueryOperations>
  categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, String, QQueryOperations>
  commonNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commonName');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, String?, QQueryOperations>
  conservationStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conservationStatus');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, String?, QQueryOperations>
  primaryPhotoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryPhoto');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, DateTime, QQueryOperations>
  savedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAt');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, String, QQueryOperations>
  scientificNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scientificName');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, String, QQueryOperations>
  slugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slug');
    });
  }

  QueryBuilder<FavoriteSpeciesCollection, String, QQueryOperations>
  speciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speciesId');
    });
  }
}

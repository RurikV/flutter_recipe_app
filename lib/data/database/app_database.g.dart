// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:typed_data';
import 'package:drift/drift.dart';

part of 'app_database.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);

  @override
  final String actualTableName = 'recipes';

  @override
  VerificationMeta get uuidMeta => const VerificationMeta('uuid');
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get nameMeta => const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get imagesMeta => const VerificationMeta('images');
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
      'images', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get descriptionMeta => const VerificationMeta('description');
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get instructionsMeta => const VerificationMeta('instructions');
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get difficultyMeta => const VerificationMeta('difficulty');
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true);

  @override
  VerificationMeta get durationMeta => const VerificationMeta('duration');
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
      'duration', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get ratingMeta => const VerificationMeta('rating');
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true);

  @override
  VerificationMeta get isFavoriteMeta => const VerificationMeta('isFavorite');
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));

  @override
  List<GeneratedColumn<Object>> get $columns => [
        uuid,
        name,
        images,
        description,
        instructions,
        difficulty,
        duration,
        rating,
        isFavorite
      ];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  Set<GeneratedColumn<Object>> get $primaryKey => {uuid};

  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      images: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      instructions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructions'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}duration'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String uuid;
  final String name;
  final String images;
  final String description;
  final String instructions;
  final int difficulty;
  final String duration;
  final int rating;
  final bool isFavorite;
  const Recipe(
      {required this.uuid,
      required this.name,
      required this.images,
      required this.description,
      required this.instructions,
      required this.difficulty,
      required this.duration,
      required this.rating,
      required this.isFavorite});

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['images'] = Variable<String>(images);
    map['description'] = Variable<String>(description);
    map['instructions'] = Variable<String>(instructions);
    map['difficulty'] = Variable<int>(difficulty);
    map['duration'] = Variable<String>(duration);
    map['rating'] = Variable<int>(rating);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'images': serializer.toJson<String>(images),
      'description': serializer.toJson<String>(description),
      'instructions': serializer.toJson<String>(instructions),
      'difficulty': serializer.toJson<int>(difficulty),
      'duration': serializer.toJson<String>(duration),
      'rating': serializer.toJson<int>(rating),
      'is_favorite': serializer.toJson<bool>(isFavorite),
    };
  }
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> images;
  final Value<String> description;
  final Value<String> instructions;
  final Value<int> difficulty;
  final Value<String> duration;
  final Value<int> rating;
  final Value<bool> isFavorite;

  const RecipesCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.images = const Value.absent(),
    this.description = const Value.absent(),
    this.instructions = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.duration = const Value.absent(),
    this.rating = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });

  RecipesCompanion.insert({
    required String uuid,
    required String name,
    required String images,
    required String description,
    required String instructions,
    required int difficulty,
    required String duration,
    required int rating,
    this.isFavorite = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        images = Value(images),
        description = Value(description),
        instructions = Value(instructions),
        difficulty = Value(difficulty),
        duration = Value(duration),
        rating = Value(rating);

  static Insertable<Recipe> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? images,
    Expression<String>? description,
    Expression<String>? instructions,
    Expression<int>? difficulty,
    Expression<String>? duration,
    Expression<int>? rating,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (images != null) 'images': images,
      if (description != null) 'description': description,
      if (instructions != null) 'instructions': instructions,
      if (difficulty != null) 'difficulty': difficulty,
      if (duration != null) 'duration': duration,
      if (rating != null) 'rating': rating,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);

  @override
  final String actualTableName = 'photos';

  @override
  VerificationMeta get idMeta => const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: (GenerationContext context) => 'PRIMARY KEY AUTOINCREMENT');

  @override
  VerificationMeta get recipeUuidMeta => const VerificationMeta('recipeUuid');
  late final GeneratedColumn<String> recipeUuid = GeneratedColumn<String>(
      'recipe_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get photoNameMeta => const VerificationMeta('photoName');
  late final GeneratedColumn<String> photoName = GeneratedColumn<String>(
      'photo_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get detectedInfoMeta => const VerificationMeta('detectedInfo');
  late final GeneratedColumn<String> detectedInfo = GeneratedColumn<String>(
      'detected_info', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get pictMeta => const VerificationMeta('pict');
  late final GeneratedColumn<Uint8List> pict = GeneratedColumn<Uint8List>(
      'pict', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true);

  @override
  List<GeneratedColumn<Object>> get $columns => [
        id,
        recipeUuid,
        photoName,
        detectedInfo,
        pict
      ];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  Set<GeneratedColumn<Object>> get $primaryKey => {id};

  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recipeUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_uuid'])!,
      photoName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_name'])!,
      detectedInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detected_info'])!,
      pict: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}pict'])!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final int id;
  final String recipeUuid;
  final String photoName;
  final String detectedInfo;
  final Uint8List pict;
  const Photo(
      {required this.id,
      required this.recipeUuid,
      required this.photoName,
      required this.detectedInfo,
      required this.pict});

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_uuid'] = Variable<String>(recipeUuid);
    map['photo_name'] = Variable<String>(photoName);
    map['detected_info'] = Variable<String>(detectedInfo);
    map['pict'] = Variable<Uint8List>(pict);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipe_uuid': serializer.toJson<String>(recipeUuid),
      'photo_name': serializer.toJson<String>(photoName),
      'detected_info': serializer.toJson<String>(detectedInfo),
      'pict': serializer.toJson<Uint8List>(pict),
    };
  }
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<int> id;
  final Value<String> recipeUuid;
  final Value<String> photoName;
  final Value<String> detectedInfo;
  final Value<Uint8List> pict;

  const PhotosCompanion({
    this.id = const Value.absent(),
    this.recipeUuid = const Value.absent(),
    this.photoName = const Value.absent(),
    this.detectedInfo = const Value.absent(),
    this.pict = const Value.absent(),
  });

  PhotosCompanion.insert({
    this.id = const Value.absent(),
    required String recipeUuid,
    required String photoName,
    required String detectedInfo,
    required Uint8List pict,
  })  : recipeUuid = Value(recipeUuid),
        photoName = Value(photoName),
        detectedInfo = Value(detectedInfo),
        pict = Value(pict);

  static Insertable<Photo> custom({
    Expression<int>? id,
    Expression<String>? recipeUuid,
    Expression<String>? photoName,
    Expression<String>? detectedInfo,
    Expression<Uint8List>? pict,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeUuid != null) 'recipe_uuid': recipeUuid,
      if (photoName != null) 'photo_name': photoName,
      if (detectedInfo != null) 'detected_info': detectedInfo,
      if (pict != null) 'pict': pict,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeUuid.present) {
      map['recipe_uuid'] = Variable<String>(recipeUuid.value);
    }
    if (photoName.present) {
      map['photo_name'] = Variable<String>(photoName.value);
    }
    if (detectedInfo.present) {
      map['detected_info'] = Variable<String>(detectedInfo.value);
    }
    if (pict.present) {
      map['pict'] = Variable<Uint8List>(pict.value);
    }
    return map;
  }
}

class $RecipeTagsTable extends RecipeTags with TableInfo<$RecipeTagsTable, RecipeTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeTagsTable(this.attachedDatabase, [this._alias]);

  @override
  final String actualTableName = 'recipe_tags';

  @override
  VerificationMeta get recipeUuidMeta => const VerificationMeta('recipeUuid');
  late final GeneratedColumn<String> recipeUuid = GeneratedColumn<String>(
      'recipe_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: (GenerationContext context) => 'REFERENCES recipes (uuid)');

  @override
  VerificationMeta get tagMeta => const VerificationMeta('tag');
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  List<GeneratedColumn<Object>> get $columns => [recipeUuid, tag];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  Set<GeneratedColumn<Object>> get $primaryKey => {recipeUuid, tag};

  @override
  RecipeTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeTag(
      recipeUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_uuid'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
    );
  }

  @override
  $RecipeTagsTable createAlias(String alias) {
    return $RecipeTagsTable(attachedDatabase, alias);
  }
}

class RecipeTag extends DataClass implements Insertable<RecipeTag> {
  final String recipeUuid;
  final String tag;
  const RecipeTag({required this.recipeUuid, required this.tag});

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recipe_uuid'] = Variable<String>(recipeUuid);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipe_uuid': serializer.toJson<String>(recipeUuid),
      'tag': serializer.toJson<String>(tag),
    };
  }
}

class RecipeTagsCompanion extends UpdateCompanion<RecipeTag> {
  final Value<String> recipeUuid;
  final Value<String> tag;

  const RecipeTagsCompanion({
    this.recipeUuid = const Value.absent(),
    this.tag = const Value.absent(),
  });

  RecipeTagsCompanion.insert({
    required String recipeUuid,
    required String tag,
  })  : recipeUuid = Value(recipeUuid),
        tag = Value(tag);

  static Insertable<RecipeTag> custom({
    Expression<String>? recipeUuid,
    Expression<String>? tag,
  }) {
    return RawValuesInsertable({
      if (recipeUuid != null) 'recipe_uuid': recipeUuid,
      if (tag != null) 'tag': tag,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recipeUuid.present) {
      map['recipe_uuid'] = Variable<String>(recipeUuid.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    return map;
  }
}

class $IngredientsTable extends Ingredients with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);

  @override
  final String actualTableName = 'ingredients';

  @override
  VerificationMeta get idMeta => const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: (GenerationContext context) => 'PRIMARY KEY AUTOINCREMENT');

  @override
  VerificationMeta get recipeUuidMeta => const VerificationMeta('recipeUuid');
  late final GeneratedColumn<String> recipeUuid = GeneratedColumn<String>(
      'recipe_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get nameMeta => const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get quantityMeta => const VerificationMeta('quantity');
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
      'quantity', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get unitMeta => const VerificationMeta('unit');
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  List<GeneratedColumn<Object>> get $columns => [id, recipeUuid, name, quantity, unit];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  Set<GeneratedColumn<Object>> get $primaryKey => {id};

  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recipeUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final int id;
  final String recipeUuid;
  final String name;
  final String quantity;
  final String unit;
  const Ingredient(
      {required this.id,
      required this.recipeUuid,
      required this.name,
      required this.quantity,
      required this.unit});

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_uuid'] = Variable<String>(recipeUuid);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<String>(quantity);
    map['unit'] = Variable<String>(unit);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipe_uuid': serializer.toJson<String>(recipeUuid),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<String>(quantity),
      'unit': serializer.toJson<String>(unit),
    };
  }
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<int> id;
  final Value<String> recipeUuid;
  final Value<String> name;
  final Value<String> quantity;
  final Value<String> unit;

  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
  });

  IngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String recipeUuid,
    required String name,
    required String quantity,
    required String unit,
  })  : recipeUuid = Value(recipeUuid),
        name = Value(name),
        quantity = Value(quantity),
        unit = Value(unit);

  static Insertable<Ingredient> custom({
    Expression<int>? id,
    Expression<String>? recipeUuid,
    Expression<String>? name,
    Expression<String>? quantity,
    Expression<String>? unit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeUuid != null) 'recipe_uuid': recipeUuid,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeUuid.present) {
      map['recipe_uuid'] = Variable<String>(recipeUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    return map;
  }
}

class $RecipeStepsTable extends RecipeSteps with TableInfo<$RecipeStepsTable, RecipeStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeStepsTable(this.attachedDatabase, [this._alias]);

  @override
  final String actualTableName = 'recipe_steps';

  @override
  VerificationMeta get idMeta => const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: (GenerationContext context) => 'PRIMARY KEY AUTOINCREMENT');

  @override
  VerificationMeta get recipeUuidMeta => const VerificationMeta('recipeUuid');
  late final GeneratedColumn<String> recipeUuid = GeneratedColumn<String>(
      'recipe_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get descriptionMeta => const VerificationMeta('description');
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get durationMeta => const VerificationMeta('duration');
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
      'duration', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  @override
  VerificationMeta get isCompletedMeta => const VerificationMeta('isCompleted');
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultValue: const Constant(false));

  @override
  List<GeneratedColumn<Object>> get $columns => [id, recipeUuid, description, duration, isCompleted];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  Set<GeneratedColumn<Object>> get $primaryKey => {id};

  @override
  RecipeStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeStep(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recipeUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_uuid'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}duration'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
    );
  }

  @override
  $RecipeStepsTable createAlias(String alias) {
    return $RecipeStepsTable(attachedDatabase, alias);
  }
}

class RecipeStep extends DataClass implements Insertable<RecipeStep> {
  final int id;
  final String recipeUuid;
  final String description;
  final String duration;
  final bool isCompleted;
  const RecipeStep(
      {required this.id,
      required this.recipeUuid,
      required this.description,
      required this.duration,
      required this.isCompleted});

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_uuid'] = Variable<String>(recipeUuid);
    map['description'] = Variable<String>(description);
    map['duration'] = Variable<String>(duration);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipe_uuid': serializer.toJson<String>(recipeUuid),
      'description': serializer.toJson<String>(description),
      'duration': serializer.toJson<String>(duration),
      'is_completed': serializer.toJson<bool>(isCompleted),
    };
  }
}

class RecipeStepsCompanion extends UpdateCompanion<RecipeStep> {
  final Value<int> id;
  final Value<String> recipeUuid;
  final Value<String> description;
  final Value<String> duration;
  final Value<bool> isCompleted;

  const RecipeStepsCompanion({
    this.id = const Value.absent(),
    this.recipeUuid = const Value.absent(),
    this.description = const Value.absent(),
    this.duration = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });

  RecipeStepsCompanion.insert({
    this.id = const Value.absent(),
    required String recipeUuid,
    required String description,
    required String duration,
    this.isCompleted = const Value.absent(),
  })  : recipeUuid = Value(recipeUuid),
        description = Value(description),
        duration = Value(duration);

  static Insertable<RecipeStep> custom({
    Expression<int>? id,
    Expression<String>? recipeUuid,
    Expression<String>? description,
    Expression<String>? duration,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeUuid != null) 'recipe_uuid': recipeUuid,
      if (description != null) 'description': description,
      if (duration != null) 'duration': duration,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeUuid.present) {
      map['recipe_uuid'] = Variable<String>(recipeUuid.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $RecipeTagsTable recipeTags = $RecipeTagsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $RecipeStepsTable recipeSteps = $RecipeStepsTable(this);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recipes, photos, recipeTags, ingredients, recipeSteps];
}

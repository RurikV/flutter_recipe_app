// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
      'images', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
      'duration', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
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
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(Insertable<Recipe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('images')) {
      context.handle(_imagesMeta,
          images.isAcceptableOrUnknown(data['images']!, _imagesMeta));
    } else if (isInserting) {
      context.missing(_imagesMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
          _instructionsMeta,
          instructions.isAcceptableOrUnknown(
              data['instructions']!, _instructionsMeta));
    } else if (isInserting) {
      context.missing(_instructionsMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
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

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      uuid: Value(uuid),
      name: Value(name),
      images: Value(images),
      description: Value(description),
      instructions: Value(instructions),
      difficulty: Value(difficulty),
      duration: Value(duration),
      rating: Value(rating),
      isFavorite: Value(isFavorite),
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      images: serializer.fromJson<String>(json['images']),
      description: serializer.fromJson<String>(json['description']),
      instructions: serializer.fromJson<String>(json['instructions']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      duration: serializer.fromJson<String>(json['duration']),
      rating: serializer.fromJson<int>(json['rating']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
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
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  Recipe copyWith(
          {String? uuid,
          String? name,
          String? images,
          String? description,
          String? instructions,
          int? difficulty,
          String? duration,
          int? rating,
          bool? isFavorite}) =>
      Recipe(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        images: images ?? this.images,
        description: description ?? this.description,
        instructions: instructions ?? this.instructions,
        difficulty: difficulty ?? this.difficulty,
        duration: duration ?? this.duration,
        rating: rating ?? this.rating,
        isFavorite: isFavorite ?? this.isFavorite,
      );
  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('images: $images, ')
          ..write('description: $description, ')
          ..write('instructions: $instructions, ')
          ..write('difficulty: $difficulty, ')
          ..write('duration: $duration, ')
          ..write('rating: $rating, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name, images, description, instructions,
      difficulty, duration, rating, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.images == this.images &&
          other.description == this.description &&
          other.instructions == this.instructions &&
          other.difficulty == this.difficulty &&
          other.duration == this.duration &&
          other.rating == this.rating &&
          other.isFavorite == this.isFavorite);
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
  final Value<int> rowid;
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
    this.rowid = const Value.absent(),
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
    this.rowid = const Value.absent(),
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
    Expression<int>? rowid,
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? images,
      Value<String>? description,
      Value<String>? instructions,
      Value<int>? difficulty,
      Value<String>? duration,
      Value<int>? rating,
      Value<bool>? isFavorite,
      Value<int>? rowid}) {
    return RecipesCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      images: images ?? this.images,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      rowid: rowid ?? this.rowid,
    );
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('images: $images, ')
          ..write('description: $description, ')
          ..write('instructions: $instructions, ')
          ..write('difficulty: $difficulty, ')
          ..write('duration: $duration, ')
          ..write('rating: $rating, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recipeUuidMeta =
      const VerificationMeta('recipeUuid');
  @override
  late final GeneratedColumn<String> recipeUuid = GeneratedColumn<String>(
      'recipe_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES recipes (uuid)'));
  static const VerificationMeta _photoNameMeta =
      const VerificationMeta('photoName');
  @override
  late final GeneratedColumn<String> photoName = GeneratedColumn<String>(
      'photo_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detectedInfoMeta =
      const VerificationMeta('detectedInfo');
  @override
  late final GeneratedColumn<String> detectedInfo = GeneratedColumn<String>(
      'detected_info', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pictMeta = const VerificationMeta('pict');
  @override
  late final GeneratedColumn<Uint8List> pict = GeneratedColumn<Uint8List>(
      'pict', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, recipeUuid, photoName, detectedInfo, pict];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(Insertable<Photo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_uuid')) {
      context.handle(
          _recipeUuidMeta,
          recipeUuid.isAcceptableOrUnknown(
              data['recipe_uuid']!, _recipeUuidMeta));
    } else if (isInserting) {
      context.missing(_recipeUuidMeta);
    }
    if (data.containsKey('photo_name')) {
      context.handle(_photoNameMeta,
          photoName.isAcceptableOrUnknown(data['photo_name']!, _photoNameMeta));
    } else if (isInserting) {
      context.missing(_photoNameMeta);
    }
    if (data.containsKey('detected_info')) {
      context.handle(
          _detectedInfoMeta,
          detectedInfo.isAcceptableOrUnknown(
              data['detected_info']!, _detectedInfoMeta));
    } else if (isInserting) {
      context.missing(_detectedInfoMeta);
    }
    if (data.containsKey('pict')) {
      context.handle(
          _pictMeta, pict.isAcceptableOrUnknown(data['pict']!, _pictMeta));
    } else if (isInserting) {
      context.missing(_pictMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
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

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      recipeUuid: Value(recipeUuid),
      photoName: Value(photoName),
      detectedInfo: Value(detectedInfo),
      pict: Value(pict),
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<int>(json['id']),
      recipeUuid: serializer.fromJson<String>(json['recipeUuid']),
      photoName: serializer.fromJson<String>(json['photoName']),
      detectedInfo: serializer.fromJson<String>(json['detectedInfo']),
      pict: serializer.fromJson<Uint8List>(json['pict']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeUuid': serializer.toJson<String>(recipeUuid),
      'photoName': serializer.toJson<String>(photoName),
      'detectedInfo': serializer.toJson<String>(detectedInfo),
      'pict': serializer.toJson<Uint8List>(pict),
    };
  }

  Photo copyWith(
          {int? id,
          String? recipeUuid,
          String? photoName,
          String? detectedInfo,
          Uint8List? pict}) =>
      Photo(
        id: id ?? this.id,
        recipeUuid: recipeUuid ?? this.recipeUuid,
        photoName: photoName ?? this.photoName,
        detectedInfo: detectedInfo ?? this.detectedInfo,
        pict: pict ?? this.pict,
      );
  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('recipeUuid: $recipeUuid, ')
          ..write('photoName: $photoName, ')
          ..write('detectedInfo: $detectedInfo, ')
          ..write('pict: $pict')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, recipeUuid, photoName, detectedInfo, $driftBlobEquality.hash(pict));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.recipeUuid == this.recipeUuid &&
          other.photoName == this.photoName &&
          other.detectedInfo == this.detectedInfo &&
          $driftBlobEquality.equals(other.pict, this.pict));
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

  PhotosCompanion copyWith(
      {Value<int>? id,
      Value<String>? recipeUuid,
      Value<String>? photoName,
      Value<String>? detectedInfo,
      Value<Uint8List>? pict}) {
    return PhotosCompanion(
      id: id ?? this.id,
      recipeUuid: recipeUuid ?? this.recipeUuid,
      photoName: photoName ?? this.photoName,
      detectedInfo: detectedInfo ?? this.detectedInfo,
      pict: pict ?? this.pict,
    );
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

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('recipeUuid: $recipeUuid, ')
          ..write('photoName: $photoName, ')
          ..write('detectedInfo: $detectedInfo, ')
          ..write('pict: $pict')
          ..write(')'))
        .toString();
  }
}

class $RecipeTagsTable extends RecipeTags
    with TableInfo<$RecipeTagsTable, RecipeTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recipeUuidMeta =
      const VerificationMeta('recipeUuid');
  @override
  late final GeneratedColumn<String> recipeUuid = GeneratedColumn<String>(
      'recipe_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES recipes (uuid)'));
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [recipeUuid, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_tags';
  @override
  VerificationContext validateIntegrity(Insertable<RecipeTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recipe_uuid')) {
      context.handle(
          _recipeUuidMeta,
          recipeUuid.isAcceptableOrUnknown(
              data['recipe_uuid']!, _recipeUuidMeta));
    } else if (isInserting) {
      context.missing(_recipeUuidMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recipeUuid, tag};
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

  RecipeTagsCompanion toCompanion(bool nullToAbsent) {
    return RecipeTagsCompanion(
      recipeUuid: Value(recipeUuid),
      tag: Value(tag),
    );
  }

  factory RecipeTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeTag(
      recipeUuid: serializer.fromJson<String>(json['recipeUuid']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipeUuid': serializer.toJson<String>(recipeUuid),
      'tag': serializer.toJson<String>(tag),
    };
  }

  RecipeTag copyWith({String? recipeUuid, String? tag}) => RecipeTag(
        recipeUuid: recipeUuid ?? this.recipeUuid,
        tag: tag ?? this.tag,
      );
  @override
  String toString() {
    return (StringBuffer('RecipeTag(')
          ..write('recipeUuid: $recipeUuid, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(recipeUuid, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeTag &&
          other.recipeUuid == this.recipeUuid &&
          other.tag == this.tag);
}

class RecipeTagsCompanion extends UpdateCompanion<RecipeTag> {
  final Value<String> recipeUuid;
  final Value<String> tag;
  final Value<int> rowid;
  const RecipeTagsCompanion({
    this.recipeUuid = const Value.absent(),
    this.tag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeTagsCompanion.insert({
    required String recipeUuid,
    required String tag,
    this.rowid = const Value.absent(),
  })  : recipeUuid = Value(recipeUuid),
        tag = Value(tag);
  static Insertable<RecipeTag> custom({
    Expression<String>? recipeUuid,
    Expression<String>? tag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recipeUuid != null) 'recipe_uuid': recipeUuid,
      if (tag != null) 'tag': tag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeTagsCompanion copyWith(
      {Value<String>? recipeUuid, Value<String>? tag, Value<int>? rowid}) {
    return RecipeTagsCompanion(
      recipeUuid: recipeUuid ?? this.recipeUuid,
      tag: tag ?? this.tag,
      rowid: rowid ?? this.rowid,
    );
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTagsCompanion(')
          ..write('recipeUuid: $recipeUuid, ')
          ..write('tag: $tag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recipeUuidMeta =
      const VerificationMeta('recipeUuid');
  @override
  late final GeneratedColumn<String> recipeUuid = GeneratedColumn<String>(
      'recipe_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES recipes (uuid)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
      'quantity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, recipeUuid, name, quantity, unit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<Ingredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_uuid')) {
      context.handle(
          _recipeUuidMeta,
          recipeUuid.isAcceptableOrUnknown(
              data['recipe_uuid']!, _recipeUuidMeta));
    } else if (isInserting) {
      context.missing(_recipeUuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
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

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      recipeUuid: Value(recipeUuid),
      name: Value(name),
      quantity: Value(quantity),
      unit: Value(unit),
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<int>(json['id']),
      recipeUuid: serializer.fromJson<String>(json['recipeUuid']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeUuid': serializer.toJson<String>(recipeUuid),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<String>(quantity),
      'unit': serializer.toJson<String>(unit),
    };
  }

  Ingredient copyWith(
          {int? id,
          String? recipeUuid,
          String? name,
          String? quantity,
          String? unit}) =>
      Ingredient(
        id: id ?? this.id,
        recipeUuid: recipeUuid ?? this.recipeUuid,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
      );
  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('recipeUuid: $recipeUuid, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeUuid, name, quantity, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.recipeUuid == this.recipeUuid &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit);
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

  IngredientsCompanion copyWith(
      {Value<int>? id,
      Value<String>? recipeUuid,
      Value<String>? name,
      Value<String>? quantity,
      Value<String>? unit}) {
    return IngredientsCompanion(
      id: id ?? this.id,
      recipeUuid: recipeUuid ?? this.recipeUuid,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
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

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeUuid: $recipeUuid, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }
}

class $RecipeStepsTable extends RecipeSteps
    with TableInfo<$RecipeStepsTable, RecipeStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recipeUuidMeta =
      const VerificationMeta('recipeUuid');
  @override
  late final GeneratedColumn<String> recipeUuid = GeneratedColumn<String>(
      'recipe_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES recipes (uuid)'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
      'duration', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, recipeUuid, description, duration, isCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_steps';
  @override
  VerificationContext validateIntegrity(Insertable<RecipeStep> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_uuid')) {
      context.handle(
          _recipeUuidMeta,
          recipeUuid.isAcceptableOrUnknown(
              data['recipe_uuid']!, _recipeUuidMeta));
    } else if (isInserting) {
      context.missing(_recipeUuidMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
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

  RecipeStepsCompanion toCompanion(bool nullToAbsent) {
    return RecipeStepsCompanion(
      id: Value(id),
      recipeUuid: Value(recipeUuid),
      description: Value(description),
      duration: Value(duration),
      isCompleted: Value(isCompleted),
    );
  }

  factory RecipeStep.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeStep(
      id: serializer.fromJson<int>(json['id']),
      recipeUuid: serializer.fromJson<String>(json['recipeUuid']),
      description: serializer.fromJson<String>(json['description']),
      duration: serializer.fromJson<String>(json['duration']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeUuid': serializer.toJson<String>(recipeUuid),
      'description': serializer.toJson<String>(description),
      'duration': serializer.toJson<String>(duration),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  RecipeStep copyWith(
          {int? id,
          String? recipeUuid,
          String? description,
          String? duration,
          bool? isCompleted}) =>
      RecipeStep(
        id: id ?? this.id,
        recipeUuid: recipeUuid ?? this.recipeUuid,
        description: description ?? this.description,
        duration: duration ?? this.duration,
        isCompleted: isCompleted ?? this.isCompleted,
      );
  @override
  String toString() {
    return (StringBuffer('RecipeStep(')
          ..write('id: $id, ')
          ..write('recipeUuid: $recipeUuid, ')
          ..write('description: $description, ')
          ..write('duration: $duration, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeUuid, description, duration, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeStep &&
          other.id == this.id &&
          other.recipeUuid == this.recipeUuid &&
          other.description == this.description &&
          other.duration == this.duration &&
          other.isCompleted == this.isCompleted);
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

  RecipeStepsCompanion copyWith(
      {Value<int>? id,
      Value<String>? recipeUuid,
      Value<String>? description,
      Value<String>? duration,
      Value<bool>? isCompleted}) {
    return RecipeStepsCompanion(
      id: id ?? this.id,
      recipeUuid: recipeUuid ?? this.recipeUuid,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
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

  @override
  String toString() {
    return (StringBuffer('RecipeStepsCompanion(')
          ..write('id: $id, ')
          ..write('recipeUuid: $recipeUuid, ')
          ..write('description: $description, ')
          ..write('duration: $duration, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
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
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [recipes, photos, recipeTags, ingredients, recipeSteps];
}

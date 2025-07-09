// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_updated.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      images: json['photo'] as String,
      description: json['description'] as String,
      instructions: json['instructions'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
      durationStr: json['durationStr'] as String,
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recipeIngredients: (json['recipeIngredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      stepLinks: (json['recipeStepLinks'] as List<dynamic>?)
          ?.map((e) => RecipeStepLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'name': instance.name,
      'photo': instance.images,
      'description': instance.description,
      'instructions': instance.instructions,
      'difficulty': instance.difficulty,
      'duration': instance.durationMinutes,
      'durationStr': instance.durationStr,
      'rating': instance.rating,
      'tags': instance.tags,
      'recipeIngredients':
          instance.recipeIngredients?.map((e) => e.toJson()).toList(),
      'recipeStepLinks': instance.stepLinks?.map((e) => e.toJson()).toList(),
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'steps': instance.steps.map((e) => e.toJson()).toList(),
      'isFavorite': instance.isFavorite,
      'comments': instance.comments.map((e) => e.toJson()).toList(),
    };

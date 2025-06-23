// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeStep _$RecipeStepFromJson(Map<String, dynamic> json) => RecipeStep(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  duration: (json['duration'] as num).toInt(),
  stepLinks:
      (json['recipeStepLinks'] as List<dynamic>?)
          ?.map((e) => RecipeStepLink.fromJson(e as Map<String, dynamic>))
          .toList(),
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$RecipeStepToJson(RecipeStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'duration': instance.duration,
      'isCompleted': instance.isCompleted,
      'recipeStepLinks': instance.stepLinks?.map((e) => e.toJson()).toList(),
    };

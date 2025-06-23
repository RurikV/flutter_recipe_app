// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeStep _$RecipeStepFromJson(Map<String, dynamic> json) => RecipeStep(
  description: json['description'] as String,
  duration: json['duration'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$RecipeStepToJson(RecipeStep instance) =>
    <String, dynamic>{
      'description': instance.description,
      'duration': instance.duration,
      'isCompleted': instance.isCompleted,
    };

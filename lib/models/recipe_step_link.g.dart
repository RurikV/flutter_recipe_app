// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeStepLink _$RecipeStepLinkFromJson(Map<String, dynamic> json) =>
    RecipeStepLink(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      recipe: RecipeRef.fromJson(json['recipe'] as Map<String, dynamic>),
      step: StepRef.fromJson(json['step'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecipeStepLinkToJson(RecipeStepLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'recipe': instance.recipe.toJson(),
      'step': instance.step.toJson(),
    };

RecipeRef _$RecipeRefFromJson(Map<String, dynamic> json) => RecipeRef(
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$RecipeRefToJson(RecipeRef instance) => <String, dynamic>{
      'id': instance.id,
    };

StepRef _$StepRefFromJson(Map<String, dynamic> json) => StepRef(
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$StepRefToJson(StepRef instance) => <String, dynamic>{
      'id': instance.id,
    };

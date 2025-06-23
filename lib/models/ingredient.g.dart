// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  caloriesForUnit: (json['caloriesForUnit'] as num).toDouble(),
  measureUnit: MeasureUnitRef.fromJson(
    json['measureUnit'] as Map<String, dynamic>,
  ),
  recipeIngredients:
      (json['recipeIngredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
  quantity: json['quantity'] as String? ?? '',
  unit: json['unit'] as String? ?? '',
);

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'caloriesForUnit': instance.caloriesForUnit,
      'measureUnit': instance.measureUnit.toJson(),
      'recipeIngredients':
          instance.recipeIngredients?.map((e) => e.toJson()).toList(),
      'quantity': instance.quantity,
      'unit': instance.unit,
    };

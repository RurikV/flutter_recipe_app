import 'package:json_annotation/json_annotation.dart';

part 'recipe_ingredient.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipeIngredient {
  final int id;
  final int count;
  
  @JsonKey(name: 'ingredient')
  final IngredientRef ingredient;
  
  @JsonKey(name: 'recipe')
  final RecipeRef? recipe;

  RecipeIngredient({
    required this.id,
    required this.count,
    required this.ingredient,
    this.recipe,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => _$RecipeIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);
}

@JsonSerializable()
class IngredientRef {
  final int id;

  IngredientRef({required this.id});

  factory IngredientRef.fromJson(Map<String, dynamic> json) => _$IngredientRefFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientRefToJson(this);
}

@JsonSerializable()
class RecipeRef {
  final int id;

  RecipeRef({required this.id});

  factory RecipeRef.fromJson(Map<String, dynamic> json) => _$RecipeRefFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeRefToJson(this);
}
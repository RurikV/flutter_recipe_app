import 'package:json_annotation/json_annotation.dart';
import 'measure_unit.dart';
import 'recipe_ingredient.dart';

part 'ingredient.g.dart';

@JsonSerializable(explicitToJson: true)
class Ingredient {
  final int id;
  final String name;

  @JsonKey(name: 'caloriesForUnit')
  final double caloriesForUnit;

  @JsonKey(name: 'measureUnit')
  final MeasureUnitRef measureUnit;

  @JsonKey(name: 'recipeIngredients')
  final List<RecipeIngredient>? recipeIngredients;

  // For backward compatibility with existing code
  final String quantity;
  final String unit;

  Ingredient({
    required this.id,
    required this.name,
    required this.caloriesForUnit,
    required this.measureUnit,
    this.recipeIngredients,
    this.quantity = '',
    this.unit = '',
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  // Factory constructor for creating a simple ingredient (for backward compatibility)
  factory Ingredient.simple({
    required String name,
    required String quantity,
    required String unit,
  }) {
    return Ingredient(
      id: 0, // Default ID
      name: name,
      caloriesForUnit: 0.0, // Default calories
      measureUnit: MeasureUnitRef(id: 0), // Default measure unit
      quantity: quantity,
      unit: unit,
    );
  }
}

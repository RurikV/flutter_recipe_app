import 'package:json_annotation/json_annotation.dart';
import 'recipe_step_link.dart';

part 'recipe_step.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipeStep {
  final int id;
  final String name;
  final int duration;
  final bool isCompleted;

  @JsonKey(name: 'recipeStepLinks')
  final List<RecipeStepLink>? stepLinks;

  RecipeStep({
    required this.id,
    required this.name,
    required this.duration,
    this.stepLinks,
    this.isCompleted = false,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) => _$RecipeStepFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeStepToJson(this);

  // Factory constructor for creating a simple step (for backward compatibility)
  factory RecipeStep.simple({
    required String description,
    required String duration,
    bool isCompleted = false,
  }) {
    return RecipeStep(
      id: 0, // Default ID
      name: description,
      duration: int.tryParse(duration) ?? 0,
      isCompleted: isCompleted,
    );
  }

  // Creates a copy of the recipe step with the given fields replaced with the new values
  RecipeStep copyWith({
    int? id,
    String? name,
    int? duration,
    List<RecipeStepLink>? stepLinks,
    bool? isCompleted,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      stepLinks: stepLinks ?? this.stepLinks,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'recipe_step_link.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipeStepLink {
  final int id;
  final int number;
  
  @JsonKey(name: 'recipe')
  final RecipeRef recipe;
  
  @JsonKey(name: 'step')
  final StepRef step;

  RecipeStepLink({
    required this.id,
    required this.number,
    required this.recipe,
    required this.step,
  });

  factory RecipeStepLink.fromJson(Map<String, dynamic> json) => _$RecipeStepLinkFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepLinkToJson(this);
}

@JsonSerializable()
class RecipeRef {
  final int id;

  RecipeRef({required this.id});

  factory RecipeRef.fromJson(Map<String, dynamic> json) => _$RecipeRefFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeRefToJson(this);
}

@JsonSerializable()
class StepRef {
  final int id;

  StepRef({required this.id});

  factory StepRef.fromJson(Map<String, dynamic> json) => _$StepRefFromJson(json);
  Map<String, dynamic> toJson() => _$StepRefToJson(this);
}
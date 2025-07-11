import 'package:json_annotation/json_annotation.dart';
import 'ingredient.dart';

part 'measure_unit.g.dart';

@JsonSerializable(explicitToJson: true)
class MeasureUnit {
  final int id;
  final String one;
  final String few;
  final String many;
  
  @JsonKey(name: 'ingredients')
  final List<Ingredient>? ingredients;

  MeasureUnit({
    required this.id,
    required this.one,
    required this.few,
    required this.many,
    this.ingredients,
  });

  factory MeasureUnit.fromJson(Map<String, dynamic> json) => _$MeasureUnitFromJson(json);

  Map<String, dynamic> toJson() => _$MeasureUnitToJson(this);
}

@JsonSerializable()
class MeasureUnitRef {
  final int id;

  MeasureUnitRef({required this.id});

  factory MeasureUnitRef.fromJson(Map<String, dynamic> json) => _$MeasureUnitRefFromJson(json);
  
  Map<String, dynamic> toJson() => _$MeasureUnitRefToJson(this);
}
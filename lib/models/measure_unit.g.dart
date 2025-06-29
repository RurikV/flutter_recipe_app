// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measure_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasureUnit _$MeasureUnitFromJson(Map<String, dynamic> json) => MeasureUnit(
  id: (json['id'] as num).toInt(),
  one: json['one'] as String,
  few: json['few'] as String,
  many: json['many'] as String,
  ingredients:
      (json['ingredients'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$MeasureUnitToJson(MeasureUnit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'one': instance.one,
      'few': instance.few,
      'many': instance.many,
      'ingredients': instance.ingredients?.map((e) => e.toJson()).toList(),
    };

MeasureUnitRef _$MeasureUnitRefFromJson(Map<String, dynamic> json) =>
    MeasureUnitRef(id: (json['id'] as num).toInt());

Map<String, dynamic> _$MeasureUnitRefToJson(MeasureUnitRef instance) =>
    <String, dynamic>{'id': instance.id};

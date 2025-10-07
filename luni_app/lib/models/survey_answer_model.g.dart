// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyAnswerModel _$SurveyAnswerModelFromJson(Map<String, dynamic> json) =>
    SurveyAnswerModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      key: json['key'] as String,
      valueJson: json['valueJson'],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SurveyAnswerModelToJson(SurveyAnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'key': instance.key,
      'valueJson': instance.valueJson,
      'createdAt': instance.createdAt.toIso8601String(),
    };

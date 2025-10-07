// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      parentKey: json['parentKey'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      isLocked: json['isLocked'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'parentKey': instance.parentKey,
      'name': instance.name,
      'emoji': instance.emoji,
      'isLocked': instance.isLocked,
      'createdAt': instance.createdAt.toIso8601String(),
    };

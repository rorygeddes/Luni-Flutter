// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueItemModel _$QueueItemModelFromJson(Map<String, dynamic> json) =>
    QueueItemModel(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String,
      transactionId: json['transaction_id'] as String,
      aiDescription: json['ai_description'] as String?,
      aiCategory: json['ai_category'] as String?,
      aiSubcategory: json['ai_subcategory'] as String?,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$QueueItemModelToJson(QueueItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'transaction_id': instance.transactionId,
      'ai_description': instance.aiDescription,
      'ai_category': instance.aiCategory,
      'ai_subcategory': instance.aiSubcategory,
      'confidence_score': instance.confidenceScore,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };

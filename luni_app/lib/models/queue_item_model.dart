import 'package:json_annotation/json_annotation.dart';

part 'queue_item_model.g.dart';

@JsonSerializable()
class QueueItemModel {
  final int id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'transaction_id')
  final String transactionId;
  @JsonKey(name: 'ai_description')
  final String? aiDescription;
  @JsonKey(name: 'ai_category')
  final String? aiCategory;
  @JsonKey(name: 'ai_subcategory')
  final String? aiSubcategory;
  @JsonKey(name: 'confidence_score')
  final double confidenceScore;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const QueueItemModel({
    required this.id,
    required this.userId,
    required this.transactionId,
    this.aiDescription,
    this.aiCategory,
    this.aiSubcategory,
    required this.confidenceScore,
    required this.status,
    required this.createdAt,
  });

  factory QueueItemModel.fromJson(Map<String, dynamic> json) => _$QueueItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueItemModelToJson(this);
}
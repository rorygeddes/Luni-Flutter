import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'account_id')
  final String accountId;
  final double amount;
  @JsonKey(defaultValue: 'Unknown Transaction')
  final String? description;
  @JsonKey(name: 'merchant_name')
  final String? merchantName;
  final DateTime date;
  final String? category;
  final String? subcategory;
  @JsonKey(name: 'is_categorized')
  final bool isCategorized;
  @JsonKey(name: 'is_split')
  final bool isSplit;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.amount,
    this.description,
    this.merchantName,
    required this.date,
    this.category,
    this.subcategory,
    required this.isCategorized,
    required this.isSplit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
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
  
  // Raw description from bank (never changes)
  @JsonKey(defaultValue: 'Unknown Transaction')
  final String? description;
  
  // AI-cleaned description (editable by user)
  @JsonKey(name: 'ai_description')
  final String? aiDescription;
  
  @JsonKey(name: 'merchant_name')
  final String? merchantName;
  final DateTime date;
  final String? category;
  final String? subcategory;
  @JsonKey(name: 'is_categorized')
  final bool isCategorized;
  @JsonKey(name: 'is_split')
  final bool isSplit;
  
  // Duplicate detection fields
  @JsonKey(name: 'is_potential_duplicate')
  final bool? isPotentialDuplicate;
  @JsonKey(name: 'duplicate_of_transaction_id')
  final String? duplicateOfTransactionId;
  
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
    this.aiDescription,
    this.merchantName,
    required this.date,
    this.category,
    this.subcategory,
    required this.isCategorized,
    required this.isSplit,
    this.isPotentialDuplicate,
    this.duplicateOfTransactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
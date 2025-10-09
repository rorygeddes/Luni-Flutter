// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? 'Unknown Transaction',
      merchantName: json['merchant_name'] as String?,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      isCategorized: json['is_categorized'] as bool,
      isSplit: json['is_split'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'account_id': instance.accountId,
      'amount': instance.amount,
      'description': instance.description,
      'merchant_name': instance.merchantName,
      'date': instance.date.toIso8601String(),
      'category': instance.category,
      'subcategory': instance.subcategory,
      'is_categorized': instance.isCategorized,
      'is_split': instance.isSplit,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

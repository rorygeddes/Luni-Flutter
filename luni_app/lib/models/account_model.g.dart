// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  institutionId: json['institution_id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  subtype: json['subtype'] as String?,
  balance: (json['balance'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'institution_id': instance.institutionId,
      'name': instance.name,
      'type': instance.type,
      'subtype': instance.subtype,
      'balance': instance.balance,
      'created_at': instance.createdAt.toIso8601String(),
    };

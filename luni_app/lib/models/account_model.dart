import 'package:json_annotation/json_annotation.dart';

part 'account_model.g.dart';

@JsonSerializable()
class AccountModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'institution_id')
  final String institutionId;
  final String name;
  final String type;
  final String? subtype;
  final double balance;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const AccountModel({
    required this.id,
    required this.userId,
    required this.institutionId,
    required this.name,
    required this.type,
    this.subtype,
    required this.balance,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => _$AccountModelFromJson(json);
  Map<String, dynamic> toJson() => _$AccountModelToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => _$GroupModelFromJson(json);
  Map<String, dynamic> toJson() => _$GroupModelToJson(this);
}

@JsonSerializable()
class GroupMemberModel {
  final String id;
  @JsonKey(name: 'group_id')
  final String groupId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String? nickname;
  @JsonKey(name: 'added_by')
  final String addedBy;
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;
  
  // Extended field (joined from profiles table)
  final String? username;
  final String? email;

  const GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    this.nickname,
    required this.addedBy,
    required this.joinedAt,
    this.username,
    this.email,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) => _$GroupMemberModelFromJson(json);
  Map<String, dynamic> toJson() => _$GroupMemberModelToJson(this);
  
  String get displayName => nickname ?? username ?? email ?? 'Unknown';
}


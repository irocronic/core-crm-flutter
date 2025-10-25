// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  role: json['role'] as String,
  roleDisplay: json['role_display'] as String?,
  phoneNumber: json['phone_number'] as String?,
  profilePicture: json['profile_picture'] as String?,
  team: (json['team'] as num?)?.toInt(),
  teamName: json['team_name'] as String?,
  isActiveEmployee: json['is_active_employee'] as bool,
  dateJoined: DateTime.parse(json['date_joined'] as String),
  lastLogin: json['last_login'] == null
      ? null
      : DateTime.parse(json['last_login'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'role': instance.role,
  'role_display': instance.roleDisplay,
  'phone_number': instance.phoneNumber,
  'profile_picture': instance.profilePicture,
  'team': instance.team,
  'team_name': instance.teamName,
  'is_active_employee': instance.isActiveEmployee,
  'date_joined': instance.dateJoined.toIso8601String(),
  'last_login': instance.lastLogin?.toIso8601String(),
};

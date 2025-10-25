// lib/features/auth/data/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String role;
  @JsonKey(name: 'role_display')
  final String? roleDisplay;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'team')
  final int? team;
  @JsonKey(name: 'team_name')
  final String? teamName;
  @JsonKey(name: 'is_active_employee')
  final bool isActiveEmployee;
  @JsonKey(name: 'date_joined')
  final DateTime dateJoined;
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.roleDisplay,
    this.phoneNumber,
    this.profilePicture,
    this.team,
    this.teamName,
    required this.isActiveEmployee,
    required this.dateJoined,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get fullName => '$firstName $lastName';

  bool get isAdmin => role == 'ADMIN';
  bool get isSalesManager => role == 'SATIS_MUDUR';
  bool get isSalesRep => role == 'SATIS_TEMSILCISI';
  bool get isAssistant => role == 'ASISTAN';
}

// user_model.g.dart dosyası build_runner ile oluşturulacak
// Komut: flutter pub run build_runner build --delete-conflicting-outputs
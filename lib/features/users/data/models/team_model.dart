// lib/features/users/data/models/team_model.dart
import '../../../auth/data/models/user_model.dart';

class TeamModel {
  final UserModel teamLeader;
  final List<UserModel> teamMembers;
  final int totalMembers;

  TeamModel({
    required this.teamLeader,
    required this.teamMembers,
    required this.totalMembers,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    var memberList = json['team_members'] as List;
    List<UserModel> members = memberList.map((i) => UserModel.fromJson(i)).toList();

    return TeamModel(
      teamLeader: UserModel.fromJson(json['team_leader']),
      teamMembers: members,
      totalMembers: json['total_members'],
    );
  }
}
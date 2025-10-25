// lib/features/properties/data/models/project_stats_model.dart

class ProjectStatsModel {
  final String projectName;
  final int propertyCount;
  final int availableCount;

  ProjectStatsModel({
    required this.projectName,
    required this.propertyCount,
    required this.availableCount,
  });

  factory ProjectStatsModel.fromJson(Map<String, dynamic> json) {
    return ProjectStatsModel(
      projectName: json['project_name'] as String,
      propertyCount: json['property_count'] as int,
      availableCount: json['available_count'] as int,
    );
  }
}
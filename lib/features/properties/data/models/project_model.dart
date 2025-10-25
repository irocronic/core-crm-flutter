// lib/features/properties/data/models/project_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final int id;
  final String name;
  final String? location;
  final String? description;
  final String? island;
  final String? parcel;
  final String? block;

  @JsonKey(name: 'property_count')
  final int? propertyCount;
  @JsonKey(name: 'available_count')
  final int? availableCount;

  // YENİ EKLENDİ
  @JsonKey(name: 'project_image')
  final String? projectImage;

  // YENİ EKLENDİ
  @JsonKey(name: 'site_plan_image')
  final String? sitePlanImage;

  ProjectModel({
    required this.id,
    required this.name,
    this.location,
    this.description,
    this.island,
    this.parcel,
    this.block,
    this.propertyCount,
    this.availableCount,
    // YENİ EKLENDİ
    this.projectImage,
    this.sitePlanImage,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}
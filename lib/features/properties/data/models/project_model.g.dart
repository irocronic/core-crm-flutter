// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  location: json['location'] as String?,
  description: json['description'] as String?,
  island: json['island'] as String?,
  parcel: json['parcel'] as String?,
  block: json['block'] as String?,
  propertyCount: (json['property_count'] as num?)?.toInt(),
  availableCount: (json['available_count'] as num?)?.toInt(),
  projectImage: json['project_image'] as String?,
  sitePlanImage: json['site_plan_image'] as String?,
);

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'description': instance.description,
      'island': instance.island,
      'parcel': instance.parcel,
      'block': instance.block,
      'property_count': instance.propertyCount,
      'available_count': instance.availableCount,
      'project_image': instance.projectImage,
      'site_plan_image': instance.sitePlanImage,
    };

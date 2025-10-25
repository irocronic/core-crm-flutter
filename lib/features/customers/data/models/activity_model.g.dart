// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    ActivityModel(
      id: (json['id'] as num).toInt(),
      customerId: (json['customer'] as num).toInt(),
      customerName: json['customer_name'] as String?,
      activityType: json['activity_type'] as String,
      subType: json['sub_type'] as String?,
      subTypeDisplay: json['sub_type_display'] as String?,
      notes: json['notes'] as String?,
      outcomeScore: (json['outcome_score'] as num?)?.toInt(),
      outcomeScoreDisplay: json['outcome_score_display'] as String?,
      nextFollowUpDate: json['next_follow_up_date'] == null
          ? null
          : DateTime.parse(json['next_follow_up_date'] as String),
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByName: json['created_by_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      activityTypeDisplay: json['activity_type_display'] as String?,
    );

Map<String, dynamic> _$ActivityModelToJson(ActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer': instance.customerId,
      'customer_name': instance.customerName,
      'activity_type': instance.activityType,
      'sub_type': ?instance.subType,
      'sub_type_display': ?instance.subTypeDisplay,
      'notes': instance.notes,
      'outcome_score': instance.outcomeScore,
      'outcome_score_display': instance.outcomeScoreDisplay,
      'next_follow_up_date': instance.nextFollowUpDate?.toIso8601String(),
      'created_by': instance.createdBy,
      'created_by_name': instance.createdByName,
      'created_at': instance.createdAt.toIso8601String(),
      'activity_type_display': instance.activityTypeDisplay,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentPlanModel _$PaymentPlanModelFromJson(Map<String, dynamic> json) =>
    PaymentPlanModel(
      id: (json['id'] as num).toInt(),
      planType: json['plan_type'] as String,
      name: json['name'] as String,
      details: json['details'] as Map<String, dynamic>,
      detailsDisplay: json['details_display'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$PaymentPlanModelToJson(PaymentPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan_type': instance.planType,
      'name': instance.name,
      'details': instance.details,
      'details_display': instance.detailsDisplay,
      'is_active': instance.isActive,
    };

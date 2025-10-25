// lib/features/properties/data/models/payment_plan_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'payment_plan_model.g.dart';

@JsonSerializable()
class PaymentPlanModel {
  final int id;

  @JsonKey(name: 'plan_type')
  final String planType;

  final String name;
  final Map<String, dynamic> details;

  @JsonKey(name: 'details_display')
  final String detailsDisplay;

  @JsonKey(name: 'is_active')
  final bool isActive;

  PaymentPlanModel({
    required this.id,
    required this.planType,
    required this.name,
    required this.details,
    required this.detailsDisplay,
    required this.isActive,
  });

  factory PaymentPlanModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPlanModelToJson(this);
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      leadStatus: json['lead_status'] as String?,
      leadStatusDisplay: json['lead_status_display'] as String?,
      source: json['source'] as String,
      sourceDisplay: json['source_display'] as String?,
      interestedIn: json['interested_in'] as String?,
      budgetMin: (json['budget_min'] as num?)?.toDouble(),
      budgetMax: (json['budget_max'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      assignedTo: (json['assigned_to'] as num?)?.toInt(),
      assignedToName: json['assigned_to_name'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByName: CustomerModel._emptyStringToNull(json['created_by_name']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      activitiesCount: (json['activities_count'] as num?)?.toInt(),
      appointmentsCount: (json['appointments_count'] as num?)?.toInt(),
      winProbability: (json['win_probability'] as num?)?.toDouble(),
      hasAppointmentToday: json['has_appointment_today'] as bool?,
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'lead_status': instance.leadStatus,
      'lead_status_display': instance.leadStatusDisplay,
      'source': instance.source,
      'source_display': instance.sourceDisplay,
      'interested_in': instance.interestedIn,
      'budget_min': instance.budgetMin,
      'budget_max': instance.budgetMax,
      'notes': instance.notes,
      'assigned_to': instance.assignedTo,
      'assigned_to_name': instance.assignedToName,
      'created_by': instance.createdBy,
      'created_by_name': instance.createdByName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'activities_count': instance.activitiesCount,
      'appointments_count': instance.appointmentsCount,
      'win_probability': instance.winProbability,
      'has_appointment_today': instance.hasAppointmentToday,
    };

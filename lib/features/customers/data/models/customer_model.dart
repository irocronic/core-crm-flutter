// lib/features/customers/data/models/customer_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  final int id;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String? email;
  @JsonKey(name: 'lead_status')
  final String? leadStatus;  // ✅ Nullable yap
  @JsonKey(name: 'lead_status_display')
  final String? leadStatusDisplay;
  final String source;
  @JsonKey(name: 'source_display')
  final String? sourceDisplay;
  @JsonKey(name: 'interested_in')
  final String? interestedIn;
  @JsonKey(name: 'budget_min')
  final double? budgetMin;
  @JsonKey(name: 'budget_max')
  final double? budgetMax;
  final String? notes;
  @JsonKey(name: 'assigned_to')
  final int? assignedTo;
  @JsonKey(name: 'assigned_to_name')
  final String? assignedToName;
  @JsonKey(name: 'created_by')
  final int? createdBy;
  
  // 🔥 ÖNEMLİ: Boş string'i null'a dönüştür
  @JsonKey(
    name: 'created_by_name',
    fromJson: _emptyStringToNull,
  )
  final String? createdByName;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'activities_count')
  final int? activitiesCount;
  @JsonKey(name: 'appointments_count')
  final int? appointmentsCount;
  @JsonKey(name: 'win_probability')
  final double? winProbability;
  @JsonKey(name: 'has_appointment_today')
  final bool? hasAppointmentToday;

  CustomerModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.leadStatus,  // ✅ required kaldırıldı
    this.leadStatusDisplay,
    required this.source,
    this.sourceDisplay,
    this.interestedIn,
    this.budgetMin,
    this.budgetMax,
    this.notes,
    this.assignedTo,
    this.assignedToName,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.activitiesCount,
    this.appointmentsCount,
    this.winProbability,
    this.hasAppointmentToday,
  });

  // 🔥 Boş string'leri null'a dönüştüren helper
  static String? _emptyStringToNull(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isEmpty) return null;
    return value as String?;
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  // Lead Status için renk
  Color get leadStatusColor {
    // ✅ Null check ekle
    if (leadStatus == null) return Colors.grey;
    
    switch (leadStatus!) {
      case 'SICAK':
        return Colors.red;
      case 'ILIK':
        return Colors.orange;
      case 'SOGUK':
        return Colors.blue;
      case 'KAZANILDI':
        return Colors.green;
      case 'KAYBEDILDI':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Lead Status için text
  String get leadStatusText {
    return leadStatusDisplay ?? leadStatus ?? 'Belirtilmemiş';  // ✅ Fallback ekle
  }

  // Kısa ad (İlk harf)
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 1).toUpperCase();
  }

  // Win probability rengi
  Color get winProbabilityColor {
    if (winProbability == null) return Colors.grey;
    if (winProbability! >= 75) return Colors.green;
    if (winProbability! >= 50) return Colors.orange;
    if (winProbability! >= 25) return Colors.blue;
    return Colors.grey;
  }
}
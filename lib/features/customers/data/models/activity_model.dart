// lib/features/customers/data/models/activity_model.dart
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_model.g.dart';

@JsonSerializable()
class ActivityModel {
  final int id;

  @JsonKey(name: 'customer')
  final int customerId;

  @JsonKey(name: 'customer_name')
  final String? customerName;

  @JsonKey(name: 'activity_type')
  final String activityType;

  // **** YENİ ALANLAR ****
  @JsonKey(name: 'sub_type', includeIfNull: false) // Backend null gönderirse dahil etme
  final String? subType;

  @JsonKey(name: 'sub_type_display', includeIfNull: false)
  final String? subTypeDisplay;
  // **** YENİ ALANLAR SONU ****

  // 🔥 DÜZELTME: Backend'den gelen field name: "notes" (description değil)
  final String? notes;

  @JsonKey(name: 'outcome_score')
  final int? outcomeScore;

  @JsonKey(name: 'outcome_score_display')
  final String? outcomeScoreDisplay;

  @JsonKey(name: 'next_follow_up_date')
  final DateTime? nextFollowUpDate;

  @JsonKey(name: 'created_by')
  final int? createdBy;

  @JsonKey(name: 'created_by_name')
  final String? createdByName;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  // 🔥 DÜZELTME: Backend'den gelmiyor, nullable yap
  @JsonKey(name: 'activity_type_display')
  final String? activityTypeDisplay;

  ActivityModel({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.activityType,
    // **** YENİ PARAMETRELER ****
    this.subType,
    this.subTypeDisplay,
    // **** YENİ PARAMETRELER SONU ****
    this.notes,
    this.outcomeScore,
    this.outcomeScoreDisplay,
    this.nextFollowUpDate,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    this.activityTypeDisplay,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$ActivityModelFromJson(json);
    } catch (e) {
      print('❌ ActivityModel parse hatası: $e');
      print('📦 JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ActivityModelToJson(this);

  // Activity type display (computed)
  // **** GÜNCELLENDİ: Alt türü göstermek için ****
  String get activityTypeDisplayText {
    String baseText;
    // Backend'den gelen display varsa onu kullan
    if (activityTypeDisplay != null && activityTypeDisplay!.isNotEmpty) {
      baseText = activityTypeDisplay!;
    } else {
      // Yoksa type'dan türet
      switch (activityType.toUpperCase()) {
        case 'CALL':
        case 'TELEFON':
          baseText = 'Telefon Görüşmesi';
          break;
        case 'MEETING':
        case 'GORUSME':
          baseText = 'Yüz Yüze Görüşme';
          break;
        case 'EMAIL':
          baseText = 'E-posta';
          break;
        case 'VISIT':
        case 'RANDEVU':
          baseText = 'Randevu';
          break;
        case 'WHATSAPP':
          baseText = 'WhatsApp';
          break;
        case 'OTHER':
        case 'DIGER':
          baseText = 'Diğer';
          break;
        default:
          baseText = activityType;
          break;
      }
    }

    // Yüz yüze görüşme ise ve alt tür varsa ekle
    if (activityType.toUpperCase() == 'GORUSME' && subTypeDisplay != null && subTypeDisplay!.isNotEmpty) {
      return '$baseText ($subTypeDisplay)';
    }

    return baseText;
  }
  // **** GÜNCELLEME SONU ****


  // Activity type icon
  IconData get activityTypeIcon {
    switch (activityType.toUpperCase()) {
      case 'CALL':
      case 'TELEFON':
        return Icons.phone;
      case 'MEETING':
      case 'GORUSME':
      // Alt türe göre ikon değişebilir (opsiyonel)
      // if (subType == 'ILK_GELEN') return Icons.person_add;
        return Icons.people;
      case 'EMAIL':
        return Icons.email;
      case 'VISIT':
      case 'RANDEVU':
        return Icons.event;
      case 'WHATSAPP':
        return Icons.chat;
      case 'OTHER':
      case 'DIGER':
        return Icons.more_horiz;
      default:
        return Icons.assignment;
    }
  }

  // Activity type color
  Color get activityTypeColor {
    switch (activityType.toUpperCase()) {
      case 'CALL':
      case 'TELEFON':
        return Colors.blue;
      case 'MEETING':
      case 'GORUSME':
      // Alt türe göre renk değişebilir (opsiyonel)
      // if (subType == 'ILK_GELEN') return Colors.deepPurple;
        return Colors.purple;
      case 'EMAIL':
        return Colors.green;
      case 'VISIT':
      case 'RANDEVU':
        return Colors.orange;
      case 'WHATSAPP':
        return Colors.green;
      case 'OTHER':
      case 'DIGER':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Outcome score value
  int get outcomeScoreValue {
    return outcomeScore ?? 50;
  }

  // Outcome score color
  Color get outcomeScoreColor {
    final score = outcomeScoreValue;
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  // Copy with method
  // **** GÜNCELLENDİ: Alt tür alanları eklendi ****
  ActivityModel copyWith({
    int? id,
    int? customerId,
    String? customerName,
    String? activityType,
    String? subType, // Yeni
    String? subTypeDisplay, // Yeni
    String? notes,
    int? outcomeScore,
    String? outcomeScoreDisplay,
    DateTime? nextFollowUpDate,
    int? createdBy,
    String? createdByName,
    DateTime? createdAt,
    String? activityTypeDisplay,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      activityType: activityType ?? this.activityType,
      subType: subType ?? this.subType, // Yeni
      subTypeDisplay: subTypeDisplay ?? this.subTypeDisplay, // Yeni
      notes: notes ?? this.notes,
      outcomeScore: outcomeScore ?? this.outcomeScore,
      outcomeScoreDisplay: outcomeScoreDisplay ?? this.outcomeScoreDisplay,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      activityTypeDisplay: activityTypeDisplay ?? this.activityTypeDisplay,
    );
  }
// **** GÜNCELLEME SONU ****
}
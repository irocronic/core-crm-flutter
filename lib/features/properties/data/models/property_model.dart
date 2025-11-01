// lib/features/properties/data/models/property_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import 'payment_plan_model.dart';

part 'property_model.g.dart';

// YENİ: Proje bilgilerini tutmak için iç içe bir sınıf
@JsonSerializable()
class ProjectInfo {
  final int id;
  final String name;

  ProjectInfo({required this.id, required this.name});

  factory ProjectInfo.fromJson(Map<String, dynamic> json) =>
      _$ProjectInfoFromJson(json);
  Map<String,
      dynamic> toJson() => _$ProjectInfoToJson(this);
}

@JsonSerializable()
class PropertyImage {
  final int id;

  @JsonKey(name: 'image')
  final String imageUrl;

  @JsonKey(name: 'image_type')
  final String imageType;

  final String? title;

  PropertyImage({
    required this.id,
    required this.imageUrl,
    required this.imageType,
    this.title,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) => _$PropertyImageFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyImageToJson(this);
}

@JsonSerializable()
class PropertyDocument {
  final int id;

  @JsonKey(name: 'document')
  final String? fileUrl;

  @JsonKey(name: 'document_type')
  final String documentType;

  @JsonKey(name: 'document_type_display')
  final String documentTypeDisplay;

  final String title;

  PropertyDocument({
    required this.id,
    this.fileUrl,
    required this.documentType,
    required this.documentTypeDisplay,
    required this.title,
  });

  factory PropertyDocument.fromJson(Map<String, dynamic> json) => _$PropertyDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyDocumentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PropertyModel {
  final int id;

  @JsonKey(name: 'project')
  final ProjectInfo project;

  // GÜNCELLEME: island ve parcel kaldırıldı
  // final String? island;
  // final String? parcel;

  final String block;
  final int floor;

  @JsonKey(name: 'unit_number')
  final String unitNumber;

  final String facade;

  @JsonKey(name: 'facade_display')
  final String? facadeDisplay;

  @JsonKey(name: 'property_type')

  final String propertyType;

  @JsonKey(name: 'property_type_display')
  final String? propertyTypeDisplay;

  @JsonKey(name: 'room_count')
  final String roomCount;

  @JsonKey(name: 'gross_area_m2')
  final double grossAreaM2;

  @JsonKey(name: 'net_area_m2')
  final double netAreaM2;

  @JsonKey(name: 'cash_price')
  final double cashPrice;

  @JsonKey(name: 'installment_price')
  final double? installmentPrice;

  final String status;

  @JsonKey(name: 'status_display')
  final String? statusDisplay;

  final String? description;

  @JsonKey(name: 'created_by')
  final int? createdBy;

  @JsonKey(name: 'created_by_name')
  final String? createdByName;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final String? thumbnail;

  @JsonKey(defaultValue: [])
  final List<PropertyImage> images;

  @JsonKey(defaultValue: [])
  final List<PropertyDocument> documents;

  @JsonKey(name: 'payment_plans', defaultValue: [])
  final List<PaymentPlanModel> paymentPlans;

  // **** YENİ KDV ALANLARI BAŞLANGIÇ ****
  @JsonKey(name: 'vat_rate')
  final double vatRate;

  @JsonKey(name: 'cash_price_with_vat')
  final double cashPriceWithVat;

  @JsonKey(name: 'installment_price_with_vat')
  final double? installmentPriceWithVat;

  @JsonKey(name: 'vat_amount_cash')
  final double vatAmountCash;

  @JsonKey(name: 'vat_amount_installment')
  final double? vatAmountInstallment;
  // **** YENİ KDV ALANLARI SON ****

  PropertyModel({
    required this.id,
    required this.project,
    // this.island, // Kaldırıldı
    // this.parcel, // Kaldırıldı
    required this.block,
    required this.floor,
    required this.unitNumber,
    required this.facade,
    this.facadeDisplay,
    required this.propertyType,
    this.propertyTypeDisplay,
    required this.roomCount,
    required this.grossAreaM2,
    required this.netAreaM2,
    required this.cashPrice,
    this.installmentPrice,

    required this.status,
    this.statusDisplay,
    this.description,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnail,
    required this.images,
    required this.documents,
    required this.paymentPlans,
    // **** YENİ KDV ALANLARI BAŞLANGIÇ ****
    required this.vatRate,
    required this.cashPriceWithVat,
    this.installmentPriceWithVat,
    required this.vatAmountCash,
    this.vatAmountInstallment,
    // **** YENİ KDV ALANLARI SON ****
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => _$PropertyModelFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);

  String get fullAddress => '${project.name} - $block Blok - Kat: $floor - No: $unitNumber';

  bool get isAvailable => status == 'SATILABILIR';
  bool get isReserved => status == 'REZERVE';
  bool get isSold => status == 'SATILDI';

  Color get statusColor {
    switch (status) {
      case 'SATILABILIR':
        return Colors.green;
      case 'REZERVE':
        return Colors.orange;
      case 'SATILDI':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
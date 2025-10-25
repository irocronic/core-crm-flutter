// lib/features/reservations/data/models/reservation_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'reservation_model.g.dart';

// YENİ EKLENDİ: Proje nesnesini parse etmek için.
@JsonSerializable()
class ProjectSummary {
  final int id;
  final String name;

  ProjectSummary({required this.id, required this.name});

  factory ProjectSummary.fromJson(Map<String, dynamic> json) =>
      _$ProjectSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReservationModel {
  final int id;
  final int property;
  @JsonKey(name: 'property_info')
  final PropertyInfo? propertyInfo;
  final int customer;
  @JsonKey(name: 'customer_info')
  final CustomerInfo? customerInfo;
  @JsonKey(name: 'sales_rep')
  final int? salesRep;
  @JsonKey(name: 'sales_rep_name')
  final String? salesRepName;

  @JsonKey(name: 'payment_plan_selected')
  final int? paymentPlanSelected;
  @JsonKey(name: 'payment_type')
  final String? paymentType;
  @JsonKey(name: 'payment_type_display')
  final String? paymentTypeDisplay;
  @JsonKey(name: 'installment_count')
  final int? installmentCount;

  @JsonKey(name: 'deposit_amount')
  final double depositAmount;
  @JsonKey(name: 'deposit_payment_method')
  final String depositPaymentMethod;
  @JsonKey(name: 'deposit_payment_method_display')
  final String? depositPaymentMethodDisplay;
  @JsonKey(name: 'deposit_receipt_number')
  final String? depositReceiptNumber;

  final String status;
  @JsonKey(name: 'status_display')
  final String? statusDisplay;
  @JsonKey(name: 'reservation_date')
  final DateTime reservationDate;
  @JsonKey(name: 'expiry_date')
  final DateTime? expiryDate;
  final String? notes;
  @JsonKey(name: 'remaining_amount')
  final double? remainingAmount;
  @JsonKey(name: 'is_expired')
  final bool? isExpired;
  @JsonKey(name: 'payments_count')
  final int? paymentsCount;
  @JsonKey(name: 'created_by')
  final int? createdBy;
  @JsonKey(name: 'recorded_by_name')
  final String? recordedByName;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final List<PaymentInfo>? payments;

  ReservationModel({
    required this.id,
    required this.property,
    this.propertyInfo,
    required this.customer,
    this.customerInfo,
    this.salesRep,
    this.salesRepName,
    this.paymentPlanSelected,
    this.paymentType,
    this.paymentTypeDisplay,
    this.installmentCount,
    required this.depositAmount,
    required this.depositPaymentMethod,
    this.depositPaymentMethodDisplay,
    this.depositReceiptNumber,
    required this.status,
    this.statusDisplay,
    required this.reservationDate,
    this.expiryDate,
    this.notes,
    this.remainingAmount,
    this.isExpired,
    this.paymentsCount,
    this.createdBy,
    this.recordedByName,
    required this.createdAt,
    required this.updatedAt,
    this.payments,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationModelToJson(this);

  bool get isActive => status == 'AKTIF';
  bool get isConverted => status == 'SATISA_DONUSTU';
  bool get isCancelled => status == 'IPTAL_EDILDI';

  Color get statusColor {
    switch (status) {
      case 'AKTIF':
        return Colors.green;
      case 'SATISA_DONUSTU':
        return Colors.blue;
      case 'IPTAL_EDILDI':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

@JsonSerializable(explicitToJson: true)
class PropertyInfo {
  final int id;
  // GÜNCELLEME: project_name alanı project nesnesi ile değiştirildi
  @JsonKey(name: 'project')
  final ProjectSummary project;
  final String block;
  final int floor;
  @JsonKey(name: 'unit_number')
  final String unitNumber;
  @JsonKey(name: 'room_count')
  final String roomCount;
  @JsonKey(name: 'property_type')
  final String? propertyType;
  @JsonKey(name: 'cash_price')
  final double? cashPrice;
  @JsonKey(name: 'installment_price')
  final double? installmentPrice;

  PropertyInfo({
    required this.id,
    // GÜNCELLEME
    required this.project,
    required this.block,
    required this.floor,
    required this.unitNumber,
    required this.roomCount,
    this.propertyType,
    this.cashPrice,
    this.installmentPrice,
  });

  factory PropertyInfo.fromJson(Map<String, dynamic> json) =>
      _$PropertyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyInfoToJson(this);

  // GÜNCELLEME: Adres bilgisi project.name'den alınıyor
  String get fullAddress =>
      '${project.name} - $block Blok - Kat: $floor - No: $unitNumber';
}

@JsonSerializable()
class CustomerInfo {
  final int id;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String? email;
  final String? address;

  CustomerInfo({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.address,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$CustomerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerInfoToJson(this);
}

@JsonSerializable()
class PaymentInfo {
  final int id;
  @JsonKey(name: 'payment_type')
  final String paymentType;
  @JsonKey(name: 'payment_type_display')
  final String? paymentTypeDisplay;
  final double amount;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'payment_method_display')
  final String? paymentMethodDisplay;
  final String status;
  @JsonKey(name: 'status_display')
  final String? statusDisplay;
  @JsonKey(name: 'due_date')
  final String dueDate;
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @JsonKey(name: 'receipt_number')
  final String? receiptNumber;
  @JsonKey(name: 'installment_number')
  final int? installmentNumber;
  final String? notes;

  PaymentInfo({
    required this.id,
    required this.paymentType,
    this.paymentTypeDisplay,
    required this.amount,
    this.paymentMethod,
    this.paymentMethodDisplay,
    required this.status,
    this.statusDisplay,
    required this.dueDate,
    this.paymentDate,
    this.receiptNumber,
    this.installmentNumber,
    this.notes,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) =>
      _$PaymentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInfoToJson(this);
}
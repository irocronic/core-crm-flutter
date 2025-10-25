// lib/features/contracts/data/models/contract_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'contract_model.freezed.dart'; // Bu satır kalmalı
part 'contract_model.g.dart'; // Bu satır kalmalı

/// Contract Type Enum
enum ContractType {
  @JsonValue('REZERVASYON')
  reservation,
  @JsonValue('SATIS')
  sales,
  @JsonValue('ON_SOZLESME')
  preSales,
}

/// Contract Status Enum
enum ContractStatus {
  @JsonValue('TASLAK')
  draft,
  @JsonValue('ONAY_BEKLIYOR')
  pendingApproval,
  @JsonValue('IMZALANDI')
  signed,
  @JsonValue('IPTAL')
  cancelled,
}

/// Contract Model
@freezed
// ✅ DEĞİŞİKLİK: 'class ContractModel' yerine 'abstract class ContractModel'
abstract class ContractModel with _$ContractModel {
  // ✅ DEĞİŞİKLİK: const factory constructor eklendi
  const factory ContractModel({
    required int id,
    @JsonKey(name: 'contract_number') required String contractNumber,
    @JsonKey(name: 'contract_type') required ContractType contractType,
    required ContractStatus status,
    @JsonKey(name: 'reservation') int? reservationId,
    @JsonKey(name: 'reservation_details') ReservationDetails? reservationDetails,
    @JsonKey(name: 'sale') int? saleId,
    @JsonKey(name: 'sale_details') SaleDetails? saleDetails,
    @JsonKey(name: 'contract_date') required DateTime contractDate,
    @JsonKey(name: 'contract_file') String? contractFile,
    @JsonKey(name: 'signed_date') DateTime? signedDate,
    @JsonKey(name: 'cancelled_date') DateTime? cancelledDate,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    String? notes,
    @JsonKey(name: 'created_by') int? createdBy,
    @JsonKey(name: 'created_by_name') String? createdByName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ContractModel; // ✅ DEĞİŞİKLİK: Implementasyon sınıfı (_ContractModel)

  factory ContractModel.fromJson(Map<String, dynamic> json) =>
      _$ContractModelFromJson(json); // ✅ Bu satır kalmalı
}

/// Reservation Details (Nested in Contract)
@freezed
// ✅ DEĞİŞİKLİK: 'class ReservationDetails' yerine 'abstract class ReservationDetails'
abstract class ReservationDetails with _$ReservationDetails {
  // ✅ DEĞİŞİKLİK: const factory constructor eklendi
  const factory ReservationDetails({
    required int id,
    @JsonKey(name: 'reservation_number') required String reservationNumber,
    @JsonKey(name: 'customer') required CustomerSummary customer,
    @JsonKey(name: 'property') required PropertySummary property,
    @JsonKey(name: 'reservation_date') required DateTime reservationDate,
    @JsonKey(name: 'reservation_amount') required String reservationAmount,
  }) = _ReservationDetails; // ✅ DEĞİŞİKLİK: Implementasyon sınıfı (_ReservationDetails)

  factory ReservationDetails.fromJson(Map<String, dynamic> json) =>
      _$ReservationDetailsFromJson(json); // ✅ Bu satır kalmalı
}

/// Sale Details (Nested in Contract)
@freezed
// ✅ DEĞİŞİKLİK: 'class SaleDetails' yerine 'abstract class SaleDetails'
abstract class SaleDetails with _$SaleDetails {
  // ✅ DEĞİŞİKLİK: const factory constructor eklendi
  const factory SaleDetails({
    required int id,
    @JsonKey(name: 'sale_number') required String saleNumber,
    @JsonKey(name: 'customer') required CustomerSummary customer,
    @JsonKey(name: 'property') required PropertySummary property,
    @JsonKey(name: 'sale_date') required DateTime saleDate,
    @JsonKey(name: 'sale_price') required String salePrice,
    @JsonKey(name: 'payment_plan') required String paymentPlan,
  }) = _SaleDetails; // ✅ DEĞİŞİKLİK: Implementasyon sınıfı (_SaleDetails)

  factory SaleDetails.fromJson(Map<String, dynamic> json) =>
      _$SaleDetailsFromJson(json); // ✅ Bu satır kalmalı
}

/// Customer Summary (Nested in Contract Details)
@freezed
// ✅ DEĞİŞİKLİK: 'class CustomerSummary' yerine 'abstract class CustomerSummary'
abstract class CustomerSummary with _$CustomerSummary {
  // ✅ DEĞİŞİKLİK: const factory constructor eklendi
  const factory CustomerSummary({
    required int id,
    @JsonKey(name: 'full_name') required String fullName,
    String? phone,
    String? email,
  }) = _CustomerSummary; // ✅ DEĞİŞİKLİK: Implementasyon sınıfı (_CustomerSummary)

  factory CustomerSummary.fromJson(Map<String, dynamic> json) =>
      _$CustomerSummaryFromJson(json); // ✅ Bu satır kalmalı
}

/// Property Summary (Nested in Contract Details)
@freezed
// ✅ DEĞİŞİKLİK: 'class PropertySummary' yerine 'abstract class PropertySummary'
abstract class PropertySummary with _$PropertySummary {
  // ✅ DEĞİŞİKLİK: const factory constructor eklendi
  const factory PropertySummary({
    required int id,
    required String title,
    @JsonKey(name: 'property_type') required String propertyType,
    @JsonKey(name: 'block_number') String? blockNumber,
    @JsonKey(name: 'floor_number') int? floorNumber,
    @JsonKey(name: 'apartment_number') String? apartmentNumber,
  }) = _PropertySummary; // ✅ DEĞİŞİKLİK: Implementasyon sınıfı (_PropertySummary)

  factory PropertySummary.fromJson(Map<String, dynamic> json) =>
      _$PropertySummaryFromJson(json); // ✅ Bu satır kalmalı
}


/// Contract Type Extension
extension ContractTypeExtension on ContractType {
  String get displayName {
    switch (this) {
      case ContractType.reservation:
        return 'Rezervasyon';
      case ContractType.sales:
        return 'Satış';
      case ContractType.preSales:
        return 'Ön Sözleşme';
    }
  }

  String get apiValue {
    switch (this) {
      case ContractType.reservation:
        return 'REZERVASYON';
      case ContractType.sales:
        return 'SATIS';
      case ContractType.preSales:
        return 'ON_SOZLESME';
    }
  }
}

/// Contract Status Extension
extension ContractStatusExtension on ContractStatus {
  String get displayName {
    switch (this) {
      case ContractStatus.draft:
        return 'Taslak';
      case ContractStatus.pendingApproval:
        return 'Onay Bekliyor';
      case ContractStatus.signed:
        return 'İmzalandı';
      case ContractStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  String get apiValue {
    switch (this) {
      case ContractStatus.draft:
        return 'TASLAK';
      case ContractStatus.pendingApproval:
        return 'ONAY_BEKLIYOR';
      case ContractStatus.signed:
        return 'IMZALANDI';
      case ContractStatus.cancelled:
        return 'IPTAL';
    }
  }
}
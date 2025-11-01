// lib/features/contracts/data/models/contract_model.dart

import 'package:flutter/foundation.dart';
import '../../../settings/data/models/seller_company_model.dart';

/// Contract Type Enum
enum ContractType {
  reservation('REZERVASYON', 'Rezervasyon Sözleşmesi'),
  sale('SATIS', 'Satış Sözleşmesi'),
  preSale('ON_SOZLESME', 'Ön Sözleşme');

  final String apiValue;
  final String displayName;

  const ContractType(this.apiValue, this.displayName);

  static ContractType fromString(String value) {
    return ContractType.values.firstWhere(
          (e) => e.apiValue == value,
      orElse: () => ContractType.reservation,
    );
  }
}

/// Contract Status Enum
enum ContractStatus {
  draft('TASLAK', 'Taslak'),
  pendingApproval('ONAY_BEKLIYOR', 'Onay Bekliyor'),
  signed('IMZALANDI', 'İmzalandı'),
  cancelled('IPTAL', 'İptal Edildi');

  final String apiValue;
  final String displayName;

  const ContractStatus(this.apiValue, this.displayName);

  static ContractStatus fromString(String value) {
    return ContractStatus.values.firstWhere(
          (e) => e.apiValue == value,
      orElse: () => ContractStatus.draft,
    );
  }
}

// ============================================================
// NESTED MODELS
// ============================================================

/// Customer Basic Info (Nested)
class CustomerBasicInfo {
  final int id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  // **** YENİ: Alıcı Detayları (PDF için) ****
  final BuyerDetails? buyerDetails;

  CustomerBasicInfo({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.buyerDetails, // **** YENİ ****
  });

  factory CustomerBasicInfo.fromJson(Map<String, dynamic> json) {
    return CustomerBasicInfo(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      // **** YENİ ****
      buyerDetails: json['buyer_details'] != null
          ? BuyerDetails.fromJson(json['buyer_details'] as Map<String, dynamic>)
          : null,
    );
  }

  String? get phone => phoneNumber;
}

// **** YENİ: BuyerDetails (minimal) ****
class BuyerDetails {
  final String? tcNumber;
  final String? businessAddress; // Tebligat adresi olarak bunu kullanabiliriz

  BuyerDetails({this.tcNumber, this.businessAddress});

  factory BuyerDetails.fromJson(Map<String, dynamic> json) {
    return BuyerDetails(
      tcNumber: json['tc_number'] as String?,
      businessAddress: json['business_address'] as String?,
    );
  }
}

/// Property Basic Info (Nested)
/// ✅ GÜNCELLENDİ: Tüm proje detayları eklendi
class PropertyBasicInfo {
  final int id;
  final String block;
  final int floor;
  final String unitNumber;
  final String propertyType;
  final String roomCount;
  final String? projectName;
  final String? netArea;
  // **** YENİ ALANLAR ****
  final String? projectProvince;
  final String? projectDistrict;
  final String? projectLocation; // Mahalle
  final String? projectIsland;   // Ada
  final String? projectParcel;   // Pafta
  // **** YENİ ALANLAR SONU ****

  PropertyBasicInfo({
    required this.id,
    required this.block,
    required this.floor,
    required this.unitNumber,
    required this.propertyType,
    required this.roomCount,
    this.projectName,
    this.netArea,
    // **** YENİ PARAMETRELER ****
    this.projectProvince,
    this.projectDistrict,
    this.projectLocation,
    this.projectIsland,
    this.projectParcel,
    // **** YENİ PARAMETRELER SONU ****
  });

  factory PropertyBasicInfo.fromJson(Map<String, dynamic> json) {
    return PropertyBasicInfo(
      id: json['id'] as int,
      block: json['block'] as String? ?? '',
      floor: json['floor'] as int? ?? 0,
      unitNumber: json['unit_number'] as String,
      propertyType: json['property_type'] as String,
      roomCount: json['room_count'] as String,
      projectName: json['project_name'] as String?,
      netArea: json['net_area'] as String?,
      // **** YENİ JSON OKUMALARI ****
      projectProvince: json['project_province'] as String?,
      projectDistrict: json['project_district'] as String?,
      projectLocation: json['project_location'] as String?,
      projectIsland: json['project_island'] as String?,
      projectParcel: json['project_parcel'] as String?,
      // **** YENİ JSON OKUMALARI SONU ****
    );
  }

  String get title => '$block Blok Kat $floor No $unitNumber';
  String? get blockNumber => block;
  int? get floorNumber => floor;
  String? get apartmentNumber => unitNumber;
}

/// Payment Plan Basic Info (Nested)
class PaymentPlanBasicInfo {
  final int id;
  final String planType;
  final String name;
  final Map<String, dynamic> details;

  PaymentPlanBasicInfo({
    required this.id,
    required this.planType,
    required this.name,
    required this.details,
  });

  factory PaymentPlanBasicInfo.fromJson(Map<String, dynamic> json) {
    return PaymentPlanBasicInfo(
      id: json['id'] as int,
      planType: json['plan_type'] as String,
      name: json['name'] as String,
      details: json['details'] as Map<String, dynamic>,
    );
  }
}

// ============================================================
// RESERVATION DETAILS
// ============================================================

/// Reservation Details Model
class ReservationDetails {
  final int id;
  final String reservationNumber;
  final DateTime reservationDate;
  final double depositAmount;
  final String depositPaymentMethod;
  final String depositPaymentMethodDisplay;
  final CustomerBasicInfo customer;
  final PropertyBasicInfo property;
  final PaymentPlanBasicInfo? paymentPlanSelected;
  final int? salesRep;
  final String? salesRepName;
  final String status;
  final String statusDisplay;
  final SellerCompanyModel? sellerCompanyInfo;

  ReservationDetails({
    required this.id,
    required this.reservationNumber,
    required this.reservationDate,
    required this.depositAmount,
    required this.depositPaymentMethod,
    required this.depositPaymentMethodDisplay,
    required this.customer,
    required this.property,
    this.paymentPlanSelected,
    this.salesRep,
    this.salesRepName,
    required this.status,
    required this.statusDisplay,
    this.sellerCompanyInfo,
  });

  factory ReservationDetails.fromJson(Map<String, dynamic> json) {
    return ReservationDetails(
      id: json['id'] as int,
      reservationNumber: json['reservation_number'] as String,
      reservationDate: DateTime.parse(json['reservation_date'] as String),
      depositAmount: (json['deposit_amount'] as num).toDouble(),
      depositPaymentMethod: json['deposit_payment_method'] as String,
      depositPaymentMethodDisplay: json['deposit_payment_method_display'] as String,
      customer: CustomerBasicInfo.fromJson(json['customer'] as Map<String, dynamic>),
      property: PropertyBasicInfo.fromJson(json['property'] as Map<String, dynamic>),
      paymentPlanSelected: json['payment_plan_selected'] != null
          ? PaymentPlanBasicInfo.fromJson(json['payment_plan_selected'] as Map<String, dynamic>)
          : null,
      salesRep: json['sales_rep'] as int?,
      salesRepName: json['sales_rep_name'] as String?,
      status: json['status'] as String,
      statusDisplay: json['status_display'] as String,
      sellerCompanyInfo: json['seller_company_info'] != null
          ? SellerCompanyModel.fromJson(json['seller_company_info'] as Map<String, dynamic>)
          : null,
    );
  }

  String get reservationAmount => depositAmount.toString();
}

// ============================================================
// SALE DETAILS
// ============================================================

/// Sale Details Model
class SaleDetails {
  final int id;
  final DateTime saleDate;
  final double salePrice;
  final CustomerBasicInfo customer;
  final PropertyBasicInfo property;
  final String? paymentPlan;

  SaleDetails({
    required this.id,
    required this.saleDate,
    required this.salePrice,
    required this.customer,
    required this.property,
    this.paymentPlan,
  });

  factory SaleDetails.fromJson(Map<String, dynamic> json) {
    return SaleDetails(
      id: json['id'] as int,
      saleDate: DateTime.parse(json['sale_date'] as String),
      salePrice: (json['sale_price'] as num).toDouble(),
      customer: CustomerBasicInfo.fromJson(json['customer'] as Map<String, dynamic>),
      property: PropertyBasicInfo.fromJson(json['property'] as Map<String, dynamic>),
      paymentPlan: json['payment_plan'] as String?,
    );
  }

  String get saleNumber => 'SAT-${id.toString().padLeft(4, '0')}';
  String get salePriceString => salePrice.toString();
}

// ============================================================
// CONTRACT MODEL
// ============================================================

/// Contract Model
class ContractModel {
  final int id;
  final int? reservationId;
  final ReservationDetails? reservationDetails;
  final int? saleId;
  final SaleDetails? saleDetails;
  final ContractType contractType;
  final String contractNumber;
  final String? contractFile;
  final ContractStatus status;
  final DateTime contractDate;
  final DateTime? signedDate;
  final DateTime? cancelledDate;
  final String? cancellationReason;
  final String? notes;
  final int? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContractModel({
    required this.id,
    this.reservationId,
    this.reservationDetails,
    this.saleId,
    this.saleDetails,
    required this.contractType,
    required this.contractNumber,
    this.contractFile,
    required this.status,
    required this.contractDate,
    this.signedDate,
    this.cancelledDate,
    this.cancellationReason,
    this.notes,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    try {
      return ContractModel(
        id: json['id'] as int,
        reservationId: json['reservation'] as int?,
        reservationDetails: json['reservation_details'] != null
            ? ReservationDetails.fromJson(json['reservation_details'] as Map<String, dynamic>)
            : null,
        saleId: json['sale'] as int?,
        saleDetails: json['sale_details'] != null
            ? SaleDetails.fromJson(json['sale_details'] as Map<String, dynamic>)
            : null,
        contractType: ContractType.fromString(json['contract_type'] as String),
        contractNumber: json['contract_number'] as String,
        contractFile: json['contract_file'] as String?,
        status: ContractStatus.fromString(json['status'] as String),
        contractDate: DateTime.parse(json['contract_date'] as String),
        signedDate: json['signed_date'] != null
            ? DateTime.parse(json['signed_date'] as String)
            : null,
        cancelledDate: json['cancelled_date'] != null
            ? DateTime.parse(json['cancelled_date'] as String)
            : null,
        cancellationReason: json['cancellation_reason'] as String?,
        notes: json['notes'] as String?,
        createdBy: json['created_by'] as int?,
        createdByName: json['created_by_name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ContractModel.fromJson error: $e');
      debugPrint('📦 JSON data: $json');
      debugPrint('📄 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation': reservationId,
      'sale': saleId,
      'contract_type': contractType.apiValue,
      'contract_number': contractNumber,
      'contract_file': contractFile,
      'status': status.apiValue,
      'contract_date': contractDate.toIso8601String().split('T')[0],
      'signed_date': signedDate?.toIso8601String().split('T')[0],
      'cancelled_date': cancelledDate?.toIso8601String().split('T')[0],
      'cancellation_reason': cancellationReason,
      'notes': notes,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ContractModel copyWith({
    int? id,
    int? reservationId,
    ReservationDetails? reservationDetails,
    int? saleId,
    SaleDetails? saleDetails,
    ContractType? contractType,
    String? contractNumber,
    String? contractFile,
    ContractStatus? status,
    DateTime? contractDate,
    DateTime? signedDate,
    DateTime? cancelledDate,
    String? cancellationReason,
    String? notes,
    int? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractModel(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      reservationDetails: reservationDetails ?? this.reservationDetails,
      saleId: saleId ?? this.saleId,
      saleDetails: saleDetails ?? this.saleDetails,
      contractType: contractType ?? this.contractType,
      contractNumber: contractNumber ?? this.contractNumber,
      contractFile: contractFile ?? this.contractFile,
      status: status ?? this.status,
      contractDate: contractDate ?? this.contractDate,
      signedDate: signedDate ?? this.signedDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ContractModel(id: $id, contractNumber: $contractNumber, type: ${contractType.displayName}, status: ${status.displayName})';
  }
}
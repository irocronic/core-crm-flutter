// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContractModel _$ContractModelFromJson(Map<String, dynamic> json) =>
    _ContractModel(
      id: (json['id'] as num).toInt(),
      contractNumber: json['contract_number'] as String,
      contractType: $enumDecode(_$ContractTypeEnumMap, json['contract_type']),
      status: $enumDecode(_$ContractStatusEnumMap, json['status']),
      reservationId: (json['reservation'] as num?)?.toInt(),
      reservationDetails: json['reservation_details'] == null
          ? null
          : ReservationDetails.fromJson(
              json['reservation_details'] as Map<String, dynamic>,
            ),
      saleId: (json['sale'] as num?)?.toInt(),
      saleDetails: json['sale_details'] == null
          ? null
          : SaleDetails.fromJson(json['sale_details'] as Map<String, dynamic>),
      contractDate: DateTime.parse(json['contract_date'] as String),
      contractFile: json['contract_file'] as String?,
      signedDate: json['signed_date'] == null
          ? null
          : DateTime.parse(json['signed_date'] as String),
      cancelledDate: json['cancelled_date'] == null
          ? null
          : DateTime.parse(json['cancelled_date'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
      notes: json['notes'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByName: json['created_by_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ContractModelToJson(_ContractModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contract_number': instance.contractNumber,
      'contract_type': _$ContractTypeEnumMap[instance.contractType]!,
      'status': _$ContractStatusEnumMap[instance.status]!,
      'reservation': instance.reservationId,
      'reservation_details': instance.reservationDetails,
      'sale': instance.saleId,
      'sale_details': instance.saleDetails,
      'contract_date': instance.contractDate.toIso8601String(),
      'contract_file': instance.contractFile,
      'signed_date': instance.signedDate?.toIso8601String(),
      'cancelled_date': instance.cancelledDate?.toIso8601String(),
      'cancellation_reason': instance.cancellationReason,
      'notes': instance.notes,
      'created_by': instance.createdBy,
      'created_by_name': instance.createdByName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ContractTypeEnumMap = {
  ContractType.reservation: 'REZERVASYON',
  ContractType.sales: 'SATIS',
  ContractType.preSales: 'ON_SOZLESME',
};

const _$ContractStatusEnumMap = {
  ContractStatus.draft: 'TASLAK',
  ContractStatus.pendingApproval: 'ONAY_BEKLIYOR',
  ContractStatus.signed: 'IMZALANDI',
  ContractStatus.cancelled: 'IPTAL',
};

_ReservationDetails _$ReservationDetailsFromJson(
  Map<String, dynamic> json,
) => _ReservationDetails(
  id: (json['id'] as num).toInt(),
  reservationNumber: json['reservation_number'] as String,
  customer: CustomerSummary.fromJson(json['customer'] as Map<String, dynamic>),
  property: PropertySummary.fromJson(json['property'] as Map<String, dynamic>),
  reservationDate: DateTime.parse(json['reservation_date'] as String),
  reservationAmount: json['reservation_amount'] as String,
);

Map<String, dynamic> _$ReservationDetailsToJson(_ReservationDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reservation_number': instance.reservationNumber,
      'customer': instance.customer,
      'property': instance.property,
      'reservation_date': instance.reservationDate.toIso8601String(),
      'reservation_amount': instance.reservationAmount,
    };

_SaleDetails _$SaleDetailsFromJson(Map<String, dynamic> json) => _SaleDetails(
  id: (json['id'] as num).toInt(),
  saleNumber: json['sale_number'] as String,
  customer: CustomerSummary.fromJson(json['customer'] as Map<String, dynamic>),
  property: PropertySummary.fromJson(json['property'] as Map<String, dynamic>),
  saleDate: DateTime.parse(json['sale_date'] as String),
  salePrice: json['sale_price'] as String,
  paymentPlan: json['payment_plan'] as String,
);

Map<String, dynamic> _$SaleDetailsToJson(_SaleDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sale_number': instance.saleNumber,
      'customer': instance.customer,
      'property': instance.property,
      'sale_date': instance.saleDate.toIso8601String(),
      'sale_price': instance.salePrice,
      'payment_plan': instance.paymentPlan,
    };

_CustomerSummary _$CustomerSummaryFromJson(Map<String, dynamic> json) =>
    _CustomerSummary(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$CustomerSummaryToJson(_CustomerSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
    };

_PropertySummary _$PropertySummaryFromJson(Map<String, dynamic> json) =>
    _PropertySummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      propertyType: json['property_type'] as String,
      blockNumber: json['block_number'] as String?,
      floorNumber: (json['floor_number'] as num?)?.toInt(),
      apartmentNumber: json['apartment_number'] as String?,
    );

Map<String, dynamic> _$PropertySummaryToJson(_PropertySummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'property_type': instance.propertyType,
      'block_number': instance.blockNumber,
      'floor_number': instance.floorNumber,
      'apartment_number': instance.apartmentNumber,
    };

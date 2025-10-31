// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuyerDetailsModel _$BuyerDetailsModelFromJson(Map<String, dynamic> json) =>
    BuyerDetailsModel(
      id: (json['id'] as num).toInt(),
      customer: (json['customer'] as num).toInt(),
      customerName: json['customer_name'] as String?,
      buyerType: json['buyer_type'] as String,
      buyerTypeDisplay: json['buyer_type_display'] as String?,
      tcNumber: json['tc_number'] as String?,
      companyName: json['company_name'] as String?,
      taxOffice: json['tax_office'] as String?,
      taxNumber: json['tax_number'] as String?,
      businessPhone: json['business_phone'] as String?,
      businessAddress: json['business_address'] as String?,
      notes: json['notes'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByName: json['created_by_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BuyerDetailsModelToJson(BuyerDetailsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer': instance.customer,
      'customer_name': instance.customerName,
      'buyer_type': instance.buyerType,
      'buyer_type_display': instance.buyerTypeDisplay,
      'tc_number': instance.tcNumber,
      'company_name': instance.companyName,
      'tax_office': instance.taxOffice,
      'tax_number': instance.taxNumber,
      'business_phone': instance.businessPhone,
      'business_address': instance.businessAddress,
      'notes': instance.notes,
      'created_by': instance.createdBy,
      'created_by_name': instance.createdByName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
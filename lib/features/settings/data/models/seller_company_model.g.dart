// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerCompanyModel _$SellerCompanyModelFromJson(Map<String, dynamic> json) =>
    SellerCompanyModel(
      id: (json['id'] as num).toInt(),
      companyName: json['company_name'] as String,
      businessAddress: json['business_address'] as String,
      businessPhone: json['business_phone'] as String,
      taxOffice: json['tax_office'] as String,
      taxNumber: json['tax_number'] as String,
      mersisNumber: json['mersis_number'] as String,
      isActive: json['is_active'] as bool,
      notes: json['notes'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByName: json['created_by_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SellerCompanyModelToJson(SellerCompanyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_name': instance.companyName,
      'business_address': instance.businessAddress,
      'business_phone': instance.businessPhone,
      'tax_office': instance.taxOffice,
      'tax_number': instance.taxNumber,
      'mersis_number': instance.mersisNumber,
      'is_active': instance.isActive,
      'notes': instance.notes,
      'created_by': instance.createdBy,
      'created_by_name': instance.createdByName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
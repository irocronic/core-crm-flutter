// lib/features/settings/data/models/seller_company_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'seller_company_model.g.dart';

@JsonSerializable()
class SellerCompanyModel {
  final int id;
  @JsonKey(name: 'company_name')
  final String companyName;
  @JsonKey(name: 'business_address')
  final String businessAddress;
  @JsonKey(name: 'business_phone')
  final String businessPhone;
  @JsonKey(name: 'tax_office')
  final String taxOffice;
  @JsonKey(name: 'tax_number')
  final String taxNumber;
  @JsonKey(name: 'mersis_number')
  final String mersisNumber;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final String? notes;
  @JsonKey(name: 'created_by')
  final int? createdBy;
  @JsonKey(name: 'created_by_name')
  final String? createdByName;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  SellerCompanyModel({
    required this.id,
    required this.companyName,
    required this.businessAddress,
    required this.businessPhone,
    required this.taxOffice,
    required this.taxNumber,
    required this.mersisNumber,
    required this.isActive,
    this.notes,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SellerCompanyModel.fromJson(Map<String, dynamic> json) =>
      _$SellerCompanyModelFromJson(json);

  Map<String, dynamic> toJson() => _$SellerCompanyModelToJson(this);
}
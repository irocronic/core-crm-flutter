// lib/features/sales/data/models/buyer_details_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'buyer_details_model.g.dart';

@JsonSerializable()
class BuyerDetailsModel {
  final int id;
  final int customer;
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @JsonKey(name: 'buyer_type')
  final String buyerType;
  @JsonKey(name: 'buyer_type_display')
  final String? buyerTypeDisplay;
  @JsonKey(name: 'tc_number')
  final String? tcNumber;
  @JsonKey(name: 'company_name')
  final String? companyName;
  @JsonKey(name: 'tax_office')
  final String? taxOffice;
  @JsonKey(name: 'tax_number')
  final String? taxNumber;
  @JsonKey(name: 'business_phone')
  final String? businessPhone;
  @JsonKey(name: 'business_address')
  final String? businessAddress;
  final String? notes;
  @JsonKey(name: 'created_by')
  final int? createdBy;
  @JsonKey(name: 'created_by_name')
  final String? createdByName;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  BuyerDetailsModel({
    required this.id,
    required this.customer,
    this.customerName,
    required this.buyerType,
    this.buyerTypeDisplay,
    this.tcNumber,
    this.companyName,
    this.taxOffice,
    this.taxNumber,
    this.businessPhone,
    this.businessAddress,
    this.notes,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BuyerDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$BuyerDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$BuyerDetailsModelToJson(this);

  // Helper enum
  BuyerDetailType get typeEnum =>
      buyerType == 'TUZEL_KISI' ? BuyerDetailType.tuzel : BuyerDetailType.gercek;
}

enum BuyerDetailType { gercek, tuzel }
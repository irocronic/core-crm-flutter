// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectSummary _$ProjectSummaryFromJson(Map<String, dynamic> json) =>
    ProjectSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ProjectSummaryToJson(ProjectSummary instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

ReservationModel _$ReservationModelFromJson(
  Map<String, dynamic> json,
) => ReservationModel(
  id: (json['id'] as num).toInt(),
  property: (json['property'] as num).toInt(),
  propertyInfo: json['property_info'] == null
      ? null
      : PropertyInfo.fromJson(json['property_info'] as Map<String, dynamic>),
  customer: (json['customer'] as num).toInt(),
  customerInfo: json['customer_info'] == null
      ? null
      : CustomerInfo.fromJson(json['customer_info'] as Map<String, dynamic>),
  salesRep: (json['sales_rep'] as num?)?.toInt(),
  salesRepName: json['sales_rep_name'] as String?,
  paymentPlanSelected: (json['payment_plan_selected'] as num?)?.toInt(),
  paymentType: json['payment_type'] as String?,
  paymentTypeDisplay: json['payment_type_display'] as String?,
  installmentCount: (json['installment_count'] as num?)?.toInt(),
  depositAmount: (json['deposit_amount'] as num).toDouble(),
  depositPaymentMethod: json['deposit_payment_method'] as String,
  depositPaymentMethodDisplay:
      json['deposit_payment_method_display'] as String?,
  depositReceiptNumber: json['deposit_receipt_number'] as String?,
  status: json['status'] as String,
  statusDisplay: json['status_display'] as String?,
  reservationDate: DateTime.parse(json['reservation_date'] as String),
  expiryDate: json['expiry_date'] == null
      ? null
      : DateTime.parse(json['expiry_date'] as String),
  notes: json['notes'] as String?,
  remainingAmount: (json['remaining_amount'] as num?)?.toDouble(),
  isExpired: json['is_expired'] as bool?,
  paymentsCount: (json['payments_count'] as num?)?.toInt(),
  createdBy: (json['created_by'] as num?)?.toInt(),
  recordedByName: json['recorded_by_name'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  payments: (json['payments'] as List<dynamic>?)
      ?.map((e) => PaymentInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReservationModelToJson(ReservationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'property': instance.property,
      'property_info': instance.propertyInfo?.toJson(),
      'customer': instance.customer,
      'customer_info': instance.customerInfo?.toJson(),
      'sales_rep': instance.salesRep,
      'sales_rep_name': instance.salesRepName,
      'payment_plan_selected': instance.paymentPlanSelected,
      'payment_type': instance.paymentType,
      'payment_type_display': instance.paymentTypeDisplay,
      'installment_count': instance.installmentCount,
      'deposit_amount': instance.depositAmount,
      'deposit_payment_method': instance.depositPaymentMethod,
      'deposit_payment_method_display': instance.depositPaymentMethodDisplay,
      'deposit_receipt_number': instance.depositReceiptNumber,
      'status': instance.status,
      'status_display': instance.statusDisplay,
      'reservation_date': instance.reservationDate.toIso8601String(),
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'notes': instance.notes,
      'remaining_amount': instance.remainingAmount,
      'is_expired': instance.isExpired,
      'payments_count': instance.paymentsCount,
      'created_by': instance.createdBy,
      'recorded_by_name': instance.recordedByName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'payments': instance.payments?.map((e) => e.toJson()).toList(),
    };

PropertyInfo _$PropertyInfoFromJson(Map<String, dynamic> json) => PropertyInfo(
  id: (json['id'] as num).toInt(),
  project: ProjectSummary.fromJson(json['project'] as Map<String, dynamic>),
  block: json['block'] as String,
  floor: (json['floor'] as num).toInt(),
  unitNumber: json['unit_number'] as String,
  roomCount: json['room_count'] as String,
  propertyType: json['property_type'] as String?,
  cashPrice: (json['cash_price'] as num?)?.toDouble(),
  installmentPrice: (json['installment_price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PropertyInfoToJson(PropertyInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project': instance.project.toJson(),
      'block': instance.block,
      'floor': instance.floor,
      'unit_number': instance.unitNumber,
      'room_count': instance.roomCount,
      'property_type': instance.propertyType,
      'cash_price': instance.cashPrice,
      'installment_price': instance.installmentPrice,
    };

CustomerInfo _$CustomerInfoFromJson(Map<String, dynamic> json) => CustomerInfo(
  id: (json['id'] as num).toInt(),
  fullName: json['full_name'] as String,
  phoneNumber: json['phone_number'] as String,
  email: json['email'] as String?,
  address: json['address'] as String?,
);

Map<String, dynamic> _$CustomerInfoToJson(CustomerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'address': instance.address,
    };

PaymentInfo _$PaymentInfoFromJson(Map<String, dynamic> json) => PaymentInfo(
  id: (json['id'] as num).toInt(),
  paymentType: json['payment_type'] as String,
  paymentTypeDisplay: json['payment_type_display'] as String?,
  amount: (json['amount'] as num).toDouble(),
  paymentMethod: json['payment_method'] as String?,
  paymentMethodDisplay: json['payment_method_display'] as String?,
  status: json['status'] as String,
  statusDisplay: json['status_display'] as String?,
  dueDate: json['due_date'] as String,
  paymentDate: json['payment_date'] as String?,
  receiptNumber: json['receipt_number'] as String?,
  installmentNumber: (json['installment_number'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$PaymentInfoToJson(PaymentInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payment_type': instance.paymentType,
      'payment_type_display': instance.paymentTypeDisplay,
      'amount': instance.amount,
      'payment_method': instance.paymentMethod,
      'payment_method_display': instance.paymentMethodDisplay,
      'status': instance.status,
      'status_display': instance.statusDisplay,
      'due_date': instance.dueDate,
      'payment_date': instance.paymentDate,
      'receipt_number': instance.receiptNumber,
      'installment_number': instance.installmentNumber,
      'notes': instance.notes,
    };

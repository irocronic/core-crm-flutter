// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: (json['id'] as num).toInt(),
  reservation: (json['reservation'] as num).toInt(),
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
  recordedBy: (json['recorded_by'] as num?)?.toInt(),
  recordedByName: json['recorded_by_name'] as String?,
  isOverdue: json['is_overdue'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reservation': instance.reservation,
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
      'recorded_by': instance.recordedBy,
      'recorded_by_name': instance.recordedByName,
      'is_overdue': instance.isOverdue,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

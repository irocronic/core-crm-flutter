// lib/features/sales/data/models/payment_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final int id;
  final int reservation;
  
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
  
  @JsonKey(name: 'recorded_by')
  final int? recordedBy;
  
  @JsonKey(name: 'recorded_by_name')
  final String? recordedByName;
  
  @JsonKey(name: 'is_overdue')
  final bool isOverdue;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.reservation,
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
    this.recordedBy,
    this.recordedByName,
    required this.isOverdue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$PaymentModelFromJson(json);
    } catch (e) {
      print('❌ PaymentModel parse hatası: $e');
      print('📦 JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  // Computed properties
  bool get isPaid => status == 'ALINDI';
  bool get isPending => status == 'BEKLENIYOR';
  bool get isOverdueStatus => status == 'GECIKTI';
  bool get isCancelled => status == 'IPTAL';

  Color get statusColor {
    switch (status) {
      case 'ALINDI':
        return Colors.green;
      case 'BEKLENIYOR':
        return Colors.orange;
      case 'GECIKTI':
        return Colors.red;
      case 'IPTAL':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'ALINDI':
        return Icons.check_circle;
      case 'BEKLENIYOR':
        return Icons.pending;
      case 'GECIKTI':
        return Icons.warning;
      case 'IPTAL':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String get paymentTypeText {
    return paymentTypeDisplay ?? paymentType;
  }

  String get statusText {
    return statusDisplay ?? status;
  }

  String? get paymentMethodText {
    return paymentMethodDisplay ?? paymentMethod;
  }

  // Copy with
  PaymentModel copyWith({
    int? id,
    int? reservation,
    String? paymentType,
    String? paymentTypeDisplay,
    double? amount,
    String? paymentMethod,
    String? paymentMethodDisplay,
    String? status,
    String? statusDisplay,
    String? dueDate,
    String? paymentDate,
    String? receiptNumber,
    int? installmentNumber,
    String? notes,
    int? recordedBy,
    String? recordedByName,
    bool? isOverdue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      reservation: reservation ?? this.reservation,
      paymentType: paymentType ?? this.paymentType,
      paymentTypeDisplay: paymentTypeDisplay ?? this.paymentTypeDisplay,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentMethodDisplay: paymentMethodDisplay ?? this.paymentMethodDisplay,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      notes: notes ?? this.notes,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedByName: recordedByName ?? this.recordedByName,
      isOverdue: isOverdue ?? this.isOverdue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
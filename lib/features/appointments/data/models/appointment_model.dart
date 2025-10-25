// lib/features/appointments/data/models/appointment_model.dart
import 'package:flutter/material.dart';

class AppointmentModel {
  final int? id;
  final int? customer;
  final String? customerName;
  final String? customerPhone;
  final int? salesRep;
  final String? salesRepName;
  final DateTime appointmentDate;
  final String? location;
  final String? status;
  final String? statusDisplay;
  final String? notes;
  final bool reminderSent;
  final bool? isUpcoming;
  final bool? isToday;
  final int? timeUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    this.id,
    this.customer,
    this.customerName,
    this.customerPhone,
    this.salesRep,
    this.salesRepName,
    required this.appointmentDate,
    this.location,
    this.status,
    this.statusDisplay,
    this.notes,
    required this.reminderSent,
    this.isUpcoming,
    this.isToday,
    this.timeUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  // Robust parsing helpers
  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'yes' || s == 'y') return true;
    if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
    return fallback;
  }

  static DateTime _parseDateTime(dynamic v, {DateTime? fallback}) {
    if (v == null) return fallback ?? DateTime.now();
    if (v is DateTime) return v;
    try {
      final s = v.toString();
      final parsed = DateTime.tryParse(s);
      return parsed ?? fallback ?? DateTime.now();
    } catch (_) {
      return fallback ?? DateTime.now();
    }
  }

  // Manual fromJson to be resilient to backend variations
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      customer: json['customer'] is num ? (json['customer'] as num).toInt() : (json['customer'] != null ? int.tryParse(json['customer'].toString()) : null),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      salesRep: json['sales_rep'] is num ? (json['sales_rep'] as num).toInt() : (json['sales_rep'] != null ? int.tryParse(json['sales_rep'].toString()) : null),
      salesRepName: json['sales_rep_name']?.toString(),
      appointmentDate: _parseDateTime(json['appointment_date']),
      location: json['location']?.toString(),
      status: json['status']?.toString(),
      statusDisplay: json['status_display']?.toString(),
      notes: json['notes']?.toString(),
      // Çok önemli: boolean alanı güvenli parse ediliyor (null/0/1/"true"/"false" destekleniyor)
      reminderSent: _toBool(json['reminder_sent'], fallback: false),
      isUpcoming: json.containsKey('is_upcoming') ? (_toBool(json['is_upcoming'], fallback: false)) : null,
      isToday: json.containsKey('is_today') ? (_toBool(json['is_today'], fallback: false)) : null,
      timeUntil: json['time_until'] is num ? (json['time_until'] as num).toInt() : (json['time_until'] != null ? int.tryParse(json['time_until'].toString()) : null),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer': customer,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'sales_rep': salesRep,
    'sales_rep_name': salesRepName,
    'appointment_date': appointmentDate.toIso8601String(),
    'location': location,
    'status': status,
    'status_display': statusDisplay,
    'notes': notes,
    'reminder_sent': reminderSent,
    'is_upcoming': isUpcoming,
    'is_today': isToday,
    'time_until': timeUntil,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Convenience getters
  bool get isPlanned => status == 'PLANLANDI';
  bool get isCompleted => status == 'TAMAMLANDI';
  bool get isCancelled => status == 'IPTAL_EDILDI';

  // UI helper (not ideal in model but bıraktım mevcut yapıya göre)
  Color get statusColor {
    switch (status) {
      case 'PLANLANDI':
        return Colors.blue;
      case 'TAMAMLANDI':
        return Colors.green;
      case 'IPTAL_EDILDI':
        return Colors.red;
      case 'GELMEDI':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
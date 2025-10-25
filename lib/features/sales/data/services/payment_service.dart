// lib/features/sales/data/services/payment_service.dart

import 'package:dio/dio.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_model.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  // Get Payments (with filters)
  Future<List<PaymentModel>> getPayments({
    int? reservationId,
    String? status,
    String? paymentType,
  }) async {
    try {
      print('💳 Ödemeler alınıyor...');
      
      final queryParams = <String, dynamic>{};
      
      if (reservationId != null) {
        queryParams['reservation_id'] = reservationId;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (paymentType != null) {
        queryParams['payment_type'] = paymentType;
      }
      
      final response = await _apiClient.get(
        '/sales/payments/',
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data['results'] ?? response.data;
      print('✅ ${data.length} ödeme alındı');
      
      return data
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ Ödeme listesi hatası: ${e.response?.statusCode}');
      print('📦 Error: ${e.response?.data}');
      throw Exception('Ödemeler alınamadı: ${e.message}');
    }
  }

  // Get Pending Payments
  Future<List<PaymentModel>> getPendingPayments() async {
    try {
      print('⏳ Bekleyen ödemeler alınıyor...');
      
      final response = await _apiClient.get('/sales/payments/pending/');
      
      final List<dynamic> data = response.data is List 
          ? response.data 
          : (response.data['results'] ?? []);
      
      print('✅ ${data.length} bekleyen ödeme alındı');
      
      return data
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ Bekleyen ödemeler hatası: ${e.response?.statusCode}');
      throw Exception('Bekleyen ödemeler alınamadı: ${e.message}');
    }
  }

  // Get Overdue Payments
  Future<List<PaymentModel>> getOverduePayments() async {
    try {
      print('🔴 Gecikmiş ödemeler alınıyor...');
      
      final response = await _apiClient.get('/sales/payments/overdue/');
      
      final List<dynamic> data = response.data is List 
          ? response.data 
          : (response.data['results'] ?? []);
      
      print('✅ ${data.length} gecikmiş ödeme alındı');
      
      return data
          .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ Gecikmiş ödemeler hatası: ${e.response?.statusCode}');
      throw Exception('Gecikmiş ödemeler alınamadı: ${e.message}');
    }
  }

  // Get Payment by ID
  Future<PaymentModel> getPaymentById(int id) async {
    try {
      print('📋 Ödeme detayı alınıyor: $id');
      
      final response = await _apiClient.get('/sales/payments/$id/');
      
      print('✅ Ödeme detayı alındı');
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Ödeme detay hatası: ${e.response?.statusCode}');
      throw Exception('Ödeme detayı alınamadı: ${e.message}');
    }
  }

  // Create Payment
  Future<PaymentModel> createPayment(Map<String, dynamic> data) async {
    try {
      print('➕ Ödeme kaydediliyor...');
      print('📦 Data: $data');
      
      final response = await _apiClient.post(
        '/sales/payments/',
        data: data,
      );
      
      print('✅ Ödeme kaydedildi');
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Ödeme kaydetme hatası: ${e.response?.statusCode}');
      print('📦 Error: ${e.response?.data}');
      
      if (e.response?.data != null && e.response!.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        final errorMessages = errors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        throw Exception('Ödeme kaydedilemedi: $errorMessages');
      }
      
      throw Exception('Ödeme kaydedilemedi: ${e.message}');
    }
  }

  // Update Payment
  Future<PaymentModel> updatePayment(int id, Map<String, dynamic> data) async {
    try {
      print('✏️ Ödeme güncelleniyor: $id');
      print('📦 Data: $data');
      
      final response = await _apiClient.put(
        '/sales/payments/$id/',
        data: data,
      );
      
      print('✅ Ödeme güncellendi');
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Ödeme güncelleme hatası: ${e.response?.statusCode}');
      throw Exception('Ödeme güncellenemedi: ${e.message}');
    }
  }

  // Mark Payment as Paid
  Future<PaymentModel> markAsPaid({
    required int paymentId,
    required String paymentDate,
    required String paymentMethod,
    String? receiptNumber,
  }) async {
    try {
      print('✅ Ödeme tahsil ediliyor: $paymentId');
      
      final data = {
        'payment_date': paymentDate,
        'payment_method': paymentMethod,
        if (receiptNumber != null && receiptNumber.isNotEmpty)
          'receipt_number': receiptNumber,
      };
      
      print('📦 Data: $data');
      
      final response = await _apiClient.post(
        '/sales/payments/$paymentId/mark_as_paid/',
        data: data,
      );
      
      print('✅ Ödeme tahsil edildi');
      
      // Backend "payment" key'i ile döndürüyor
      if (response.data is Map && response.data.containsKey('payment')) {
        return PaymentModel.fromJson(response.data['payment']);
      }
      
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Ödeme tahsil etme hatası: ${e.response?.statusCode}');
      print('📦 Error: ${e.response?.data}');
      throw Exception('Ödeme tahsil edilemedi: ${e.message}');
    }
  }

  // Delete Payment
  Future<void> deletePayment(int id) async {
    try {
      print('🗑️ Ödeme siliniyor: $id');
      
      await _apiClient.delete('/sales/payments/$id/');
      
      print('✅ Ödeme silindi');
    } on DioException catch (e) {
      print('❌ Ödeme silme hatası: ${e.response?.statusCode}');
      throw Exception('Ödeme silinemedi: ${e.message}');
    }
  }

  // Get Payments by Reservation
  Future<List<PaymentModel>> getPaymentsByReservation(int reservationId) async {
    return getPayments(reservationId: reservationId);
  }
}
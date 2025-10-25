// lib/features/appointments/data/services/appointment_service.dart
import 'package:dio/dio.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final ApiClient _apiClient;

  AppointmentService(this._apiClient);

  // Get Appointments
  Future<List<AppointmentModel>> getAppointments({
    String? date,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (date != null) {
        queryParams['date'] = date;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        ApiConstants.appointments,
        queryParameters: queryParams,
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Randevular yüklenemedi: ${e.message}');
    }
  }

  // Get Today's Appointments
  Future<List<AppointmentModel>> getTodayAppointments() async {
    try {
      final response = await _apiClient.get(ApiConstants.todayAppointments);
      
      final results = response.data['results'] as List;
      return results
          .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Bugünün randevuları yüklenemedi: ${e.message}');
    }
  }

  // Get Upcoming Appointments
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    try {
      final response = await _apiClient.get(ApiConstants.upcomingAppointments);
      
      final results = response.data['results'] as List;
      return results
          .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Yaklaşan randevular yüklenemedi: ${e.message}');
    }
  }

  // Create Appointment
  Future<AppointmentModel> createAppointment(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.appointments,
        data: data,
      );
      return AppointmentModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        final errorMessages = errors.values.join(', ');
        throw Exception(errorMessages);
      }
      throw Exception('Randevu oluşturulamadı: ${e.message}');
    }
  }

  // Complete Appointment
  Future<void> completeAppointment(int id) async {
    try {
      await _apiClient.post('${ApiConstants.appointments}$id/complete/');
    } on DioException catch (e) {
      throw Exception('Randevu tamamlanamadı: ${e.message}');
    }
  }

  // Cancel Appointment
  Future<void> cancelAppointment(int id) async {
    try {
      await _apiClient.post('${ApiConstants.appointments}$id/cancel/');
    } on DioException catch (e) {
      throw Exception('Randevu iptal edilemedi: ${e.message}');
    }
  }
}
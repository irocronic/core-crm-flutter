// lib/features/customers/data/services/note_service.dart
import 'package:dio/dio.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/note_model.dart';

class NoteService {
  final ApiClient _apiClient;

  NoteService(this._apiClient);

  // Get Notes by Customer
  Future<List<NoteModel>> getNotesByCustomer(int customerId) async {
    try {
      print('📝 Müşteri notları alınıyor: $customerId');
      final response = await _apiClient.get(
        '/crm/notes/', // Backend'deki NoteViewSet URL'si
        queryParameters: {'customer': customerId},
      );
      final List<dynamic> data = response.data['results'] ?? response.data;
      print('✅ ${data.length} not alındı');
      return data
          .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ Not listesi hatası: ${e.response?.statusCode}');
      throw Exception('Notlar alınamadı: ${e.message}');
    }
  }

  // Create Note
  Future<NoteModel> createNote(Map<String, dynamic> data) async {
    try {
      print('➕ Not oluşturuluyor...');
      print('📦 Data: $data');

      final response = await _apiClient.post(
        '/crm/notes/',
        data: data,
      );
      print('✅ Not oluşturuldu');
      return NoteModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ Not oluşturma hatası: ${e.response?.statusCode}');
      print('📦 Error: ${e.response?.data}');
      throw Exception('Not oluşturulamadı: ${e.message}');
    }
  }
}
// lib/features/customers/data/services/customer_service.dart
import 'package:dio/dio.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/pagination_model.dart';
import '../models/customer_model.dart';
import '../models/customer_stats_model.dart';
// 🔥 YENİ IMPORT
import '../models/timeline_event_model.dart';

class CustomerService {
  final ApiClient _apiClient;

  CustomerService(this._apiClient);

  // 🔥 YENİ: Müşteri Zaman Tünelini Getirir
  Future<List<TimelineEventModel>> getCustomerTimeline(int customerId) async {
    try {
      print('⏳ Müşteri zaman tüneli alınıyor: $customerId');
      final endpoint = ApiConstants.customerTimeline.replaceAll('{id}', customerId.toString());
      final response = await _apiClient.get(endpoint);
      final List<dynamic> data = response.data as List<dynamic>;
      print('✅ ${data.length} zaman tüneli olayı alındı');
      return data
          .map((json) => TimelineEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ Müşteri zaman tüneli hatası: ${e.response?.statusCode}');
      throw Exception('Zaman tüneli alınamadı: ${e.message}');
    }
  }

  // ✅ Get My Customers (Liste)
  Future<PaginationModel<CustomerModel>> getMyCustomers({
    int? page,
    String? search,
  }) async {
    try {
      print('👤 Benim müşterilerim alınıyor...');
      final queryParameters = <String, dynamic>{};

      if (page != null) {
        queryParameters['page'] = page;
      }
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _apiClient.get(
        ApiConstants.myCustomers,
        queryParameters: queryParameters,
      );
      print('✅ Müşteriler alındı');

      return PaginationModel<CustomerModel>.fromJson(
        response.data,
            (json) {
          try {
            return CustomerModel.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('❌ Müşteri parse hatası: $e');
            print('📦 Hatalı veri: $json');

            rethrow;
          }
        },
      );
    } on DioException catch (e) {
      print('❌ My customers hatası: ${e.response?.statusCode}');
      throw Exception('Müşterilerim alınamadı: ${e.message}');
    }
  }

  // ✅ YENİ: Get Hot Leads
  Future<PaginationModel<CustomerModel>> getHotLeads({
    int? page,
    String? search,
  }) async {
    try {
      print('🔥 Sıcak müşteriler (hot leads) alınıyor...');
      final queryParameters = <String, dynamic>{};

      if (page != null) {
        queryParameters['page'] = page;
      }
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _apiClient.get(
        ApiConstants.hotLeads, // hot_leads endpoint'i
        queryParameters: queryParameters,
      );
      print('✅ Sıcak müşteriler alındı');

      return PaginationModel<CustomerModel>.fromJson(
        response.data,
            (json) => CustomerModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      print('❌ Hot leads hatası: ${e.response?.statusCode}');
      throw Exception('Sıcak müşteriler alınamadı: ${e.message}');
    }
  }

  // ✅ DÜZELTME: Get Customer Detail - ApiConstants.customers kullan
  Future<CustomerModel> getCustomerDetail(int id) async {
    try {
      print('📋 Müşteri detayı alınıyor: $id');
      // 🔥 ÖNEMLİ: ApiConstants.myCustomers DEĞİL, ApiConstants.customers kullan
      final response = await _apiClient.get('${ApiConstants.customers}$id/');
      print('✅ Müşteri detayı alındı');
      return CustomerModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Müşteri detay hatası: ${e.response?.statusCode}');
      print('📦 Error response: ${e.response?.data}');
      throw Exception('Müşteri detayı alınamadı: ${e.message}');
    }
  }

  // ✅ Create Customer
  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    try {
      print('➕ Müşteri oluşturuluyor...');
      print('📦 Data: $data');

      final response = await _apiClient.post(
        ApiConstants.customers,
        data: data,
      );
      print('✅ Müşteri oluşturuldu');
      return CustomerModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Müşteri oluşturma hatası: ${e.response?.statusCode}');
      print('📦 Error: ${e.response?.data}');
      throw Exception('Müşteri oluşturulamadı: ${e.response?.data ?? e.message}');
    }
  }

  // ✅ Update Customer
  Future<CustomerModel> updateCustomer(int id, Map<String, dynamic> data) async {
    try {
      print('✏️ Müşteri güncelleniyor: $id');
      print('📦 Data: $data');

      final response = await _apiClient.put(
        '${ApiConstants.customers}$id/',
        data: data,
      );
      print('✅ Müşteri güncellendi');
      return CustomerModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Müşteri güncelleme hatası: ${e.response?.statusCode}');
      print('📦 Error: ${e.response?.data}');
      throw Exception('Müşteri güncellenemedi: ${e.response?.data ?? e.message}');
    }
  }

  // ✅ Delete Customer
  Future<void> deleteCustomer(int id) async {
    try {
      print('🗑️ Müşteri siliniyor: $id');
      await _apiClient.delete('${ApiConstants.customers}$id/');

      print('✅ Müşteri silindi');
    } on DioException catch (e) {
      print('❌ Müşteri silme hatası: ${e.response?.statusCode}');
      throw Exception('Müşteri silinemedi: ${e.message}');
    }
  }

  // ✅ Update Lead Status
  Future<CustomerModel> updateLeadStatus(int id, String status) async {
    try {
      print('🔄 Lead status güncelleniyor: $id -> $status');
      final response = await _apiClient.patch(
        '${ApiConstants.customers}$id/',
        data: {'lead_status': status},
      );
      print('✅ Lead status güncellendi');
      return CustomerModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Lead status güncelleme hatası: ${e.response?.statusCode}');
      throw Exception('Lead status güncellenemedi: ${e.message}');
    }
  }

  // ✅ Assign Customer (Tekli atama/transfer için kullanılır)
  Future<CustomerModel> assignCustomer(int id, int? userId) async {
    try {
      print('👤 Müşteri atanıyor: $id -> User: $userId');
      final response = await _apiClient.patch(
        '${ApiConstants.customers}$id/',
        data: {'assigned_to': userId},
      );
      print('✅ Müşteri atandı');
      return CustomerModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Müşteri atama hatası: ${e.response?.statusCode}');
      throw Exception('Müşteri atanamadı: ${e.message}');
    }
  }

  // 🔥 YENİ METOT: Toplu müşteri atama
  Future<void> assignCustomers(List<int> customerIds, int salesRepId) async {
    try {
      print('👥 Toplu müşteri atama: ${customerIds.length} müşteri -> User: $salesRepId');
      await _apiClient.post(
        ApiConstants.assignCustomers,
        data: {
          'customer_ids': customerIds,
          'sales_rep_id': salesRepId,
        },
      );
      print('✅ Toplu atama başarılı');
    } on DioException catch (e) {
      print('❌ Toplu atama hatası: ${e.response?.statusCode}');
      throw Exception('Müşteriler atanamadı: ${e.response?.data?['error'] ?? e.message}');
    }
  }


  // ✅ Update Win Probability
  Future<CustomerModel> updateWinProbability(int id, double probability) async {
    try {
      print('📊 Win probability güncelleniyor: $id -> $probability%');
      final response = await _apiClient.patch(
        '${ApiConstants.customers}$id/',
        data: {'win_probability': probability},
      );
      print('✅ Win probability güncellendi');
      return CustomerModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Win probability güncelleme hatası: ${e.response?.statusCode}');
      throw Exception('Win probability güncellenemedi: ${e.message}');
    }
  }

  // ✅ HATA DÜZELTİLDİ: EKSİK METOT EKLENDİ
  Future<CustomerStatsModel> getCustomerStatistics() async {
    try {
      print('📊 Müşteri istatistikleri alınıyor...');
      final response = await _apiClient.get(ApiConstants.customerStats);
      print('✅ Müşteri istatistikleri alındı');
      return CustomerStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Müşteri istatistikleri hatası: ${e.response?.statusCode}');
      throw Exception('Müşteri istatistikleri alınamadı: ${e.message}');
    }
  }
}
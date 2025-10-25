// lib/features/contracts/data/services/contract_service.dart

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/contract_model.dart';

/// Contract Service - API operations for contracts
class ContractService {
  final ApiClient _apiClient;

  ContractService(this._apiClient);

  /// Get all contracts with optional filters
  Future<List<ContractModel>> getContracts({
    ContractType? contractType,
    ContractStatus? status,
    String? search,
    int? reservationId,
    int? saleId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (contractType != null) {
        queryParameters['contract_type'] = contractType.apiValue;
      }
      if (status != null) {
        queryParameters['status'] = status.apiValue;
      }
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (reservationId != null) {
        queryParameters['reservation'] = reservationId;
      }
      if (saleId != null) {
        queryParameters['sale'] = saleId;
      }
      if (startDate != null) {
        queryParameters['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        '/sales/contracts/',
        queryParameters: queryParameters,
      );

      if (response.data['results'] != null) {
        return (response.data['results'] as List)
            .map((json) => ContractModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get contract by ID
  Future<ContractModel> getContractById(int id) async {
    try {
      final response = await _apiClient.get('/sales/contracts/$id/');
      return ContractModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new contract
  Future<ContractModel> createContract({
    required ContractType contractType,
    required DateTime contractDate,
    int? reservationId,
    int? saleId,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'contract_type': contractType.apiValue,
        'contract_date': contractDate.toIso8601String().split('T')[0],
      };

      if (reservationId != null) {
        data['reservation'] = reservationId;
      }
      if (saleId != null) {
        data['sale'] = saleId;
      }
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      final response = await _apiClient.post(
        '/sales/contracts/',
        data: data,
      );

      return ContractModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update contract
  Future<ContractModel> updateContract({
    required int id,
    ContractType? contractType,
    DateTime? contractDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (contractType != null) {
        data['contract_type'] = contractType.apiValue;
      }
      if (contractDate != null) {
        data['contract_date'] = contractDate.toIso8601String().split('T')[0];
      }
      if (notes != null) {
        data['notes'] = notes;
      }

      final response = await _apiClient.patch(
        '/sales/contracts/$id/',
        data: data,
      );

      return ContractModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark contract as signed
  Future<ContractModel> markAsSigned(int id) async {
    try {
      final response = await _apiClient.post(
        '/sales/contracts/$id/mark_as_signed/',
      );
      return ContractModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel contract
  Future<ContractModel> cancelContract({
    required int id,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.post(
        '/sales/contracts/$id/cancel/',
        data: {'cancellation_reason': reason},
      );
      return ContractModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate contract PDF
  Future<void> generatePdf(int id) async {
    try {
      await _apiClient.post('/sales/contracts/$id/generate_pdf/');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Download contract PDF
  Future<Response> downloadContractPdf(String contractFileUrl) async {
    try {
      final response = await _apiClient.dio.get(
        contractFileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete contract
  Future<void> deleteContract(int id) async {
    try {
      await _apiClient.delete('/sales/contracts/$id/');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get contracts by reservation
  Future<List<ContractModel>> getContractsByReservation(int reservationId) async {
    return getContracts(reservationId: reservationId);
  }

  /// Get contracts by sale
  Future<List<ContractModel>> getContractsBySale(int saleId) async {
    return getContracts(saleId: saleId);
  }

  /// Get pending approval contracts
  Future<List<ContractModel>> getPendingApprovalContracts() async {
    return getContracts(status: ContractStatus.pendingApproval);
  }

  /// Get draft contracts
  Future<List<ContractModel>> getDraftContracts() async {
    return getContracts(status: ContractStatus.draft);
  }

  /// Get signed contracts
  Future<List<ContractModel>> getSignedContracts() async {
    return getContracts(status: ContractStatus.signed);
  }

  /// Error handler
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final message = error.response!.data['detail'] ??
            error.response!.data['message'] ??
            'Bir hata oluştu';

        if (statusCode == 404) {
          return Exception('Sözleşme bulunamadı');
        } else if (statusCode == 403) {
          return Exception('Bu işlem için yetkiniz yok');
        } else if (statusCode == 400) {
          return Exception(message);
        }
      }
      return Exception('Bağlantı hatası: ${error.message}');
    }
    return Exception('Beklenmeyen bir hata oluştu: $error');
  }
}
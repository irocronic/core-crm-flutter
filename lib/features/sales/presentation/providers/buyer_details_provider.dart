// lib/features/sales/presentation/providers/buyer_details_provider.dart
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/buyer_details_model.dart';
import '../../data/services/buyer_details_service.dart';

class BuyerDetailsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final BuyerDetailsService _buyerService;

  BuyerDetailsProvider(this._apiClient) {
    _buyerService = BuyerDetailsService(_apiClient);
  }

  // State
  BuyerDetailsModel? _buyerDetails;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _validationErrors = {};

  // Getters
  BuyerDetailsModel? get buyerDetails => _buyerDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get validationErrors => _validationErrors;

  void _clearErrors() {
    _errorMessage = null;
    _validationErrors = {};
  }

  Future<void> loadBuyerDetails(int customerId) async {
    if (_isLoading) return;
    _isLoading = true;
    _clearErrors();
    notifyListeners();

    try {
      _buyerDetails = await _buyerService.getBuyerDetails(customerId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Bilinmeyen bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrUpdateBuyerDetails(
      int customerId,
      Map<String, dynamic> data,
      ) async {
    _isLoading = true;
    _clearErrors();
    notifyListeners();

    try {
      // **** DÜZELTME BAŞLANGICI ****
      // 'customer' ID'si hem oluşturma hem de güncelleme için gereklidir.
      // Backend serializer'ı (BuyerDetailsCreateUpdateSerializer)  'customer' alanını bekliyor.
      data['customer'] = customerId;
      // **** DÜZELTME SONU ****

      if (_buyerDetails != null) {
        // Güncelle
        _buyerDetails = await _buyerService.updateBuyerDetails(_buyerDetails!.id, data);
      } else {
        // Oluştur
        // data['customer'] = customerId; // <-- Bu satır yukarı taşındı
        _buyerDetails = await _buyerService.createBuyerDetails(data);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      if (e.isValidationError) {
        _validationErrors = e.errors ?? {};
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'İşlem başarısız: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearBuyerDetails() {
    _buyerDetails = null;
    notifyListeners();
  }
}
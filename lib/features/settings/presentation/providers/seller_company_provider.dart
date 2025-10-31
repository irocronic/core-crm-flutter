// lib/features/settings/presentation/providers/seller_company_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_realtyflow_crm/core/network/api_exception.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/seller_company_model.dart';
import '../../data/services/settings_service.dart';

class SellerCompanyProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final SettingsService _settingsService;

  SellerCompanyProvider(this._apiClient) {
    _settingsService = SettingsService(_apiClient);
  }

  // State
  List<SellerCompanyModel> _companies = [];
  SellerCompanyModel? _selectedCompany;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _validationErrors = {};

  // Getters
  List<SellerCompanyModel> get companies => _companies;
  SellerCompanyModel? get selectedCompany => _selectedCompany;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get validationErrors => _validationErrors;

  void _clearErrors() {
    _errorMessage = null;
    _validationErrors = {};
  }

  /// Tüm firmaları yükle
  Future<void> loadCompanies({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _clearErrors();
    notifyListeners();

    try {
      _companies = await _settingsService.getSellerCompanies();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Bilinmeyen bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tek bir firmayı yükle (Form düzenlemesi için)
  Future<bool> loadCompanyById(int id) async {
    _isLoading = true;
    _selectedCompany = null;
    _clearErrors();
    notifyListeners();

    try {
      _selectedCompany = await _settingsService.getSellerCompany(id);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Firma yüklenemedi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Yeni firma oluştur
  Future<bool> createCompany(Map<String, dynamic> data) async {
    _isLoading = true;
    _clearErrors();
    notifyListeners();

    try {
      final newCompany = await _settingsService.createSellerCompany(data);
      _companies.insert(0, newCompany);
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
      _errorMessage = 'Firma oluşturulamadı: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Firma güncelle
  Future<bool> updateCompany(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _clearErrors();
    notifyListeners();

    try {
      final updatedCompany = await _settingsService.updateSellerCompany(id, data);

      final index = _companies.indexWhere((c) => c.id == id);
      if (index != -1) {
        _companies[index] = updatedCompany;
      }
      if (_selectedCompany?.id == id) {
        _selectedCompany = updatedCompany;
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
      _errorMessage = 'Firma güncellenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Firma sil
  Future<bool> deleteCompany(int id) async {
    _isLoading = true;
    _clearErrors();
    notifyListeners();

    try {
      await _settingsService.deleteSellerCompany(id);
      _companies.removeWhere((c) => c.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Firma silinemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hataları temizle (Form ekranı için)
  void clearFormErrors() {
    _clearErrors();
    notifyListeners();
  }

  /// Seçili firmayı temizle
  void clearSelectedCompany() {
    _selectedCompany = null;
    notifyListeners();
  }
}
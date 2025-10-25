// lib/features/reservations/presentation/providers/reservation_provider.dart

import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/reservation_model.dart';
import '../../data/services/reservation_service.dart';
import '../../../../shared/models/pagination_model.dart';

enum ReservationListType { all, mySales, active }

class ReservationProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;
  late final ReservationService _reservationService; // ✅ Değişken adı düzeltildi

  ReservationProvider(this._apiClient, this._authProvider) {
    _reservationService = ReservationService(_apiClient);
  }

  // State
  List<ReservationModel> _reservations = [];
  ReservationModel? _selectedReservation;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  ReservationListType _listType = ReservationListType.all;
  List<ReservationModel> _customerSales = [];
  bool _isCustomerSalesLoading = false;
  String? _customerSalesErrorMessage;

  Map<String, dynamic>? _statistics;
  bool _isStatsLoading = false;

  // **** YENİ DASHBOARD STATE'LERİ ****
  List<ReservationModel> _dashboardSales = [];
  bool _isDashboardSalesLoading = false;
  String? _dashboardSalesError;
  DateTimeRange? _dashboardDateFilter;
  // **** YENİ DASHBOARD STATE'LERİ SONU ****

  // Getters
  List<ReservationModel> get reservations => _reservations;
  ReservationModel? get selectedReservation => _selectedReservation;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  ReservationListType get listType => _listType;
  List<ReservationModel> get customerSales => _customerSales;
  bool get isCustomerSalesLoading => _isCustomerSalesLoading;
  String? get customerSalesErrorMessage => _customerSalesErrorMessage;

  Map<String, dynamic>? get statistics => _statistics;
  bool get isStatsLoading => _isStatsLoading;

  // **** YENİ DASHBOARD GETTER'LARI ****
  List<ReservationModel> get dashboardSales => _dashboardSales;
  bool get isDashboardSalesLoading => _isDashboardSalesLoading;
  String? get dashboardSalesError => _dashboardSalesError;
  DateTimeRange? get dashboardDateFilter => _dashboardDateFilter;
  // **** YENİ DASHBOARD GETTER'LARI SONU ****

  Future<void> loadStatistics() async {
    _isStatsLoading = true;
    notifyListeners();
    try {
      _statistics = await _reservationService.getReservationStatistics(); // ✅ Değişken adı düzeltildi
    } catch (e) {
      print("İstatistikler yüklenemedi: $e");
      _statistics = null;
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReservations({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _reservations.clear();
      loadStatistics();
    }

    if (_isLoading || _isLoadingMore) return;
    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      late final PaginationModel<ReservationModel> result;
      switch (_listType) {
        case ReservationListType.mySales:
          result = await _reservationService.getMyReservations(page: _currentPage); // ✅ Değişken adı düzeltildi
          break;
        case ReservationListType.active:
          result = await _reservationService.getActiveReservations(page: _currentPage); // ✅ Değişken adı düzeltildi
          break;
        case ReservationListType.all:
        default:
          result = await _reservationService.getReservations(page: _currentPage); // ✅ Değişken adı düzeltildi
          break;
      }

      if (_currentPage == 1) {
        _reservations = result.results;
      } else {
        _reservations.addAll(result.results);
      }

      _hasMore = result.next != null;
      if (_hasMore) {
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setListType(ReservationListType type) {
    if (_listType == type) return;
    _listType = type;
    notifyListeners();
    loadReservations(refresh: true);
  }

  // Hem 'SATISA_DONUSTU' hem de 'AKTIF' durumları isteniyor
  Future<void> loadSalesByCustomer(int customerId) async {
    _isCustomerSalesLoading = true;
    _customerSalesErrorMessage = null;
    notifyListeners();
    try {
      final result = await _reservationService.getReservations( // ✅ Değişken adı düzeltildi
        customerId: customerId,
        status: 'SATISA_DONUSTU,AKTIF', // Hem satışa dönüşenleri hem de aktif rezervasyonları al
        limit: 1000,
        page: 1,
      );
      _customerSales = result.results;
    } catch (e) {
      _customerSalesErrorMessage = e.toString();
      _customerSales = [];
    } finally {
      _isCustomerSalesLoading = false;
      notifyListeners();
    }
  }

  // Dashboard için Satış/Rezervasyonları Yükle
  Future<void> loadDashboardSales({DateTimeRange? dateRange}) async {
    _isDashboardSalesLoading = true;
    _dashboardSalesError = null;
    _dashboardDateFilter = dateRange; // Seçilen filtreyi sakla
    notifyListeners();

    try {
      // API'ye startDate/endDate named parametresi olmadığı için sunucudan tüm sonuçları çekip
      // client-side filtre uyguluyoruz.
      final result = await _reservationService.getReservations( // ✅ Değişken adı düzeltildi
        status: 'SATISA_DONUSTU,AKTIF',
        limit: 1000,
        page: 1,
      );

      List<ReservationModel> results = result.results;

      if (dateRange != null) {
        final start = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
        final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day, 23, 59, 59, 999);
        results = results.where((r) {
          final d = r.reservationDate;
          return !d.isBefore(start) && !d.isAfter(end);
        }).toList();
      }

      _dashboardSales = results;
      // Sonuçları tarihe göre (en yeniden en eskiye) sırala
      _dashboardSales.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
    } catch (e) {
      _dashboardSalesError = 'Satış/Rezervasyon verileri yüklenemedi: ${e.toString()}';
      _dashboardSales = [];
    } finally {
      _isDashboardSalesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReservationDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedReservation = await _reservationService.getReservationDetail(id); // ✅ Değişken adı düzeltildi
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReservation(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newReservation = await _reservationService.createReservation(data); // ✅ Değişken adı düzeltildi
      _reservations.insert(0, newReservation);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> convertToSale(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedReservation = await _reservationService.convertToSale(id); // ✅ Değişken adı düzeltildi
      if (_selectedReservation?.id == id) {
        _selectedReservation = updatedReservation;
      }
      final index = _reservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reservations[index] = updatedReservation;
      }
      final customerSaleIndex = _customerSales.indexWhere((r) => r.id == id);
      if (customerSaleIndex != -1) {
        _customerSales[customerSaleIndex] = updatedReservation;
      } else {
        if (updatedReservation.status == 'SATISA_DONUSTU') {
          if (selectedReservation?.customer == updatedReservation.customer) {
            _customerSales.insert(0, updatedReservation);
          }
        }
      }
      // Dashboard listesini de güncelle
      final dashboardIndex = _dashboardSales.indexWhere((r) => r.id == id);
      if (dashboardIndex != -1) {
        _dashboardSales[dashboardIndex] = updatedReservation;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelReservation(int id, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _reservationService.cancelReservation(id, reason); // ✅ Değişken adı düzeltildi
      final index = _reservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        final updatedReservation = await _reservationService.getReservationDetail(id); // ✅ Değişken adı düzeltildi
        _reservations[index] = updatedReservation;
        if (_selectedReservation?.id == id) {
          _selectedReservation = updatedReservation;
        }
      }
      _customerSales.removeWhere((r) => r.id == id);
      // Dashboard listesinden de kaldır
      _dashboardSales.removeWhere((r) => r.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    _customerSalesErrorMessage = null;
    _dashboardSalesError = null;
    notifyListeners();
  }

  void clearSelectedReservation() {
    _selectedReservation = null;
    notifyListeners();
  }
}
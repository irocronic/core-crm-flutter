// lib/features/customers/presentation/providers/customer_provider.dart
import 'package:flutter/material.dart';
import 'dart:collection';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/pagination_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/customer_model.dart';
import '../../data/services/customer_service.dart';
import '../../data/models/customer_stats_model.dart';
import '../../data/models/timeline_event_model.dart';

enum CustomerListType { all, hotLeads }

class CustomerProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;
  late final CustomerService _customerService;

  // 🔥 GÜNCELLEME: Max cached items limiti
  static const int MAX_CACHED_ITEMS = 500;

  CustomerProvider(this._apiClient, this._authProvider) {
    _customerService = CustomerService(_apiClient);
  }

  // State
  List<CustomerModel> _customers = [];
  CustomerModel? _selectedCustomer;
  List<TimelineEventModel> _timeline = [];
  bool _isTimelineLoading = false;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  Map<String, dynamic> _validationErrors = {};
  int _currentPage = 1;
  bool _hasMore = true;
  String? _searchQuery;
  CustomerListType _listType = CustomerListType.all;
  final Set<int> _selectedCustomerIds = {};
  bool _isAssigning = false;

  // İstatistikler için State
  CustomerStatsModel? _stats;
  bool _isStatsLoading = false;

  // Getters
  List<CustomerModel> get customers => _customers;
  CustomerModel? get selectedCustomer => _selectedCustomer;
  List<TimelineEventModel> get timeline => _timeline;
  bool get isTimelineLoading => _isTimelineLoading;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get validationErrors => _validationErrors;
  bool get hasMore => _hasMore;
  CustomerListType get listType => _listType;
  UnmodifiableSetView<int> get selectedCustomerIds => UnmodifiableSetView<int>(_selectedCustomerIds);
  bool get isSelectionMode => _selectedCustomerIds.isNotEmpty;
  bool get isAssigning => _isAssigning;
  CustomerStatsModel? get stats => _stats;
  bool get isStatsLoading => _isStatsLoading;

  Future<void> loadCustomerTimeline(int customerId) async {
    _isTimelineLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _timeline = await _customerService.getCustomerTimeline(customerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isTimelineLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(int customerId) {
    if (_selectedCustomerIds.contains(customerId)) {
      _selectedCustomerIds.remove(customerId);
    } else {
      _selectedCustomerIds.add(customerId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedCustomerIds.clear();
    notifyListeners();
  }

  bool isCustomerSelected(int customerId) {
    return _selectedCustomerIds.contains(customerId);
  }

  void _clearErrors() {
    _errorMessage = null;
    _validationErrors = {};
  }

  // İstatistikleri yüklemek için metot
  Future<void> loadCustomerStats() async {
    _isStatsLoading = true;
    notifyListeners();
    try {
      _stats = await _customerService.getCustomerStatistics();
    } catch (e) {
      debugPrint("CRM istatistikleri yüklenemedi: $e");
      _stats = null;
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }

  // 🔥 GÜNCELLEME: Memory management eklenmiş pagination
  Future<void> loadCustomers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _customers.clear();
      clearSelection();
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
      late final PaginationModel<CustomerModel> result;
      if (_listType == CustomerListType.hotLeads) {
        result = await _customerService.getHotLeads(
          page: _currentPage,
          search: _searchQuery,
        );
      } else {
        result = await _customerService.getMyCustomers(
          page: _currentPage,
          search: _searchQuery,
        );
      }

      debugPrint('📥 API Response (page $_currentPage): ${result.results.length} customers');

      if (_currentPage == 1) {
        _customers = result.results;
      } else {
        _customers.addAll(result.results);

        // 🔥 BELLEK OPTİMİZASYONU: Maksimum limit kontrolü
        if (_customers.length > MAX_CACHED_ITEMS) {
          debugPrint('⚠️ [MEMORY OPTIMIZATION] Customer list exceeded $MAX_CACHED_ITEMS items, trimming...');

          // En eski öğeleri sil (baştan kırp)
          final itemsToRemove = _customers.length - MAX_CACHED_ITEMS;
          _customers = _customers.sublist(itemsToRemove);

          debugPrint('✅ [MEMORY OPTIMIZATION] Trimmed $itemsToRemove items, current size: ${_customers.length}');
        }
      }

      _hasMore = result.next != null;
      _currentPage++;
    } catch (e, stackTrace) {
      debugPrint('❌ Customer load error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setListType(CustomerListType type) {
    if (_listType == type) return;
    _listType = type;
    loadCustomers(refresh: true);
  }

  Future<void> searchCustomers(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    _hasMore = true;
    _customers.clear();
    await loadCustomers();
  }

  void clearSearch() {
    _searchQuery = null;
    _currentPage = 1;
    _hasMore = true;
    _customers.clear();
    loadCustomers();
  }

  Future<void> loadCustomerDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCustomer = await _customerService.getCustomerDetail(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> data) async {
    _isLoading = true;
    _clearErrors();
    notifyListeners();
    try {
      final newCustomer = await _customerService.createCustomer(data);
      _customers.insert(0, newCustomer);
      return true;
    } on ValidationException catch (e) {
      _validationErrors = e.errors;
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _clearErrors();
    notifyListeners();
    try {
      final updatedCustomer = await _customerService.updateCustomer(id, data);
      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }

      if (_selectedCustomer?.id == id) {
        _selectedCustomer = updatedCustomer;
      }

      return true;
    } on ValidationException catch (e) {
      _validationErrors = e.errors;
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _customerService.deleteCustomer(id);
      _customers.removeWhere((c) => c.id == id);
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

  Future<bool> assignCustomers(int salesRepId) async {
    _isAssigning = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _customerService.assignCustomers(_selectedCustomerIds.toList(), salesRepId);
      await loadCustomers(refresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isAssigning = false;
      notifyListeners();
    }
  }

  Future<bool> transferCustomer(int customerId, int salesRepId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedCustomer = await _customerService.assignCustomer(customerId, salesRepId);
      if (_selectedCustomer?.id == customerId) {
        _selectedCustomer = updatedCustomer;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  // 🔥 YENİ: Bellek temizleme metodu
  void clearCache() {
    _customers.clear();
    _currentPage = 1;
    _hasMore = true;
    _selectedCustomer = null;
    _timeline.clear();
    debugPrint('🗑️ [CACHE CLEARED] Customer cache temizlendi');
    notifyListeners();
  }
}
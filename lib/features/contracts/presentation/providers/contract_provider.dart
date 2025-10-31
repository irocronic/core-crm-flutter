// lib/features/contracts/presentation/providers/contract_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/contract_model.dart';
import '../../data/services/contract_service.dart';
import '../../data/services/contract_docx_export_service.dart';

/// Contract Provider - State management for contracts
class ContractProvider with ChangeNotifier {
  final ContractService _contractService;
  // 🔥 FIX: ApiClient'i ContractDocxExportService'e inject et
  late final ContractDocxExportService _docxExportService;

  ContractProvider(this._contractService) {
    // 🔥 FIX: ApiClient'i service'e geçir
    _docxExportService = ContractDocxExportService(_contractService.apiClient);
  }

  // State variables
  List<ContractModel> _contracts = [];
  ContractModel? _selectedContract;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isExporting = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Filter variables
  ContractType? _filterType;
  ContractStatus? _filterStatus;
  String? _searchQuery;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<ContractModel> get contracts => _contracts;
  ContractModel? get selectedContract => _selectedContract;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isExporting => _isExporting;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  ContractType? get filterType => _filterType;
  ContractStatus? get filterStatus => _filterStatus;
  String? get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Statistics
  int get totalContracts => _contracts.length;
  int get draftCount =>
      _contracts.where((c) => c.status == ContractStatus.draft).length;
  int get pendingApprovalCount => _contracts
      .where((c) => c.status == ContractStatus.pendingApproval)
      .length;
  int get signedCount =>
      _contracts.where((c) => c.status == ContractStatus.signed).length;
  int get cancelledCount =>
      _contracts.where((c) => c.status == ContractStatus.cancelled).length;

  /// Load contracts with filters
  Future<void> loadContracts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _contracts.clear();
    }

    if (_isLoading || _isLoadingMore) return;

    if (_currentPage == 1) {
      _isLoading = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final newContracts = await _contractService.getContracts(
        contractType: _filterType,
        status: _filterStatus,
        search: _searchQuery,
        startDate: _startDate,
        endDate: _endDate,
        page: _currentPage,
        pageSize: 20,
      );

      if (newContracts.isEmpty) {
        _hasMoreData = false;
      } else {
        if (refresh) {
          _contracts = newContracts;
        } else {
          _contracts.addAll(newContracts);
        }
        _currentPage++;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading contracts: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more contracts (pagination)
  Future<void> loadMoreContracts() async {
    if (!_hasMoreData || _isLoadingMore) return;
    await loadContracts();
  }

  /// Load contract by ID
  Future<void> loadContractById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedContract = await _contractService.getContractById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading contract: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new contract
  Future<bool> createContract({
    required ContractType contractType,
    required DateTime contractDate,
    int? reservationId,
    int? saleId,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newContract = await _contractService.createContract(
        contractType: contractType,
        contractDate: contractDate,
        reservationId: reservationId,
        saleId: saleId,
        notes: notes,
      );

      _contracts.insert(0, newContract);
      _selectedContract = newContract;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating contract: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update contract
  Future<bool> updateContract({
    required int id,
    ContractType? contractType,
    DateTime? contractDate,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedContract = await _contractService.updateContract(
        id: id,
        contractType: contractType,
        contractDate: contractDate,
        notes: notes,
      );

      final index = _contracts.indexWhere((c) => c.id == id);
      if (index != -1) {
        _contracts[index] = updatedContract;
      }

      if (_selectedContract?.id == id) {
        _selectedContract = updatedContract;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating contract: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark contract as signed
  Future<bool> markAsSigned(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedContract = await _contractService.markAsSigned(id);

      final index = _contracts.indexWhere((c) => c.id == id);
      if (index != -1) {
        _contracts[index] = updatedContract;
      }

      if (_selectedContract?.id == id) {
        _selectedContract = updatedContract;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error marking contract as signed: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel contract
  Future<bool> cancelContract({
    required int id,
    required String reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedContract = await _contractService.cancelContract(
        id: id,
        reason: reason,
      );

      final index = _contracts.indexWhere((c) => c.id == id);
      if (index != -1) {
        _contracts[index] = updatedContract;
      }

      if (_selectedContract?.id == id) {
        _selectedContract = updatedContract;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error cancelling contract: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate PDF for contract
  Future<bool> generatePdf(int id) async {
    try {
      await _contractService.generatePdf(id);
      await loadContractById(id);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error generating PDF: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // 🔥 DOCX EXPORT METODLARI
  // ============================================================

  /// Sözleşmeyi DOCX olarak export eder
  Future<String?> exportContractAsDocx(int contractId) async {
    _isExporting = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedContract == null || _selectedContract!.id != contractId) {
        await loadContractById(contractId);
      }

      if (_selectedContract == null) {
        throw Exception('Sözleşme bulunamadı');
      }

      final filePath = await _docxExportService.exportContract(_selectedContract!);

      debugPrint('✅ DOCX export başarılı: $filePath');

      _error = null;
      return filePath;
    } catch (e) {
      _error = 'DOCX export hatası: ${e.toString()}';
      debugPrint('❌ DOCX export hatası: $e');
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Sözleşmeyi DOCX olarak export eder ve paylaşır
  Future<bool> exportAndShareDocx(int contractId) async {
    try {
      final filePath = await exportContractAsDocx(contractId);

      if (filePath == null) {
        return false;
      }

      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Sözleşme - ${_selectedContract?.contractNumber}',
        text: 'Sözleşme DOCX dosyası ektedir.',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      _error = 'Paylaşım hatası: ${e.toString()}';
      debugPrint('❌ Share error: $e');
      return false;
    }
  }

  /// Sözleşmeyi DOCX olarak export eder ve açar
  Future<bool> exportAndOpenDocx(int contractId) async {
    try {
      final filePath = await exportContractAsDocx(contractId);

      if (filePath == null) {
        return false;
      }

      final result = await OpenFilex.open(filePath);

      return result.type == ResultType.done;
    } catch (e) {
      _error = 'Dosya açma hatası: ${e.toString()}';
      debugPrint('❌ Open file error: $e');
      return false;
    }
  }

  /// Sözleşmeyi DOCX olarak Downloads klasörüne kaydeder
  Future<String?> saveDocxToDownloads(int contractId) async {
    _isExporting = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedContract == null || _selectedContract!.id != contractId) {
        await loadContractById(contractId);
      }

      if (_selectedContract == null) {
        throw Exception('Sözleşme bulunamadı');
      }

      final tempPath = await _docxExportService.exportContract(_selectedContract!);

      final bytes = await File(tempPath).readAsBytes();

      final finalPath = await _docxExportService.saveToDownloads(
        bytes,
        _selectedContract!,
      );

      debugPrint('✅ DOCX Downloads klasörüne kaydedildi: $finalPath');

      _error = null;
      return finalPath;
    } catch (e) {
      _error = 'DOCX kaydetme hatası: ${e.toString()}';
      debugPrint('❌ Save error: $e');
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Delete contract
  Future<bool> deleteContract(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _contractService.deleteContract(id);

      _contracts.removeWhere((c) => c.id == id);

      if (_selectedContract?.id == id) {
        _selectedContract = null;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting contract: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set filter type
  void setFilterType(ContractType? type) {
    _filterType = type;
    loadContracts(refresh: true);
  }

  /// Set filter status
  void setFilterStatus(ContractStatus? status) {
    _filterStatus = status;
    loadContracts(refresh: true);
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadContracts(refresh: true);
  }

  /// Set date range
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadContracts(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    _filterType = null;
    _filterStatus = null;
    _searchQuery = null;
    _startDate = null;
    _endDate = null;
    loadContracts(refresh: true);
  }

  /// Clear selected contract
  void clearSelectedContract() {
    _selectedContract = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _contracts.clear();
    _selectedContract = null;
    super.dispose();
  }
}
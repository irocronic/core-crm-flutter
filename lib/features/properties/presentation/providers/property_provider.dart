// lib/features/properties/presentation/providers/property_provider.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; //
import 'package:file_picker/file_picker.dart'; // <-- Eklendi
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/property_model.dart';
import '../../data/services/property_service.dart';
import '../../data/models/project_model.dart'; //
import '../../data/models/payment_plan_model.dart'; //
import '../../data/models/property_stats_model.dart'; //
// YENİ IMPORTLAR (Platform ve İndirme için)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart'; // İzinler için
// ✨ YENİ Eklenen Import ✨
import 'package:universal_html/html.dart' as html;

class PropertyProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;
  late final PropertyService _propertyService;

  PropertyProvider(this._apiClient, this._authProvider) {
    _propertyService = PropertyService(_apiClient);
  }

  List<PropertyModel> _properties = [];
  PropertyModel? _selectedProperty;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _searchQuery;
  String? _filterStatus;
  int? _filterProjectId;
  List<ProjectModel> _projects = [];
  PropertyStatisticsModel? _statistics;
  bool _isStatsLoading = false;
  String? downloadedFilePath; // İndirilen dosya yolunu tutmak için (mobil)

  List<PropertyModel> get properties => _properties;
  PropertyModel? get selectedProperty => _selectedProperty;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int? get filterProjectId => _filterProjectId;
  List<ProjectModel> get projects => _projects;
  String? get filterStatus => _filterStatus;
  PropertyStatisticsModel? get statistics => _statistics;
  bool get isStatsLoading => _isStatsLoading;

  Future<bool> createProject(Map<String, dynamic> data, XFile? projectImage,
      XFile? sitePlanImage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newProject = await _propertyService.createProject(
          data, projectImage, sitePlanImage);
      _projects.insert(0, newProject); // Yeni projeyi listenin başına ekle
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- YENİ METOT: Örnek CSV İndirme ---
  Future<bool> downloadSampleCsv() async {
    _isLoading = true; // State'i yönetmek için
    _errorMessage = null;
    downloadedFilePath = null; // Önceki yolu temizle
    notifyListeners();
    try {
      final response = await _propertyService.downloadSampleCsv();

      if (kIsWeb) {
        // Web: Blob oluşturup indirme linki tetikle
        final blob = html.Blob([response.data], 'text/csv;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "ornek_mulk_sablonu.csv")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobil: Dosyayı geçici bir yere kaydet
        // İzin kontrolü (isteğe bağlı ama önerilir)
        if (Platform.isAndroid || Platform.isIOS) {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
          if (!status.isGranted) {
            throw Exception("Dosya yazma izni verilmedi.");
          }
        }

        final directory = await getTemporaryDirectory(); // Geçici dizin
        final filePath = '${directory.path}/ornek_mulk_sablonu.csv';
        final file = File(filePath);
        // Gelen veri byte listesi (Uint8List) olmalı
        if (response.data is List<int>) {
          await file.writeAsBytes(response.data);
          downloadedFilePath = filePath; // Kaydedilen yolu state'e ata
          print("Örnek CSV indirildi: $filePath");
          // İsteğe bağlı: Dosyayı otomatik aç
          // await OpenFile.open(filePath);
        } else {
          throw Exception("İndirilen veri formatı beklenmiyor (bytes bekleniyordu).");
        }
      }
      return true;
    } catch (e) {
      _errorMessage = 'Örnek şablon indirilemedi: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- YENİ METOT: CSV Dosyası Yükleme ---
  Future<bool> uploadBulkPropertiesCsv(PlatformFile file) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyService.uploadBulkPropertiesCsv(file);
      await loadProperties(refresh: true); // Başarılı yükleme sonrası listeyi yenile
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bulkCreateProperties(
      List<Map<String, dynamic>> properties) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyService.bulkCreateProperties(properties);
      await loadProperties(refresh: true); // Yeniden yükle
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

  Future<void> loadStatistics() async {
    _isStatsLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final statsData = await _propertyService.getPropertyStatistics();
      _statistics = PropertyStatisticsModel.fromJson(statsData);
    } catch (e) {
      _errorMessage = 'İstatistikler yüklenemedi: $e';
      _statistics = null;
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      loadProperties(refresh: true),
      loadProjects(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProjects() async {
    try {
      _projects = await _propertyService.getProjects();
    } catch (e) {
      debugPrint("Proje listesi yüklenemedi: $e");
    }
    notifyListeners();
  }

  Future<void> loadProperties({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _properties.clear();
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
      final result = await _propertyService.getProperties(
        page: _currentPage,
        search: _searchQuery,
        status: _filterStatus,
        projectId: _filterProjectId,
      );
      if (_currentPage == 1) {
        _properties = result.results;
      } else {
        _properties.addAll(result.results);
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

  Future<void> loadAvailableProperties({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _properties.clear();
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
      final result = await _propertyService.getAvailableProperties(
        page: _currentPage,
        search: _searchQuery,
      );
      if (_currentPage == 1) {
        _properties = result.results;
      } else {
        _properties.addAll(result.results);
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

  Future<void> searchProperties(String query) async {
    _searchQuery = query;
    await loadProperties(refresh: true);
  }

  Future<void> filterByStatus(String? status) async {
    _filterStatus = status;
    await loadProperties(refresh: true);
  }

  Future<void> filterByProject(int? projectId) async {
    _searchQuery = null;
    _filterStatus = null;
    _filterProjectId = projectId;
    await loadProperties(refresh: true);
  }

  void clearFilters() {
    _searchQuery = null;
    _filterStatus = null;
    _filterProjectId = null;
    notifyListeners();
  }

  Future<void> loadPropertyDetail(int id) async {
    _selectedProperty = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedProperty = await _propertyService.getPropertyDetail(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProperty(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newProperty = await _propertyService.createProperty(data);
      _properties.insert(0, newProperty);
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

  Future<bool> updateProperty(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProperty = await _propertyService.updateProperty(id, data);
      final index = _properties.indexWhere((p) => p.id == id);
      if (index != -1) {
        _properties[index] = updatedProperty;
      }
      if (_selectedProperty?.id == id) {
        _selectedProperty = updatedProperty;
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

  Future<bool> uploadImages(int propertyId, List<XFile> imageFiles) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyService.uploadImages(propertyId, imageFiles);
      await loadPropertyDetail(propertyId); // Detayı yenile
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Görseller yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadDocument({
    required int propertyId,
    required String title,
    required String docType,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyService.uploadDocument(
        propertyId: propertyId,
        title: title,
        docType: docType,
        fileName: fileName,
        filePath: filePath,
        fileBytes: fileBytes,
      );
      await loadPropertyDetail(propertyId); // Detayı yenile
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Belge yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPaymentPlan(int propertyId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyService.createPaymentPlan(propertyId, data);
      await loadPropertyDetail(propertyId); // Detayı yenile
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ödeme planı oluşturulamadı: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProperty(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyService.deleteProperty(id);
      _properties.removeWhere((p) => p.id == id);
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

  Future<bool> deleteDocument(int propertyId, int documentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _propertyService.deleteDocument(documentId);
      await loadPropertyDetail(propertyId); // Detayı yenile
      return true;
    } catch (e) {
      _errorMessage = "Belge silinemedi: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePaymentPlan(int propertyId, int planId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _propertyService.deletePaymentPlan(planId);
      await loadPropertyDetail(propertyId); // Detayı yenile
      return true;
    } catch (e) {
      _errorMessage = "Ödeme planı silinemedi: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteImage(int propertyId, int imageId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _propertyService.deleteImage(imageId);
      await loadPropertyDetail(propertyId); // Detayı yenile
      return true;
    } catch (e) {
      _errorMessage = "Görsel silinemedi: $e";
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

  void clearSelectedProperty() {
    _selectedProperty = null;
    notifyListeners();
  }
}
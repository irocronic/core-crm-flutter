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
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // <-- debugPrint eklendi
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
  int? _filterProjectId; // Proje filtresi burada tutuluyor
  List<ProjectModel> _projects = [];
  PropertyStatisticsModel? _statistics;
  bool _isStatsLoading = false;
  String? downloadedFilePath; // İndirilen dosya yolunu tutmak için (mobil)

  // --- FİLTRE STATE'LERİ ---
  String? _filterStatus;
  String? _filterPropertyType;
  String? _filterRoomCount;
  String? _filterFacade;
  double? _filterMinArea;
  double? _filterMaxArea;
  // --- FİLTRE STATE'LERİ SONU ---

  List<PropertyModel> get properties => _properties;
  PropertyModel? get selectedProperty => _selectedProperty;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int? get filterProjectId => _filterProjectId;
  List<ProjectModel> get projects => _projects;
  PropertyStatisticsModel? get statistics => _statistics;
  bool get isStatsLoading => _isStatsLoading;

  // --- GETTER'LAR ---
  String? get filterStatus => _filterStatus;
  String? get filterPropertyType => _filterPropertyType;
  String? get filterRoomCount => _filterRoomCount;
  String? get filterFacade => _filterFacade;
  double? get filterMinArea => _filterMinArea;
  double? get filterMaxArea => _filterMaxArea;
  // --- GETTER'LAR SONU ---

  // ======================== DEBUG LOG Helper ========================
  void _log(String message) {
    debugPrint('[PropertyProvider] $message');
  }
  // =================================================================

  Future<bool> createProject(Map<String, dynamic> data, XFile? projectImage,
      XFile? sitePlanImage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _log('Yeni proje oluşturuluyor...');
      final newProject = await _propertyService.createProject(
          data, projectImage, sitePlanImage);
      _projects.insert(0, newProject); // Yeni projeyi listenin başına ekle
      _log('✅ Yeni proje başarıyla oluşturuldu: ${newProject.name}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _log('❌ Proje oluşturma hatası: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> downloadSampleCsv() async {
    _isLoading = true; // State'i yönetmek için
    _errorMessage = null;
    downloadedFilePath = null; // Önceki yolu temizle
    notifyListeners();
    _log('📄 Örnek CSV şablonu indirme işlemi başlatılıyor...');
    try {
      final response = await _propertyService.downloadSampleCsv();

      if (kIsWeb) {
        _log('📄 Web platformu: İndirme linki oluşturuluyor...');
        final blob = html.Blob([response.data], 'text/csv;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "ornek_mulk_sablonu.csv")
          ..click();
        html.Url.revokeObjectUrl(url);
        _log('✅ Web: İndirme işlemi tetiklendi.');
      } else {
        _log('📄 Mobil platformu: Dosya kaydediliyor...');
        if (Platform.isAndroid || Platform.isIOS) {
          _log('🔒 Depolama izni kontrol ediliyor...');
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            _log('🔒 İzin isteniyor...');
            status = await Permission.storage.request();
          }
          if (!status.isGranted) {
            _log('❌ İzin verilmedi.');
            throw Exception("Dosya yazma izni verilmedi.");
          }
          _log('✅ İzin verildi.');
        }

        final directory = await getTemporaryDirectory(); // Geçici dizin
        final filePath = '${directory.path}/ornek_mulk_sablonu.csv';
        final file = File(filePath);
        _log('💾 Dosya şuraya kaydedilecek: $filePath');
        if (response.data is List<int>) {
          await file.writeAsBytes(response.data);
          downloadedFilePath = filePath; // Kaydedilen yolu state'e ata
          _log("✅ Örnek CSV indirildi: $filePath");
        } else {
          _log('❌ İndirilen veri formatı beklenmiyor: ${response.data.runtimeType}');
          throw Exception("İndirilen veri formatı beklenmiyor (bytes bekleniyordu).");
        }
      }
      return true;
    } catch (e) {
      _errorMessage = 'Örnek şablon indirilemedi: ${e.toString()}';
      _log('❌ Örnek CSV indirme hatası: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadBulkPropertiesCsv(PlatformFile file) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _log('🔼 Toplu mülk CSV yükleme işlemi başlatılıyor: ${file.name}');
    try {
      await _propertyService.uploadBulkPropertiesCsv(file);
      _log('✅ Toplu mülk CSV başarıyla yüklendi. Liste yenileniyor...');
      await loadProperties(refresh: true); // Başarılı yükleme sonrası listeyi yenile
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _log('❌ Toplu mülk CSV yükleme hatası: $_errorMessage');
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
    _log('🏘️ ${properties.length} mülk toplu oluşturuluyor...');
    try {
      await _propertyService.bulkCreateProperties(properties);
      _log('✅ Mülkler başarıyla oluşturuldu. Liste yenileniyor...');
      await loadProperties(refresh: true); // Yeniden yükle
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _log('❌ Toplu mülk oluşturma hatası: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadStatistics() async {
    _isStatsLoading = true;
    _errorMessage = null;
    notifyListeners();
    _log('📊 İstatistikler yükleniyor...');
    try {
      final statsData = await _propertyService.getPropertyStatistics();
      _statistics = PropertyStatisticsModel.fromJson(statsData);
      _log('✅ İstatistikler başarıyla yüklendi.');
    } catch (e) {
      _errorMessage = 'İstatistikler yüklenemedi: $e';
      _log('❌ İstatistik yükleme hatası: $_errorMessage');
      _statistics = null;
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    _log('🏁 Başlangıç verileri yükleniyor (Mülkler ve Projeler)...');
    await Future.wait([
      loadProperties(refresh: true),
      loadProjects(),
    ]);
    _isLoading = false;
    _log('✅ Başlangıç verileri yüklendi.');
    notifyListeners();
  }

  Future<void> loadProjects() async {
    _log('🏗️ Projeler yükleniyor...');
    try {
      _projects = await _propertyService.getProjects();
      _log('✅ ${_projects.length} proje yüklendi.');
    } catch (e) {
      _log("❌ Proje listesi yüklenemedi: $e");
    }
    notifyListeners();
  }

  // --- loadProperties Metodu ---
  Future<void> loadProperties({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _properties.clear();
      _log('🔄 Mülk listesi yenileniyor...');
    } else {
      _log('➕ Sonraki mülk sayfası yükleniyor (Sayfa: $_currentPage)...');
    }

    if (_isLoading || _isLoadingMore) {
      _log('⚠️ Yükleme zaten devam ediyor, işlem iptal edildi.');
      return;
    }
    if (!_hasMore && !refresh) {
      _log('⚠️ Daha fazla mülk yok, işlem iptal edildi.');
      return;
    }

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    // notifyListeners(); // Hemen listener çağırmak yerine try-catch sonrası çağır

    // ======================== DEBUG LOG: Filtre Değerleri ========================
    _log('🔍 loadProperties - Uygulanacak Filtreler:');
    _log('   - Proje ID: $_filterProjectId');
    _log('   - Durum: $_filterStatus');
    _log('   - Tip: $_filterPropertyType');
    _log('   - Oda: $_filterRoomCount');
    _log('   - Cephe: $_filterFacade');
    _log('   - Min Alan: $_filterMinArea');
    _log('   - Max Alan: $_filterMaxArea');
    _log('   - Arama: $_searchQuery');
    // ==========================================================================
    notifyListeners(); // Filtre loglandıktan sonra listener'ı çağır

    try {
      final result = await _propertyService.getProperties(
        page: _currentPage,
        search: _searchQuery,
        status: _filterStatus,
        projectId: _filterProjectId,
        propertyType: _filterPropertyType,
        roomCount: _filterRoomCount,
        facade: _filterFacade,
        minArea: _filterMinArea,
        maxArea: _filterMaxArea,
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
      _log('✅ ${_properties.length} mülk yüklendi (toplam). Daha fazla var mı: $_hasMore');
    } catch (e) {
      _errorMessage = e.toString();
      _log('❌ Mülk yükleme hatası: $_errorMessage');
      if(refresh) _properties = []; // Hata durumunda listeyi temizle (refresh ise)
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableProperties({bool refresh = false}) async {
    // ... (Mevcut kod - Log eklenebilir) ...
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _properties.clear();
      _log('🔄 Müsait mülk listesi yenileniyor...');
    } else {
      _log('➕ Sonraki müsait mülk sayfası yükleniyor (Sayfa: $_currentPage)...');
    }

    if (_isLoading || _isLoadingMore) return;
    if (!_hasMore && !refresh) return;

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
      _log('✅ ${_properties.length} müsait mülk yüklendi. Daha fazla var mı: $_hasMore');
    } catch (e) {
      _errorMessage = e.toString();
      _log('❌ Müsait mülk yükleme hatası: $_errorMessage');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchProperties(String query) async {
    _searchQuery = query.isEmpty ? null : query; // Boş query null olmalı
    _log("🔎 Arama yapılıyor: '$_searchQuery'");
    await loadProperties(refresh: true);
  }

  // --- FİLTRE AYARLAMA METOTLARI (loadProperties çağrısı kaldırıldı) ---
  void setFilterStatus(String? status) {
    _filterStatus = status;
    _log("⬇️ Durum filtresi ayarlandı: $status");
    notifyListeners(); // Sadece state'i güncelle, yüklemeyi applyFilters yapacak
    // await loadProperties(refresh: true); // <-- KALDIRILDI
  }

  void setFilterType(String? type) {
    _filterPropertyType = type;
    _log("⬇️ Tip filtresi ayarlandı: $type");
    notifyListeners();
    // await loadProperties(refresh: true); // <-- KALDIRILDI
  }

  void setFilterRoomCount(String? count) {
    _filterRoomCount = count;
    _log("⬇️ Oda sayısı filtresi ayarlandı: $count");
    notifyListeners();
    // await loadProperties(refresh: true); // <-- KALDIRILDI
  }

  void setFilterFacade(String? facade) {
    _filterFacade = facade;
    _log("⬇️ Cephe filtresi ayarlandı: $facade");
    notifyListeners();
    // await loadProperties(refresh: true); // <-- KALDIRILDI
  }

  void setFilterArea(double? min, double? max) {
    _filterMinArea = min;
    _filterMaxArea = max;
    _log("⬇️ Alan filtresi ayarlandı: Min=$min, Max=$max");
    notifyListeners();
    // await loadProperties(refresh: true); // <-- KALDIRILDI
  }
  // --- FİLTRE AYARLAMA METOTLARI SONU ---

  // *** YENİ METOT: Tüm filtreleri uygula ve yükle ***
  Future<void> applyAllFilters({
    String? status,
    String? propertyType,
    String? roomCount,
    String? facade,
    double? minArea,
    double? maxArea,
  }) async {
    _log("⚙️ Tüm filtreler uygulanıyor...");
    _filterStatus = status;
    _filterPropertyType = propertyType;
    _filterRoomCount = roomCount;
    _filterFacade = facade;
    _filterMinArea = minArea;
    _filterMaxArea = maxArea;
    // Proje ID ve arama sorgusu korunur.
    notifyListeners(); // State güncellendiğini bildir
    await loadProperties(refresh: true); // Veriyi yeniden yükle
  }
  // *** YENİ METOT SONU ***

  Future<void> filterByProject(int? projectId) async {
    // Proje filtresi uygulandığında diğer filtreleri temizle
    _searchQuery = null;
    _filterStatus = null;
    _filterPropertyType = null;
    _filterRoomCount = null;
    _filterFacade = null;
    _filterMinArea = null;
    _filterMaxArea = null;
    _filterProjectId = projectId;
    _log("⬇️ Proje filtresi ayarlandı: $projectId. Diğer filtreler temizlendi.");
    notifyListeners(); // State değiştiğini bildir
    await loadProperties(refresh: true); // Yeniden yükle
  }

  // --- DÜZELTME: clearFilters metodu proje filtresini TEMİZLEMEZ ve loadProperties çağırır ---
  void clearFilters() {
    _searchQuery = null;
    _filterStatus = null;
    _filterPropertyType = null;
    _filterRoomCount = null;
    _filterFacade = null;
    _filterMinArea = null;
    _filterMaxArea = null;
    _log("🚫 Tüm filtreler temizlendi (Proje filtresi hariç). Liste yenileniyor...");
    notifyListeners();
    // Filtreleri temizledikten sonra verileri yeniden yükle
    // Proje filtresi hala aktif olacağı için doğru liste yüklenecektir
    loadProperties(refresh: true);
  }
  // --- DÜZELTME SONU ---


  Future<void> loadPropertyDetail(int id) async {
    _selectedProperty = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _log("📋 Mülk detayı yükleniyor: ID $id");
    try {
      _selectedProperty = await _propertyService.getPropertyDetail(id);
      _log("✅ Mülk detayı başarıyla yüklendi: ID $id");
    } catch (e) {
      _errorMessage = e.toString();
      _log("❌ Mülk detayı yükleme hatası: ID $id - Hata: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProperty(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _log("➕ Yeni mülk oluşturuluyor...");
    try {
      final newProperty = await _propertyService.createProperty(data);
      _properties.insert(0, newProperty);
      _log("✅ Yeni mülk başarıyla oluşturuldu: ID ${newProperty.id}");
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _log("❌ Yeni mülk oluşturma hatası: $_errorMessage");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProperty(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _log("✏️ Mülk güncelleniyor: ID $id");
    try {
      final updatedProperty = await _propertyService.updateProperty(id, data);
      final index = _properties.indexWhere((p) => p.id == id);
      if (index != -1) {
        _properties[index] = updatedProperty;
      }
      if (_selectedProperty?.id == id) {
        _selectedProperty = updatedProperty;
      }
      _log("✅ Mülk başarıyla güncellendi: ID $id");
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _log("❌ Mülk güncelleme hatası: ID $id - Hata: $_errorMessage");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadImages(int propertyId, List<XFile> imageFiles) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _log("🖼️ ${imageFiles.length} görsel yükleniyor: Mülk ID $propertyId");
    try {
      await _propertyService.uploadImages(propertyId, imageFiles);
      _log("✅ Görseller yüklendi. Mülk detayı yenileniyor...");
      await loadPropertyDetail(propertyId); // Detayı yenile
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Görseller yüklenemedi: $e';
      _log("❌ Görsel yükleme hatası: Mülk ID $propertyId - Hata: $_errorMessage");
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
    _log("📄 Belge yükleniyor: '$title' - Mülk ID $propertyId");
    try {
      await _propertyService.uploadDocument(
        propertyId: propertyId,
        title: title,
        docType: docType,
        fileName: fileName,
        filePath: filePath,
        fileBytes: fileBytes,
      );
      _log("✅ Belge yüklendi. Mülk detayı yenileniyor...");
      await loadPropertyDetail(propertyId); // Detayı yenile
      _isLoading = false; //
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Belge yüklenemedi: $e';
      _log("❌ Belge yükleme hatası: Mülk ID $propertyId - Hata: $_errorMessage");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPaymentPlan(int propertyId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _log("💰 Ödeme planı oluşturuluyor: Mülk ID $propertyId");
    try {
      await _propertyService.createPaymentPlan(propertyId, data);
      _log("✅ Ödeme planı oluşturuldu. Mülk detayı yenileniyor...");
      await loadPropertyDetail(propertyId); // Detayı yenile
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ödeme planı oluşturulamadı: $e';
      _log("❌ Ödeme planı oluşturma hatası: Mülk ID $propertyId - Hata: $_errorMessage");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProperty(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _log("🗑️ Mülk siliniyor: ID $id");
    try {
      await _propertyService.deleteProperty(id);
      _properties.removeWhere((p) => p.id == id);
      _log("✅ Mülk başarıyla silindi: ID $id");
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _log("❌ Mülk silme hatası: ID $id - Hata: $_errorMessage");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(int propertyId, int documentId) async {
    _isLoading = true;
    notifyListeners();
    _log("🗑️ Belge siliniyor: ID $documentId - Mülk ID $propertyId");
    try {
      await _propertyService.deleteDocument(documentId);
      _log("✅ Belge silindi. Mülk detayı yenileniyor...");
      await loadPropertyDetail(propertyId); // Detayı yenile
      return true;
    } catch (e) {
      _errorMessage = "Belge silinemedi: $e";
      _log("❌ Belge silme hatası: ID $documentId - Hata: $_errorMessage");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePaymentPlan(int propertyId, int planId) async {
    _isLoading = true;
    notifyListeners();
    _log("🗑️ Ödeme planı siliniyor: ID $planId - Mülk ID $propertyId");
    try {
      await _propertyService.deletePaymentPlan(planId);
      _log("✅ Ödeme planı silindi. Mülk detayı yenileniyor...");
      await loadPropertyDetail(propertyId); // Detayı yenile
      return true;
    } catch (e) {
      _errorMessage = "Ödeme planı silinemedi: $e";
      _log("❌ Ödeme planı silme hatası: ID $planId - Hata: $_errorMessage");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteImage(int propertyId, int imageId) async {
    _isLoading = true;
    notifyListeners();
    _log("🗑️ Görsel siliniyor: ID $imageId - Mülk ID $propertyId");
    try {
      await _propertyService.deleteImage(imageId);
      _log("✅ Görsel silindi. Mülk detayı yenileniyor...");
      await loadPropertyDetail(propertyId); // Detayı yenile
      return true;
    } catch (e) {
      _errorMessage = "Görsel silinemedi: $e";
      _log("❌ Görsel silme hatası: ID $imageId - Hata: $_errorMessage");
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
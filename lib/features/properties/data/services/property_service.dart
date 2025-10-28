// lib/features/properties/data/services/property_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // Bu import gerekli
import 'package:file_picker/file_picker.dart'; // <-- Eklendi

import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/pagination_model.dart';
import '../models/property_model.dart'; //
import '../models/payment_plan_model.dart';
import '../models/project_model.dart'; // Bu import gerekli

class PropertyService {
  final ApiClient _apiClient;
  PropertyService(this._apiClient);

  // ======================== DEBUG LOG Helper ========================
  void _log(String message) {
    // Kendi log prefix'inizi veya daha gelişmiş bir logger kullanabilirsiniz
    debugPrint('[PropertyService] $message');
  }
  // ==================================================================


  Future<ProjectModel> createProject(Map<String, dynamic> data,
      XFile? projectImage, XFile? sitePlanImage) async {
    try {
      _log('🏗️ Yeni proje oluşturma isteği gönderiliyor...'); // Log eklendi
      final formData = FormData.fromMap(data); // Metin verilerini ekle

      if (projectImage != null) {
        _log('🖼️ Proje görseli ekleniyor: ${projectImage.name}'); // Log eklendi
        if (kIsWeb) {
          final bytes = await projectImage.readAsBytes();
          formData.files.add(MapEntry(
            'project_image', // Django modelindeki field adı
            MultipartFile.fromBytes(bytes, filename: projectImage.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'project_image', //
            await MultipartFile.fromFile(projectImage.path,
                filename: projectImage.name),
          ));
        }
      }

      if (sitePlanImage != null) {
        _log('🗺️ Vaziyet planı görseli ekleniyor: ${sitePlanImage.name}'); // Log eklendi
        if (kIsWeb) {
          final bytes = await sitePlanImage.readAsBytes();
          formData.files.add(MapEntry(
            'site_plan_image', // Django modelindeki field adı
            MultipartFile.fromBytes(bytes, filename: sitePlanImage.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'site_plan_image',
            await MultipartFile.fromFile(sitePlanImage.path, //
                filename: sitePlanImage.name),
          ));
        }
      }

      _log('📦 Gönderilecek Form Verisi (Fields): ${formData.fields}'); // Log eklendi
      _log('📦 Gönderilecek Dosyalar: ${formData.files.map((f) => f.key)}'); // Log eklendi

      final response = await _apiClient.post(
        ApiConstants.projects, // Proje endpoint'i
        data: formData,
      );

      _log('✅ Proje başarıyla oluşturuldu (Yanıt Kodu: ${response.statusCode})'); // Log eklendi
      return ProjectModel.fromJson(response.data);

    } on DioException catch (e) {
      _log('❌ Proje oluşturma hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error Response: ${e.response?.data}'); // Log eklendi
      String errorMessage = 'Proje oluşturulamadı.';
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first; //
          final firstErrorValue = errors[firstErrorKey];
          if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
            errorMessage = '${firstErrorKey}: ${firstErrorValue.first}';
          } else {
            errorMessage = '${firstErrorKey}: ${firstErrorValue.toString()}';
          }
        }
      } else if (e.response?.data is String) { //
        errorMessage = e.response!.data;
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    } catch (e) {
      _log('❌ Beklenmedik Proje oluşturma hatası: $e'); // Log eklendi
      throw Exception('Beklenmedik bir hata oluştu: ${e.toString()}');
    }
  }

  // --- YENİ METOT: Örnek CSV İndirme ---
  Future<Response> downloadSampleCsv() async {
    try {
      _log('📄 Örnek CSV şablonu indirme isteği gönderiliyor...'); // Log eklendi
      // GET isteği, backend'den dosya içeriğini (byte) alacak
      final response = await _apiClient.get(
        '${ApiConstants.properties}export-sample-csv/',
        options: Options(
          responseType: ResponseType.bytes, // Dosya içeriğini byte olarak al
        ),
      );
      _log('✅ Örnek CSV şablonu başarıyla alındı (Yanıt Kodu: ${response.statusCode}).'); // Log eklendi
      return response;
    } on DioException catch (e) {
      _log('❌ Örnek CSV indirme hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error: ${e.response?.data}'); // Log eklendi
      throw Exception('Örnek şablon indirilemedi: ${e.message}');
    }
  }

  // --- YENİ METOT: CSV Dosyası Yükleme ---
  Future<Response> uploadBulkPropertiesCsv(PlatformFile file) async {
    try {
      _log('🔼 Toplu mülk CSV dosyası yükleme isteği gönderiliyor: ${file.name}'); // Log eklendi
      final formData = FormData();

      if (kIsWeb) { //
        // Web: Byte verisini kullan
        _log('   (Web) Byte verisi kullanılıyor...'); // Log eklendi
        formData.files.add(MapEntry(
          'file', // Backend'de beklenen dosya alanı adı
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        ));
      } else {
        // Mobil: Dosya yolunu kullan
        _log('   (Mobil) Dosya yolu kullanılıyor: ${file.path}'); // Log eklendi
        formData.files.add(MapEntry(
          'file', // Backend'de beklenen dosya alanı adı
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      }

      // API isteğini gönder
      final response = await _apiClient.post(
        '${ApiConstants.properties}bulk-create-from-csv/', // Yeni endpoint
        data: formData, //
      );

      _log('✅ Toplu mülk CSV dosyası başarıyla yüklendi ve işlendi (Yanıt Kodu: ${response.statusCode}).'); // Log eklendi
      return response; // Başarılı yanıtı döndür (örn: kaç tane oluşturulduğu bilgisi)

    } on DioException catch (e) {
      _log('❌ Toplu mülk CSV yükleme hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error Response: ${e.response?.data}'); // Log eklendi
      // Hata detayını ayıkla
      String errorMessage = 'Toplu mülk yüklenemedi.';
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        if (errors.containsKey('error')) {
          errorMessage = errors['error'].toString();
          if (errors.containsKey('details') && errors['details'] is List) {
            // İlk birkaç hatayı mesaja ekleyebiliriz
            errorMessage += '\nDetaylar:\n';
            final details = (errors['details'] as List).take(3).map((d) { //
              if (d is Map) {
                return "Satır ${d['line']}: ${d['errors']}";
              }
              return d.toString();
            }).join('\n');
            errorMessage += details;
            if ((errors['details'] as List).length > 3) {
              errorMessage += "\n...";
            }
          }
        } else {
          errorMessage = errors.toString(); // Genel map hatası
        }
      } else if (e.response?.data is String) { //
        errorMessage = e.response!.data;
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    } catch (e) {
      _log('❌ Beklenmedik Toplu mülk CSV yükleme hatası: $e'); // Log eklendi
      throw Exception('Beklenmedik bir hata oluştu: ${e.toString()}');
    }
  }

  // ✅ GÜNCELLEME: Proje listesini API'den doğru şekilde almak için düzeltildi
  Future<List<ProjectModel>> getProjects() async {
    try {
      _log('🏗️ Proje listesi isteği gönderiliyor...'); // Log eklendi
      final response = await _apiClient.get(ApiConstants.projects);

      // Yanıtın Map olup olmadığını ve 'results' anahtarını içerip içermediğini kontrol et
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        // 'results' listesini al
        final List<dynamic> data = response.data['results'] as List<dynamic>? ?? []; //
        _log('✅ ${data.length} proje alındı (Sayfalanmış)'); // Log eklendi
        return data
            .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.data is List) {
        // Eğer yanıt doğrudan liste ise (sayfalama yoksa)
        final List<dynamic> data = response.data as List<dynamic>;
        _log('✅ ${data.length} proje alındı (Sayfasız)'); // Log eklendi
        return data
            .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Beklenmeyen format
        _log('❌ Proje listesi yanıtı beklenmeyen formatta: ${response.data.runtimeType}'); // Log eklendi
        throw Exception('Projeler yüklenemedi: Geçersiz yanıt formatı');
      }
    } on DioException catch (e) { //
      _log('❌ Proje listesi hatası: ${e.response?.statusCode}'); // Log eklendi
      throw Exception('Projeler yüklenemedi: ${e.message}');
    } catch (e) { // Diğer hatalar için (örn: format hatası)
      _log('❌ Proje listesi işleme hatası: $e'); // Log eklendi
      throw Exception('Projeler işlenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<void> bulkCreateProperties(
      List<Map<String, dynamic>> properties) async {
    try {
      _log('🏘️ ${properties.length} adet mülk toplu olarak oluşturma isteği gönderiliyor...'); // Log eklendi
      final data = {'properties': properties};
      await _apiClient.post(
        '${ApiConstants.properties}bulk_create/',
        data: data,
      );
      _log('✅ Mülkler başarıyla oluşturuldu.'); // Log eklendi
    } on DioException catch (e) {
      _log('❌ Toplu mülk oluşturma hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error: ${e.response?.data}'); // Log eklendi
      throw Exception(
          'Toplu mülk oluşturulamadı: ${e.response?.data ?? e.message}'); //
    }
  }

  // --- GÜNCELLEME: getProperties metoduna yeni filtre parametreleri eklendi ---
  Future<PaginationModel<PropertyModel>> getProperties({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    int? projectId,
    // Yeni filtre parametreleri
    String? propertyType,
    String? roomCount,
    String? facade,
    double? minArea,
    double? maxArea,
  }) async {
    try {
      _log('🏠 Gayrimenkuller isteği gönderiliyor (Sayfa: $page)...'); // Log eklendi
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': limit,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search; //
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (projectId != null) {
        queryParams['project'] = projectId;
      }
      // Yeni filtre parametrelerini ekle
      if (propertyType != null && propertyType.isNotEmpty) {
        queryParams['property_type'] = propertyType; // API'deki beklenen ad
      }
      if (roomCount != null && roomCount.isNotEmpty) {
        // Backend'in CharFilter(lookup_expr='icontains') kullandığını varsayarsak:
        // Backend filterset'te parametre adı 'room_count' olarak tanımlı,
        // lookup_expr zaten 'icontains' olduğu için sadece 'room_count' gönderilmelidir.
        queryParams['room_count'] = roomCount;
      }
      if (facade != null && facade.isNotEmpty) {
        queryParams['facade'] = facade; // API'deki beklenen ad //
      }
      if (minArea != null) {
        // Backend FilterSet net_area için min_area / max_area parametrelerini bekliyor
        queryParams['min_area'] = minArea;
      }
      if (maxArea != null) {
        queryParams['max_area'] = maxArea;
      }

      _log('🔍 API Query Params: $queryParams'); // Sorgu parametrelerini logla

      final response = await _apiClient.get(
        ApiConstants.properties,
        queryParameters: queryParams,
      );
      _log('✅ Gayrimenkuller alındı (Yanıt Kodu: ${response.statusCode})'); // Log eklendi

      return PaginationModel<PropertyModel>.fromJson(
        response.data,
            (json) => PropertyModel.fromJson(json as Map<String, dynamic>), //
      );
    } on DioException catch (e) {
      _log('❌ Gayrimenkul listesi hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error: ${e.response?.data}'); // Log eklendi
      throw Exception('Gayrimenkuller yüklenemedi: ${e.message}');
    }
  }
  // --- GÜNCELLEME SONU ---


  Future<PaginationModel<PropertyModel>> getAvailableProperties({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      _log('🏡 Müsait gayrimenkuller isteği gönderiliyor (Sayfa: $page)...'); // Log eklendi
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': limit,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        ApiConstants.availableProperties,
        queryParameters: queryParams, //
      );
      _log('✅ Müsait gayrimenkuller alındı (Yanıt Kodu: ${response.statusCode})'); // Log eklendi

      return PaginationModel<PropertyModel>.fromJson(
        response.data,
            (json) => PropertyModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _log('❌ Müsait gayrimenkul hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error: ${e.response?.data}'); // Log eklendi
      throw Exception('Satılık gayrimenkuller yüklenemedi: ${e.message}');
    }
  }

  Future<PropertyModel> getPropertyDetail(int id) async {
    try {
      _log('📋 Gayrimenkul detayı isteği gönderiliyor: ID $id'); // Log eklendi
      final response = await _apiClient.get('${ApiConstants.properties}$id/');
      _log('📦 Raw property detail response: ${response.data}');
      final raw =
          (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};

      // --- SANITIZE ---
      _log('🧹 Yanıt verisi temizleniyor...'); // Log eklendi
      // Project (make sure it's a valid map with id and name)
      if (raw['project'] == null || raw['project'] is! Map) { //
        _log('   ⚠️ Proje bilgisi eksik veya geçersiz, varsayılan kullanılıyor.'); // Log eklendi
        raw['project'] = {'id': 0, 'name': 'Bilinmeyen Proje'};
      } else if (raw['project'] is Map && !raw['project'].containsKey('id')) {
        _log('   ⚠️ Proje ID eksik, varsayılan (0) kullanılıyor.'); // Log eklendi
        raw['project']['id'] = 0;
        raw['project']['name'] = raw['project']['name'] ?? 'Bilinmeyen Proje';
      }

      // Images (ensure list of maps with default values)
      if (raw['images'] is List) {
        final safeImages = <Map<String, dynamic>>[];
        for (var item in raw['images'] as List) {
          if (item is Map<String, dynamic>) {
            safeImages.add({
              'id': item['id'] ?? 0,
              'image': item['image'] ?? '', //
              'image_type': item['image_type'] ?? 'OTHER',
              'title': item['title'] ?? '',
            });
          } else {
            _log('   ⚠️ Geçersiz görsel verisi atlandı: $item'); // Log eklendi
          }
        }
        raw['images'] = safeImages;
      } else {
        _log('   ⚠️ Görsel listesi bulunamadı veya geçersiz, boş liste kullanılıyor.'); // Log eklendi
        raw['images'] = <Map<String, dynamic>>[];
      }

      // Documents (ensure list of maps with default values)
      if (raw['documents'] is List) {
        final safeDocs = <Map<String, dynamic>>[];
        for (var item in raw['documents'] as List) {
          if (item is Map<String, dynamic>) {
            safeDocs.add({ //
              'id': item['id'] ?? 0,
              'document': item['document'] ?? '',
              'document_type': item['document_type'] ?? 'DIGER',
              'document_type_display': item['document_type_display'] ?? 'Diğer',
              'title': item['title'] ?? '',
            });
          } else {
            _log('   ⚠️ Geçersiz belge verisi atlandı: $item'); // Log eklendi
          }
        }
        raw['documents'] = safeDocs;
      } else {
        _log('   ⚠️ Belge listesi bulunamadı veya geçersiz, boş liste kullanılıyor.'); // Log eklendi
        raw['documents'] = <Map<String, dynamic>>[];
      }

      // Payment Plans (ensure list of maps with default values)
      if (raw['payment_plans'] is List) { //
        final safePlans = <Map<String, dynamic>>[];
        for (var item in raw['payment_plans'] as List) {
          if (item is Map<String, dynamic>) {
            safePlans.add({
              'id': item['id'] ?? 0,
              'plan_type': item['plan_type'] ?? 'OTHER',
              'name': item['name'] ?? '',
              'details': item['details'] ?? <String, dynamic>{},
              'details_display': item['details_display'] ?? '',
              'is_active': item['is_active'] ?? true, //
            });
          } else {
            _log('   ⚠️ Geçersiz ödeme planı verisi atlandı: $item'); // Log eklendi
          }
        }
        raw['payment_plans'] = safePlans;
      } else {
        _log('   ⚠️ Ödeme planı listesi bulunamadı veya geçersiz, boş liste kullanılıyor.'); // Log eklendi
        raw['payment_plans'] = <Map<String, dynamic>>[];
      }
      // --- SANITIZE END ---

      _log('✅ Gayrimenkul detayı alındı ve temizlendi (Yanıt Kodu: ${response.statusCode})'); // Log eklendi
      return PropertyModel.fromJson(raw);
    } on DioException catch (e) {
      _log('❌ Gayrimenkul detay hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error: ${e.response?.data}'); // Log eklendi
      throw Exception('Gayrimenkul detayı yüklenemedi: ${e.message}');
    } catch (e, st) {
      _log('❌ Gayrimenkul detay parsing hatası: $e'); // Log eklendi
      _log('$st');
      rethrow; // Re-throw the original error for provider handling
    }
  }

  Future<Map<String, dynamic>> getPropertyStatistics() async {
    try {
      _log('📊 Gayrimenkul istatistikleri isteği gönderiliyor...'); // Log eklendi
      final response = await _apiClient.get(ApiConstants.propertyStatistics); //
      _log('✅ İstatistikler alındı (Yanıt Kodu: ${response.statusCode})'); // Log eklendi
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _log('❌ İstatistik hatası: ${e.response?.statusCode}'); // Log eklendi
      throw Exception('İstatistikler yüklenemedi: ${e.message}');
    }
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    try {
      _log('➕ Yeni gayrimenkul oluşturma isteği gönderiliyor...'); // Log eklendi
      _log('📦 Data: $data'); // Log eklendi
      final response = await _apiClient.post(
        ApiConstants.properties,
        data: data,
      );
      _log('✅ Gayrimenkul oluşturuldu (Yanıt Kodu: ${response.statusCode})'); // Log eklendi
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Gayrimenkul oluşturma hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error: ${e.response?.data}'); // Log eklendi
      throw Exception(
          'Gayrimenkul oluşturulamadı: ${e.response?.data ?? e.message}');
    }
  }

  Future<PropertyModel> updateProperty(int id, Map<String, dynamic> data) async {
    try {
      _log('✏️ Gayrimenkul güncelleme isteği gönderiliyor: ID $id'); // Log eklendi //
      _log('📦 Data: $data'); // Log eklendi
      final response = await _apiClient.put(
        '${ApiConstants.properties}$id/',
        data: data,
      );
      _log('✅ Gayrimenkul güncellendi (Yanıt Kodu: ${response.statusCode})'); // Log eklendi
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Gayrimenkul güncelleme hatası: ${e.response?.statusCode}'); // Log eklendi
      _log('📦 Error: ${e.response?.data}'); // Log eklendi
      throw Exception(
          'Gayrimenkul güncellenemedi: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> uploadImages(int propertyId, List<XFile> imageFiles) async {
    try {
      _log('🖼️ ${imageFiles.length} görsel yükleme isteği gönderiliyor: Mülk ID $propertyId'); // Log eklendi
      final formData = FormData();
      for (var file in imageFiles) {
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          formData.files.add(MapEntry(
            'images', // Use 'images' as key for multiple files //
            MultipartFile.fromBytes(bytes, filename: file.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'images', // Use 'images' as key for multiple files
            await MultipartFile.fromFile(file.path, filename: file.name),
          ));
        }
      }

      final response = await _apiClient.post(
        '${ApiConstants.properties}$propertyId/upload_images/',
        data: formData,
      );
      _log('✅ Görseller başarıyla yüklendi (Yanıt Kodu: ${response.statusCode}).'); // Log eklendi
    } on DioException catch (e) {
      _log('❌ Görsel yükleme hatası: ${e.response?.data}'); // Log eklendi //
      throw Exception(
          'Görsel yüklenemedi: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  Future<void> uploadDocument({
    required int propertyId,
    required String title,
    required String docType,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    try {
      _log('📄 Belge yükleme isteği gönderiliyor: $title - Mülk ID $propertyId'); // Log eklendi
      late MultipartFile multipartFile;

      if (fileBytes != null) {
        _log('   (Web) Byte verisi kullanılıyor...'); // Log eklendi
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (filePath != null) {
        _log('   (Mobil) Dosya yolu kullanılıyor: $filePath'); // Log eklendi
        multipartFile =
        await MultipartFile.fromFile(filePath, filename: fileName);
      } else {
        _log('❌ Yüklenecek dosya verisi bulunamadı.'); // Log eklendi
        throw Exception(
            'Yüklenecek dosya verisi (path veya bytes) bulunamadı.'); //
      }

      FormData formData = FormData.fromMap({
        'document': multipartFile,
        'title': title,
        'document_type': docType,
      });

      _log('📦 Gönderilecek Form Verisi: title=$title, document_type=$docType, file=$fileName'); // Log eklendi
      final response = await _apiClient.post(
        '${ApiConstants.properties}$propertyId/upload_documents/',
        data: formData,
      );
      _log('✅ Belge başarıyla yüklendi (Yanıt Kodu: ${response.statusCode}).'); // Log eklendi
    } on DioException catch (e) {
      _log('❌ Belge yükleme hatası: ${e.response?.data}'); // Log eklendi
      throw Exception(
          'Belge yüklenemedi: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  Future<PaymentPlanModel> createPaymentPlan(
      int propertyId, Map<String, dynamic> data) async {
    try {
      _log('💰 Ödeme planı oluşturma isteği gönderiliyor: Mülk ID $propertyId'); // Log eklendi
      final response = await _apiClient.post(
        '${ApiConstants.properties}$propertyId/create_payment_plan/',
        data: data, //
      );
      _log('✅ Ödeme planı oluşturuldu (Yanıt Kodu: ${response.statusCode}).'); // Log eklendi
      return PaymentPlanModel.fromJson(response.data['payment_plan']);
    } on DioException catch (e) {
      _log('❌ Ödeme planı oluşturma hatası: ${e.response?.data}'); // Log eklendi
      throw Exception(
          'Ödeme planı oluşturulamadı: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  Future<void> deleteDocument(int documentId) async {
    try {
      _log('🗑️ Belge silme isteği gönderiliyor: ID $documentId'); // Log eklendi
      final response = await _apiClient.delete('/properties/documents/$documentId/');
      _log('✅ Belge silindi (Yanıt Kodu: ${response.statusCode}).'); // Log eklendi
    } on DioException catch (e) {
      _log('❌ Belge silme hatası: ${e.response?.statusCode}'); // Log eklendi
      throw Exception('Belge silinemedi: ${e.message}');
    }
  }

  Future<void> deletePaymentPlan(int planId) async {
    try {
      _log('🗑️ Ödeme planı silme isteği gönderiliyor: ID $planId'); // Log eklendi
      final response = await _apiClient.delete('/properties/payment-plans/$planId/');
      _log('✅ Ödeme planı silindi (Yanıt Kodu: ${response.statusCode}).'); // Log eklendi
    } on DioException catch (e) {
      _log('❌ Ödeme planı silme hatası: ${e.response?.statusCode}'); // Log eklendi
      throw Exception('Ödeme planı silinemedi: ${e.message}');
    }
  }

  Future<void> deleteImage(int imageId) async {
    try {
      _log('🗑️ Görsel silme isteği gönderiliyor: ID $imageId'); // Log eklendi
      final response = await _apiClient.delete('/properties/images/$imageId/');
      _log('✅ Görsel silindi (Yanıt Kodu: ${response.statusCode}).'); // Log eklendi
    } on DioException catch (e) {
      _log('❌ Görsel silme hatası: ${e.response?.statusCode}'); // Log eklendi
      throw Exception('Görsel silinemedi: ${e.message}'); //
    }
  }


  Future<void> deleteProperty(int id) async {
    try {
      _log('🗑️ Gayrimenkul silme isteği gönderiliyor: ID $id'); // Log eklendi
      final response = await _apiClient.delete('${ApiConstants.properties}$id/');
      _log('✅ Gayrimenkul silindi (Yanıt Kodu: ${response.statusCode})'); // Log eklendi
    } on DioException catch (e) {
      _log('❌ Gayrimenkul silme hatası: ${e.response?.statusCode}'); // Log eklendi
      throw Exception('Gayrimenkul silinemedi: ${e.message}');
    }
  }

  Future<PropertyModel> updatePropertyStatus(int id, String status) async {
    try {
      _log('🔄 Gayrimenkul durumu güncelleme isteği gönderiliyor: ID $id -> $status'); // Log eklendi
      final response = await _apiClient.patch(
        '${ApiConstants.properties}$id/',
        data: {'status': status},
      );
      _log('✅ Durum güncellendi (Yanıt Kodu: ${response.statusCode})'); // Log eklendi
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Durum güncelleme hatası: ${e.response?.statusCode}'); // Log eklendi
      throw Exception('Durum güncellenemedi: ${e.message}');
    }
  }

  Future<PropertyModel> updatePropertyPrice(int id, double price) async {
    try {
      _log('💰 Gayrimenkul fiyatı güncelleme isteği gönderiliyor: ID $id -> $price'); // Log eklendi //
      final response = await _apiClient.patch(
        '${ApiConstants.properties}$id/',
        data: {'price': price}, // Use 'price' if that's the field name, adjust if needed
      );
      _log('✅ Fiyat güncellendi (Yanıt Kodu: ${response.statusCode})'); // Log eklendi
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Fiyat güncelleme hatası: ${e.response?.statusCode}'); // Log eklendi
      throw Exception('Fiyat güncellenemedi: ${e.message}');
    }
  }
}
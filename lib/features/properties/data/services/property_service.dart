// lib/features/properties/data/services/property_service.dart
import 'package:dio/dio.dart'; // [cite: 1331]
import 'package:flutter/foundation.dart'; // [cite: 1331]
import 'package:image_picker/image_picker.dart'; // [cite: 1331]
import 'dart:typed_data'; // Bu import gerekli // [cite: 1331]
import 'package:file_picker/file_picker.dart'; // <-- Eklendi [cite: 1331]

import '../../../../config/constants.dart'; // [cite: 1331]
import '../../../../core/network/api_client.dart'; // [cite: 1331]
import '../../../../shared/models/pagination_model.dart'; // [cite: 1331]
import '../models/property_model.dart'; // [cite: 1331]
import '../models/payment_plan_model.dart'; // [cite: 1331]
import '../models/project_model.dart'; // Bu import gerekli // [cite: 1331]

class PropertyService {
  final ApiClient _apiClient; // [cite: 1331]
  PropertyService(this._apiClient); // [cite: 1331]

  Future<ProjectModel> createProject(Map<String, dynamic> data,
      XFile? projectImage, XFile? sitePlanImage) async { // [cite: 1331]
    try {
      debugPrint('🏗️ Yeni proje oluşturuluyor...'); // [cite: 1331]
      final formData = FormData.fromMap(data); // Metin verilerini ekle // [cite: 1331]

      if (projectImage != null) { // [cite: 1331]
        if (kIsWeb) { // [cite: 1331]
          final bytes = await projectImage.readAsBytes(); // [cite: 1331]
          formData.files.add(MapEntry( // [cite: 1331]
            'project_image', // Django modelindeki field adı // [cite: 1331]
            MultipartFile.fromBytes(bytes, filename: projectImage.name), // [cite: 1332]
          ));
        } else { // [cite: 1332]
          formData.files.add(MapEntry( // [cite: 1332]
            'project_image', // [cite: 1332]
            await MultipartFile.fromFile(projectImage.path, // [cite: 1332]
                filename: projectImage.name), // [cite: 1332]
          ));
        }
      }

      if (sitePlanImage != null) { // [cite: 1332]
        if (kIsWeb) { // [cite: 1332]
          final bytes = await sitePlanImage.readAsBytes(); // [cite: 1332]
          formData.files.add(MapEntry( // [cite: 1332]
            'site_plan_image', // Django modelindeki field adı // [cite: 1332]
            MultipartFile.fromBytes(bytes, filename: sitePlanImage.name), // [cite: 1333]
          ));
        } else { // [cite: 1333]
          formData.files.add(MapEntry( // [cite: 1333]
            'site_plan_image', // [cite: 1333]
            await MultipartFile.fromFile(sitePlanImage.path, // [cite: 1333]
                filename: sitePlanImage.name), // [cite: 1333]
          ));
        }
      }

      debugPrint('📦 Gönderilecek Form Verisi (Fields): ${formData.fields}'); // [cite: 1333]
      debugPrint('📦 Gönderilecek Dosyalar: ${formData.files.map((f) => f.key)}'); // [cite: 1333]

      final response = await _apiClient.post( // [cite: 1333]
        ApiConstants.projects, // Proje endpoint'i // [cite: 1333]
        data: formData, // [cite: 1334]
      );

      debugPrint('✅ Proje başarıyla oluşturuldu'); // [cite: 1334]
      return ProjectModel.fromJson(response.data); // [cite: 1334]

    } on DioException catch (e) { // [cite: 1334]
      debugPrint('❌ Proje oluşturma hatası: ${e.response?.statusCode}'); // [cite: 1334]
      debugPrint('📦 Error Response: ${e.response?.data}'); // [cite: 1334]
      String errorMessage = 'Proje oluşturulamadı.'; // [cite: 1334]
      if (e.response?.data is Map) { // [cite: 1334]
        final errors = e.response!.data as Map<String, dynamic>; // [cite: 1334]
        if (errors.isNotEmpty) { // [cite: 1334]
          final firstErrorKey = errors.keys.first; // [cite: 1334]
          final firstErrorValue = errors[firstErrorKey]; // [cite: 1334]
          if (firstErrorValue is List && firstErrorValue.isNotEmpty) { // [cite: 1334]
            errorMessage = '${firstErrorKey}: ${firstErrorValue.first}'; // [cite: 1335]
          } else { // [cite: 1335]
            errorMessage = '${firstErrorKey}: ${firstErrorValue.toString()}'; // [cite: 1335]
          }
        }
      } else if (e.response?.data is String) { // [cite: 1335]
        errorMessage = e.response!.data; // [cite: 1335]
      } else if (e.message != null) { // [cite: 1335]
        errorMessage = e.message!; // [cite: 1335]
      }
      throw Exception(errorMessage); // [cite: 1335]
    } catch (e) { // [cite: 1335]
      debugPrint('❌ Beklenmedik Proje oluşturma hatası: $e'); // [cite: 1335]
      throw Exception('Beklenmedik bir hata oluştu: ${e.toString()}'); // [cite: 1335]
    }
  }

  // --- YENİ METOT: Örnek CSV İndirme ---
  Future<Response> downloadSampleCsv() async {
    try {
      debugPrint('📄 Örnek CSV şablonu indiriliyor...'); // [cite: 1336]
      // GET isteği, backend'den dosya içeriğini (byte) alacak
      final response = await _apiClient.get( // [cite: 1336]
        '${ApiConstants.properties}export-sample-csv/', // [cite: 1336]
        options: Options( // [cite: 1336]
          responseType: ResponseType.bytes, // Dosya içeriğini byte olarak al // [cite: 1336]
        ),
      );
      debugPrint('✅ Örnek CSV şablonu başarıyla alındı.'); // [cite: 1336]
      return response; // [cite: 1336]
    } on DioException catch (e) { // [cite: 1336]
      debugPrint('❌ Örnek CSV indirme hatası: ${e.response?.statusCode}'); // [cite: 1336]
      debugPrint('📦 Error: ${e.response?.data}'); // [cite: 1336]
      throw Exception('Örnek şablon indirilemedi: ${e.message}'); // [cite: 1336]
    }
  }

  // --- YENİ METOT: CSV Dosyası Yükleme ---
  Future<Response> uploadBulkPropertiesCsv(PlatformFile file) async {
    try {
      debugPrint('🔼 Toplu mülk CSV dosyası yükleniyor: ${file.name}'); // [cite: 1337]
      final formData = FormData(); // [cite: 1337]

      if (kIsWeb) { // [cite: 1337]
        // Web: Byte verisini kullan
        formData.files.add(MapEntry( // [cite: 1337]
          'file', // Backend'de beklenen dosya alanı adı // [cite: 1337]
          MultipartFile.fromBytes(file.bytes!, filename: file.name), // [cite: 1337]
        ));
      } else { // [cite: 1337]
        // Mobil: Dosya yolunu kullan
        formData.files.add(MapEntry( // [cite: 1337]
          'file', // Backend'de beklenen dosya alanı adı // [cite: 1337]
          await MultipartFile.fromFile(file.path!, filename: file.name), // [cite: 1337]
        ));
      }

      // API isteğini gönder
      final response = await _apiClient.post( // [cite: 1338]
        '${ApiConstants.properties}bulk-create-from-csv/', // Yeni endpoint // [cite: 1338]
        data: formData, // [cite: 1338]
      );

      debugPrint('✅ Toplu mülk CSV dosyası başarıyla yüklendi ve işlendi.'); // [cite: 1338]
      return response; // Başarılı yanıtı döndür (örn: kaç tane oluşturulduğu bilgisi) // [cite: 1338]

    } on DioException catch (e) { // [cite: 1338]
      debugPrint('❌ Toplu mülk CSV yükleme hatası: ${e.response?.statusCode}'); // [cite: 1338]
      debugPrint('📦 Error Response: ${e.response?.data}'); // [cite: 1338]
      // Hata detayını ayıkla
      String errorMessage = 'Toplu mülk yüklenemedi.'; // [cite: 1338]
      if (e.response?.data is Map) { // [cite: 1338]
        final errors = e.response!.data as Map<String, dynamic>; // [cite: 1338]
        if (errors.containsKey('error')) { // [cite: 1338]
          errorMessage = errors['error'].toString(); // [cite: 1338]
          if (errors.containsKey('details') && errors['details'] is List) { // [cite: 1338]
            // İlk birkaç hatayı mesaja ekleyebiliriz
            errorMessage += '\nDetaylar:\n'; // [cite: 1339]
            final details = (errors['details'] as List).take(3).map((d) { // [cite: 1339]
              if (d is Map) { // [cite: 1339]
                return "Satır ${d['line']}: ${d['errors']}"; // [cite: 1339]
              }
              return d.toString(); // [cite: 1339]
            }).join('\n');
            errorMessage += details; // [cite: 1339]
            if ((errors['details'] as List).length > 3) { // [cite: 1339]
              errorMessage += "\n..."; // [cite: 1339]
            }
          }
        } else { // [cite: 1339]
          errorMessage = errors.toString(); // Genel map hatası // [cite: 1340]
        }
      } else if (e.response?.data is String) { // [cite: 1340]
        errorMessage = e.response!.data; // [cite: 1340]
      } else if (e.message != null) { // [cite: 1340]
        errorMessage = e.message!; // [cite: 1340]
      }
      throw Exception(errorMessage); // [cite: 1340]
    } catch (e) { // [cite: 1340]
      debugPrint('❌ Beklenmedik Toplu mülk CSV yükleme hatası: $e'); // [cite: 1340]
      throw Exception('Beklenmedik bir hata oluştu: ${e.toString()}'); // [cite: 1340]
    }
  }

  // ✅ GÜNCELLEME: Proje listesini API'den doğru şekilde almak için düzeltildi
  Future<List<ProjectModel>> getProjects() async { // [cite: 1340]
    try {
      debugPrint('🏗️ Proje listesi alınıyor...'); // [cite: 1340]
      final response = await _apiClient.get(ApiConstants.projects); // [cite: 1340]

      // Yanıtın Map olup olmadığını ve 'results' anahtarını içerip içermediğini kontrol et
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        // 'results' listesini al
        final List<dynamic> data = response.data['results'] as List<dynamic>? ?? []; // [cite: 1340]
        debugPrint('✅ ${data.length} proje alındı (Sayfalanmış)'); // [cite: 1340]
        return data //
            .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>)) //
            .toList(); //
      } else if (response.data is List) {
        // Eğer yanıt doğrudan liste ise (sayfalama yoksa)
        final List<dynamic> data = response.data as List<dynamic>;
        debugPrint('✅ ${data.length} proje alındı (Sayfasız)');
        return data
            .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Beklenmeyen format
        debugPrint('❌ Proje listesi yanıtı beklenmeyen formatta: ${response.data.runtimeType}');
        throw Exception('Projeler yüklenemedi: Geçersiz yanıt formatı');
      }
    } on DioException catch (e) { //
      debugPrint('❌ Proje listesi hatası: ${e.response?.statusCode}'); //
      throw Exception('Projeler yüklenemedi: ${e.message}'); //
    } catch (e) { // Diğer hatalar için (örn: format hatası)
      debugPrint('❌ Proje listesi işleme hatası: $e');
      throw Exception('Projeler işlenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<void> bulkCreateProperties(
      List<Map<String, dynamic>> properties) async { //
    try {
      debugPrint( //
          '🏘️ ${properties.length} adet mülk toplu olarak oluşturuluyor...'); //
      final data = {'properties': properties}; //
      await _apiClient.post( //
        '${ApiConstants.properties}bulk_create/', //
        data: data, // [cite: 1342]
      ); // [cite: 1342]
      debugPrint('✅ Mülkler başarıyla oluşturuldu.'); // [cite: 1342]
    } on DioException catch (e) { // [cite: 1342]
      debugPrint('❌ Toplu mülk oluşturma hatası: ${e.response?.statusCode}'); // [cite: 1342]
      debugPrint('📦 Error: ${e.response?.data}'); // [cite: 1342]
      throw Exception( // [cite: 1342]
          'Toplu mülk oluşturulamadı: ${e.response?.data ?? e.message}'); // [cite: 1342]
    }
  }

  Future<PaginationModel<PropertyModel>> getProperties({ // [cite: 1342]
    int page = 1, // [cite: 1342]
    int limit = 20, // [cite: 1342]
    String? search, // [cite: 1342]
    String? status, // [cite: 1342]
    String? propertyType, // [cite: 1342]
    int? projectId, // [cite: 1342]
  }) async {
    try {
      debugPrint('🏠 Gayrimenkuller alınıyor...'); // [cite: 1342]
      final queryParams = <String, dynamic>{ // [cite: 1343]
        'page': page, // [cite: 1343]
        'page_size': limit, // [cite: 1343]
      };
      if (search != null && search.isNotEmpty) { // [cite: 1343]
        queryParams['search'] = search; // [cite: 1343]
      }
      if (status != null && status.isNotEmpty) { // [cite: 1343]
        queryParams['status'] = status; // [cite: 1343]
      }
      if (propertyType != null && propertyType.isNotEmpty) { // [cite: 1343]
        queryParams['property_type'] = propertyType; // [cite: 1343]
      }
      if (projectId != null) { // [cite: 1343]
        queryParams['project'] = projectId; // [cite: 1343]
      }

      final response = await _apiClient.get( // [cite: 1344]
        ApiConstants.properties, // [cite: 1344]
        queryParameters: queryParams, // [cite: 1344]
      );
      debugPrint('✅ Gayrimenkuller alındı'); // [cite: 1344]

      return PaginationModel<PropertyModel>.fromJson( // [cite: 1344]
        response.data, // [cite: 1344]
            (json) => PropertyModel.fromJson(json as Map<String, dynamic>), // [cite: 1344]
      );
    } on DioException catch (e) { // [cite: 1344]
      debugPrint('❌ Gayrimenkul listesi hatası: ${e.response?.statusCode}'); // [cite: 1344]
      debugPrint('📦 Error: ${e.response?.data}'); // [cite: 1344]
      throw Exception('Gayrimenkuller yüklenemedi: ${e.message}'); // [cite: 1344]
    }
  }

  Future<PaginationModel<PropertyModel>> getAvailableProperties({ // [cite: 1344]
    int page = 1, // [cite: 1344]
    int limit = 20, // [cite: 1344]
    String? search, // [cite: 1344]
  }) async {
    try {
      debugPrint('🏡 Müsait gayrimenkuller alınıyor...'); // [cite: 1345]
      final queryParams = <String, dynamic>{ // [cite: 1345]
        'page': page, // [cite: 1345]
        'page_size': limit, // [cite: 1345]
      };
      if (search != null && search.isNotEmpty) { // [cite: 1345]
        queryParams['search'] = search; // [cite: 1345]
      }

      final response = await _apiClient.get( // [cite: 1345]
        ApiConstants.availableProperties, // [cite: 1345]
        queryParameters: queryParams, // [cite: 1345]
      );
      debugPrint('✅ Müsait gayrimenkuller alındı'); // [cite: 1345]

      return PaginationModel<PropertyModel>.fromJson( // [cite: 1345]
        response.data, // [cite: 1345]
            (json) => PropertyModel.fromJson(json as Map<String, dynamic>), // [cite: 1345]
      ); // [cite: 1346]
    } on DioException catch (e) { // [cite: 1346]
      debugPrint('❌ Müsait gayrimenkul hatası: ${e.response?.statusCode}'); // [cite: 1346]
      debugPrint('📦 Error: ${e.response?.data}'); // [cite: 1346]
      throw Exception('Satılık gayrimenkuller yüklenemedi: ${e.message}'); // [cite: 1346]
    }
  }

  Future<PropertyModel> getPropertyDetail(int id) async { // [cite: 1346]
    try {
      debugPrint('📋 Gayrimenkul detayı alınıyor: $id'); // [cite: 1346]
      final response = await _apiClient.get('${ApiConstants.properties}$id/'); // [cite: 1346]
      debugPrint('📦 Raw property detail response: ${response.data}'); // [cite: 1346]
      final raw = // [cite: 1346]
      (response.data as Map<String, dynamic>?) ?? <String, dynamic>{}; // [cite: 1346]

      if (raw['project'] == null || raw['project'] is! Map) { // [cite: 1346]
        raw['project'] = {'id': 0, 'name': 'Bilinmeyen Proje'}; // [cite: 1346]
      } else if (raw['project'] is Map && !raw['project'].containsKey('id')) { // [cite: 1347]
        raw['project']['id'] = 0; // [cite: 1347]
        raw['project']['name'] = raw['project']['name'] ?? 'Bilinmeyen Proje'; // [cite: 1347]
      }


      if (raw['images'] is List) { // [cite: 1347]
        final safeImages = <Map<String, dynamic>>[]; // [cite: 1347]
        for (var item in raw['images'] as List) { // [cite: 1347]
          if (item is Map<String, dynamic>) { // [cite: 1347]
            safeImages.add({ // [cite: 1347]
              'id': item['id'] ?? 0, // [cite: 1347]
              'image': item['image'] ?? '', // [cite: 1347]
              'image_type': item['image_type'] ?? 'OTHER', // [cite: 1348]
              'title': item['title'] ?? '', // [cite: 1348]
            });
          }
        }
        raw['images'] = safeImages; // [cite: 1348]
      } else { // [cite: 1348]
        raw['images'] = <Map<String, dynamic>>[]; // [cite: 1348]
      }

      if (raw['documents'] is List) { // [cite: 1348]
        final safeDocs = <Map<String, dynamic>>[]; // [cite: 1348]
        for (var item in raw['documents'] as List) { // [cite: 1348]
          if (item is Map<String, dynamic>) { // [cite: 1348]
            safeDocs.add({ // [cite: 1349]
              'id': item['id'] ?? 0, // [cite: 1349]
              'document': item['document'] ?? '', // [cite: 1349]
              'document_type': item['document_type'] ?? 'DIGER', // [cite: 1349]
              'document_type_display': item['document_type_display'] ?? 'Diğer', // [cite: 1349]
              'title': item['title'] ?? '', // [cite: 1349]
            });
          }
        }
        raw['documents'] = safeDocs; // [cite: 1349]
      } else { // [cite: 1349]
        raw['documents'] = <Map<String, dynamic>>[]; // [cite: 1349]
      }

      if (raw['payment_plans'] is List) { // [cite: 1350]
        final safePlans = <Map<String, dynamic>>[]; // [cite: 1350]
        for (var item in raw['payment_plans'] as List) { // [cite: 1350]
          if (item is Map<String, dynamic>) { // [cite: 1350]
            safePlans.add({ // [cite: 1350]
              'id': item['id'] ?? 0, // [cite: 1350]
              'plan_type': item['plan_type'] ?? 'OTHER', // [cite: 1350]
              'name': item['name'] ?? '', // [cite: 1350]
              'details': item['details'] ?? <String, dynamic>{}, // [cite: 1350]
              'details_display': item['details_display'] ?? '', // [cite: 1351]
              'is_active': item['is_active'] ?? true, // [cite: 1351]
            }); // [cite: 1351]
          }
        }
        raw['payment_plans'] = safePlans; // [cite: 1351]
      } else { // [cite: 1351]
        raw['payment_plans'] = <Map<String, dynamic>>[]; // [cite: 1351]
      }

      debugPrint('✅ Gayrimenkul detayı alındı (sanitized)'); // [cite: 1351]
      return PropertyModel.fromJson(raw); // [cite: 1351]
    } on DioException catch (e) { // [cite: 1351]
      debugPrint('❌ Gayrimenkul detay hatası: ${e.response?.statusCode}'); // [cite: 1351]
      debugPrint('📦 Error: ${e.response?.data}'); // [cite: 1351]
      throw Exception('Gayrimenkul detayı yüklenemedi: ${e.message}'); // [cite: 1352]
    } catch (e, st) { // [cite: 1352]
      debugPrint('❌ Gayrimenkul detay parsing hatası: $e'); // [cite: 1352]
      debugPrint('$st'); // [cite: 1352]
      rethrow; // Re-throw the original error for provider handling // [cite: 1352]
    }
  }

  Future<Map<String, dynamic>> getPropertyStatistics() async { // [cite: 1352]
    try {
      debugPrint('📊 Gayrimenkul istatistikleri alınıyor...'); // [cite: 1352]
      final response = await _apiClient.get(ApiConstants.propertyStatistics); // [cite: 1352]
      debugPrint('✅ İstatistikler alındı'); // [cite: 1352]
      return response.data as Map<String, dynamic>; // [cite: 1352]
    } on DioException catch (e) { // [cite: 1352]
      debugPrint('❌ İstatistik hatası: ${e.response?.statusCode}'); // [cite: 1352]
      throw Exception('İstatistikler yüklenemedi: ${e.message}'); // [cite: 1352]
    }
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async { // [cite: 1353]
    try {
      debugPrint('➕ Gayrimenkul oluşturuluyor...'); // [cite: 1353]
      debugPrint('📦 Data: $data'); // [cite: 1353]
      final response = await _apiClient.post( // [cite: 1353]
        ApiConstants.properties, // [cite: 1353]
        data: data, // [cite: 1353]
      );
      debugPrint('✅ Gayrimenkul oluşturuldu'); // [cite: 1353]
      return PropertyModel.fromJson(response.data); // [cite: 1353]
    } on DioException catch (e) { // [cite: 1353]
      debugPrint('❌ Gayrimenkul oluşturma hatası: ${e.response?.statusCode}'); // [cite: 1353]
      debugPrint('📦 Error: ${e.response?.data}'); // [cite: 1353]
      throw Exception( // [cite: 1353]
          'Gayrimenkul oluşturulamadı: ${e.response?.data ?? e.message}'); // [cite: 1353]
    }
  }

  Future<PropertyModel> updateProperty(int id, Map<String, dynamic> data) async { // [cite: 1353]
    try {
      debugPrint('✏️ Gayrimenkul güncelleniyor: $id'); // [cite: 1354]
      debugPrint('📦 Data: $data'); // [cite: 1354]
      final response = await _apiClient.put( // [cite: 1354]
        '${ApiConstants.properties}$id/', // [cite: 1354]
        data: data, // [cite: 1354]
      );
      debugPrint('✅ Gayrimenkul güncellendi'); // [cite: 1354]
      return PropertyModel.fromJson(response.data); // [cite: 1354]
    } on DioException catch (e) { // [cite: 1354]
      debugPrint('❌ Gayrimenkul güncelleme hatası: ${e.response?.statusCode}'); // [cite: 1354]
      debugPrint('📦 Error: ${e.response?.data}'); // [cite: 1354]
      throw Exception( // [cite: 1354]
          'Gayrimenkul güncellenemedi: ${e.response?.data ?? e.message}'); // [cite: 1354]
    }
  }

  Future<void> uploadImages(int propertyId, List<XFile> imageFiles) async { // [cite: 1354]
    try {
      debugPrint( // [cite: 1354]
          '🖼️ ${imageFiles.length} adet görsel yükleniyor: Property ID $propertyId'); // [cite: 1355]
      final formData = FormData(); // [cite: 1355]
      for (var file in imageFiles) { // [cite: 1355]
        if (kIsWeb) { // [cite: 1355]
          final bytes = await file.readAsBytes(); // [cite: 1355]
          formData.files.add(MapEntry( // [cite: 1355]
            'images', // Use 'images' as key for multiple files // [cite: 1355]
            MultipartFile.fromBytes(bytes, filename: file.name), // [cite: 1355]
          ));
        } else { // [cite: 1355]
          formData.files.add(MapEntry( // [cite: 1355]
            'images', // Use 'images' as key for multiple files // [cite: 1356]
            await MultipartFile.fromFile(file.path, filename: file.name), // [cite: 1356]
          ));
        }
      }

      await _apiClient.post( // [cite: 1356]
        '${ApiConstants.properties}$propertyId/upload_images/', // [cite: 1356]
        data: formData, // [cite: 1356]
      );
      debugPrint('✅ Görseller başarıyla yüklendi.'); // [cite: 1356]
    } on DioException catch (e) { // [cite: 1356]
      debugPrint('❌ Görsel yükleme hatası: ${e.response?.data}'); // [cite: 1356]
      throw Exception( // [cite: 1356]
          'Görsel yüklenemedi: ${e.response?.data['detail'] ?? e.message}'); // [cite: 1356]
    }
  }

  Future<void> uploadDocument({ // [cite: 1356]
    required int propertyId, // [cite: 1356]
    required String title, // [cite: 1356]
    required String docType, // [cite: 1356]
    required String fileName, // [cite: 1357]
    String? filePath, // [cite: 1357]
    Uint8List? fileBytes, // [cite: 1357]
  }) async {
    try {
      debugPrint('📄 Belge yükleniyor: $title'); // [cite: 1357]
      late MultipartFile multipartFile; // [cite: 1357]

      if (fileBytes != null) { // [cite: 1357]
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName); // [cite: 1357]
      } else if (filePath != null) { // [cite: 1357]
        multipartFile = // [cite: 1357]
        await MultipartFile.fromFile(filePath, filename: fileName); // [cite: 1357]
      } else { // [cite: 1357]
        throw Exception( // [cite: 1357]
            'Yüklenecek dosya verisi (path veya bytes) bulunamadı.'); // [cite: 1357]
      }

      FormData formData = FormData.fromMap({ // [cite: 1358]
        'document': multipartFile, // [cite: 1358]
        'title': title, // [cite: 1358]
        'document_type': docType, // [cite: 1358]
      });

      await _apiClient.post( // [cite: 1358]
        '${ApiConstants.properties}$propertyId/upload_documents/', // [cite: 1358]
        data: formData, // [cite: 1358]
      );
      debugPrint('✅ Belge başarıyla yüklendi.'); // [cite: 1358]
    } on DioException catch (e) { // [cite: 1358]
      throw Exception( // [cite: 1358]
          'Belge yüklenemedi: ${e.response?.data['detail'] ?? e.message}'); // [cite: 1358]
    }
  }

  Future<PaymentPlanModel> createPaymentPlan( // [cite: 1358]
      int propertyId, Map<String, dynamic> data) async {
    try {
      debugPrint('💰 Ödeme planı oluşturuluyor...'); // [cite: 1358]
      final response = await _apiClient.post( // [cite: 1359]
        '${ApiConstants.properties}$propertyId/create_payment_plan/', // [cite: 1359]
        data: data, // [cite: 1359]
      );
      debugPrint('✅ Ödeme planı oluşturuldu.'); // [cite: 1359]
      return PaymentPlanModel.fromJson(response.data['payment_plan']); // [cite: 1359]
    } on DioException catch (e) { // [cite: 1359]
      throw Exception( // [cite: 1359]
          'Ödeme planı oluşturulamadı: ${e.response?.data['detail'] ?? e.message}'); // [cite: 1359]
    }
  }

  Future<void> deleteDocument(int documentId) async { // [cite: 1359]
    try {
      await _apiClient.delete('/properties/documents/$documentId/'); // [cite: 1359]
    } on DioException catch (e) { // [cite: 1359]
      throw Exception('Belge silinemedi: ${e.message}'); // [cite: 1359]
    }
  }

  Future<void> deletePaymentPlan(int planId) async { // [cite: 1359]
    try {
      await _apiClient.delete('/properties/payment-plans/$planId/'); // [cite: 1359]
    } on DioException catch (e) { // [cite: 1360]
      throw Exception('Ödeme planı silinemedi: ${e.message}'); // [cite: 1360]
    }
  }

  Future<void> deleteImage(int imageId) async { // [cite: 1360]
    try {
      await _apiClient.delete('/properties/images/$imageId/'); // [cite: 1360]
    } on DioException catch (e) { // [cite: 1360]
      throw Exception('Görsel silinemedi: ${e.message}'); // [cite: 1360]
    }
  }


  Future<void> deleteProperty(int id) async { // [cite: 1360]
    try {
      debugPrint('🗑️ Gayrimenkul siliniyor: $id'); // [cite: 1360]
      await _apiClient.delete('${ApiConstants.properties}$id/'); // [cite: 1360]
      debugPrint('✅ Gayrimenkul silindi'); // [cite: 1360]
    } on DioException catch (e) { // [cite: 1360]
      debugPrint('❌ Gayrimenkul silme hatası: ${e.response?.statusCode}'); // [cite: 1360]
      throw Exception('Gayrimenkul silinemedi: ${e.message}'); // [cite: 1360]
    }
  }

  Future<PropertyModel> updatePropertyStatus(int id, String status) async { // [cite: 1361]
    try {
      debugPrint('🔄 Gayrimenkul durumu güncelleniyor: $id -> $status'); // [cite: 1361]
      final response = await _apiClient.patch( // [cite: 1361]
        '${ApiConstants.properties}$id/', // [cite: 1361]
        data: {'status': status}, // [cite: 1361]
      );
      debugPrint('✅ Durum güncellendi'); // [cite: 1361]
      return PropertyModel.fromJson(response.data); // [cite: 1361]
    } on DioException catch (e) { // [cite: 1361]
      debugPrint('❌ Durum güncelleme hatası: ${e.response?.statusCode}'); // [cite: 1361]
      throw Exception('Durum güncellenemedi: ${e.message}'); // [cite: 1361]
    }
  }

  Future<PropertyModel> updatePropertyPrice(int id, double price) async { // [cite: 1361]
    try { // [cite: 1361]
      debugPrint('💰 Gayrimenkul fiyatı güncelleniyor: $id -> $price'); // [cite: 1361]
      final response = await _apiClient.patch( // [cite: 1361]
        '${ApiConstants.properties}$id/', // [cite: 1362]
        data: {'price': price}, // Use 'price' if that's the field name, adjust if needed // [cite: 1362]
      );
      debugPrint('✅ Fiyat güncellendi'); // [cite: 1362]
      return PropertyModel.fromJson(response.data); // [cite: 1362]
    } on DioException catch (e) { // [cite: 1362]
      debugPrint('❌ Fiyat güncelleme hatası: ${e.response?.statusCode}'); // [cite: 1362]
      throw Exception('Fiyat güncellenemedi: ${e.message}'); // [cite: 1362]
    }
  }
}
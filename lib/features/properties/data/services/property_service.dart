// lib/features/properties/data/services/property_service.dart
import 'package:dio/dio.dart'; //
import 'package:flutter/foundation.dart'; //
import 'package:image_picker/image_picker.dart'; //
import 'dart:typed_data'; // Bu import gerekli //
import 'package:file_picker/file_picker.dart'; // <-- Eklendi

import '../../../../config/constants.dart'; //
import '../../../../core/network/api_client.dart'; //
import '../../../../shared/models/pagination_model.dart'; //
import '../models/property_model.dart'; //
import '../models/payment_plan_model.dart'; //
import '../models/project_model.dart'; // Bu import gerekli //

class PropertyService {
  final ApiClient _apiClient; //
  PropertyService(this._apiClient); //

  Future<ProjectModel> createProject(Map<String, dynamic> data,
      XFile? projectImage, XFile? sitePlanImage) async { //
    try {
      debugPrint('🏗️ Yeni proje oluşturuluyor...'); //
      final formData = FormData.fromMap(data); // Metin verilerini ekle //

      if (projectImage != null) { //
        if (kIsWeb) { //
          final bytes = await projectImage.readAsBytes(); //
          formData.files.add(MapEntry( //
            'project_image', // Django modelindeki field adı //
            MultipartFile.fromBytes(bytes, filename: projectImage.name), //
          ));
        } else { //
          formData.files.add(MapEntry( //
            'project_image', //
            await MultipartFile.fromFile(projectImage.path, //
                filename: projectImage.name), //
          ));
        }
      }

      if (sitePlanImage != null) { //
        if (kIsWeb) { //
          final bytes = await sitePlanImage.readAsBytes(); //
          formData.files.add(MapEntry( //
            'site_plan_image', // Django modelindeki field adı //
            MultipartFile.fromBytes(bytes, filename: sitePlanImage.name), //
          ));
        } else { //
          formData.files.add(MapEntry( //
            'site_plan_image', //
            await MultipartFile.fromFile(sitePlanImage.path, //
                filename: sitePlanImage.name), //
          ));
        }
      }

      debugPrint('📦 Gönderilecek Form Verisi (Fields): ${formData.fields}'); //
      debugPrint('📦 Gönderilecek Dosyalar: ${formData.files.map((f) => f.key)}'); //

      final response = await _apiClient.post( //
        ApiConstants.projects, // Proje endpoint'i //
        data: formData, //
      );

      debugPrint('✅ Proje başarıyla oluşturuldu'); //
      return ProjectModel.fromJson(response.data); //

    } on DioException catch (e) { //
      debugPrint('❌ Proje oluşturma hatası: ${e.response?.statusCode}'); //
      debugPrint('📦 Error Response: ${e.response?.data}'); //
      String errorMessage = 'Proje oluşturulamadı.'; //
      if (e.response?.data is Map) { //
        final errors = e.response!.data as Map<String, dynamic>; //
        if (errors.isNotEmpty) { //
          final firstErrorKey = errors.keys.first; //
          final firstErrorValue = errors[firstErrorKey]; //
          if (firstErrorValue is List && firstErrorValue.isNotEmpty) { //
            errorMessage = '${firstErrorKey}: ${firstErrorValue.first}'; //
          } else { //
            errorMessage = '${firstErrorKey}: ${firstErrorValue.toString()}'; //
          }
        }
      } else if (e.response?.data is String) { //
        errorMessage = e.response!.data; //
      } else if (e.message != null) { //
        errorMessage = e.message!; //
      }
      throw Exception(errorMessage); //
    } catch (e) { //
      debugPrint('❌ Beklenmedik Proje oluşturma hatası: $e'); //
      throw Exception('Beklenmedik bir hata oluştu: ${e.toString()}'); //
    }
  }

  // --- YENİ METOT: Örnek CSV İndirme ---
  Future<Response> downloadSampleCsv() async {
    try {
      debugPrint('📄 Örnek CSV şablonu indiriliyor...');
      // GET isteği, backend'den dosya içeriğini (byte) alacak
      final response = await _apiClient.get(
        '${ApiConstants.properties}export-sample-csv/',
        options: Options(
          responseType: ResponseType.bytes, // Dosya içeriğini byte olarak al
        ),
      );
      debugPrint('✅ Örnek CSV şablonu başarıyla alındı.');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Örnek CSV indirme hatası: ${e.response?.statusCode}');
      debugPrint('📦 Error: ${e.response?.data}');
      throw Exception('Örnek şablon indirilemedi: ${e.message}');
    }
  }

  // --- YENİ METOT: CSV Dosyası Yükleme ---
  Future<Response> uploadBulkPropertiesCsv(PlatformFile file) async {
    try {
      debugPrint('🔼 Toplu mülk CSV dosyası yükleniyor: ${file.name}');
      final formData = FormData();

      if (kIsWeb) {
        // Web: Byte verisini kullan
        formData.files.add(MapEntry(
          'file', // Backend'de beklenen dosya alanı adı
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        ));
      } else {
        // Mobil: Dosya yolunu kullan
        formData.files.add(MapEntry(
          'file', // Backend'de beklenen dosya alanı adı
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      }

      // API isteğini gönder
      final response = await _apiClient.post(
        '${ApiConstants.properties}bulk-create-from-csv/', // Yeni endpoint
        data: formData,
      );

      debugPrint('✅ Toplu mülk CSV dosyası başarıyla yüklendi ve işlendi.');
      return response; // Başarılı yanıtı döndür (örn: kaç tane oluşturulduğu bilgisi)

    } on DioException catch (e) {
      debugPrint('❌ Toplu mülk CSV yükleme hatası: ${e.response?.statusCode}');
      debugPrint('📦 Error Response: ${e.response?.data}');
      // Hata detayını ayıkla
      String errorMessage = 'Toplu mülk yüklenemedi.';
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        if (errors.containsKey('error')) {
          errorMessage = errors['error'].toString();
          if (errors.containsKey('details') && errors['details'] is List) {
            // İlk birkaç hatayı mesaja ekleyebiliriz
            errorMessage += '\nDetaylar:\n';
            final details = (errors['details'] as List).take(3).map((d) {
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
      } else if (e.response?.data is String) {
        errorMessage = e.response!.data;
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ Beklenmedik Toplu mülk CSV yükleme hatası: $e');
      throw Exception('Beklenmedik bir hata oluştu: ${e.toString()}');
    }
  }

  Future<List<ProjectModel>> getProjects() async { //
    try {
      debugPrint('🏗️ Proje listesi alınıyor...'); //
      final response = await _apiClient.get(ApiConstants.projects); //
      final List<dynamic> data = response.data as List<dynamic>? ?? []; //
      debugPrint('✅ ${data.length} proje alındı'); //
      return data //
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>)) //
          .toList(); //
    } on DioException catch (e) { //
      debugPrint('❌ Proje listesi hatası: ${e.response?.statusCode}'); //
      throw Exception('Projeler yüklenemedi: ${e.message}'); //
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
        data: data, //
      ); //
      debugPrint('✅ Mülkler başarıyla oluşturuldu.'); //
    } on DioException catch (e) { //
      debugPrint('❌ Toplu mülk oluşturma hatası: ${e.response?.statusCode}'); //
      debugPrint('📦 Error: ${e.response?.data}'); //
      throw Exception( //
          'Toplu mülk oluşturulamadı: ${e.response?.data ?? e.message}'); //
    }
  }

  Future<PaginationModel<PropertyModel>> getProperties({ //
    int page = 1, //
    int limit = 20, //
    String? search, //
    String? status, //
    String? propertyType, //
    int? projectId, //
  }) async {
    try {
      debugPrint('🏠 Gayrimenkuller alınıyor...'); //
      final queryParams = <String, dynamic>{ //
        'page': page, //
        'page_size': limit, //
      };
      if (search != null && search.isNotEmpty) { //
        queryParams['search'] = search; //
      }
      if (status != null && status.isNotEmpty) { //
        queryParams['status'] = status; //
      }
      if (propertyType != null && propertyType.isNotEmpty) { //
        queryParams['property_type'] = propertyType; //
      }
      if (projectId != null) { //
        queryParams['project'] = projectId; //
      }

      final response = await _apiClient.get( //
        ApiConstants.properties, //
        queryParameters: queryParams, //
      );
      debugPrint('✅ Gayrimenkuller alındı'); //

      return PaginationModel<PropertyModel>.fromJson( //
        response.data, //
            (json) => PropertyModel.fromJson(json as Map<String, dynamic>), //
      );
    } on DioException catch (e) { //
      debugPrint('❌ Gayrimenkul listesi hatası: ${e.response?.statusCode}'); //
      debugPrint('📦 Error: ${e.response?.data}'); //
      throw Exception('Gayrimenkuller yüklenemedi: ${e.message}'); //
    }
  }

  Future<PaginationModel<PropertyModel>> getAvailableProperties({ //
    int page = 1, //
    int limit = 20, //
    String? search, //
  }) async {
    try {
      debugPrint('🏡 Müsait gayrimenkuller alınıyor...'); //
      final queryParams = <String, dynamic>{ //
        'page': page, //
        'page_size': limit, //
      };
      if (search != null && search.isNotEmpty) { //
        queryParams['search'] = search; //
      }

      final response = await _apiClient.get( //
        ApiConstants.availableProperties, //
        queryParameters: queryParams, //
      );
      debugPrint('✅ Müsait gayrimenkuller alındı'); //

      return PaginationModel<PropertyModel>.fromJson( //
        response.data, //
            (json) => PropertyModel.fromJson(json as Map<String, dynamic>), //
      );
    } on DioException catch (e) { //
      debugPrint('❌ Müsait gayrimenkul hatası: ${e.response?.statusCode}'); //
      debugPrint('📦 Error: ${e.response?.data}'); //
      throw Exception('Satılık gayrimenkuller yüklenemedi: ${e.message}'); //
    }
  }

  Future<PropertyModel> getPropertyDetail(int id) async { //
    try {
      debugPrint('📋 Gayrimenkul detayı alınıyor: $id'); //
      final response = await _apiClient.get('${ApiConstants.properties}$id/'); //
      debugPrint('📦 Raw property detail response: ${response.data}'); //
      final raw = //
      (response.data as Map<String, dynamic>?) ?? <String, dynamic>{}; //

      if (raw['project'] == null || raw['project'] is! Map) { //
        raw['project'] = {'id': 0, 'name': 'Bilinmeyen Proje'}; //
      } else if (raw['project'] is Map && !raw['project'].containsKey('id')) { //
        raw['project']['id'] = 0; //
        raw['project']['name'] = raw['project']['name'] ?? 'Bilinmeyen Proje'; //
      }


      if (raw['images'] is List) { //
        final safeImages = <Map<String, dynamic>>[]; //
        for (var item in raw['images'] as List) { //
          if (item is Map<String, dynamic>) { //
            safeImages.add({ //
              'id': item['id'] ?? 0, //
              'image': item['image'] ?? '', //
              'image_type': item['image_type'] ?? 'OTHER', //
              'title': item['title'] ?? '', //
            });
          }
        }
        raw['images'] = safeImages; //
      } else { //
        raw['images'] = <Map<String, dynamic>>[]; //
      }

      if (raw['documents'] is List) { //
        final safeDocs = <Map<String, dynamic>>[]; //
        for (var item in raw['documents'] as List) { //
          if (item is Map<String, dynamic>) { //
            safeDocs.add({ //
              'id': item['id'] ?? 0, //
              'document': item['document'] ?? '', //
              'document_type': item['document_type'] ?? 'DIGER', //
              'document_type_display': item['document_type_display'] ?? 'Diğer', //
              'title': item['title'] ?? '', //
            });
          }
        }
        raw['documents'] = safeDocs; //
      } else { //
        raw['documents'] = <Map<String, dynamic>>[]; //
      }

      if (raw['payment_plans'] is List) { //
        final safePlans = <Map<String, dynamic>>[]; //
        for (var item in raw['payment_plans'] as List) { //
          if (item is Map<String, dynamic>) { //
            safePlans.add({ //
              'id': item['id'] ?? 0, //
              'plan_type': item['plan_type'] ?? 'OTHER', //
              'name': item['name'] ?? '', //
              'details': item['details'] ?? <String, dynamic>{}, //
              'details_display': item['details_display'] ?? '', //
              'is_active': item['is_active'] ?? true, //
            }); //
          }
        }
        raw['payment_plans'] = safePlans; //
      } else { //
        raw['payment_plans'] = <Map<String, dynamic>>[]; //
      }

      debugPrint('✅ Gayrimenkul detayı alındı (sanitized)'); //
      return PropertyModel.fromJson(raw); //
    } on DioException catch (e) { //
      debugPrint('❌ Gayrimenkul detay hatası: ${e.response?.statusCode}'); //
      debugPrint('📦 Error: ${e.response?.data}'); //
      throw Exception('Gayrimenkul detayı yüklenemedi: ${e.message}'); //
    } catch (e, st) { //
      debugPrint('❌ Gayrimenkul detay parsing hatası: $e'); //
      debugPrint('$st'); //
      rethrow; // Re-throw the original error for provider handling //
    }
  }

  Future<Map<String, dynamic>> getPropertyStatistics() async { //
    try {
      debugPrint('📊 Gayrimenkul istatistikleri alınıyor...'); //
      final response = await _apiClient.get(ApiConstants.propertyStatistics); //
      debugPrint('✅ İstatistikler alındı'); //
      return response.data as Map<String, dynamic>; //
    } on DioException catch (e) { //
      debugPrint('❌ İstatistik hatası: ${e.response?.statusCode}'); //
      throw Exception('İstatistikler yüklenemedi: ${e.message}'); //
    }
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async { //
    try {
      debugPrint('➕ Gayrimenkul oluşturuluyor...'); //
      debugPrint('📦 Data: $data'); //
      final response = await _apiClient.post( //
        ApiConstants.properties, //
        data: data, //
      );
      debugPrint('✅ Gayrimenkul oluşturuldu'); //
      return PropertyModel.fromJson(response.data); //
    } on DioException catch (e) { //
      debugPrint('❌ Gayrimenkul oluşturma hatası: ${e.response?.statusCode}'); //
      debugPrint('📦 Error: ${e.response?.data}'); //
      throw Exception( //
          'Gayrimenkul oluşturulamadı: ${e.response?.data ?? e.message}'); //
    }
  }

  Future<PropertyModel> updateProperty(int id, Map<String, dynamic> data) async { //
    try {
      debugPrint('✏️ Gayrimenkul güncelleniyor: $id'); //
      debugPrint('📦 Data: $data'); //
      final response = await _apiClient.put( //
        '${ApiConstants.properties}$id/', //
        data: data, //
      );
      debugPrint('✅ Gayrimenkul güncellendi'); //
      return PropertyModel.fromJson(response.data); //
    } on DioException catch (e) { //
      debugPrint('❌ Gayrimenkul güncelleme hatası: ${e.response?.statusCode}'); //
      debugPrint('📦 Error: ${e.response?.data}'); //
      throw Exception( //
          'Gayrimenkul güncellenemedi: ${e.response?.data ?? e.message}'); //
    }
  }

  Future<void> uploadImages(int propertyId, List<XFile> imageFiles) async { //
    try {
      debugPrint( //
          '🖼️ ${imageFiles.length} adet görsel yükleniyor: Property ID $propertyId'); //
      final formData = FormData(); //
      for (var file in imageFiles) { //
        if (kIsWeb) { //
          final bytes = await file.readAsBytes(); //
          formData.files.add(MapEntry( //
            'images', // Use 'images' as key for multiple files //
            MultipartFile.fromBytes(bytes, filename: file.name), //
          ));
        } else { //
          formData.files.add(MapEntry( //
            'images', // Use 'images' as key for multiple files //
            await MultipartFile.fromFile(file.path, filename: file.name), //
          ));
        }
      }

      await _apiClient.post( //
        '${ApiConstants.properties}$propertyId/upload_images/', //
        data: formData, //
      );
      debugPrint('✅ Görseller başarıyla yüklendi.'); //
    } on DioException catch (e) { //
      debugPrint('❌ Görsel yükleme hatası: ${e.response?.data}'); //
      throw Exception( //
          'Görsel yüklenemedi: ${e.response?.data['detail'] ?? e.message}'); //
    }
  }

  Future<void> uploadDocument({ //
    required int propertyId, //
    required String title, //
    required String docType, //
    required String fileName, //
    String? filePath, //
    Uint8List? fileBytes, //
  }) async {
    try {
      debugPrint('📄 Belge yükleniyor: $title'); //
      late MultipartFile multipartFile; //

      if (fileBytes != null) { //
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName); //
      } else if (filePath != null) { //
        multipartFile = //
        await MultipartFile.fromFile(filePath, filename: fileName); //
      } else { //
        throw Exception( //
            'Yüklenecek dosya verisi (path veya bytes) bulunamadı.'); //
      }

      FormData formData = FormData.fromMap({ //
        'document': multipartFile, //
        'title': title, //
        'document_type': docType, //
      });

      await _apiClient.post( //
        '${ApiConstants.properties}$propertyId/upload_documents/', //
        data: formData, //
      );
      debugPrint('✅ Belge başarıyla yüklendi.'); //
    } on DioException catch (e) { //
      throw Exception( //
          'Belge yüklenemedi: ${e.response?.data['detail'] ?? e.message}'); //
    }
  }

  Future<PaymentPlanModel> createPaymentPlan( //
      int propertyId, Map<String, dynamic> data) async {
    try {
      debugPrint('💰 Ödeme planı oluşturuluyor...'); //
      final response = await _apiClient.post( //
        '${ApiConstants.properties}$propertyId/create_payment_plan/', //
        data: data, //
      );
      debugPrint('✅ Ödeme planı oluşturuldu.'); //
      return PaymentPlanModel.fromJson(response.data['payment_plan']); //
    } on DioException catch (e) { //
      throw Exception( //
          'Ödeme planı oluşturulamadı: ${e.response?.data['detail'] ?? e.message}'); //
    }
  }

  Future<void> deleteDocument(int documentId) async { //
    try {
      await _apiClient.delete('/properties/documents/$documentId/'); //
    } on DioException catch (e) { //
      throw Exception('Belge silinemedi: ${e.message}'); //
    }
  }

  Future<void> deletePaymentPlan(int planId) async { //
    try {
      await _apiClient.delete('/properties/payment-plans/$planId/'); //
    } on DioException catch (e) { //
      throw Exception('Ödeme planı silinemedi: ${e.message}'); //
    }
  }

  Future<void> deleteImage(int imageId) async { //
    try {
      await _apiClient.delete('/properties/images/$imageId/'); //
    } on DioException catch (e) { //
      throw Exception('Görsel silinemedi: ${e.message}'); //
    }
  }


  Future<void> deleteProperty(int id) async { //
    try {
      debugPrint('🗑️ Gayrimenkul siliniyor: $id'); //
      await _apiClient.delete('${ApiConstants.properties}$id/'); //
      debugPrint('✅ Gayrimenkul silindi'); //
    } on DioException catch (e) { //
      debugPrint('❌ Gayrimenkul silme hatası: ${e.response?.statusCode}'); //
      throw Exception('Gayrimenkul silinemedi: ${e.message}'); //
    }
  }

  Future<PropertyModel> updatePropertyStatus(int id, String status) async { //
    try {
      debugPrint('🔄 Gayrimenkul durumu güncelleniyor: $id -> $status'); //
      final response = await _apiClient.patch( //
        '${ApiConstants.properties}$id/', //
        data: {'status': status}, //
      );
      debugPrint('✅ Durum güncellendi'); //
      return PropertyModel.fromJson(response.data); //
    } on DioException catch (e) { //
      debugPrint('❌ Durum güncelleme hatası: ${e.response?.statusCode}'); //
      throw Exception('Durum güncellenemedi: ${e.message}'); //
    }
  }

  Future<PropertyModel> updatePropertyPrice(int id, double price) async { //
    try { //
      debugPrint('💰 Gayrimenkul fiyatı güncelleniyor: $id -> $price'); //
      final response = await _apiClient.patch( //
        '${ApiConstants.properties}$id/', //
        data: {'price': price}, // Use 'price' if that's the field name, adjust if needed //
      );
      debugPrint('✅ Fiyat güncellendi'); //
      return PropertyModel.fromJson(response.data); //
    } on DioException catch (e) { //
      debugPrint('❌ Fiyat güncelleme hatası: ${e.response?.statusCode}'); //
      throw Exception('Fiyat güncellenemedi: ${e.message}'); //
    }
  }
}
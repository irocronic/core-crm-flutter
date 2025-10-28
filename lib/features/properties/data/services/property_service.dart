// lib/features/properties/data/services/property_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../models/selected_image.dart';
import '../../../../config/constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/pagination_model.dart';
import '../models/property_model.dart';
import '../models/payment_plan_model.dart';
import '../models/project_model.dart';

class PropertyService {
  final ApiClient _apiClient;
  PropertyService(this._apiClient);

  void _log(String message) {
    debugPrint('[PropertyService] $message');
  }

  Future<ProjectModel> createProject(Map<String, dynamic> data,
      XFile? projectImage, XFile? sitePlanImage) async {
    try {
      _log('🏗️ Yeni proje oluşturma isteği gönderiliyor...');
      final formData = FormData.fromMap(data);

      if (projectImage != null) {
        _log('🖼️ Proje görseli ekleniyor: ${projectImage.name}');
        if (kIsWeb) {
          final bytes = await projectImage.readAsBytes();
          formData.files.add(MapEntry(
            'project_image',
            MultipartFile.fromBytes(bytes, filename: projectImage.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'project_image',
            await MultipartFile.fromFile(projectImage.path,
                filename: projectImage.name),
          ));
        }
      }

      if (sitePlanImage != null) {
        _log('🗺️ Vaziyet planı görseli ekleniyor: ${sitePlanImage.name}');
        if (kIsWeb) {
          final bytes = await sitePlanImage.readAsBytes();
          formData.files.add(MapEntry(
            'site_plan_image',
            MultipartFile.fromBytes(bytes, filename: sitePlanImage.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'site_plan_image',
            await MultipartFile.fromFile(sitePlanImage.path,
                filename: sitePlanImage.name),
          ));
        }
      }

      _log('📦 Gönderilecek Form Verisi (Fields): ${formData.fields}');
      _log('📦 Gönderilecek Dosyalar: ${formData.files.map((f) => f.key)}');

      final response = await _apiClient.post(
        ApiConstants.projects,
        data: formData,
      );

      _log('✅ Proje başarıyla oluşturuldu (Yanıt Kodu: ${response.statusCode})');
      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Proje oluşturma hatası: ${e.response?.statusCode}');
      _log('📦 Error Response: ${e.response?.data}');
      String errorMessage = 'Proje oluşturulamadı.';
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          final firstErrorValue = errors[firstErrorKey];
          if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
            errorMessage = '${firstErrorKey}: ${firstErrorValue.first}';
          } else {
            errorMessage = '${firstErrorKey}: ${firstErrorValue.toString()}';
          }
        }
      } else if (e.response?.data is String) {
        errorMessage = e.response!.data;
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    } catch (e) {
      _log('❌ Beklenmedik Proje oluşturma hatası: $e');
      throw Exception('Beklenmedik bir hata oluştu: ${e.toString()}');
    }
  }

  Future<Response> downloadSampleCsv() async {
    try {
      _log('📄 Örnek CSV şablonu indirme isteği gönderiliyor...');
      final response = await _apiClient.get(
        '${ApiConstants.properties}export-sample-csv/',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      _log('✅ Örnek CSV şablonu başarıyla alındı (Yanıt Kodu: ${response.statusCode}).');
      return response;
    } on DioException catch (e) {
      _log('❌ Örnek CSV indirme hatası: ${e.response?.statusCode}');
      _log('📦 Error: ${e.response?.data}');
      throw Exception('Örnek şablon indirilemedi: ${e.message}');
    }
  }

  Future<Response> uploadBulkPropertiesCsv(PlatformFile file) async {
    try {
      _log('🔼 Toplu mülk CSV dosyası yükleme isteği gönderiliyor: ${file.name}');
      final formData = FormData();

      if (kIsWeb) {
        _log('   (Web) Byte verisi kullanılıyor...');
        formData.files.add(MapEntry(
          'file',
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        ));
      } else {
        _log('   (Mobil) Dosya yolu kullanılıyor: ${file.path}');
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      }

      final response = await _apiClient.post(
        '${ApiConstants.properties}bulk-create-from-csv/',
        data: formData,
      );

      _log('✅ Toplu mülk CSV dosyası başarıyla yüklendi ve işlendi (Yanıt Kodu: ${response.statusCode}).');
      return response;
    } on DioException catch (e) {
      _log('❌ Toplu mülk CSV yükleme hatası: ${e.response?.statusCode}');
      _log('📦 Error Response: ${e.response?.data}');
      String errorMessage = 'Toplu mülk yüklenemedi.';
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        if (errors.containsKey('error')) {
          errorMessage = errors['error'].toString();
          if (errors.containsKey('details') && errors['details'] is List) {
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
          errorMessage = errors.toString();
        }
      } else if (e.response?.data is String) {
        errorMessage = e.response!.data;
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    } catch (e) {
      _log('❌ Beklenmedik Toplu mülk CSV yükleme hatası: $e');
      throw Exception('Beklenmedik bir hata oluştu: ${e.toString()}');
    }
  }

  Future<List<ProjectModel>> getProjects() async {
    try {
      _log('🏗️ Proje listesi isteği gönderiliyor...');
      final response = await _apiClient.get(ApiConstants.projects);
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        final List<dynamic> data = response.data['results'] as List<dynamic>? ?? [];
        _log('✅ ${data.length} proje alındı (Sayfalanmış)');
        return data
            .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        _log('✅ ${data.length} proje alındı (Sayfasız)');
        return data
            .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _log('❌ Proje listesi yanıtı beklenmeyen formatta: ${response.data.runtimeType}');
        throw Exception('Projeler yüklenemedi: Geçersiz yanıt formatı');
      }
    } on DioException catch (e) {
      _log('❌ Proje listesi hatası: ${e.response?.statusCode}');
      throw Exception('Projeler yüklenemedi: ${e.message}');
    } catch (e) {
      _log('❌ Proje listesi işleme hatası: $e');
      throw Exception('Projeler işlenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<void> bulkCreateProperties(
      List<Map<String, dynamic>> properties) async {
    try {
      _log('🏘️ ${properties.length} adet mülk toplu olarak oluşturma isteği gönderiliyor...');
      final data = {'properties': properties};
      await _apiClient.post(
        '${ApiConstants.properties}bulk_create/',
        data: data,
      );
      _log('✅ Mülkler başarıyla oluşturuldu.');
    } on DioException catch (e) {
      _log('❌ Toplu mülk oluşturma hatası: ${e.response?.statusCode}');
      _log('📦 Error: ${e.response?.data}');
      throw Exception(
          'Toplu mülk oluşturulamadı: ${e.response?.data ?? e.message}');
    }
  }

  Future<PaginationModel<PropertyModel>> getProperties({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    int? projectId,
    String? propertyType,
    String? roomCount,
    String? facade,
    double? minArea,
    double? maxArea,
  }) async {
    try {
      _log('🏠 Gayrimenkuller isteği gönderiliyor (Sayfa: $page)...');
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': limit,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (projectId != null) queryParams['project'] = projectId;
      if (propertyType != null && propertyType.isNotEmpty) queryParams['property_type'] = propertyType;
      if (roomCount != null && roomCount.isNotEmpty) queryParams['room_count'] = roomCount;
      if (facade != null && facade.isNotEmpty) queryParams['facade'] = facade;
      if (minArea != null) queryParams['min_area'] = minArea;
      if (maxArea != null) queryParams['max_area'] = maxArea;

      _log('🔍 API Query Params: $queryParams');

      final response = await _apiClient.get(
        ApiConstants.properties,
        queryParameters: queryParams,
      );
      _log('✅ Gayrimenkuller alındı (Yanıt Kodu: ${response.statusCode})');

      return PaginationModel<PropertyModel>.fromJson(
        response.data,
            (json) => PropertyModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _log('❌ Gayrimenkul listesi hatası: ${e.response?.statusCode}');
      _log('📦 Error: ${e.response?.data}');
      throw Exception('Gayrimenkuller yüklenemedi: ${e.message}');
    }
  }

  Future<PaginationModel<PropertyModel>> getAvailableProperties({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      _log('🏡 Müsait gayrimenkuller isteği gönderiliyor (Sayfa: $page)...');
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': limit,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        ApiConstants.availableProperties,
        queryParameters: queryParams,
      );
      _log('✅ Müsait gayrimenkuller alındı (Yanıt Kodu: ${response.statusCode})');

      return PaginationModel<PropertyModel>.fromJson(
        response.data,
            (json) => PropertyModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _log('❌ Müsait gayrimenkul hatası: ${e.response?.statusCode}');
      _log('📦 Error: ${e.response?.data}');
      throw Exception('Satılık gayrimenkuller yüklenemedi: ${e.message}');
    }
  }

  Future<PropertyModel> getPropertyDetail(int id) async {
    try {
      _log('📋 Gayrimenkul detayı isteği gönderiliyor: ID $id');
      final response = await _apiClient.get('${ApiConstants.properties}$id/');
      _log('📦 Raw property detail response: ${response.data}');
      final raw =
          (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};

      _log('🧹 Yanıt verisi temizleniyor...');
      if (raw['project'] == null || raw['project'] is! Map) {
        _log('   ⚠️ Proje bilgisi eksik veya geçersiz, varsayılan kullanılıyor.');
        raw['project'] = {'id': 0, 'name': 'Bilinmeyen Proje'};
      } else if (raw['project'] is Map && !raw['project'].containsKey('id')) {
        _log('   ⚠️ Proje ID eksik, varsayılan (0) kullanılıyor.');
        raw['project']['id'] = 0;
        raw['project']['name'] = raw['project']['name'] ?? 'Bilinmeyen Proje';
      }
      if (raw['images'] is List) {
        final safeImages = <Map<String, dynamic>>[];
        for (var item in raw['images'] as List) {
          if (item is Map<String, dynamic>) {
            safeImages.add({
              'id': item['id'] ?? 0,
              'image': item['image'] ?? '',
              'image_type': item['image_type'] ?? 'OTHER',
              'title': item['title'] ?? '',
            });
          } else { _log('   ⚠️ Geçersiz görsel verisi atlandı: $item'); }
        }
        raw['images'] = safeImages;
      } else {
        _log('   ⚠️ Görsel listesi bulunamadı veya geçersiz, boş liste kullanılıyor.');
        raw['images'] = <Map<String, dynamic>>[];
      }
      if (raw['documents'] is List) {
        final safeDocs = <Map<String, dynamic>>[];
        for (var item in raw['documents'] as List) {
          if (item is Map<String, dynamic>) {
            safeDocs.add({
              'id': item['id'] ?? 0,
              'document': item['document'] ?? '',
              'document_type': item['document_type'] ?? 'DIGER',
              'document_type_display': item['document_type_display'] ?? 'Diğer',
              'title': item['title'] ?? '',
            });
          } else { _log('   ⚠️ Geçersiz belge verisi atlandı: $item'); }
        }
        raw['documents'] = safeDocs;
      } else {
        _log('   ⚠️ Belge listesi bulunamadı veya geçersiz, boş liste kullanılıyor.');
        raw['documents'] = <Map<String, dynamic>>[];
      }
      if (raw['payment_plans'] is List) {
        final safePlans = <Map<String, dynamic>>[];
        for (var item in raw['payment_plans'] as List) {
          if (item is Map<String, dynamic>) {
            safePlans.add({
              'id': item['id'] ?? 0,
              'plan_type': item['plan_type'] ?? 'OTHER',
              'name': item['name'] ?? '',
              'details': item['details'] ?? <String, dynamic>{},
              'details_display': item['details_display'] ?? '',
              'is_active': item['is_active'] ?? true,
            });
          } else { _log('   ⚠️ Geçersiz ödeme planı verisi atlandı: $item'); }
        }
        raw['payment_plans'] = safePlans;
      } else {
        _log('   ⚠️ Ödeme planı listesi bulunamadı veya geçersiz, boş liste kullanılıyor.');
        raw['payment_plans'] = <Map<String, dynamic>>[];
      }

      _log('✅ Gayrimenkul detayı alındı ve temizlendi (Yanıt Kodu: ${response.statusCode})');
      return PropertyModel.fromJson(raw);
    } on DioException catch (e) {
      _log('❌ Gayrimenkul detay hatası: ${e.response?.statusCode}');
      _log('📦 Error: ${e.response?.data}');
      throw Exception('Gayrimenkul detayı yüklenemedi: ${e.message}');
    } catch (e, st) {
      _log('❌ Gayrimenkul detay parsing hatası: $e');
      _log('$st');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPropertyStatistics() async {
    try {
      _log('📊 Gayrimenkul istatistikleri isteği gönderiliyor...');
      final response = await _apiClient.get(ApiConstants.propertyStatistics);
      _log('✅ İstatistikler alındı (Yanıt Kodu: ${response.statusCode})');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _log('❌ İstatistik hatası: ${e.response?.statusCode}');
      throw Exception('İstatistikler yüklenemedi: ${e.message}');
    }
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    try {
      _log('➕ Yeni gayrimenkul oluşturma isteği gönderiliyor...');
      _log('📦 Data: $data');
      final response = await _apiClient.post(
        ApiConstants.properties,
        data: data,
      );
      _log('✅ Gayrimenkul oluşturuldu (Yanıt Kodu: ${response.statusCode})');
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Gayrimenkul oluşturma hatası: ${e.response?.statusCode}');
      _log('📦 Error: ${e.response?.data}');
      throw Exception(
          'Gayrimenkul oluşturulamadı: ${e.response?.data ?? e.message}');
    }
  }

  Future<PropertyModel> updateProperty(int id, Map<String, dynamic> data) async {
    try {
      _log('✏️ Gayrimenkul güncelleme isteği gönderiliyor: ID $id');
      _log('📦 Data: $data');
      final response = await _apiClient.put(
        '${ApiConstants.properties}$id/',
        data: data,
      );
      _log('✅ Gayrimenkul güncellendi (Yanıt Kodu: ${response.statusCode})');
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Gayrimenkul güncelleme hatası: ${e.response?.statusCode}');
      _log('📦 Error: ${e.response?.data}');
      throw Exception(
          'Gayrimenkul güncellenemedi: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> uploadImages(int propertyId, List<SelectedImage> selectedImages) async {
    try {
      _log('🖼️ ${selectedImages.length} görsel yükleme isteği gönderiliyor: Mülk ID $propertyId');
      final formData = FormData();
      List<String> imageTypes = [];

      for (var selectedImage in selectedImages) {
        final file = selectedImage.file;
        imageTypes.add(selectedImage.type);

        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          formData.files.add(MapEntry(
            'images',
            MultipartFile.fromBytes(bytes, filename: file.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ));
        }
      }

      for (int i = 0; i < imageTypes.length; i++) {
        formData.fields.add(MapEntry('image_types[]', imageTypes[i]));
      }
      _log('📦 Gönderilecek Form Verisi: fields=${formData.fields}, files=${formData.files.length}');

      final response = await _apiClient.post(
        '${ApiConstants.properties}$propertyId/upload_images/',
        data: formData,
      );
      _log('✅ Görseller başarıyla yüklendi (Yanıt Kodu: ${response.statusCode}).');
    } on DioException catch (e) {
      _log('❌ Görsel yükleme hatası: ${e.response?.data}');
      String detail = e.message ?? 'Bilinmeyen Dio hatası';
      if (e.response?.data is Map && e.response!.data.containsKey('detail')) {
        detail = e.response!.data['detail'];
      } else if (e.response?.data is String) {
        detail = e.response!.data;
      }
      throw Exception('Görsel yüklenemedi: $detail');
    } catch (e) {
      _log('❌ Beklenmedik görsel yükleme hatası: $e');
      throw Exception('Görsel yüklenirken beklenmedik bir hata oluştu: $e');
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
      _log('📄 Belge yükleme isteği gönderiliyor: $title - Mülk ID $propertyId');
      late MultipartFile multipartFile;

      if (fileBytes != null) {
        _log('   (Web) Byte verisi kullanılıyor...');
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (filePath != null) {
        _log('   (Mobil) Dosya yolu kullanılıyor: $filePath');
        multipartFile =
        await MultipartFile.fromFile(filePath, filename: fileName);
      } else {
        _log('❌ Yüklenecek dosya verisi bulunamadı.');
        throw Exception(
            'Yüklenecek dosya verisi (path veya bytes) bulunamadı.');
      }

      FormData formData = FormData.fromMap({
        'document': multipartFile,
        'title': title,
        'document_type': docType,
      });

      _log('📦 Gönderilecek Form Verisi: title=$title, document_type=$docType, file=$fileName');
      final response = await _apiClient.post(
        '${ApiConstants.properties}$propertyId/upload_documents/',
        data: formData,
      );
      _log('✅ Belge başarıyla yüklendi (Yanıt Kodu: ${response.statusCode}).');
    } on DioException catch (e) {
      _log('❌ Belge yükleme hatası: ${e.response?.data}');
      throw Exception(
          'Belge yüklenemedi: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  Future<PaymentPlanModel> createPaymentPlan(
      int propertyId, Map<String, dynamic> data) async {
    try {
      _log('💰 Ödeme planı oluşturma isteği gönderiliyor: Mülk ID $propertyId');
      final response = await _apiClient.post(
        '${ApiConstants.properties}$propertyId/create_payment_plan/',
        data: data,
      );
      _log('✅ Ödeme planı oluşturuldu (Yanıt Kodu: ${response.statusCode}).');
      return PaymentPlanModel.fromJson(response.data['payment_plan']);
    } on DioException catch (e) {
      _log('❌ Ödeme planı oluşturma hatası: ${e.response?.data}');
      throw Exception(
          'Ödeme planı oluşturulamadı: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  Future<void> deleteDocument(int documentId) async {
    try {
      _log('🗑️ Belge silme isteği gönderiliyor: ID $documentId');
      final response = await _apiClient.delete('/properties/documents/$documentId/');
      _log('✅ Belge silindi (Yanıt Kodu: ${response.statusCode}).');
    } on DioException catch (e) {
      _log('❌ Belge silme hatası: ${e.response?.statusCode}');
      throw Exception('Belge silinemedi: ${e.message}');
    }
  }

  Future<void> deletePaymentPlan(int planId) async {
    try {
      _log('🗑️ Ödeme planı silme isteği gönderiliyor: ID $planId');
      final response = await _apiClient.delete('/properties/payment-plans/$planId/');
      _log('✅ Ödeme planı silindi (Yanıt Kodu: ${response.statusCode}).');
    } on DioException catch (e) {
      _log('❌ Ödeme planı silme hatası: ${e.response?.statusCode}');
      throw Exception('Ödeme planı silinemedi: ${e.message}');
    }
  }

  Future<void> deleteImage(int imageId) async {
    try {
      _log('🗑️ Görsel silme isteği gönderiliyor: ID $imageId');
      final response = await _apiClient.delete('/properties/images/$imageId/');
      _log('✅ Görsel silindi (Yanıt Kodu: ${response.statusCode}).');
    } on DioException catch (e) {
      _log('❌ Görsel silme hatası: ${e.response?.statusCode}');
      throw Exception('Görsel silinemedi: ${e.message}');
    }
  }

  Future<void> deleteProperty(int id) async {
    try {
      _log('🗑️ Gayrimenkul silme isteği gönderiliyor: ID $id');
      final response = await _apiClient.delete('${ApiConstants.properties}$id/');
      _log('✅ Gayrimenkul silindi (Yanıt Kodu: ${response.statusCode})');
    } on DioException catch (e) {
      _log('❌ Gayrimenkul silme hatası: ${e.response?.statusCode}');
      throw Exception('Gayrimenkul silinemedi: ${e.message}');
    }
  }

  Future<PropertyModel> updatePropertyStatus(int id, String status) async {
    try {
      _log('🔄 Gayrimenkul durumu güncelleme isteği gönderiliyor: ID $id -> $status');
      final response = await _apiClient.patch(
        '${ApiConstants.properties}$id/',
        data: {'status': status},
      );
      _log('✅ Durum güncellendi (Yanıt Kodu: ${response.statusCode})');
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Durum güncelleme hatası: ${e.response?.statusCode}');
      throw Exception('Durum güncellenemedi: ${e.message}');
    }
  }

  Future<PropertyModel> updatePropertyPrice(int id, double price) async {
    try {
      _log('💰 Gayrimenkul fiyatı güncelleme isteği gönderiliyor: ID $id -> $price');
      final response = await _apiClient.patch(
        '${ApiConstants.properties}$id/',
        data: {'price': price},
      );
      _log('✅ Fiyat güncellendi (Yanıt Kodu: ${response.statusCode})');
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      _log('❌ Fiyat güncelleme hatası: ${e.response?.statusCode}');
      throw Exception('Fiyat güncellenemedi: ${e.message}');
    }
  }
}
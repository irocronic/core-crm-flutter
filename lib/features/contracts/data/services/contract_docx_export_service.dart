// lib/features/contracts/data/services/contract_docx_export_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'dart:html' as html show Blob, Url, AnchorElement;
import '../../data/models/contract_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/constants.dart';

/// Contract DOCX Export Service
/// XML namespace'leri koruyarak DOCX oluşturur
class ContractDocxExportService {
  final ApiClient? _apiClient;

  ContractDocxExportService([this._apiClient]);

  /// Sözleşmeyi DOCX olarak export eder
  Future<String> exportContract(ContractModel contract) async {
    try {
      debugPrint('📄 [DOCX Export] Başlatılıyor - Sözleşme: ${contract.contractNumber}');
      debugPrint('🖥️ [Platform] ${kIsWeb ? "WEB" : Platform.operatingSystem}');

      // 🔥 Eğer reservation_details veya sale_details yoksa API'den çek
      ContractModel enrichedContract = contract;

      if (contract.reservationId != null && contract.reservationDetails == null) {
        debugPrint('🔄 [DOCX Export] Rezervasyon detayları eksik, API\'den çekiliyor...');
        enrichedContract = await _fetchFullContractData(contract.id);
      } else if (contract.saleId != null && contract.saleDetails == null) {
        debugPrint('🔄 [DOCX Export] Satış detayları eksik, API\'den çekiliyor...');
        enrichedContract = await _fetchFullContractData(contract.id);
      }

      // 1. Template dosyasını yükle
      final byteData = await rootBundle.load('assets/templates/contract_template.docx');
      final templateBytes = byteData.buffer.asUint8List();
      debugPrint('✅ [DOCX Export] Template yüklendi (${templateBytes.length} bytes)');

      // 2. Archive olarak decode et
      final archive = ZipDecoder().decodeBytes(templateBytes);
      debugPrint('🗜️ [DOCX Export] Archive decoded: ${archive.files.length} files');

      // 3. Sözleşme verilerini hazırla
      final replacements = _prepareReplacements(enrichedContract);
      debugPrint('✅ [DOCX Export] ${replacements.length} replacement hazırlandı');

      // 4. 🔥 Namespace-aware replacement
      final modifiedArchive = _replaceInArchivePreserveNamespaces(archive, replacements);
      debugPrint('✅ [DOCX Export] Archive modified (namespaces preserved)');

      // 5. Archive'i encode et
      final docxBytes = ZipEncoder().encode(modifiedArchive);
      if (docxBytes == null) {
        throw Exception('DOCX encoding başarısız');
      }
      debugPrint('✅ [DOCX Export] DOCX created (${docxBytes.length} bytes)');

      final uint8ListBytes = Uint8List.fromList(docxBytes);

      // 6. Platform'a göre dosyayı kaydet
      if (kIsWeb) {
        return await _saveFileWeb(uint8ListBytes, enrichedContract);
      } else {
        return await _saveFile(uint8ListBytes, enrichedContract);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [DOCX Export] Error: $e');
      debugPrint('📄 [DOCX Export] Stack Trace: $stackTrace');
      throw Exception('DOCX export hatası: $e');
    }
  }

  /// 🔥 API'den tam contract datasını çeker
  Future<ContractModel> _fetchFullContractData(int contractId) async {
    if (_apiClient == null) {
      debugPrint('⚠️ [DOCX Export] ApiClient yok, mevcut veriyle devam ediliyor');
      throw Exception('ApiClient bulunamadı, detaylı veri çekilemiyor');
    }

    try {
      final response = await _apiClient!.get('${ApiConstants.contracts}$contractId/');
      final fullContract = ContractModel.fromJson(response.data);

      debugPrint('✅ [DOCX Export] Full contract data çekildi');
      debugPrint('📦 [Contract Details] reservation_details: ${fullContract.reservationDetails != null}');
      debugPrint('📦 [Contract Details] sale_details: ${fullContract.saleDetails != null}');
      // **** DÜZELTİLMİŞ KONTROL: sellerCompanyInfo ****
      debugPrint('📦 [Contract Details] seller_company_info: ${fullContract.reservationDetails?.sellerCompanyInfo != null}');

      return fullContract;
    } catch (e) {
      debugPrint('❌ [DOCX Export] Full contract data çekilemedi: $e');
      rethrow;
    }
  }

  /// Placeholder değerlerini hazırlar - EKSİKSİZ VERSİYON
  /// ✅ GÜNCELLENDİ: net_area ve project_name eklendi
  Map<String, String> _prepareReplacements(ContractModel contract) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    final replacements = <String, String>{};

    // ============================================================
    // 🔥 TEMEL SÖZLEŞME BİLGİLERİ
    // ============================================================
    replacements['contract_number'] = contract.contractNumber;
    replacements['contract_type'] = contract.contractType.displayName;
    replacements['contract_date'] = dateFormat.format(contract.contractDate);
    replacements['status'] = contract.status.displayName;
    replacements['status_icon'] = _getStatusIcon(contract.status);
    replacements['created_by'] = contract.createdByName ?? 'Bilinmiyor';
    replacements['created_at'] = dateFormat.format(contract.createdAt);
    replacements['updated_at'] = dateFormat.format(contract.updatedAt);
    replacements['notes'] = contract.notes ?? 'Not eklenmemiş';

    replacements['signed_date'] = contract.signedDate != null
        ? dateFormat.format(contract.signedDate!)
        : 'Henüz imzalanmadı';
    replacements['cancelled_date'] = contract.cancelledDate != null
        ? dateFormat.format(contract.cancelledDate!)
        : '-';
    replacements['cancellation_reason'] = contract.cancellationReason ?? '-';

    // ============================================================
    // 🔥 REZERVASYON DETAYLARI
    // ============================================================
    if (contract.reservationDetails != null) {
      final reservation = contract.reservationDetails!;

      debugPrint('✅ [Replacements] Rezervasyon detayları bulundu');

      // Temel rezervasyon bilgileri
      replacements['reservation_number'] = reservation.reservationNumber;
      replacements['reservation_id'] = reservation.id.toString();
      replacements['reservation_date'] = dateFormat.format(reservation.reservationDate);
      replacements['reservation_amount'] = currencyFormat.format(reservation.depositAmount);
      replacements['reservation_amount_number'] = reservation.depositAmount.toString();

      // Müşteri Bilgileri
      replacements['customer_id'] = reservation.customer.id.toString();
      replacements['customer_name'] = reservation.customer.fullName;
      replacements['customer_phone'] = reservation.customer.phoneNumber ?? '-';
      replacements['customer_email'] = reservation.customer.email ?? '-';

      debugPrint('👤 [Customer] ${reservation.customer.fullName}');

      // Mülk Bilgileri
      replacements['property_id'] = reservation.property.id.toString();
      replacements['property_title'] = reservation.property.title;
      replacements['property_type'] = reservation.property.propertyType;
      replacements['block_number'] = reservation.property.block;
      replacements['floor_number'] = reservation.property.floor.toString();
      replacements['apartment_number'] = reservation.property.unitNumber;

      // 🔥 Oda sayısı
      replacements['room_count'] = reservation.property.roomCount;

      // ✅ GÜNCELLENDİ: Net alan (API'den geliyor)
      replacements['net_area'] = reservation.property.netArea ?? '-';

      // ✅ GÜNCELLENDİ: Proje adı (API'den geliyor)
      replacements['project_name'] = reservation.property.projectName ?? '-';

      debugPrint('🏠 [Property] ${reservation.property.title}');
      debugPrint('🔢 [Room Count] ${reservation.property.roomCount}');
      debugPrint('📐 [Net Area] ${reservation.property.netArea ?? "Belirtilmemiş"}');
      debugPrint('🏗️ [Project Name] ${reservation.property.projectName ?? "Belirtilmemiş"}');

      // Mülk tam adresi
      final propertyFullAddress = [
        reservation.property.title,
        'Blok: ${reservation.property.block}',
        'Kat: ${reservation.property.floor}',
        'Daire: ${reservation.property.unitNumber}',
      ].join(', ');
      replacements['property_full_address'] = propertyFullAddress;

      // ============================================================
      // 🔥 ÖDEME PLANI BİLGİLERİ (Detaylı)
      // ============================================================
      if (reservation.paymentPlanSelected != null) {
        final plan = reservation.paymentPlanSelected!;

        replacements['payment_plan_name'] = plan.name;

        debugPrint('💳 [Payment Plan] ${plan.name}');
        debugPrint('📦 [Plan Details] ${plan.details}');

        // Vadeli fiyat
        if (plan.details.containsKey('installment_price')) {
          final installmentPrice = plan.details['installment_price'];
          if (installmentPrice != null) {
            final priceValue = installmentPrice is num
                ? installmentPrice.toDouble()
                : double.tryParse(installmentPrice.toString()) ?? 0;
            replacements['installment_price'] = currencyFormat.format(priceValue);
          } else {
            replacements['installment_price'] = '-';
          }
        } else {
          replacements['installment_price'] = '-';
        }

        // Peşin fiyat (peşin ödeme planı için)
        if (plan.details.containsKey('cash_price')) {
          final cashPrice = plan.details['cash_price'];
          if (cashPrice != null) {
            final priceValue = cashPrice is num
                ? cashPrice.toDouble()
                : double.tryParse(cashPrice.toString()) ?? 0;
            replacements['cash_price'] = currencyFormat.format(priceValue);
          } else {
            replacements['cash_price'] = '-';
          }
        } else {
          replacements['cash_price'] = '-';
        }

        // Peşinat
        if (plan.details.containsKey('down_payment')) {
          final downPayment = plan.details['down_payment'];
          if (downPayment != null) {
            final paymentValue = downPayment is num
                ? downPayment.toDouble()
                : double.tryParse(downPayment.toString()) ?? 0;
            replacements['down_payment'] = currencyFormat.format(paymentValue);
          } else {
            replacements['down_payment'] = '-';
          }
        } else {
          replacements['down_payment'] = '-';
        }

        // Taksit sayısı
        if (plan.details.containsKey('installment_count')) {
          final installmentCount = plan.details['installment_count'];
          replacements['installment_count'] = installmentCount != null
              ? '$installmentCount Ay'
              : '-';
        } else {
          replacements['installment_count'] = '-';
        }

        // Aylık taksit
        if (plan.details.containsKey('monthly_installment')) {
          final monthlyInstallment = plan.details['monthly_installment'];
          if (monthlyInstallment != null) {
            final installmentValue = monthlyInstallment is num
                ? monthlyInstallment.toDouble()
                : double.tryParse(monthlyInstallment.toString()) ?? 0;
            replacements['monthly_installment'] = currencyFormat.format(installmentValue);
          } else {
            replacements['monthly_installment'] = '-';
          }
        } else {
          replacements['monthly_installment'] = '-';
        }

      } else {
        // Ödeme planı yoksa boş değerler
        replacements['payment_plan_name'] = '-';
        replacements['installment_price'] = '-';
        replacements['cash_price'] = '-';
        replacements['down_payment'] = '-';
        replacements['installment_count'] = '-';
        replacements['monthly_installment'] = '-';
      }

      // ============================================================
      // 🔥 KAPARO BİLGİLERİ
      // ============================================================
      replacements['deposit_amount'] = currencyFormat.format(reservation.depositAmount);
      replacements['deposit_payment_method'] = reservation.depositPaymentMethodDisplay;

    } else {
      debugPrint('⚠️ [Replacements] Rezervasyon detayları YOK');

      // Rezervasyon yoksa boş değerler
      replacements['reservation_number'] = '-';
      replacements['reservation_id'] = '-';
      replacements['reservation_date'] = '-';
      replacements['reservation_amount'] = '-';
      replacements['reservation_amount_number'] = '0';
      replacements['customer_id'] = '-';
      replacements['customer_name'] = '-';
      replacements['customer_phone'] = '-';
      replacements['customer_email'] = '-';
      replacements['property_id'] = '-';
      replacements['property_title'] = '-';
      replacements['property_type'] = '-';
      replacements['block_number'] = '-';
      replacements['floor_number'] = '-';
      replacements['apartment_number'] = '-';
      replacements['room_count'] = '-';
      replacements['net_area'] = '-';
      replacements['project_name'] = '-';
      replacements['property_full_address'] = '-';
      replacements['payment_plan_name'] = '-';
      replacements['installment_price'] = '-';
      replacements['cash_price'] = '-';
      replacements['down_payment'] = '-';
      replacements['installment_count'] = '-';
      replacements['monthly_installment'] = '-';
      replacements['deposit_amount'] = '-';
      replacements['deposit_payment_method'] = '-';
    }

    // ============================================================
    // 🔥 SATIŞ DETAYLARI (Satış sözleşmeleri için)
    // ============================================================
    if (contract.saleDetails != null) {
      final sale = contract.saleDetails!;

      debugPrint('✅ [Replacements] Satış detayları bulundu');

      replacements['sale_number'] = sale.saleNumber;
      replacements['sale_id'] = sale.id.toString();
      replacements['sale_date'] = dateFormat.format(sale.saleDate);
      replacements['sale_price'] = currencyFormat.format(sale.salePrice);
      replacements['sale_price_number'] = sale.salePriceString;
      replacements['payment_plan'] = sale.paymentPlan ?? '-';

      // Müşteri Bilgileri (Satış)
      replacements['sale_customer_id'] = sale.customer.id.toString();
      replacements['sale_customer_name'] = sale.customer.fullName;
      replacements['sale_customer_phone'] = sale.customer.phoneNumber ?? '-';
      replacements['sale_customer_email'] = sale.customer.email ?? '-';

      // Mülk Bilgileri (Satış)
      replacements['sale_property_id'] = sale.property.id.toString();
      replacements['sale_property_title'] = sale.property.title;
      replacements['sale_property_type'] = sale.property.propertyType;
      replacements['sale_block_number'] = sale.property.block;
      replacements['sale_floor_number'] = sale.property.floor.toString();
      replacements['sale_apartment_number'] = sale.property.unitNumber;

      // ✅ GÜNCELLENDİ: Satış için de net_area ve project_name
      replacements['sale_net_area'] = sale.property.netArea ?? '-';
      replacements['sale_project_name'] = sale.property.projectName ?? '-';

      // Mülk tam adresi (Satış)
      final salePropertyFullAddress = [
        sale.property.title,
        'Blok: ${sale.property.block}',
        'Kat: ${sale.property.floor}',
        'Daire: ${sale.property.unitNumber}',
      ].join(', ');
      replacements['sale_property_full_address'] = salePropertyFullAddress;

    } else {
      debugPrint('⚠️ [Replacements] Satış detayları YOK');

      // Satış yoksa boş değerler
      replacements['sale_number'] = '-';
      replacements['sale_id'] = '-';
      replacements['sale_date'] = '-';
      replacements['sale_price'] = '-';
      replacements['sale_price_number'] = '0';
      replacements['payment_plan'] = '-';
      replacements['sale_customer_id'] = '-';
      replacements['sale_customer_name'] = '-';
      replacements['sale_customer_phone'] = '-';
      replacements['sale_customer_email'] = '-';
      replacements['sale_property_id'] = '-';
      replacements['sale_property_title'] = '-';
      replacements['sale_property_type'] = '-';
      replacements['sale_block_number'] = '-';
      replacements['sale_floor_number'] = '-';
      replacements['sale_apartment_number'] = '-';
      replacements['sale_net_area'] = '-';
      replacements['sale_project_name'] = '-';
      replacements['sale_property_full_address'] = '-';
    }

    // ============================================================
    // 🔥 ŞİRKET BİLGİLERİ (**** DÜZELTME ****)
    // ============================================================
    // Sabit kodlanmış veriler yerine modelden gelen dinamik veriler kullanıldı

    final company = contract.reservationDetails?.sellerCompanyInfo;

    replacements['company_name'] = company?.companyName ?? 'N/A';
    replacements['company_address'] = company?.businessAddress ?? 'N/A';
    replacements['company_phone'] = company?.businessPhone ?? 'N/A';
    replacements['tax_office'] = company?.taxOffice ?? 'N/A';
    replacements['tax_number'] = company?.taxNumber ?? 'N/A';
    replacements['mersis_number'] = company?.mersisNumber ?? 'N/A';

    // Bu alanlar şablonunuzda yoktu, ama eğer eklerseniz modelde yoklar (Sadece Django'da SellerCompany'ye eklenirse gelir)
    // replacements['company_email'] = company?.email ?? 'N/A';
    // replacements['company_website'] = company?.website ?? 'N/A';
    // ============================================================
    // 🔥 DÜZELTME SONU
    // ============================================================


    // ============================================================
    // 🔥 YASAL BİLGİLER
    // ============================================================
    replacements['legal_notice'] =
    'Bu sözleşme elektronik ortamda oluşturulmuştur ve yasal olarak geçerlidir. '
        'Taraflar bu sözleşmeyi kabul ederek yasal haklarını kullanmış sayılırlar.';

    replacements['terms_and_conditions'] =
    '1. Bu sözleşme taraflar arasında akdedilmiştir.\n'
        '2. Sözleşme şartları değişmez niteliktedir.\n'
        '3. İhtilaflarda İstanbul Mahkemeleri yetkilidir.';

    // ============================================================
    // 🔥 BUGÜNÜN TARİHİ
    // ============================================================
    replacements['current_date'] = dateFormat.format(DateTime.now());
    replacements['current_year'] = DateTime.now().year.toString();

    debugPrint('📋 [Replacements] Toplam ${replacements.length} adet değer hazırlandı');

    // 🔥 Debug: Eksik kalan placeholder'ları göster
    replacements.forEach((key, value) {
      if (value == '-' || value.startsWith('{')) {
        debugPrint('⚠️ [Missing] $key = $value');
      }
    });

    return replacements;
  }

  /// Status ikonu döner
  String _getStatusIcon(ContractStatus status) {
    switch (status) {
      case ContractStatus.draft:
        return '📝';
      case ContractStatus.pendingApproval:
        return '⏳';
      case ContractStatus.signed:
        return '✅';
      case ContractStatus.cancelled:
        return '❌';
    }
  }

  /// 🔥 Namespace'leri koruyarak replacement yapar
  Archive _replaceInArchivePreserveNamespaces(
      Archive archive,
      Map<String, String> replacements,
      ) {
    final newArchive = Archive();

    for (final file in archive.files) {
      if (file.isFile) {
        // Sadece document.xml dosyasını işle
        if (file.name == 'word/document.xml') {
          try {
            debugPrint('🔄 [Replace] Processing ${file.name}...');

            String content = utf8.decode(file.content as List<int>);

            // 🔥 XML-safe replacement
            replacements.forEach((key, value) {
              final safeValue = _escapeXml(value);

              // Pattern 1: <w:t>{key}</w:t>
              final pattern1 = RegExp(
                '(<w:t[^>]*>)\\{$key\\}(</w:t>)',
                multiLine: true,
              );
              content = content.replaceAllMapped(pattern1, (match) {
                return '${match.group(1)}$safeValue${match.group(2)}';
              });

              // Pattern 2: <w:t>{{key}}</w:t>
              final pattern2 = RegExp(
                '(<w:t[^>]*>)\\{\\{$key\\}\\}(</w:t>)',
                multiLine: true,
              );
              content = content.replaceAllMapped(pattern2, (match) {
                return '${match.group(1)}$safeValue${match.group(2)}';
              });

              // Pattern 3: Basit replacement (fallback)
              content = content.replaceAll('{$key}', safeValue);
              content = content.replaceAll('{{$key}}', safeValue);
            });

            final newFile = ArchiveFile(
              file.name,
              content.length,
              Uint8List.fromList(utf8.encode(content)),
            );
            newArchive.addFile(newFile);

            debugPrint('✅ [Replace] ${file.name} processed successfully');
          } catch (e) {
            debugPrint('❌ [Replace] Error processing ${file.name}: $e');
            // Hata olursa orijinali kopyala
            final newFile = ArchiveFile(
              file.name,
              file.size,
              Uint8List.fromList(file.content as List<int>),
            );
            newArchive.addFile(newFile);
          }
        } else {
          // Diğer dosyaları olduğu gibi kopyala
          final newFile = ArchiveFile(
            file.name,
            file.size,
            Uint8List.fromList(file.content as List<int>),
          );
          newArchive.addFile(newFile);
        }
      }
    }

    return newArchive;
  }

  /// XML özel karakterlerini escape eder
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// WEB: Browser'a dosya indir
  Future<String> _saveFileWeb(Uint8List bytes, ContractModel contract) async {
    try {
      final fileName = 'Sozlesme_${contract.contractNumber}.docx';

      final blob = html.Blob(
        [bytes],
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      html.Url.revokeObjectUrl(url);

      debugPrint('✅ [WEB Download] Dosya indirildi: $fileName');
      return fileName;
    } catch (e) {
      debugPrint('❌ [WEB Download] Hata: $e');
      throw Exception('Web download hatası: $e');
    }
  }

  /// MOBILE/DESKTOP: Dosya sistemine kaydet
  Future<String> _saveFile(Uint8List bytes, ContractModel contract) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Sozlesme_${contract.contractNumber}_$timestamp.docx';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint('✅ [DOCX File] Dosya kaydedildi: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ [DOCX File] Dosya kaydedilemedi: $e');
      throw Exception('Dosya kaydedilemedi: $e');
    }
  }

  /// Downloads klasörüne kaydet
  Future<String> saveToDownloads(Uint8List bytes, ContractModel contract) async {
    if (kIsWeb) {
      return await _saveFileWeb(bytes, contract);
    }

    try {
      Directory? directory;

      if (Platform.isAndroid) {
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
            if (directory != null) {
              final downloadsPath = '${directory.path}/Downloads';
              directory = Directory(downloadsPath);
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }
            }
          }
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Kayıt dizini bulunamadı');
      }

      final fileName = 'Sozlesme_${contract.contractNumber}.docx';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint('✅ [DOCX Downloads] Dosya kaydedildi: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ [DOCX Downloads] Kaydetme hatası: $e');
      throw Exception('Dosya kaydedilemedi: $e');
    }
  }
}
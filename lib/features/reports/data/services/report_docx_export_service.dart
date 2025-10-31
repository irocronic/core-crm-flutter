// lib/features/reports/data/services/report_docx_export_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:docx_generator/docx_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// Report DOCX Export Service
/// Satış raporlarını DOCX formatında programatik olarak oluşturur
/// docx_generator paketi kullanılarak template'e ihtiyaç duymadan export yapar
class ReportDocxExportService {
  /// Raporu DOCX olarak export eder
  Future<String> exportReport(Map<String, dynamic> reportData) async {
    try {
      debugPrint('📄 [Report DOCX] Export başlatılıyor...');

      // 1. DOCX Document oluştur
      final docx = DocxDocument();

      // 2. Rapor içeriğini oluştur
      _buildReportDocument(docx, reportData);

      debugPrint('✅ [Report DOCX] Document oluşturuldu');

      // 3. DOCX'i byte array'e dönüştür
      final bytes = await docx.save();

      debugPrint('✅ [Report DOCX] Bytes oluşturuldu (${bytes.length} bytes)');

      // 4. Dosyayı kaydet
      final filePath = await _saveFile(bytes, reportData);
      debugPrint('✅ [Report DOCX] Dosya kaydedildi: $filePath');

      return filePath;
    } catch (e, stackTrace) {
      debugPrint('❌ [Report DOCX] Error: $e');
      debugPrint('📄 [Report DOCX] Stack Trace: $stackTrace');
      throw Exception('Report DOCX export hatası: $e');
    }
  }

  /// DOCX document içeriğini oluşturur
  void _buildReportDocument(
      DocxDocument docx, Map<String, dynamic> reportData) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    // ============================================================
    // BAŞLIK (HEADER)
    // ============================================================
    docx.addParagraph(
      text: 'SATIŞ RAPORU',
      style: ParagraphStyle(
        alignment: TextAlignment.center,
        fontSize: 24,
        bold: true,
        fontFamily: 'Arial',
      ),
    );

    docx.addParagraph(
      text: reportData['report_number'] ?? 'N/A',
      style: ParagraphStyle(
        alignment: TextAlignment.center,
        fontSize: 16,
        bold: true,
        fontFamily: 'Arial',
        topSpacing: 6,
        bottomSpacing: 12,
      ),
    );

    // Dönem Bilgisi
    docx.addParagraph(
      text: _getPeriodText(reportData),
      style: ParagraphStyle(
        alignment: TextAlignment.center,
        fontSize: 12,
        fontFamily: 'Arial',
        color: 0xFF757575,
        bottomSpacing: 12,
      ),
    );

    // Çizgi
    docx.addParagraph(
      text: '─────────────────────────────────────────────',
      style: ParagraphStyle(
        alignment: TextAlignment.center,
        fontSize: 10,
        bottomSpacing: 12,
      ),
    );

    // ============================================================
    // RAPOR BİLGİLERİ
    // ============================================================
    docx.addParagraph(
      text: 'RAPOR BİLGİLERİ',
      style: ParagraphStyle(
        fontSize: 14,
        bold: true,
        fontFamily: 'Arial',
        topSpacing: 12,
        bottomSpacing: 8,
      ),
    );

    final infoTable = docx.addTable(
      rows: 4,
      columns: 2,
      borderStyle: TableBorderStyle.all,
    );

    final startDate = reportData['start_date'] != null
        ? dateFormat.format(DateTime.parse(reportData['start_date']))
        : 'N/A';

    final endDate = reportData['end_date'] != null
        ? dateFormat.format(DateTime.parse(reportData['end_date']))
        : 'N/A';

    final createdAt = reportData['created_at'] != null
        ? dateFormat.format(DateTime.parse(reportData['created_at']))
        : dateFormat.format(DateTime.now());

    final infoData = [
      ['Rapor No:', reportData['report_number'] ?? 'N/A'],
      ['Başlangıç Tarihi:', startDate],
      ['Bitiş Tarihi:', endDate],
      ['Oluşturulma Tarihi:', createdAt],
    ];

    for (int i = 0; i < infoData.length; i++) {
      infoTable.setCell(
        row: i,
        column: 0,
        content: infoData[i][0],
        style: TableCellStyle(
          bold: true,
          backgroundColor: 0xFFF5F5F5,
          fontSize: 11,
        ),
      );
      infoTable.setCell(
        row: i,
        column: 1,
        content: infoData[i][1],
        style: TableCellStyle(fontSize: 11),
      );
    }

    // ============================================================
    // SATIŞ İSTATİSTİKLERİ
    // ============================================================
    docx.addParagraph(
      text: 'SATIŞ İSTATİSTİKLERİ',
      style: ParagraphStyle(
        fontSize: 14,
        bold: true,
        fontFamily: 'Arial',
        topSpacing: 16,
        bottomSpacing: 8,
      ),
    );

    final statsTable = docx.addTable(
      rows: 5,
      columns: 2,
      borderStyle: TableBorderStyle.all,
    );

    final statsData = [
      [
        'Toplam Satış Sayısı:',
        _formatNumber(reportData['total_sales_count'] ?? 0)
      ],
      [
        'Toplam Satış Tutarı:',
        currencyFormat.format(_parseDouble(reportData['total_sales_amount']))
      ],
      [
        'Ortalama Satış Tutarı:',
        currencyFormat.format(_parseDouble(reportData['average_sale_amount']))
      ],
      [
        'En Yüksek Satış:',
        currencyFormat.format(_parseDouble(reportData['highest_sale_amount']))
      ],
      [
        'En Düşük Satış:',
        currencyFormat.format(_parseDouble(reportData['lowest_sale_amount']))
      ],
    ];

    for (int i = 0; i < statsData.length; i++) {
      statsTable.setCell(
        row: i,
        column: 0,
        content: statsData[i][0],
        style: TableCellStyle(
          bold: true,
          backgroundColor: 0xFFF5F5F5,
          fontSize: 11,
        ),
      );
      statsTable.setCell(
        row: i,
        column: 1,
        content: statsData[i][1],
        style: TableCellStyle(fontSize: 11, alignment: TextAlignment.right),
      );
    }

    // ============================================================
    // REZERVASYON İSTATİSTİKLERİ
    // ============================================================
    docx.addParagraph(
      text: 'REZERVASYON İSTATİSTİKLERİ',
      style: ParagraphStyle(
        fontSize: 14,
        bold: true,
        fontFamily: 'Arial',
        topSpacing: 16,
        bottomSpacing: 8,
      ),
    );

    final reservationTable = docx.addTable(
      rows: 5,
      columns: 2,
      borderStyle: TableBorderStyle.all,
    );

    final reservationData = [
      [
        'Toplam Rezervasyon:',
        _formatNumber(reportData['total_reservations_count'] ?? 0)
      ],
      [
        'Aktif Rezervasyon:',
        _formatNumber(reportData['active_reservations_count'] ?? 0)
      ],
      [
        'Tamamlanan:',
        _formatNumber(reportData['completed_reservations_count'] ?? 0)
      ],
      [
        'İptal Edilen:',
        _formatNumber(reportData['cancelled_reservations_count'] ?? 0)
      ],
      [
        'Toplam Tutar:',
        currencyFormat
            .format(_parseDouble(reportData['total_reservations_amount']))
      ],
    ];

    for (int i = 0; i < reservationData.length; i++) {
      reservationTable.setCell(
        row: i,
        column: 0,
        content: reservationData[i][0],
        style: TableCellStyle(
          bold: true,
          backgroundColor: 0xFFF5F5F5,
          fontSize: 11,
        ),
      );
      reservationTable.setCell(
        row: i,
        column: 1,
        content: reservationData[i][1],
        style: TableCellStyle(fontSize: 11, alignment: TextAlignment.right),
      );
    }

    // ============================================================
    // ÖDEME İSTATİSTİKLERİ
    // ============================================================
    docx.addParagraph(
      text: 'ÖDEME İSTATİSTİKLERİ',
      style: ParagraphStyle(
        fontSize: 14,
        bold: true,
        fontFamily: 'Arial',
        topSpacing: 16,
        bottomSpacing: 8,
      ),
    );

    final paymentTable = docx.addTable(
      rows: 4,
      columns: 2,
      borderStyle: TableBorderStyle.all,
    );

    final paymentData = [
      [
        'Toplam Tahsilat:',
        currencyFormat
            .format(_parseDouble(reportData['total_collections_amount']))
      ],
      [
        'Bekleyen Ödemeler:',
        currencyFormat
            .format(_parseDouble(reportData['pending_payments_amount']))
      ],
      [
        'Gecikmiş Ödemeler:',
        currencyFormat
            .format(_parseDouble(reportData['overdue_payments_amount']))
      ],
      ['Ödeme Oranı:', '${_formatPercentage(reportData['payment_rate'])}%'],
    ];

    for (int i = 0; i < paymentData.length; i++) {
      paymentTable.setCell(
        row: i,
        column: 0,
        content: paymentData[i][0],
        style: TableCellStyle(
          bold: true,
          backgroundColor: 0xFFF5F5F5,
          fontSize: 11,
        ),
      );
      paymentTable.setCell(
        row: i,
        column: 1,
        content: paymentData[i][1],
        style: TableCellStyle(fontSize: 11, alignment: TextAlignment.right),
      );
    }

    // ============================================================
    // SATIŞ LİSTESİ (Varsa)
    // ============================================================
    if (reportData['sales'] != null &&
        reportData['sales'] is List &&
        (reportData['sales'] as List).isNotEmpty) {
      docx.addParagraph(
        text: 'SATIŞ LİSTESİ',
        style: ParagraphStyle(
          fontSize: 14,
          bold: true,
          fontFamily: 'Arial',
          topSpacing: 16,
          bottomSpacing: 8,
        ),
      );

      final sales = reportData['sales'] as List;
      final salesTable = docx.addTable(
        rows: sales.length + 1,
        columns: 5,
        borderStyle: TableBorderStyle.all,
      );

      // Başlıklar
      final headers = ['#', 'Satış No', 'Müşteri', 'Mülk', 'Tutar'];
      for (int col = 0; col < headers.length; col++) {
        salesTable.setCell(
          row: 0,
          column: col,
          content: headers[col],
          style: TableCellStyle(
            bold: true,
            backgroundColor: 0xFF2196F3,
            textColor: 0xFFFFFFFF,
            fontSize: 11,
            alignment: TextAlignment.center,
          ),
        );
      }

      // Satışlar
      for (int i = 0; i < sales.length; i++) {
        final sale = sales[i] as Map<String, dynamic>;

        salesTable.setCell(
          row: i + 1,
          column: 0,
          content: (i + 1).toString(),
          style: TableCellStyle(fontSize: 10, alignment: TextAlignment.center),
        );

        salesTable.setCell(
          row: i + 1,
          column: 1,
          content: sale['sale_number'] ?? 'N/A',
          style: TableCellStyle(fontSize: 10),
        );

        salesTable.setCell(
          row: i + 1,
          column: 2,
          content: sale['customer_name'] ?? 'N/A',
          style: TableCellStyle(fontSize: 10),
        );

        salesTable.setCell(
          row: i + 1,
          column: 3,
          content: sale['property_title'] ?? 'N/A',
          style: TableCellStyle(fontSize: 10),
        );

        salesTable.setCell(
          row: i + 1,
          column: 4,
          content: currencyFormat.format(_parseDouble(sale['sale_amount'])),
          style: TableCellStyle(fontSize: 10, alignment: TextAlignment.right),
        );
      }
    }

    // ============================================================
    // NOTLAR (Varsa)
    // ============================================================
    if (reportData['notes'] != null &&
        reportData['notes'].toString().isNotEmpty) {
      docx.addParagraph(
        text: 'NOTLAR',
        style: ParagraphStyle(
          fontSize: 12,
          bold: true,
          fontFamily: 'Arial',
          topSpacing: 16,
          bottomSpacing: 6,
        ),
      );

      docx.addParagraph(
        text: reportData['notes'].toString(),
        style: ParagraphStyle(
          fontSize: 10,
          fontFamily: 'Arial',
          bottomSpacing: 12,
        ),
      );
    }

    // ============================================================
    // FOOTER
    // ============================================================
    docx.addParagraph(
      text: '',
      style: ParagraphStyle(topSpacing: 24),
    );

    docx.addParagraph(
      text: '─────────────────────────────────────────────',
      style: ParagraphStyle(
        alignment: TextAlignment.center,
        fontSize: 10,
        bottomSpacing: 8,
      ),
    );

    docx.addParagraph(
      text:
      'Bu rapor ${DateFormat('dd MMMM yyyy HH:mm', 'tr_TR').format(DateTime.now())} tarihinde elektronik olarak oluşturulmuştur.',
      style: ParagraphStyle(
        alignment: TextAlignment.center,
        fontSize: 9,
        color: 0xFF757575,
        fontFamily: 'Arial',
        italic: true,
      ),
    );
  }

  /// Dönem metnini oluşturur
  String _getPeriodText(Map<String, dynamic> reportData) {
    final period = reportData['period'];
    if (period == null) return 'Özel Dönem';

    switch (period) {
      case 'today':
        return 'Bugün';
      case 'yesterday':
        return 'Dün';
      case 'this_week':
        return 'Bu Hafta';
      case 'last_week':
        return 'Geçen Hafta';
      case 'this_month':
        return 'Bu Ay';
      case 'last_month':
        return 'Geçen Ay';
      case 'this_quarter':
        return 'Bu Çeyrek';
      case 'last_quarter':
        return 'Geçen Çeyrek';
      case 'this_year':
        return 'Bu Yıl';
      case 'last_year':
        return 'Geçen Yıl';
      case 'custom':
        return 'Özel Dönem';
      default:
        return period.toString();
    }
  }

  /// Double parse helper
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Sayı formatlama
  String _formatNumber(dynamic value) {
    final number = value is int
        ? value
        : (value is double
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '0') ?? 0);
    return NumberFormat.decimalPattern('tr_TR').format(number);
  }

  /// Yüzde formatlama
  String _formatPercentage(dynamic value) {
    final percent = _parseDouble(value);
    return percent.toStringAsFixed(1);
  }

  /// Dosyayı kaydet
  Future<String> _saveFile(
      Uint8List bytes, Map<String, dynamic> reportData) async {
    try {
      final directory = await getTemporaryDirectory();
      final reportNumber = reportData['report_number'] ?? 'RAPOR';
      final fileName =
          'Rapor_${reportNumber}_${DateTime.now().millisecondsSinceEpoch}.docx';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint('✅ [Report DOCX] Dosya kaydedildi: $filePath');

      return filePath;
    } catch (e) {
      debugPrint('❌ [Report DOCX] Dosya kaydedilemedi: $e');
      throw Exception('Dosya kaydedilemedi: $e');
    }
  }

  /// Downloads klasörüne kaydet
  Future<String> saveToDownloads(
      Uint8List bytes, Map<String, dynamic> reportData) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Kayıt dizini bulunamadı');
      }

      final reportNumber = reportData['report_number'] ?? 'RAPOR';
      final fileName = 'Rapor_$reportNumber.docx';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint('✅ [Report Downloads] Dosya kaydedildi: $filePath');

      return filePath;
    } catch (e) {
      debugPrint('❌ [Report Downloads] Dosya kaydedilemedi: $e');
      throw Exception('Dosya kaydedilemedi: $e');
    }
  }
}
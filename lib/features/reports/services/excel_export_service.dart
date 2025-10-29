// lib/features/reports/services/excel_export_service.dart

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Web için
import 'dart:typed_data';
import '../domain/entities/sales_report_entity.dart';

class ExcelExportService {
  static Future<dynamic> generateExcel(SalesReportEntity report) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Rapor'];

      final dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');
      final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

      // Başlık stili
      final headerStyle = CellStyle(
        backgroundColorHex: '#4472C4',
        fontColorHex: '#FFFFFF',
        bold: true,
        fontSize: 12,
      );

      // Rapor bilgileri
      int row = 0;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = 'SATIŞ RAPORU';
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row), CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
      row += 2;

      _addRow(sheet, row++, ['Rapor ID', report.id.toString()]);
      _addRow(sheet, row++, ['Rapor Türü', report.reportTypeDisplay]);
      _addRow(sheet, row++, ['Başlangıç', dateFormat.format(report.startDate)]);
      _addRow(sheet, row++, ['Bitiş', dateFormat.format(report.endDate)]);
      row += 2;

      // İstatistikler
      final stats = report.statistics;

      switch (report.reportType) {
        case ReportType.salesSummary:
          final reservations = stats['reservations'] as Map<String, dynamic>? ?? {};
          final payments = stats['payments'] as Map<String, dynamic>? ?? {};

          _addHeaderRow(sheet, row++, ['REZERVASYONLAR', ''], headerStyle);
          _addRow(sheet, row++, ['Toplam', reservations['total']?.toString() ?? '0']);
          _addRow(sheet, row++, ['Aktif', reservations['active']?.toString() ?? '0']);
          _addRow(sheet, row++, ['Satışa Dönüşen', reservations['converted']?.toString() ?? '0']);
          _addRow(sheet, row++, ['İptal', reservations['cancelled']?.toString() ?? '0']);
          _addRow(sheet, row++, ['Toplam Kaparo', currencyFormat.format(reservations['total_deposit'] ?? 0)]);
          row += 2;

          _addHeaderRow(sheet, row++, ['ÖDEMELER', ''], headerStyle);
          _addRow(sheet, row++, ['Toplam Tahsilat', currencyFormat.format(payments['total_collected'] ?? 0)]);
          _addRow(sheet, row++, ['Ödeme Sayısı', payments['payment_count']?.toString() ?? '0']);
          break;

        case ReportType.repPerformance:
          final summary = stats['performance_summary'] as Map<String, dynamic>? ?? {};
          final reps = stats['rep_performance'] as List<dynamic>? ?? [];

          _addHeaderRow(sheet, row++, ['PERFORMANS ÖZETİ', ''], headerStyle);
          _addRow(sheet, row++, ['Temsilci Sayısı', summary['total_sales_reps']?.toString() ?? '0']);
          _addRow(sheet, row++, ['Görüşme', summary['total_activity_count']?.toString() ?? '0']);
          _addRow(sheet, row++, ['Satış', summary['total_sales_count']?.toString() ?? '0']);
          _addRow(sheet, row++, ['Ciro', currencyFormat.format(summary['total_revenue'] ?? 0)]);
          row += 2;

          if (reps.isNotEmpty) {
            _addHeaderRow(sheet, row++, ['Temsilci', 'Görüşme', 'Satış', 'Ciro', 'Oran (%)'], headerStyle);
            for (var rep in reps) {
              _addRow(sheet, row++, [
                rep['rep_name'] ?? '-',
                rep['activity_count']?.toString() ?? '0',
                rep['sales_count']?.toString() ?? '0',
                currencyFormat.format(rep['total_revenue'] ?? 0),
                '${rep['conversion_rate'] ?? 0}%',
              ]);
            }
          }
          break;

        case ReportType.customerSource:
          final summary = stats['source_summary'] as Map<String, dynamic>? ?? {};
          final sources = stats['source_data'] as List<dynamic>? ?? [];

          _addHeaderRow(sheet, row++, ['MÜŞTERİ KAYNAK ÖZETİ', ''], headerStyle);
          _addRow(sheet, row++, ['Toplam Müşteri', summary['total_customers']?.toString() ?? '0']);
          _addRow(sheet, row++, ['Popüler Kaynak', summary['most_common_source'] ?? 'N/A']);
          row += 2;

          if (sources.isNotEmpty) {
            _addHeaderRow(sheet, row++, ['Kaynak', 'Müşteri Sayısı'], headerStyle);
            for (var source in sources) {
              _addRow(sheet, row++, [
                source['source'] ?? '-',
                source['count']?.toString() ?? '0',
              ]);
            }
          }
          break;

        default:
          break;
      }

      // Sütun genişlikleri
      sheet.setColWidth(0, 30);
      sheet.setColWidth(1, 25);
      sheet.setColWidth(2, 15);
      sheet.setColWidth(3, 20);
      sheet.setColWidth(4, 15);

      final bytes = excel.encode();
      if (bytes == null) return null;

      // ✅ Platform kontrolü
      if (kIsWeb) {
        // Web: Dosyayı tarayıcıda indir
        final blob = html.Blob([Uint8List.fromList(bytes)], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'rapor_${report.id}_${DateTime.now().millisecondsSinceEpoch}.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);

        return bytes; // Web'de bytes döndür
      } else {
        // Mobil/Desktop: Dosyaya kaydet
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/rapor_${report.id}_${DateTime.now().millisecondsSinceEpoch}.xlsx');
        await file.writeAsBytes(bytes);
        return file; // Mobil'de File döndür
      }
    } catch (e) {
      print('❌ Excel oluşturma hatası: $e');
      return null;
    }
  }

  static void _addRow(Sheet sheet, int rowIndex, List<dynamic> values) {
    for (int i = 0; i < values.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).value = values[i];
    }
  }

  static void _addHeaderRow(Sheet sheet, int rowIndex, List<dynamic> values, CellStyle style) {
    for (int i = 0; i < values.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
      cell.value = values[i];
      cell.cellStyle = style;
    }
  }
}
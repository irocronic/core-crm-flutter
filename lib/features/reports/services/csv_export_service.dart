// lib/features/reports/services/csv_export_service.dart

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Web için
import 'dart:convert';
import '../domain/entities/sales_report_entity.dart';

class CsvExportService {
  static Future<dynamic> generateCsv(SalesReportEntity report) async {
    try {
      final dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');
      final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

      List<List<dynamic>> rows = [];

      // Başlık
      rows.add(['SATIŞ RAPORU']);
      rows.add([]);
      rows.add(['Rapor ID', report.id.toString()]);
      rows.add(['Rapor Türü', report.reportTypeDisplay]);
      rows.add(['Başlangıç', dateFormat.format(report.startDate)]);
      rows.add(['Bitiş', dateFormat.format(report.endDate)]);
      rows.add([]);

      final stats = report.statistics;

      switch (report.reportType) {
        case ReportType.salesSummary:
          final reservations = stats['reservations'] as Map<String, dynamic>? ?? {};
          final payments = stats['payments'] as Map<String, dynamic>? ?? {};

          rows.add(['REZERVASYONLAR']);
          rows.add(['Toplam', reservations['total']]);
          rows.add(['Aktif', reservations['active']]);
          rows.add(['Satışa Dönüşen', reservations['converted']]);
          rows.add(['İptal', reservations['cancelled']]);
          rows.add(['Toplam Kaparo', reservations['total_deposit']]);
          rows.add([]);
          rows.add(['ÖDEMELER']);
          rows.add(['Toplam Tahsilat', payments['total_collected']]);
          rows.add(['Ödeme Sayısı', payments['payment_count']]);
          break;

        case ReportType.repPerformance:
          final summary = stats['performance_summary'] as Map<String, dynamic>? ?? {};
          final reps = stats['rep_performance'] as List<dynamic>? ?? [];

          rows.add(['PERFORMANS ÖZETİ']);
          rows.add(['Temsilci Sayısı', summary['total_sales_reps']]);
          rows.add(['Görüşme', summary['total_activity_count']]);
          rows.add(['Satış', summary['total_sales_count']]);
          rows.add(['Ciro', summary['total_revenue']]);
          rows.add([]);

          if (reps.isNotEmpty) {
            rows.add(['Temsilci', 'Görüşme', 'Satış', 'Ciro', 'Oran (%)']);
            for (var rep in reps) {
              rows.add([
                rep['rep_name'],
                rep['activity_count'],
                rep['sales_count'],
                rep['total_revenue'],
                '${rep['conversion_rate']}%',
              ]);
            }
          }
          break;

        case ReportType.customerSource:
          final summary = stats['source_summary'] as Map<String, dynamic>? ?? {};
          final sources = stats['source_data'] as List<dynamic>? ?? [];

          rows.add(['MÜŞTERİ KAYNAK ÖZETİ']);
          rows.add(['Toplam Müşteri', summary['total_customers']]);
          rows.add(['Popüler Kaynak', summary['most_common_source']]);
          rows.add([]);

          if (sources.isNotEmpty) {
            rows.add(['Kaynak', 'Müşteri Sayısı']);
            for (var source in sources) {
              rows.add([source['source'], source['count']]);
            }
          }
          break;

        default:
          break;
      }

      // CSV'ye dönüştür
      String csv = const ListToCsvConverter(fieldDelimiter: ';', eol: '\n').convert(rows);

      // UTF-8 BOM ekle (Excel Türkçe karakter desteği için)
      final bom = '\uFEFF';
      csv = bom + csv;

      // ✅ Platform kontrolü
      if (kIsWeb) {
        // Web: Dosyayı tarayıcıda indir
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'rapor_${report.id}_${DateTime.now().millisecondsSinceEpoch}.csv')
          ..click();
        html.Url.revokeObjectUrl(url);

        return bytes; // Web'de bytes döndür
      } else {
        // Mobil/Desktop: Dosyaya kaydet
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/rapor_${report.id}_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csv);
        return file; // Mobil'de File döndür
      }
    } catch (e) {
      print('❌ CSV oluşturma hatası: $e');
      return null;
    }
  }
}
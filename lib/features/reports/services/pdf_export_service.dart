// lib/features/reports/services/pdf_export_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // ✅ debugPrint için
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Web için
import 'dart:typed_data';
import '../domain/entities/sales_report_entity.dart';

class PdfExportService {
  /// PDF oluştur ve kaydet
  /// Web platformunda: Uint8List döndürür
  /// Mobil/Desktop platformunda: File döndürür
  /// Hata durumunda: null döndürür
  static Future<dynamic> generatePdf(SalesReportEntity report) async {
    try {
      debugPrint('🔵 [PDF SERVICE] Başlıyor - Platform: ${kIsWeb ? "Web" : "Mobil"}');
      debugPrint('🔵 [PDF SERVICE] Report ID: ${report.id}');
      debugPrint('🔵 [PDF SERVICE] Report Type: ${report.reportType}');

      final pdf = pw.Document();
      final dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');
      final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

      // Türkçe font desteği
      final ttf = await PdfGoogleFonts.robotoRegular();
      final ttfBold = await PdfGoogleFonts.robotoBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttfBold,
          ),
          build: (pw.Context context) {
            return [
              // Başlık
              pw.Header(
                level: 0,
                child: pw.Text(
                  'SATIŞ RAPORU',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Rapor Bilgileri
              _buildInfoTable(report, dateFormat),
              pw.SizedBox(height: 30),

              // İstatistikler
              pw.Header(
                level: 1,
                child: pw.Text(
                  'İSTATİSTİKLER',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              // Rapor türüne göre içerik
              ...(_buildStatisticsContent(report, currencyFormat)),

              // Footer
              pw.SizedBox(height: 40),
              pw.Divider(),
              pw.Text(
                'Oluşturulma: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ];
          },
        ),
      );

      debugPrint('🔵 [PDF SERVICE] PDF dokümanı oluşturuldu');

      // PDF'i byte array'e çevir
      final Uint8List bytes = await pdf.save();
      debugPrint('🔵 [PDF SERVICE] PDF byte array\'e çevrildi: ${bytes.length} bytes');

      // ✅ FIX: Platform kontrolü - AÇIK RETURN TİPİ
      if (kIsWeb) {
        debugPrint('🌐 [PDF SERVICE] Web platformu tespit edildi');

        // Web: Tarayıcıda indir
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'rapor_${report.id}_${DateTime.now().millisecondsSinceEpoch}.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);

        debugPrint('✅ [PDF SERVICE] Web - Dosya tarayıcıya indirildi');
        debugPrint('🔵 [PDF SERVICE] Döndürülen tip: Uint8List (${bytes.length} bytes)');

        // Web'de Uint8List döndür
        return bytes as dynamic; // ✅ FIX: Explicit dynamic cast

      } else {
        debugPrint('📱 [PDF SERVICE] Mobil/Desktop platformu tespit edildi');

        // Mobil/Desktop: Dosyaya kaydet
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/rapor_${report.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        debugPrint('✅ [PDF SERVICE] Mobil - Dosya kaydedildi: $filePath');
        debugPrint('🔵 [PDF SERVICE] Döndürülen tip: File');

        // Mobil'de File döndür
        return file as dynamic; // ✅ FIX: Explicit dynamic cast
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [PDF SERVICE] HATA: $e');
      debugPrint('📄 [PDF SERVICE] Stack Trace:\n$stackTrace');
      return null;
    }
  }

  /// PDF'i önizle ve paylaş (Sadece mobil)
  static Future<void> previewAndShare(dynamic fileOrBytes) async {
    if (kIsWeb) {
      // Web'de paylaşım yok, dosya zaten indirildi
      debugPrint('ℹ️ [PDF SERVICE] Web platformunda dosya indirildi');
      return;
    }

    try {
      if (fileOrBytes is File) {
        final bytes = await fileOrBytes.readAsBytes();
        await Printing.sharePdf(bytes: bytes, filename: fileOrBytes.path.split('/').last);
        debugPrint('✅ [PDF SERVICE] Dosya paylaşıldı');
      } else if (fileOrBytes is Uint8List) {
        await Printing.sharePdf(bytes: fileOrBytes, filename: 'rapor.pdf');
        debugPrint('✅ [PDF SERVICE] Bytes paylaşıldı');
      } else {
        debugPrint('⚠️ [PDF SERVICE] Geçersiz veri tipi: ${fileOrBytes.runtimeType}');
      }
    } catch (e) {
      debugPrint('❌ [PDF SERVICE] Paylaşım hatası: $e');
    }
  }

  static pw.Widget _buildInfoTable(SalesReportEntity report, DateFormat dateFormat) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _buildTableRow('Rapor ID', report.id.toString()),
        _buildTableRow('Rapor Türü', report.reportTypeDisplay),
        _buildTableRow('Başlangıç Tarihi', dateFormat.format(report.startDate)),
        _buildTableRow('Bitiş Tarihi', dateFormat.format(report.endDate)),
      ],
    );
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  static List<pw.Widget> _buildStatisticsContent(
      SalesReportEntity report,
      NumberFormat currencyFormat,
      ) {
    final stats = report.statistics;
    final widgets = <pw.Widget>[];

    switch (report.reportType) {
      case ReportType.salesSummary:
        final reservations = stats['reservations'] as Map<String, dynamic>? ?? {};
        final payments = stats['payments'] as Map<String, dynamic>? ?? {};

        widgets.add(_buildStatTable('REZERVASYONLAR', [
          ['Toplam', reservations['total']?.toString() ?? '0'],
          ['Aktif', reservations['active']?.toString() ?? '0'],
          ['Satışa Dönüşen', reservations['converted']?.toString() ?? '0'],
          ['İptal', reservations['cancelled']?.toString() ?? '0'],
          ['Toplam Kaparo', currencyFormat.format(reservations['total_deposit'] ?? 0)],
        ]));

        widgets.add(pw.SizedBox(height: 20));

        widgets.add(_buildStatTable('ÖDEMELER', [
          ['Toplam Tahsilat', currencyFormat.format(payments['total_collected'] ?? 0)],
          ['Ödeme Sayısı', payments['payment_count']?.toString() ?? '0'],
        ]));
        break;

      case ReportType.repPerformance:
        final summary = stats['performance_summary'] as Map<String, dynamic>? ?? {};
        final reps = stats['rep_performance'] as List<dynamic>? ?? [];

        widgets.add(_buildStatTable('ÖZET', [
          ['Temsilci Sayısı', summary['total_sales_reps']?.toString() ?? '0'],
          ['Görüşme', summary['total_activity_count']?.toString() ?? '0'],
          ['Satış', summary['total_sales_count']?.toString() ?? '0'],
          ['Ciro', currencyFormat.format(summary['total_revenue'] ?? 0)],
        ]));

        widgets.add(pw.SizedBox(height: 20));
        widgets.add(pw.Text('TEMSİLCİ DETAYLARI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.SizedBox(height: 10));

        if (reps.isNotEmpty) {
          widgets.add(pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildHeaderCell('Temsilci'),
                  _buildHeaderCell('Görüşme'),
                  _buildHeaderCell('Satış'),
                  _buildHeaderCell('Ciro'),
                  _buildHeaderCell('Oran (%)'),
                ],
              ),
              ...reps.map((rep) {
                return pw.TableRow(
                  children: [
                    _buildDataCell(rep['rep_name'] ?? '-'),
                    _buildDataCell(rep['activity_count']?.toString() ?? '0'),
                    _buildDataCell(rep['sales_count']?.toString() ?? '0'),
                    _buildDataCell(currencyFormat.format(rep['total_revenue'] ?? 0)),
                    _buildDataCell('${rep['conversion_rate'] ?? 0}%'),
                  ],
                );
              }).toList(),
            ],
          ));
        }
        break;

      case ReportType.customerSource:
        final summary = stats['source_summary'] as Map<String, dynamic>? ?? {};
        final sources = stats['source_data'] as List<dynamic>? ?? [];

        widgets.add(_buildStatTable('ÖZET', [
          ['Toplam Müşteri', summary['total_customers']?.toString() ?? '0'],
          ['Popüler Kaynak', summary['most_common_source'] ?? 'N/A'],
        ]));

        widgets.add(pw.SizedBox(height: 20));
        widgets.add(pw.Text('KAYNAK DAĞILIMI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.SizedBox(height: 10));

        if (sources.isNotEmpty) {
          widgets.add(pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildHeaderCell('Kaynak'),
                  _buildHeaderCell('Müşteri Sayısı'),
                ],
              ),
              ...sources.map((source) {
                return pw.TableRow(
                  children: [
                    _buildDataCell(source['source'] ?? '-'),
                    _buildDataCell(source['count']?.toString() ?? '0'),
                  ],
                );
              }).toList(),
            ],
          ));
        }
        break;

      default:
        widgets.add(pw.Text('Bilinmeyen rapor türü'));
    }

    return widgets;
  }

  static pw.Widget _buildStatTable(String title, List<List<String>> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 5),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: data.map((row) {
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(row[0], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(row[1]),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildDataCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }
}
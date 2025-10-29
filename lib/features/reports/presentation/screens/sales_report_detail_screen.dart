// lib/features/reports/presentation/screens/sales_report_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import '../../domain/entities/sales_report_entity.dart';
import '../providers/sales_report_provider.dart';

class SalesReportDetailScreen extends StatefulWidget {
  final String reportId;

  const SalesReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<SalesReportDetailScreen> createState() => _SalesReportDetailScreenState();
}

class _SalesReportDetailScreenState extends State<SalesReportDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesReportProvider>().loadReportById(widget.reportId);
    });
  }

  /// Export dialog göster
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_download, color: Colors.blue),
            SizedBox(width: 8),
            Text('Raporu Dışa Aktar'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Raporu hangi formatta indirmek istersiniz?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
              title: const Text('PDF'),
              subtitle: const Text('Taşınabilir Belge Formatı'),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () {
                Navigator.pop(dialogContext);
                _exportReportLocal(context, 'pdf');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green, size: 32),
              title: const Text('Excel'),
              subtitle: const Text('Microsoft Excel Formatı'),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () {
                Navigator.pop(dialogContext);
                _exportReportLocal(context, 'excel');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blue, size: 32),
              title: const Text('CSV'),
              subtitle: const Text('Virgülle Ayrılmış Değerler'),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () {
                Navigator.pop(dialogContext);
                _exportReportLocal(context, 'csv');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  /// ✅ FIXED: Flutter'dan direkt export işlemi
  Future<void> _exportReportLocal(BuildContext context, String format) async {
    final provider = context.read<SalesReportProvider>();
    final report = provider.selectedReport;

    if (report == null) {
      _showErrorDialog(context, 'Rapor bulunamadı');
      return;
    }

    // Loading dialog göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('$format dosyası hazırlanıyor...'),
                  const SizedBox(height: 8),
                  const Text(
                    'Bu işlem birkaç saniye sürebilir',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Export işlemini yap
    final result = await provider.exportReportLocal(
      report: report,
      format: format,
    );

    if (context.mounted) {
      Navigator.pop(context); // Loading dialog'u kapat
    }

    if (!context.mounted) return;

    if (result != null) {
      _showSuccessDialog(context, result);
    } else {
      _showErrorDialog(context, provider.errorMessage ?? 'Export başarısız');
    }
  }

  /// ✅ FIXED: ExportResult ile type-safe success dialog
  void _showSuccessDialog(BuildContext context, ExportResult result) {
    final isWeb = result.isWeb;
    final fileName = result.fileName;
    final fileData = result.data;
    final format = result.format;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Başarılı'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isWeb
                ? '$format dosyası tarayıcınıza indirildi!'
                : '$format dosyası kaydedildi!'),
            const SizedBox(height: 8),
            Text(
              fileName,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isWeb) ...[
              const SizedBox(height: 12),
              const Text(
                'ℹ️ Dosya tarayıcınızın indirmeler klasörüne kaydedildi.',
                style: TextStyle(fontSize: 10, color: Colors.blue),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          // ✅ FIXED: Sadece mobilde "Aç" ve "Paylaş" butonları
          if (!isWeb && result.isFile) ...[
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final file = result.asFile();
                  if (file != null) {
                    await OpenFile.open(file.path);
                    debugPrint('✅ [UI] Dosya açıldı: ${file.path}');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dosya açılamadı: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Aç'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final file = result.asFile();
                  if (file != null) {
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      subject: 'Satış Raporu',
                      text: 'İlişikteki satış raporunu paylaşıyorum.',
                    );
                    debugPrint('✅ [UI] Dosya paylaşıldı: ${file.path}');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Paylaşım hatası: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Paylaş'),
            ),
          ],
        ],
      ),
    );
  }

  /// Hata dialog'u
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Hata'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Detayı'),
        actions: [
          // Export butonu
          Consumer<SalesReportProvider>(
            builder: (context, provider, child) {
              if (provider.isExporting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }

              return IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: provider.selectedReport != null
                    ? () => _showExportDialog(context)
                    : null,
                tooltip: 'Raporu Dışa Aktar',
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  context.read<SalesReportProvider>().loadReportById(widget.reportId);
                  break;
                case 'export':
                  _showExportDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Yenile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Dışa Aktar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<SalesReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Hata',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadReportById(widget.reportId);
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final report = provider.selectedReport;
          if (report == null) {
            return const Center(child: Text('Rapor bulunamadı'));
          }

          return SingleChildScrollView(
            child: _buildReportBody(context, report),
          );
        },
      ),
    );
  }

  Widget _buildReportBody(BuildContext context, SalesReportEntity report) {
    switch (report.reportType) {
      case ReportType.salesSummary:
        return _buildSalesSummaryReport(context, report);
      case ReportType.repPerformance:
        return _buildRepPerformanceReport(context, report);
      case ReportType.customerSource:
        return _buildCustomerSourceReport(context, report);
      default:
        return const Center(child: Text('Bilinmeyen rapor türü.'));
    }
  }

  Widget _buildSalesSummaryReport(BuildContext context, SalesReportEntity report) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final stats = report.statistics;

    final totalSales = (stats['payments']?['total_collected'] as num?)?.toDouble() ?? 0.0;
    final orderCount = (stats['reservations']?['total'] as int?) ?? 0;
    final avgOrderValue = orderCount > 0 ? totalSales / orderCount : 0.0;

    return Column(
      children: [
        _buildHeaderCard(context, report, currencyFormat.format(totalSales)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.shopping_cart,
                      label: 'Toplam Satış Adedi',
                      value: orderCount.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.trending_up,
                      label: 'Ortalama Satış Değeri',
                      value: currencyFormat.format(avgOrderValue),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRepPerformanceReport(BuildContext context, SalesReportEntity report) {
    final stats = report.statistics;
    final List<dynamic> performanceData = stats['rep_performance'] ?? [];
    final summary = stats['performance_summary'] ?? {};
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Column(
      children: [
        _buildHeaderCard(context, report, currencyFormat.format(summary['total_revenue'] ?? 0.0)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performans Özeti',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: [
                  _buildStatCard(context, icon: Icons.people, label: 'Temsilci', value: summary['total_sales_reps']?.toString() ?? '0', color: Colors.purple),
                  _buildStatCard(context, icon: Icons.record_voice_over, label: 'Görüşme', value: summary['total_activity_count']?.toString() ?? '0', color: Colors.blue),
                  _buildStatCard(context, icon: Icons.point_of_sale, label: 'Satış', value: summary['total_sales_count']?.toString() ?? '0', color: Colors.green),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Temsilci Detayları',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: performanceData.length,
                itemBuilder: (ctx, index) {
                  final data = performanceData[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(data['rep_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Görüşme: ${data['activity_count']} - Satış: ${data['sales_count']}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(currencyFormat.format(data['total_revenue']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('${data['conversion_rate']}% Dönüşüm', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSourceReport(BuildContext context, SalesReportEntity report) {
    final stats = report.statistics;
    final List<dynamic> sourceData = stats['source_data'] ?? [];
    final summary = stats['source_summary'] ?? {};
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal, Colors.indigo];

    return Column(
      children: [
        _buildHeaderCard(context, report, '${summary['total_customers'] ?? 0} Müşteri'),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kaynak Dağılımı',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: sourceData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: (data['count'] as int).toDouble(),
                        title: '${data['count']}',
                        radius: 100,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...sourceData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: colors[index % colors.length], child: Text('${index + 1}', style: const TextStyle(color: Colors.white))),
                    title: Text(data['source']),
                    trailing: Text('${data['count']} Müşteri', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              })
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, SalesReportEntity report, String value) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.reportTypeDisplay,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${dateFormat.format(report.startDate)} - ${dateFormat.format(report.endDate)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
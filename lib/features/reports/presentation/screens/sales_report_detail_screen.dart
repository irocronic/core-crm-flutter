// /lib/features/reports/presentation/screens/sales_report_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../providers/sales_report_provider.dart';

class SalesReportDetailScreen extends StatefulWidget {
  final String reportId;
  const SalesReportDetailScreen({
    super.key,
    required this.reportId,
  });
  @override
  State<SalesReportDetailScreen> createState() =>
      _SalesReportDetailScreenState();
}

class _SalesReportDetailScreenState extends State<SalesReportDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesReportProvider>().loadReportById(widget.reportId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Detayı'),
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

          // GÜNCELLEME: Rapor türüne göre doğru widget'ı göster
          return SingleChildScrollView(
            child: _buildReportBody(context, report),
          );
        },
      ),
    );
  }

  // YENİ: Rapor türüne göre body oluşturan ana fonksiyon
  Widget _buildReportBody(BuildContext context, SalesReportEntity report) {
    switch(report.reportType) {
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

  // 1. Genel Satış Özeti Raporu Widget'ı
  Widget _buildSalesSummaryReport(BuildContext context, SalesReportEntity report) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
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
              // İleride diğer detaylar buraya eklenebilir.
            ],
          ),
        )
      ],
    );
  }

  // 2. Temsilci Performans Raporu Widget'ı
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

  // 3. Müşteri Kaynak Raporu Widget'ı
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

  // Ortak Widget'lar
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
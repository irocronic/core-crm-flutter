// lib/features/reports/presentation/widgets/sales_report_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/sales_report_entity.dart';

class SalesReportCard extends StatelessWidget {
  final SalesReportEntity report;
  final VoidCallback? onTap;

  const SalesReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  // GÜNCELLEME: Rapor türüne göre özet bilgileri getiren helper
  Widget _buildSummary(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final stats = report.statistics;

    switch (report.reportType) {
      case ReportType.salesSummary:
        final totalSales = (stats['payments']?['total_collected'] as num?)?.toDouble() ?? 0.0;
        final orderCount = (stats['reservations']?['total'] as int?) ?? 0;
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.attach_money,
                label: 'Toplam Ciro',
                value: currencyFormat.format(totalSales),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.shopping_cart,
                label: 'Satış Adedi',
                value: orderCount.toString(),
                color: Colors.blue,
              ),
            ),
          ],
        );

      case ReportType.repPerformance:
        final repCount = (stats['performance_summary']?['total_sales_reps'] as int?) ?? 0;
        final totalRevenue = (stats['performance_summary']?['total_revenue'] as num?)?.toDouble() ?? 0.0;
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.people,
                label: 'Temsilci Sayısı',
                value: repCount.toString(),
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.trending_up,
                label: 'Toplam Ciro',
                value: currencyFormat.format(totalRevenue),
                color: Colors.teal,
              ),
            ),
          ],
        );

      case ReportType.customerSource:
        final totalCustomers = (stats['source_summary']?['total_customers'] as int?) ?? 0;
        final mostCommonSource = (stats['source_summary']?['most_common_source'] as String?) ?? 'N/A';
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.alt_route,
                label: 'Toplam Müşteri',
                value: totalCustomers.toString(),
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.star,
                label: 'Popüler Kaynak',
                value: mostCommonSource,
                color: Colors.amber,
              ),
            ),
          ],
        );

      default:
        return const Text('Rapor verisi anlaşılamadı.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // GÜNCELLEME: Rapor türü başlığı
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.reportTypeDisplay,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${dateFormat.format(report.startDate)} - ${dateFormat.format(report.endDate)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        )
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // GÜNCELLEME: Dinamik özet alanı
              _buildSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
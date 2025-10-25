// lib/features/properties/presentation/screens/property_stats_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/property_stats_model.dart';
import '../providers/property_provider.dart';
// EKLENEN KOD: CustomDrawer bileşenini içe aktarma
import '../../../../shared/widgets/custom_drawer.dart';

class PropertyStatsScreen extends StatefulWidget {
  const PropertyStatsScreen({super.key});

  @override
  State<PropertyStatsScreen> createState() => _PropertyStatsScreenState();
}

class _PropertyStatsScreenState extends State<PropertyStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // EKLENEN KOD: CustomDrawer buraya eklenmiştir.
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Gayrimenkul İstatistikleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PropertyProvider>().loadStatistics();
            },
          ),
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, _) {
          if (provider.isStatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.statistics == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('İstatistikler yüklenemedi.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadStatistics();
                    },
                    child: const Text('Tekrar Dene'),
                  )
                ],
              ),
            );
          }

          final stats = provider.statistics!;

          return RefreshIndicator(
            onRefresh: () => provider.loadStatistics(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalPropertiesCard(stats.totalProperties),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Durum Dağılımı'),
                  const SizedBox(height: 16),
                  _buildStatusChart(context, stats),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Fiyat Analizi'),
                  const SizedBox(height: 16),
                  _buildPriceStatsGrid(stats.priceStats),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Alan Analizi'),
                  const SizedBox(height: 16),
                  _buildAreaStatsGrid(stats.areaStats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTotalPropertiesCard(int total) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              'Toplam Gayrimenkul',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              total.toString(),
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart(BuildContext context, PropertyStatisticsModel stats) {
    final statusData = [
      {'name': 'Satılabilir', 'value': stats.available, 'color': Colors.green},
      {'name': 'Rezerve', 'value': stats.reserved, 'color': Colors.orange},
      {'name': 'Satıldı', 'value': stats.sold, 'color': Colors.red},
      {'name': 'Pasif', 'value': stats.passive, 'color': Colors.grey},
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: statusData.map((data) {
            return PieChartSectionData(
              color: data['color'] as Color,
              value: (data['value'] as int).toDouble(),
              title: '${data['value']}',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPriceStatsGrid(PriceStats stats) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildStatCard(
            'Min. Fiyat',
            stats.minCashPrice != null
                ? CurrencyFormatter.formatCompact(stats.minCashPrice!)
                : 'N/A',
            Icons.arrow_downward,
            Colors.blue),
        _buildStatCard(
            'Ort. Fiyat',
            stats.avgCashPrice != null
                ? CurrencyFormatter.formatCompact(stats.avgCashPrice!)
                : 'N/A',
            Icons.attach_money,
            Colors.green),
        _buildStatCard(
            'Max. Fiyat',
            stats.maxCashPrice != null
                ? CurrencyFormatter.formatCompact(stats.maxCashPrice!)
                : 'N/A',
            Icons.arrow_upward,
            Colors.red),
      ],
    );
  }

  Widget _buildAreaStatsGrid(AreaStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
            'Ort. Brüt Alan',
            stats.avgGrossArea != null
                ? '${stats.avgGrossArea!.toStringAsFixed(1)} m²'
                : 'N/A',
            Icons.fullscreen,
            Colors.purple),
        _buildStatCard(
            'Ort. Net Alan',
            stats.avgNetArea != null
                ? '${stats.avgNetArea!.toStringAsFixed(1)} m²'
                : 'N/A',
            Icons.fullscreen_exit,
            Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
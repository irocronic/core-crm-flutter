import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/custom_drawer.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../providers/sales_report_provider.dart';
import '../widgets/report_filter_dialog.dart';
import '../widgets/sales_report_card.dart';
import 'sales_report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesReportProvider>().loadReports();
    });
  }

  void _showFilterDialog() async {
    final ReportFilterEntity? filter = await showDialog<ReportFilterEntity>(
      context: context,
      builder: (dialogContext) => ReportFilterDialog(
        currentFilter: context.read<SalesReportProvider>().currentFilter,
        onApplyFilter: (selectedFilter) {
          Navigator.of(dialogContext, rootNavigator: true).pop(selectedFilter);
        },
      ),
      useRootNavigator: true,
    );
    if (filter != null) {
      context.read<SalesReportProvider>().updateFilter(filter);
    }
  }

  void _showGenerateReportDialog() async {
    final ReportFilterEntity? filter = await showDialog<ReportFilterEntity>(
      context: context,
      builder: (dialogContext) => ReportFilterDialog(
        currentFilter: context.read<SalesReportProvider>().currentFilter,
        onApplyFilter: (selectedFilter) {
          Navigator.of(dialogContext, rootNavigator: true).pop(selectedFilter);
        },
        isGenerateMode: true,
      ),
      useRootNavigator: true,
    );

    if (filter == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (loadingContext) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Rapor oluşturuluyor...'),
              ],
            ),
          ),
        ),
      ),
    );

    final provider = context.read<SalesReportProvider>();
    final report = await provider.generateReport(filter: filter);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!mounted) return;

    if (report != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapor başarıyla oluşturuldu'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Rapor oluşturulamadı',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satış Raporları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SalesReportProvider>().refreshReports();
            },
            tooltip: 'Yenile',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGenerateReportDialog,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Rapor'),
      ),
      body: Consumer<SalesReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.reports.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null && provider.reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
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
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.clearError();
                      provider.refreshReports();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (provider.reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz rapor bulunmuyor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showGenerateReportDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Raporunu Oluştur'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshReports(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.reports.length,
              itemBuilder: (context, index) {
                final report = provider.reports[index];
                return SalesReportCard(
                  report: report,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalesReportDetailScreen(
                          reportId: report.id.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
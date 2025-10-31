// lib/features/settings/presentation/screens/settings_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_drawer.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/seller_company_provider.dart';
import '../../data/models/seller_company_model.dart';

class SettingsListScreen extends StatefulWidget {
  const SettingsListScreen({super.key});

  @override
  State<SettingsListScreen> createState() => _SettingsListScreenState();
}

class _SettingsListScreenState extends State<SettingsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // AuthProvider'ı oku (dinleme)
    final authProvider = context.read<AuthProvider>();

    // Yetki kontrolü
    if (!authProvider.isAdmin && !authProvider.isSalesManager) {
      // Yetkisi yoksa veri yüklemeye çalışma
      return;
    }

    // Yetkisi varsa veriyi yükle
    await context.read<SellerCompanyProvider>().loadCompanies(refresh: true);
  }

  void _showDeleteDialog(BuildContext context, SellerCompanyModel company) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Firmayı Sil'),
        content: Text(
          '\'${company.companyName}\' adlı firmayı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<SellerCompanyProvider>();
              final success = await provider.deleteCompany(company.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Firma başarıyla silindi'
                        : provider.errorMessage ?? 'Firma silinemedi'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Yetki kontrolü (Build-time)
    if (!authProvider.isAdmin && !authProvider.isSalesManager) {
      return Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: const Text('Ayarlar'),
        ),
        body: const ErrorDisplay(
          message: 'Bu alana erişim yetkiniz bulunmamaktadır.',
        ),
      );
    }

    // Yetkisi varsa
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<SellerCompanyProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.companies.isEmpty) {
              return const LoadingIndicator(message: 'Ayarlar yükleniyor...');
            }

            if (provider.errorMessage != null && provider.companies.isEmpty) {
              return ErrorDisplay(
                message: provider.errorMessage!,
                onRetry: _loadData,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Satıcı Firma Yönetimi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (provider.companies.isEmpty)
                  const Expanded(
                    child: EmptyState(
                      icon: Icons.business_outlined,
                      title: 'Satıcı Firma Bulunamadı',
                      subtitle: 'Sözleşmelerde kullanılmak üzere yeni bir satıcı firma ekleyin.',
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.companies.length,
                      itemBuilder: (context, index) {
                        final company = provider.companies[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              Icons.business,
                              color: company.isActive
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            title: Text(
                              company.companyName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'VN: ${company.taxNumber} - ${company.taxOffice}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  company.isActive ? Icons.check_circle : Icons.cancel,
                                  color: company.isActive ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(context, company),
                                ),
                              ],
                            ),
                            onTap: () {
                              context.go('/settings/seller-company/${company.id}/edit');
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/settings/seller-company/new'),
        child: const Icon(Icons.add),
        tooltip: 'Yeni Satıcı Firma Ekle',
      ),
    );
  }
}
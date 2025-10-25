// lib/features/customers/presentation/screens/customers_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/custom_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../users/presentation/providers/user_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Önce satış temsilcilerini yükle (dialog için)
      context.read<UserProvider>().loadSalesReps();
      context.read<CustomerProvider>().loadCustomers(refresh: true);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        final provider = context.read<CustomerProvider>();
        if (provider.hasMore && !provider.isLoadingMore) {
          provider.loadCustomers();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    // Ekrandan çıkarken seçimi temizle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CustomerProvider>().clearSelection();
      }
    });
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      context.read<CustomerProvider>().clearSearch();
    } else {
      context.read<CustomerProvider>().searchCustomers(query);
    }
  }

  // 🔥 YENİ METOT: Atama dialog'u
  void _showAssignDialog() {
    final customerProvider = context.read<CustomerProvider>();
    final userProvider = context.read<UserProvider>();
    final selectedCount = customerProvider.selectedCustomerIds.length;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$selectedCount Müşteriyi Ata'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userProvider.salesReps.length,
              itemBuilder: (context, index) {
                final rep = userProvider.salesReps[index];
                return ListTile(
                  title: Text(rep.fullName),
                  onTap: () async {
                    Navigator.of(dialogContext).pop(); // Dialog'u kapat
                    final success = await customerProvider.assignCustomers(rep.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Müşteriler başarıyla atandı'
                              : customerProvider.errorMessage ?? 'İşlem başarısız'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }


  // 🔥 GÜNCELLENMİŞ: AppBar artık dinamik
  AppBar _buildAppBar(BuildContext context, CustomerProvider provider) {
    final isManager = context.read<AuthProvider>().isSalesManager;

    if (provider.isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => provider.clearSelection(),
        ),
        title: Text('${provider.selectedCustomerIds.length} seçildi'),
        actions: [
          // Sadece yöneticiler atama yapabilir
          if (isManager)
            TextButton(
              onPressed: _showAssignDialog,
              child: const Text('ATA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      );
    }

    final isHotLeadsActive = provider.listType == CustomerListType.hotLeads;
    return AppBar(
      title: Text(isHotLeadsActive ? 'Sıcak Müşteriler' : 'Tüm Müşteriler'),
      actions: [
        Tooltip(
          message: isHotLeadsActive ? 'Tüm Müşterileri Göster' : 'Sıcak Müşterileri Göster',
          child: IconButton(
            icon: Icon(
              isHotLeadsActive ? Icons.local_fire_department : Icons.local_fire_department_outlined,
              color: isHotLeadsActive ? Colors.redAccent : null,
            ),
            onPressed: () {
              final newType = isHotLeadsActive ? CustomerListType.all : CustomerListType.hotLeads;
              provider.setListType(newType);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filtreleme yakında eklenecek')),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Müşteri ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _handleSearch('');
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _handleSearch,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    return Scaffold(
      appBar: _buildAppBar(context, provider),
      drawer: const CustomDrawer(),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadCustomers(refresh: true),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (provider.customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.listType == CustomerListType.hotLeads ? 'Sıcak müşteri bulunamadı' : 'Henüz müşteri yok',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yeni müşteri eklemek için + butonuna basın',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadCustomers(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.customers.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.customers.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final customer = provider.customers[index];
                return CustomerCard(
                  customer: customer,
                  isSelected: provider.isCustomerSelected(customer.id),
                  onLongPress: () {
                    provider.toggleSelection(customer.id);
                  },
                  onTap: () {
                    if (provider.isSelectionMode) {
                      provider.toggleSelection(customer.id);
                    } else {
                      context.go('/customers/${customer.id}');
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      // 🔥 GÜNCELLEME: Seçim modunda FAB'ı gizle
      floatingActionButton: context.watch<CustomerProvider>().isSelectionMode
          ? null
          : FloatingActionButton(
        onPressed: () => context.go('/customers/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
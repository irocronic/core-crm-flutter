// lib/features/customers/presentation/screens/customers_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/custom_drawer.dart'; // [cite: 146]
import '../../../auth/presentation/providers/auth_provider.dart'; // [cite: 146]
import '../../../users/presentation/providers/user_provider.dart'; // [cite: 146]
import '../providers/customer_provider.dart'; // [cite: 146]
import '../widgets/customer_card.dart'; // [cite: 146]

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key}); // [cite: 146]

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState(); // [cite: 146]
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final _scrollController = ScrollController(); // [cite: 146]
  final _searchController = TextEditingController(); // [cite: 146]

  @override
  void initState() {
    super.initState(); // [cite: 146]

    WidgetsBinding.instance.addPostFrameCallback((_) { // [cite: 146]
      // Önce satış temsilcilerini yükle (dialog için)
      context.read<UserProvider>().loadSalesReps(); // [cite: 146, 147]
      context.read<CustomerProvider>().loadCustomers(refresh: true); // [cite: 147]
    });
    _scrollController.addListener(() { // [cite: 147]
      if (_scrollController.position.pixels >= // [cite: 147]
          _scrollController.position.maxScrollExtent * 0.8) { // [cite: 147]
        final provider = context.read<CustomerProvider>(); // [cite: 147]
        if (provider.hasMore && !provider.isLoadingMore) { // [cite: 147]
          provider.loadCustomers(); // [cite: 147]
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // [cite: 147]
    _searchController.dispose(); // [cite: 147]
    // Ekrandan çıkarken seçimi temizle
    WidgetsBinding.instance.addPostFrameCallback((_) { // [cite: 147]
      if (mounted) { // [cite: 147]
        context.read<CustomerProvider>().clearSelection(); // [cite: 147]
      }
    });
    super.dispose(); // [cite: 147]
  }

  void _handleSearch(String query) { // [cite: 147]
    if (query.isEmpty) { // [cite: 147]
      context.read<CustomerProvider>().clearSearch(); // [cite: 148]
    } else {
      context.read<CustomerProvider>().searchCustomers(query); // [cite: 148]
    }
  }

  // 🔥 YENİ METOT: Atama dialog'u [cite: 148]
  void _showAssignDialog() {
    final customerProvider = context.read<CustomerProvider>(); // [cite: 148]
    final userProvider = context.read<UserProvider>(); // [cite: 148]
    final selectedCount = customerProvider.selectedCustomerIds.length; // [cite: 148]

    showDialog( // [cite: 148]
      context: context, // [cite: 148]
      builder: (dialogContext) { // [cite: 148]
        return AlertDialog( // [cite: 148]
          title: Text('$selectedCount Müşteriyi Ata'), // [cite: 148]
          content: SizedBox( // [cite: 148]
            width: double.maxFinite, // [cite: 148]
            child: ListView.builder( // [cite: 148]
              shrinkWrap: true, // [cite: 148]
              itemCount: userProvider.salesReps.length, // [cite: 148]
              itemBuilder: (context, index) { // [cite: 149]
                final rep = userProvider.salesReps[index]; // [cite: 149]
                return ListTile( // [cite: 149]
                  title: Text(rep.fullName), // [cite: 149]
                  onTap: () async { // [cite: 149]
                    Navigator.of(dialogContext).pop(); // Dialog'u kapat [cite: 149]
                    final success = await customerProvider.assignCustomers(rep.id); // [cite: 149]
                    if (mounted) { // [cite: 150]
                      ScaffoldMessenger.of(context).showSnackBar( // [cite: 150]
                        SnackBar( // [cite: 150]
                          content: Text(success // [cite: 150]
                              ? 'Müşteriler başarıyla atandı' // [cite: 150]
                              : customerProvider.errorMessage ?? 'İşlem başarısız'), // [cite: 150]
                          backgroundColor: success ? Colors.green : Colors.red, // [cite: 151]
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [ // [cite: 151]
            TextButton( // [cite: 151, 152]
              onPressed: () => Navigator.of(dialogContext).pop(), // [cite: 152]
              child: const Text('İptal'), // [cite: 152]
            ),
          ],
        );
      },
    );
  }


  // 🔥 GÜNCELLENMİŞ: AppBar artık dinamik [cite: 152]
  AppBar _buildAppBar(BuildContext context, CustomerProvider provider) {
    final isManager = context.read<AuthProvider>().isSalesManager; // [cite: 152]

    if (provider.isSelectionMode) { // [cite: 152]
      return AppBar( // [cite: 152]
        leading: IconButton( // [cite: 152]
          icon: const Icon(Icons.close), // [cite: 152]
          onPressed: () => provider.clearSelection(), // [cite: 152]
        ),
        title: Text('${provider.selectedCustomerIds.length} seçildi'), // [cite: 152]
        actions: [ // [cite: 153]
          // Sadece yöneticiler atama yapabilir
          if (isManager) // [cite: 153]
            TextButton( // [cite: 153]
              onPressed: _showAssignDialog, // [cite: 153]
              child: const Text('ATA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // [cite: 153]
            ),
        ],
      );
    }

    final isHotLeadsActive = provider.listType == CustomerListType.hotLeads; // [cite: 153]
    return AppBar( // [cite: 153]
      title: Text(isHotLeadsActive ? 'Sıcak Müşteriler' : 'Tüm Müşteriler'), // [cite: 153]
      actions: [ // [cite: 153]
        Tooltip( // [cite: 153, 154]
          message: isHotLeadsActive ? 'Tüm Müşterileri Göster' : 'Sıcak Müşterileri Göster', // [cite: 154]
          child: IconButton( // [cite: 154]
            icon: Icon( // [cite: 154]
              isHotLeadsActive ? Icons.local_fire_department : Icons.local_fire_department_outlined, // [cite: 154]
              color: isHotLeadsActive ? Colors.redAccent : null, // [cite: 154]
            ),
            onPressed: () { // [cite: 154]
              final newType = isHotLeadsActive ? CustomerListType.all : CustomerListType.hotLeads; // [cite: 154]
              provider.setListType(newType); // [cite: 154]
            },
          ), // [cite: 155]
        ),
        IconButton( // [cite: 155]
          icon: const Icon(Icons.filter_list), // [cite: 155]
          onPressed: () { // [cite: 155]
            ScaffoldMessenger.of(context).showSnackBar( // [cite: 155]
              const SnackBar(content: Text('Filtreleme yakında eklenecek')), // [cite: 155]
            );
          },
        ),
      ],
      bottom: PreferredSize( // [cite: 155]
        preferredSize: const Size.fromHeight(60), // [cite: 155]
        child: Padding( // [cite: 155]
          padding: const EdgeInsets.all(8.0), // [cite: 155]
          child: TextField( // [cite: 156]
            controller: _searchController, // [cite: 156]
            decoration: InputDecoration( // [cite: 156]
              hintText: 'Müşteri ara...', // [cite: 156]
              prefixIcon: const Icon(Icons.search), // [cite: 156]
              suffixIcon: _searchController.text.isNotEmpty // [cite: 156]
                  ? IconButton( // [cite: 156]
                icon: const Icon(Icons.clear), // [cite: 156]
                onPressed: () { // [cite: 156]
                  _searchController.clear(); // [cite: 156]
                  _handleSearch(''); //
                },
              )
                  : null, //
              filled: true, //
              // ------------------------------------
              // DEĞİŞİKLİK BURADA: fillColor kaldırıldı
              // fillColor: Colors.white, //  <-- BU SATIRI KALDIRIN VEYA YORUM SATIRI YAPIN
              // ------------------------------------
              border: OutlineInputBorder( //
                borderRadius: BorderRadius.circular(30), //
                borderSide: BorderSide.none, //
              ), // [cite: 158]
            ),
            onChanged: _handleSearch, // [cite: 158]
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>(); // [cite: 158]

    return Scaffold( // [cite: 158]
      appBar: _buildAppBar(context, provider), // [cite: 158]
      drawer: const CustomDrawer(), // [cite: 158]
      body: Consumer<CustomerProvider>( // [cite: 158]
        builder: (context, provider, _) { // [cite: 158]
          if (provider.isLoading && provider.customers.isEmpty) { // [cite: 158]
            return const Center(child: CircularProgressIndicator()); // [cite: 158]
          }

          if (provider.errorMessage != null && provider.customers.isEmpty) { // [cite: 159]
            return Center( // [cite: 159]
              child: Column( // [cite: 159]
                mainAxisAlignment: MainAxisAlignment.center, // [cite: 159]
                children: [ // [cite: 159]
                  const Icon(Icons.error_outline, size: 64, color: Colors.red), // [cite: 159]
                  const SizedBox(height: 16), // [cite: 159]
                  Text( // [cite: 159]
                    provider.errorMessage!, // [cite: 160]
                    style: const TextStyle(color: Colors.red), // [cite: 160]
                    textAlign: TextAlign.center, // [cite: 160]
                  ),
                  const SizedBox(height: 16), // [cite: 160]
                  ElevatedButton( // [cite: 160]
                    onPressed: () => provider.loadCustomers(refresh: true), // [cite: 160]
                    child: const Text('Tekrar Dene'), // [cite: 161]
                  ),
                ],
              ),
            );
          }

          if (provider.customers.isEmpty) { // [cite: 161]
            return Center( // [cite: 161]
              child: Column( // [cite: 161]
                mainAxisAlignment: MainAxisAlignment.center, // [cite: 161]
                children: [ // [cite: 161]
                  Icon( // [cite: 162]
                    Icons.people_outline, // [cite: 162]
                    size: 64, // [cite: 162]
                    color: Colors.grey[400], // [cite: 162]
                  ),
                  const SizedBox(height: 16), // [cite: 162]
                  Text( // [cite: 162]
                    provider.listType == CustomerListType.hotLeads ? 'Sıcak müşteri bulunamadı' : 'Henüz müşteri yok', // [cite: 162]
                    style: TextStyle( // [cite: 163]
                      fontSize: 18, // [cite: 163]
                      color: Colors.grey[600], // [cite: 163]
                    ),
                  ),
                  const SizedBox(height: 8), // [cite: 163]
                  Text( // [cite: 163]
                    'Yeni müşteri eklemek için + butonuna basın', // [cite: 164]
                    style: TextStyle(color: Colors.grey[500]), // [cite: 164]
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator( // [cite: 164]
            onRefresh: () => provider.loadCustomers(refresh: true), // [cite: 164]
            child: ListView.builder( // [cite: 164]
              controller: _scrollController, // [cite: 165]
              padding: const EdgeInsets.all(16), // [cite: 165]
              itemCount: provider.customers.length + (provider.hasMore ? 1 : 0), // [cite: 165]
              itemBuilder: (context, index) { // [cite: 165]
                if (index == provider.customers.length) { // [cite: 165]
                  return const Center( // [cite: 165]
                    child: Padding( // [cite: 165]
                      padding: EdgeInsets.all(16.0), // [cite: 165]
                      child: CircularProgressIndicator(), // [cite: 166]
                    ),
                  );
                }

                final customer = provider.customers[index]; // [cite: 166]
                return CustomerCard( // [cite: 166]
                  customer: customer, // [cite: 166]
                  isSelected: provider.isCustomerSelected(customer.id), // [cite: 166]
                  onLongPress: () { // [cite: 167]
                    provider.toggleSelection(customer.id); // [cite: 167]
                  },
                  onTap: () { // [cite: 167]
                    if (provider.isSelectionMode) { // [cite: 167]
                      provider.toggleSelection(customer.id); // [cite: 167]
                    } else {
                      context.go('/customers/${customer.id}'); // [cite: 167]
                    }
                  }, // [cite: 168]
                );
              },
            ),
          );
        },
      ),
      // 🔥 GÜNCELLEME: Seçim modunda FAB'ı gizle [cite: 168]
      floatingActionButton: context.watch<CustomerProvider>().isSelectionMode // [cite: 168]
          ? null // [cite: 168]
          : FloatingActionButton( // [cite: 168]
        onPressed: () => context.go('/customers/new'), // [cite: 168]
        child: const Icon(Icons.add), // [cite: 168]
      ),
    );
  }
}
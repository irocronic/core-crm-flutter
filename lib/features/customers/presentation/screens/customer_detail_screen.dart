// lib/features/customers/presentation/screens/customer_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../users/presentation/providers/user_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/note_provider.dart';
import '../widgets/note_list_widget.dart';
import '../widgets/note_form_dialog.dart';
import '../widgets/activity_form_dialog.dart';
import '../widgets/customer_timeline_widget.dart';
// **** YENİ IMPORT ****
import '../widgets/customer_sales_list_widget.dart';
// EKLENEN KOD: CustomDrawer bileşenini içe aktarma
import '../../../../shared/widgets/custom_drawer.dart';
// **** YENİ IMPORT SONU ****
import '../../data/models/customer_model.dart';


class CustomerDetailScreen extends StatefulWidget {
  final int customerId;
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // **** GÜNCELLEME: Sekme sayısı 4'e çıkarıldı ****
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection); // FAB kontrolü için listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = context.read<CustomerProvider>();
      customerProvider.loadCustomerDetail(widget.customerId);
      customerProvider.loadCustomerTimeline(widget.customerId);
      context.read<NoteProvider>().loadNotesByCustomer(widget.customerId);
      context.read<UserProvider>().loadSalesReps();
    });
  }

  // **** YENİ: FAB görünürlüğünü kontrol etmek için ****
  void _handleTabSelection() {
    if (mounted) {
      setState(() {}); // Tab değiştiğinde FAB'ı güncellemek için rebuild tetikle
    }
  }
  // **** YENİ SONU ****

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Listener'ı kaldır
    _tabController.dispose();
    super.dispose();
  }

  void _showAddActivityDialog(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => ActivityFormDialog(
        customerId: customer.id,
        onSuccess: () {
          context.read<CustomerProvider>().loadCustomerTimeline(widget.customerId);
          context.read<CustomerProvider>().loadCustomerDetail(widget.customerId);
        },
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => NoteFormDialog(
        customerId: widget.customerId,
        onSuccess: () {
          context.read<NoteProvider>().loadNotesByCustomer(widget.customerId);
        },
      ),
    );
  }

  void _showTransferDialog() {
    final customerProvider = context.read<CustomerProvider>();
    final userProvider = context.read<UserProvider>();
    final customerName = customerProvider.selectedCustomer?.fullName ?? 'Müşteri';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('"$customerName" Transfer Et'),
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
                    final success = await customerProvider.transferCustomer(widget.customerId, rep.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Müşteri başarıyla transfer edildi'
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: const Text(
          'Bu müşteriyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final provider = context.read<CustomerProvider>();
              final success = await provider.deleteCustomer(widget.customerId);

              if (mounted) {
                if (success) {
                  context.go('/customers');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Müşteri silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Silinemedi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
    final isManager = context.watch<AuthProvider>().isSalesManager;
    return Scaffold(
      // EKLENEN KOD: CustomDrawer buraya eklenmiştir.
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Müşteri Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/customers/${widget.customerId}/edit');
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              if (isManager)
                const PopupMenuItem(
                  value: 'transfer',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Transfer Et'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
              if (value == 'transfer') {
                _showTransferDialog();
              }
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
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
                ],
              ),
            );
          }

          final customer = provider.selectedCustomer;
          if (customer == null) {
            return const Center(child: Text('Müşteri bulunamadı'));
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(child: _buildHeaderCard(customer)),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(icon: Icon(Icons.timeline), text: 'Zaman Tüneli'),
                        Tab(icon: Icon(Icons.person), text: 'Detaylar'),
                        Tab(icon: Icon(Icons.note_alt), text: 'Notlar'),
                        // **** YENİ SEKME ****
                        Tab(icon: Icon(Icons.point_of_sale), text: 'Satışlar'),
                        // **** YENİ SEKME SONU ****
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // 1. Zaman Tüneli Sekmesi
                const CustomerTimelineWidget(),
                // 2. Detaylar Sekmesi
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _buildSection(
                        context,
                        title: 'İletişim Bilgileri',
                        icon: Icons.contact_phone,
                        children: [
                          _buildInfoRow(
                            context,
                            icon: Icons.phone,
                            label: 'Telefon',
                            value: customer.phoneNumber,
                          ),
                          if (customer.email != null)
                            _buildInfoRow(
                              context,
                              icon: Icons.email,
                              label: 'E-posta',
                              value: customer.email!,
                            ),
                        ],
                      ),
                      _buildSection(
                        context,
                        title: 'Müşteri Bilgileri',
                        icon: Icons.info,
                        children: [
                          _buildInfoRow(
                            context,
                            icon: Icons.source,
                            label: 'Kaynak',
                            value: customer.sourceDisplay ?? customer.source,
                          ),
                          if (customer.interestedIn != null)
                            _buildInfoRow(
                              context,
                              icon: Icons.home,
                              label: 'İlgilendiği Tipler',
                              value: customer.interestedIn!,
                            ),
                          if (customer.budgetMin != null || customer.budgetMax != null)
                            _buildInfoRow(
                              context,
                              icon: Icons.attach_money,
                              label: 'Bütçe',
                              value:
                              '${customer.budgetMin != null ? CurrencyFormatter.format(customer.budgetMin!) : ''} - ${customer.budgetMax != null ? CurrencyFormatter.format(customer.budgetMax!) : ''}',
                            ),
                          if (customer.assignedToName != null)
                            _buildInfoRow(
                              context,
                              icon: Icons.person,
                              label: 'Atanan',
                              value: customer.assignedToName!,
                            ),
                        ],
                      ),
                      _buildSection(
                        context,
                        title: 'Sistem Bilgileri',
                        icon: Icons.info_outline,
                        children: [
                          _buildInfoRow(
                            context,
                            icon: Icons.person_add,
                            label: 'Oluşturan',
                            value: customer.createdByName ?? '-',
                          ),
                          _buildInfoRow(
                            context,
                            icon: Icons.calendar_today,
                            label: 'Oluşturulma',
                            value: DateFormatter.formatDateTime(customer.createdAt),
                          ),
                          _buildInfoRow(
                            context,
                            icon: Icons.update,
                            label: 'Güncelleme',
                            value: DateFormatter.formatDateTime(customer.updatedAt),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                // 3. Notlar Sekmesi
                Consumer<NoteProvider>(
                  builder: (context, noteProvider, _) {
                    return NoteListWidget(
                      notes: noteProvider.notes,
                      isLoading: noteProvider.isLoading,
                    );
                  },
                ),
                // **** YENİ GÖRÜNÜM ****
                CustomerSalesListWidget(customerId: widget.customerId),
                // **** YENİ GÖRÜNÜM SONU ****
              ],
            ),
          );
        },
      ),
      // **** GÜNCELLEME: FAB görünürlüğü tab index'e göre ayarlandı ****
      floatingActionButton: (_tabController.index == 0 || // Zaman Tüneli
          _tabController.index == 1 || // Detaylar
          _tabController.index == 2)   // Notlar
          ? FloatingActionButton(
        onPressed: () {
          final customer = context.read<CustomerProvider>().selectedCustomer;
          if (customer != null) {
            if (_tabController.index == 2) {
              _showAddNoteDialog();
            } else {
              _showAddActivityDialog(customer);
            }
          }
        },
        child: const Icon(Icons.add),
        tooltip: _tabController.index == 2 ? 'Not Ekle' : 'Aktivite Ekle',
      )
          : null, // Satışlar sekmesinde FAB gizli
    );
  }

  Widget _buildHeaderCard(CustomerModel customer) {
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
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              customer.fullName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            customer.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (customer.leadStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: customer.leadStatusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                customer.leadStatusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
        Widget? action,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (action != null) action,
                ],
              ),
              const Divider(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// TabBar'ı SliverAppBar içinde sabitlemek için helper class
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
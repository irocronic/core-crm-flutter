// lib/features/properties/presentation/screens/properties_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/property_provider.dart';
import '../widgets/property_card.dart';
// EKLENEN KOD: CustomDrawer bileşenini içe aktarma
import '../../../../shared/widgets/custom_drawer.dart';
// ✨ YENİ IMPORT: AuthProvider'ı ekliyoruz ✨
import '../../../auth/presentation/providers/auth_provider.dart';


class PropertiesListScreen extends StatefulWidget {
  final int projectId;
  final String? projectName;

  const PropertiesListScreen({
    super.key,
    required this.projectId,
    this.projectName,
  });

  @override
  State<PropertiesListScreen> createState() => _PropertiesListScreenState();
}

class _PropertiesListScreenState extends State<PropertiesListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PropertyProvider>();
      // ✅ GÜNCELLEME: clearFilters() çağrısını kaldırıyoruz.
      // Sadece filterByProject çağırmak, diğer filtreleri de temizleyip
      // doğru isteği başlatacaktır.
      provider.filterByProject(widget.projectId);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        final provider = context.read<PropertyProvider>();
        if (provider.hasMore && !provider.isLoadingMore) {
          provider.loadProperties();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<PropertyProvider>().searchProperties(query);
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<PropertyProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              title: const Text('Duruma Göre Filtrele'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusFilterRadio(provider, 'Tümü', null),
                  _buildStatusFilterRadio(provider, 'Satılabilir', 'SATILABILIR'),
                  _buildStatusFilterRadio(provider, 'Rezerve', 'REZERVE'),
                  _buildStatusFilterRadio(provider, 'Satıldı', 'SATILDI'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    provider.filterByStatus(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Filtreyi Temizle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusFilterRadio(PropertyProvider provider, String title, String? value) {
    return RadioListTile<String?>(
      title: Text(title),
      value: value,
      groupValue: provider.filterStatus,
      onChanged: (newValue) {
        provider.filterByStatus(newValue);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✨ AuthProvider'ı burada watch ile dinliyoruz ✨
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      // EKLENEN KOD: CustomDrawer buraya eklenmiştir.
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(widget.projectName ?? 'Gayrimenkuller'),
        actions: [
          // ✨ YENİ BUTON (Sadece Admin görebilir) ✨
          if (authProvider.isAdmin)
            IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: 'Toplu Yükleme (CSV)',
              onPressed: () {
                context.go('/properties/bulk-upload');
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showStatusFilterDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Mülk ara (Blok, No, Oda)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PropertyProvider>().searchProperties('');
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
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.properties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.properties.isEmpty) {
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
                    onPressed: () => provider.filterByProject(widget.projectId),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (provider.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Bu projede mülk bulunamadı',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.filterByProject(widget.projectId),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.properties.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.properties.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final property = provider.properties[index];
                return PropertyCard(
                  property: property,
                  onTap: () => context.go('/properties/${property.id}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/properties/new'),
        tooltip: 'Yeni Gayrimenkul Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
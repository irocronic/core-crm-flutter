// lib/features/properties/presentation/screens/properties_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
// Gerekli import eklendi
import 'package:flutter/services.dart'; // FilteringTextInputFormatter için

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
      // Sadece initState'te bir kere proje filtresi uygulanır
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
    // Proje filtresini koruyarak arama yap
    final provider = context.read<PropertyProvider>();
    provider.searchProperties(query);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true, // İçeriğin sığması için
        builder: (context) {
          // Ayrı bir widget'a taşıdık
          return const PropertyFilterDialog();
        });
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(widget.projectName ?? 'Gayrimenkuller'),
        actions: [
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
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
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
                    // filterByProject yerine refresh çağırmak daha mantıklı olabilir
                    onPressed: () => provider.loadProperties(refresh: true),
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
                    'Bu kriterlere uygun mülk bulunamadı', // Mesaj güncellendi
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  // Filtre uygulanmışsa temizleme butonu
                  if (provider.filterStatus != null ||
                      provider.filterPropertyType != null ||
                      provider.filterRoomCount != null ||
                      provider.filterFacade != null ||
                      provider.filterMinArea != null ||
                      provider.filterMaxArea != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Filtreleri temizlerken proje filtresini koru
                          provider.clearFilters(); // Bu artık loadProperties'i çağırıyor
                          // provider.filterByProject(widget.projectId); // Bu satır gereksiz
                        },
                        child: const Text('Filtreleri Temizle'),
                      ),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh yaparken mevcut filtreleri koruyarak yükle
              await provider.loadProperties(refresh: true);
            },
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
      floatingActionButton: (authProvider.isAdmin || authProvider.isSalesManager)
          ? FloatingActionButton(
        onPressed: () => context.go('/properties/new'),
        tooltip: 'Yeni Gayrimenkul Ekle',
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

// PropertyFilterDialog widget'ı
class PropertyFilterDialog extends StatefulWidget {
  const PropertyFilterDialog({super.key});

  @override
  State<PropertyFilterDialog> createState() => _PropertyFilterDialogState();
}

class _PropertyFilterDialogState extends State<PropertyFilterDialog> {
  // Geçici state'ler
  String? _tempStatus;
  String? _tempPropertyType;
  String? _tempRoomCount;
  String? _tempFacade;
  final TextEditingController _minAreaController = TextEditingController();
  final TextEditingController _maxAreaController = TextEditingController();

  // Sabit listeler
  final List<String> _propertyTypes = ['DAIRE', 'VILLA', 'OFIS'];
  final List<String> _roomCounts = ['1+0', '1+1', '2+1', '3+1', '4+1', '5+1', '5+2', 'Diğer'];
  final List<String> _facades = ['GUNEY', 'KUZEY', 'DOGU', 'BATI', 'GUNEY_DOGU', 'GUNEY_BATI', 'KUZEY_DOGU', 'KUZEY_BATI'];

  @override
  void initState() {
    super.initState();
    // Mevcut filtreleri al
    final provider = context.read<PropertyProvider>();
    _tempStatus = provider.filterStatus;
    _tempPropertyType = provider.filterPropertyType;
    _tempRoomCount = provider.filterRoomCount;
    _tempFacade = provider.filterFacade;
    _minAreaController.text = provider.filterMinArea?.toStringAsFixed(0) ?? '';
    _maxAreaController.text = provider.filterMaxArea?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }


  // *** GÜNCELLEME: _applyFilters metodu ***
  void _applyFilters() {
    final provider = context.read<PropertyProvider>();
    final double? minArea = _minAreaController.text.isNotEmpty ? double.tryParse(_minAreaController.text) : null;
    final double? maxArea = _maxAreaController.text.isNotEmpty ? double.tryParse(_maxAreaController.text) : null;

    // Min/Max kontrolü
    if (minArea != null && maxArea != null && minArea > maxArea) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Min m² değeri Max m² değerinden büyük olamaz.'), backgroundColor: Colors.orange),
      );
      return; // Filtreleri uygulama
    }

    // Provider'a yeni applyAllFilters metodunu çağırarak filtreleri uygula
    provider.applyAllFilters(
      status: _tempStatus,
      propertyType: _tempPropertyType,
      roomCount: _tempRoomCount,
      facade: _tempFacade,
      minArea: minArea,
      maxArea: maxArea,
    );


    Navigator.pop(context); // Bottom sheet'i kapat
  }
  // *** GÜNCELLEME SONU ***

  // *** GÜNCELLEME: _clearFilters metodu ***
  void _clearFilters() {
    // Geçici state'leri sıfırla
    setState(() {
      _tempStatus = null;
      _tempPropertyType = null;
      _tempRoomCount = null;
      _tempFacade = null;
      _minAreaController.clear();
      _maxAreaController.clear();
    });
    // Provider'daki filtreleri temizle
    final provider = context.read<PropertyProvider>();
    provider.clearFilters(); // Bu artık loadProperties'i çağıracak

    // Proje filtresini tekrar uygula (eğer proje listesindeysek)
    // Bu kontrol gereksiz olabilir çünkü clearFilters artık proje ID'sini koruyor.
    // Ancak emin olmak için bırakılabilir veya kaldırılabilir.
    // if (provider.filterProjectId != null) {
    //   provider.filterByProject(provider.filterProjectId);
    // }
    Navigator.pop(context); // Bottom sheet'i kapat
  }
  // *** GÜNCELLEME SONU ***

  @override
  Widget build(BuildContext context) {
    // Dropdown item'larını oluştururken null değeri için 'Tümü' seçeneği ekle
    List<DropdownMenuItem<String?>> buildDropdownItems(List<String> items, {String? firstItemLabel = 'Tümü'}) {
      List<DropdownMenuItem<String?>> menuItems = [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(firstItemLabel ?? 'Seçiniz'),
        ),
      ];
      menuItems.addAll(items.map((String value) {
        return DropdownMenuItem<String?>(
          value: value,
          // Backend'den display name gelmiyorsa, basit bir dönüşüm yapabiliriz
          child: Text(_translateValue(value) ?? value),
        );
      }).toList());
      return menuItems;
    }

    List<DropdownMenuItem<String?>> buildStatusDropdownItems() {
      return [
        const DropdownMenuItem<String?>(value: null, child: Text('Tümü')),
        const DropdownMenuItem<String?>(value: 'SATILABILIR', child: Text('Satılabilir')),
        const DropdownMenuItem<String?>(value: 'REZERVE', child: Text('Rezerve')),
        const DropdownMenuItem<String?>(value: 'SATILDI', child: Text('Satıldı')),
        const DropdownMenuItem<String?>(value: 'PASIF', child: Text('Pasif')),
      ];
    }

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, // Klavye için boşluk
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView( // Kaydırma eklendi
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filtrele', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Durum Filtresi (Dropdown)
            DropdownButtonFormField<String?>(
              value: _tempStatus,
              decoration: const InputDecoration(labelText: 'Durum', border: OutlineInputBorder()),
              items: buildStatusDropdownItems(),
              onChanged: (value) => setState(() => _tempStatus = value),
            ),
            const SizedBox(height: 16),

            // Tip Filtresi (Dropdown)
            DropdownButtonFormField<String?>(
              value: _tempPropertyType,
              decoration: const InputDecoration(labelText: 'Mülk Tipi', border: OutlineInputBorder()),
              items: buildDropdownItems(_propertyTypes, firstItemLabel: 'Tüm Tipler'),
              onChanged: (value) => setState(() => _tempPropertyType = value),
            ),
            const SizedBox(height: 16),

            // Oda Sayısı Filtresi (Dropdown)
            DropdownButtonFormField<String?>(
              value: _tempRoomCount,
              decoration: const InputDecoration(labelText: 'Oda Sayısı', border: OutlineInputBorder()),
              items: buildDropdownItems(_roomCounts, firstItemLabel: 'Tüm Oda Sayıları'),
              onChanged: (value) => setState(() => _tempRoomCount = value),
            ),
            const SizedBox(height: 16),

            // Cephe Filtresi (Dropdown)
            DropdownButtonFormField<String?>(
              value: _tempFacade,
              decoration: const InputDecoration(labelText: 'Cephe', border: OutlineInputBorder()),
              items: buildDropdownItems(_facades, firstItemLabel: 'Tüm Cepheler'),
              onChanged: (value) => setState(() => _tempFacade = value),
            ),
            const SizedBox(height: 16),

            // m² Aralığı (İki TextFormField)
            Text('Net Alan Aralığı (m²)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Min m²',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true), // Ondalıklı girişe izin ver
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))], // Sayı ve nokta
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Max m²',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true), // Ondalıklı girişe izin ver
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))], // Sayı ve nokta
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Temizle'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Filtrele'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Basit bir çeviri fonksiyonu (ihtiyaç olursa genişletilebilir)
  String? _translateValue(String? value) {
    const translations = {
      'DAIRE': 'Daire',
      'VILLA': 'Villa',
      'OFIS': 'Ofis',
      'GUNEY': 'Güney',
      'KUZEY': 'Kuzey',
      'DOGU': 'Doğu',
      'BATI': 'Batı',
      'GUNEY_DOGU': 'Güney-Doğu',
      'GUNEY_BATI': 'Güney-Batı',
      'KUZEY_DOGU': 'Kuzey-Doğu',
      'KUZEY_BATI': 'Kuzey-Batı',
    };
    return translations[value] ?? value;
  }
}
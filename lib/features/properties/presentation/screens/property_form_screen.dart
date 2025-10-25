// lib/features/properties/presentation/screens/property_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../providers/property_provider.dart';
import '../../data/models/project_model.dart';
// EKLENEN KOD: CustomDrawer bileşenini içe aktarma
import '../../../../shared/widgets/custom_drawer.dart';

class PropertyFormScreen extends StatefulWidget {
  final int? propertyId;

  const PropertyFormScreen({
    super.key,
    this.propertyId,
  });

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _blockController = TextEditingController();
  final _floorController = TextEditingController();
  final _unitNumberController = TextEditingController();
  final _grossAreaController = TextEditingController();
  final _netAreaController = TextEditingController();
  final _cashPriceController = TextEditingController();
  final _installmentPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  // GÜNCELLEME: Artık proje seçildiğinde otomatik dolacaklar
  final _islandController = TextEditingController();
  final _parcelController = TextEditingController();

  // Dropdown values
  int? _selectedProjectId;
  String _selectedPropertyType = 'DAIRE';
  String _selectedStatus = 'SATILABILIR';
  String _selectedFacade = 'GUNEY';
  String _selectedRoomCount = '1+1';

  bool get isEditing => widget.propertyId != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PropertyProvider>();
    provider.loadProjects(); // Load projects for the dropdown

    if (isEditing) {
      _isLoading = true;
      _loadPropertyData();
    }
  }

  void _loadPropertyData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PropertyProvider>();
      await provider.loadPropertyDetail(widget.propertyId!);

      final property = provider.selectedProperty;
      if (property != null && mounted) {
        // Projeyi de bulup state'e atayalım ki otomatik doldurma çalışsın
        final selectedProject = provider.projects.firstWhere(
              (p) => p.id == property.project.id,
          orElse: () => ProjectModel(id: 0, name: '', block: null), // Default değer eklendi
        );

        setState(() {
          _selectedProjectId = property.project.id;
          // Otomatik doldurma
          _islandController.text = selectedProject.island ?? '';
          _parcelController.text = selectedProject.parcel ?? '';
          _blockController.text = property.block.isNotEmpty ? property.block : (selectedProject.block ?? '');

          _floorController.text = property.floor.toString();
          _unitNumberController.text = property.unitNumber;
          _grossAreaController.text = property.grossAreaM2.toString();
          _netAreaController.text = property.netAreaM2.toString();
          _cashPriceController.text = property.cashPrice.toStringAsFixed(0);
          _installmentPriceController.text =
              property.installmentPrice?.toStringAsFixed(0) ?? '';
          _descriptionController.text = property.description ?? '';
          _selectedPropertyType = property.propertyType;
          _selectedStatus = property.status;
          _selectedFacade = property.facade;
          _selectedRoomCount = property.roomCount;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Gayrimenkul bilgileri yüklenemedi.');
      }
    });
  }

  @override
  void dispose() {
    _blockController.dispose();
    _floorController.dispose();
    _unitNumberController.dispose();
    _grossAreaController.dispose();
    _netAreaController.dispose();
    _cashPriceController.dispose();
    _installmentPriceController.dispose();
    _descriptionController.dispose();
    _islandController.dispose();
    _parcelController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // GÜNCELLEME: island ve parcel artık gönderilmiyor
    final data = <String, dynamic>{
      'project': _selectedProjectId,
      'block': _blockController.text.trim(),
      'floor': int.tryParse(_floorController.text.trim()),
      'unit_number': _unitNumberController.text.trim(),
      'gross_area_m2': double.tryParse(_grossAreaController.text.trim()),
      'net_area_m2': double.tryParse(_netAreaController.text.trim()),
      'cash_price': double.tryParse(_cashPriceController.text.trim()),
      'installment_price': _installmentPriceController.text.trim().isNotEmpty
          ? double.tryParse(_installmentPriceController.text.trim())
          : null,
      'description': _descriptionController.text.trim(),
      // 'island': _islandController.text.trim(), // Kaldırıldı
      // 'parcel': _parcelController.text.trim(), // Kaldırıldı
      'property_type': _selectedPropertyType,
      'status': _selectedStatus,
      'facade': _selectedFacade,
      'room_count': _selectedRoomCount,
    };

    final provider = context.read<PropertyProvider>();
    bool success = false;

    if (isEditing) {
      success = await provider.updateProperty(widget.propertyId!, data);
    } else {
      success = await provider.createProperty(data);
    }

    if (!mounted) return;

    if (success) {
      // ✅ HATA DÜZELTMESİ: Geri gidilebiliyorsa pop yap, gidilemiyorsa ana sayfaya yönlendir.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/properties');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isEditing ? 'Gayrimenkul güncellendi' : 'Gayrimenkul eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'İşlem başarısız oldu');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyProvider>();

    return Scaffold(
      // EKLENEN KOD: CustomDrawer buraya eklenmiştir.
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title:
        Text(isEditing ? 'Gayrimenkulü Düzenle' : 'Yeni Gayrimenkul Ekle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Project Dropdown
              DropdownButtonFormField<int>(
                value: _selectedProjectId,
                decoration: const InputDecoration(
                    labelText: 'Proje *',
                    prefixIcon: Icon(Icons.business)),
                items: provider.projects.map((ProjectModel project) {
                  return DropdownMenuItem<int>(
                    value: project.id,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                    if (value != null) {
                      final selectedProject = provider.projects.firstWhere((p) => p.id == value);
                      _islandController.text = selectedProject.island ?? '';
                      _parcelController.text = selectedProject.parcel ?? '';
                      _blockController.text = selectedProject.block ?? '';
                    } else {
                      _islandController.clear();
                      _parcelController.clear();
                      _blockController.clear();
                    }
                  });
                },
                validator: (value) =>
                value == null ? 'Lütfen bir proje seçin' : null,
              ),
              const SizedBox(height: 16),
              // GÜNCELLEME: Ada, Pafta ve Blok bilgileri readOnly
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _islandController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Ada'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _parcelController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Pafta'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Block and Unit Number
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _blockController,
                      decoration:
                      const InputDecoration(labelText: 'Blok *'),
                      validator: (value) =>
                          Validators.required(value, fieldName: 'Blok'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitNumberController,
                      decoration:
                      const InputDecoration(labelText: 'Daire No *'),
                      validator: (value) => Validators.required(value,
                          fieldName: 'Daire No'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Floor and Room Count
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _floorController,
                      decoration: const InputDecoration(labelText: 'Kat *'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          Validators.numeric(value, fieldName: 'Kat'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRoomCount,
                      decoration:
                      const InputDecoration(labelText: 'Oda Sayısı *'),
                      items: [
                        '1+0',
                        '1+1',
                        '2+1',
                        '3+1',
                        '4+1',
                        '5+1',
                        '5+2',
                        'Diğer'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedRoomCount = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Areas
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _grossAreaController,
                      decoration: const InputDecoration(
                          labelText: 'Brüt Alan (m²) *',
                          suffixText: 'm²'),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.numeric(value,
                          fieldName: 'Brüt Alan'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _netAreaController,
                      decoration: const InputDecoration(
                          labelText: 'Net Alan (m²) *', suffixText: 'm²'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          Validators.numeric(value, fieldName: 'Net Alan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Prices
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cashPriceController,
                      decoration: const InputDecoration(
                          labelText: 'Peşin Fiyat (₺) *',
                          suffixText: '₺'),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.numeric(value,
                          fieldName: 'Peşin Fiyat'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _installmentPriceController,
                      decoration: const InputDecoration(
                          labelText: 'Vadeli Fiyat (₺)', suffixText: '₺'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Property Type and Facade
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPropertyType,
                      decoration:
                      const InputDecoration(labelText: 'Mülk Tipi *'),
                      items: const [
                        DropdownMenuItem(
                            value: 'DAIRE', child: Text('Daire')),
                        DropdownMenuItem(
                            value: 'VILLA', child: Text('Villa')),
                        DropdownMenuItem(
                            value: 'OFIS', child: Text('Ofis')),
                      ],
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedPropertyType = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFacade,
                      decoration:
                      const InputDecoration(labelText: 'Cephe *'),
                      items: const [
                        DropdownMenuItem(
                            value: 'GUNEY', child: Text('Güney')),
                        DropdownMenuItem(
                            value: 'KUZEY', child: Text('Kuzey')),
                        DropdownMenuItem(
                            value: 'DOGU', child: Text('Doğu')),
                        DropdownMenuItem(
                            value: 'BATI', child: Text('Batı')),
                        DropdownMenuItem(
                            value: 'GUNEY_DOGU',
                            child: Text('Güney-Doğu')),
                        DropdownMenuItem(
                            value: 'GUNEY_BATI',
                            child: Text('Güney-Batı')),
                        DropdownMenuItem(
                            value: 'KUZEY_DOGU',
                            child: Text('Kuzey-Doğu')),
                        DropdownMenuItem(
                            value: 'KUZEY_BATI',
                            child: Text('Kuzey-Batı')),
                      ],
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedFacade = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Durum *'),
                items: const [
                  DropdownMenuItem(
                      value: 'SATILABILIR', child: Text('Satılabilir')),
                  DropdownMenuItem(
                      value: 'REZERVE', child: Text('Rezerve')),
                  DropdownMenuItem(
                      value: 'SATILDI', child: Text('Satıldı')),
                  DropdownMenuItem(value: 'PASIF', child: Text('Pasif')),
                ],
                onChanged: (value) {
                  if (value != null)
                    setState(() => _selectedStatus = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _handleSubmit,
                  child: provider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Text(isEditing ? 'Güncelle' : 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
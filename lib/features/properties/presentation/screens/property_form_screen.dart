// lib/features/properties/presentation/screens/property_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // <-- YENİ: Görsel seçimi için eklendi
import 'dart:io'; // <-- YENİ: Dosya işlemleri için eklendi
import 'package:flutter/foundation.dart' show kIsWeb; // <-- YENİ: Web platformu kontrolü için eklendi
// **** YENİ ALAN ****
import 'package:flutter/services.dart'; // Sayısal formatlama için eklendi

import '../../../../core/utils/validators.dart';
import '../providers/property_provider.dart';
import '../../data/models/project_model.dart';
import '../../../../shared/widgets/custom_drawer.dart'; // EKLENEN KOD: CustomDrawer bileşenini içe aktarma
// YENİ IMPORT: PropertyImage modeli (görsel tipi için)
import '../../data/models/property_model.dart' show PropertyImage;
// YENİ IMPORT: SelectedImage artık data/models altında
import '../../data/models/selected_image.dart';

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
  final _islandController = TextEditingController();
  final _parcelController = TextEditingController();
  // **** YENİ KDV CONTROLLER'I ****
  final _vatRateController = TextEditingController(text: '20.0'); // Varsayılan KDV %20

  // Dropdown values
  int? _selectedProjectId;
  String _selectedPropertyType = 'DAIRE';
  String _selectedStatus = 'SATILABILIR';
  String _selectedFacade = 'GUNEY';
  String _selectedRoomCount = '1+1';

  // --- YENİ STATE'LER ---
  final ImagePicker _picker = ImagePicker();
  List<SelectedImage> _selectedImages = []; // Seçilen görselleri tutacak liste
  // --- YENİ STATE'LER SONU ---


  bool get isEditing => widget.propertyId != null;
  bool _isLoading = false;
  // GÜNCELLEME: Yükleniyor durumunu daha detaylı takip etmek için
  bool _isLoadingData = false; // Veri yükleme durumu
  bool _isSaving = false; // Kaydetme durumu

  @override
  void initState() {
    super.initState();
    final provider = context.read<PropertyProvider>();
    provider.loadProjects(); // Projeleri yükle

    if (isEditing) {
      // GÜNCELLEME: _isLoadingData olarak değiştirildi
      _isLoadingData = true;
      _loadPropertyData();
    }
  }

  void _loadPropertyData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PropertyProvider>();
      await provider.loadPropertyDetail(widget.propertyId!);

      final property = provider.selectedProperty;
      if (property != null && mounted) {
        final selectedProject = provider.projects.firstWhere(
              (p) => p.id == property.project.id,
          orElse: () => ProjectModel(id: 0, name: '', block: null),
        );

        setState(() {
          _selectedProjectId = property.project.id;
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
          // **** YENİ KDV ALANI YÜKLEME ****
          _vatRateController.text = property.vatRate.toStringAsFixed(2);
          // GÜNCELLEME: _isLoadingData olarak değiştirildi
          _isLoadingData = false;
          // Mevcut görselleri forma eklemeyeceğiz, düzenleme ekranında ayrı yönetilebilir.
        });
      } else if (mounted) {
        // GÜNCELLEME: _isLoadingData olarak değiştirildi
        setState(() => _isLoadingData = false);
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
    _vatRateController.dispose(); // **** YENİ CONTROLLER'I DISPOSE ET ****
    super.dispose();
  }

  // --- YENİ METOT: Görsel Seçme ---
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.addAll(
              pickedFiles.map((file) => SelectedImage(file: file)).toList()
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Görsel seçilemedi: $e');
    }
  }
  // --- YENİ METOT SONU ---

  // --- YENİ METOT: Görsel Kaldırma ---
  void _removeImage(int index) {
    if (mounted) {
      setState(() {
        _selectedImages.removeAt(index);
      });
    }
  }
  // --- YENİ METOT SONU ---

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

    // GÜNCELLEME: _isSaving olarak değiştirildi
    setState(() => _isSaving = true);

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
      'property_type': _selectedPropertyType,
      'status': _selectedStatus,
      'facade': _selectedFacade,
      'room_count': _selectedRoomCount,
      // **** YENİ KDV ALANI ****
      'vat_rate': double.tryParse(_vatRateController.text.trim().replaceAll(',', '.')) ?? 20.0,
    };

    final provider = context.read<PropertyProvider>();
    bool success = false;
    int? createdPropertyId; // Yeni oluşturulan mülkün ID'sini tutmak için

    try {
      if (isEditing) {
        success = await provider.updateProperty(widget.propertyId!, data);
        if (success) createdPropertyId = widget.propertyId; // Düzenlemede ID zaten var
      } else {
        success = await provider.createProperty(data);
        if (success) {
          // Başarıyla oluşturulduysa, son eklenen mülkün ID'sini al (varsayım: liste başa ekleniyor)
          if (provider.properties.isNotEmpty) {
            createdPropertyId = provider.properties.first.id;
          }
        }
      }

      // --- YENİ KISIM: Görselleri Yükleme ---
      if (success && createdPropertyId != null && _selectedImages.isNotEmpty) {
        // Doğrudan SelectedImage listesi gönder
        bool imageSuccess = await provider.uploadImages(createdPropertyId, _selectedImages);
        if (!imageSuccess && mounted) {
          // Görsel yükleme başarısız olursa kullanıcıyı bilgilendir ama işlem devam etsin
          _showErrorSnackBar(provider.errorMessage ?? 'Görseller yüklenirken bir sorun oluştu.');
          // Başarılı saymaya devam edebiliriz, mülk kaydedildi.
        }
      }
      // --- YENİ KISIM SONU ---

      if (!mounted) return;

      if (success) {
        if (context.canPop()) {
          context.pop();
        } else {
          // Normalde liste ekranına yönlendirir, ama detay daha mantıklı olabilir
          // context.go('/properties');
          if (createdPropertyId != null) {
            context.go('/properties/$createdPropertyId'); // Oluşturulan/güncellenen mülkün detayına git
          } else {
            context.go('/properties'); // Fallback
          }
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
    } catch (e) {
      _showErrorSnackBar('Hata: ${e.toString()}');
    } finally {
      if (mounted) {
        // GÜNCELLEME: _isSaving olarak değiştirildi
        setState(() => _isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyProvider>();

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title:
        Text(isEditing ? 'Gayrimenkulü Düzenle' : 'Yeni Gayrimenkul Ekle'),
      ),
      // GÜNCELLEME: _isLoadingData olarak değiştirildi
      body: _isLoadingData
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
                      // Projenin genel bloğu varsa ve mülk bloğu boşsa doldur
                      if(_blockController.text.trim().isEmpty) {
                        _blockController.text = selectedProject.block ?? '';
                      }
                    } else {
                      _islandController.clear();
                      _parcelController.clear();
                      // Proje seçimi kaldırılınca blok temizlenmeli mi? Karar verilmeli.
                      // _blockController.clear();
                    }
                  });
                },
                validator: (value) =>
                value == null ? 'Lütfen bir proje seçin' : null,
              ),
              const SizedBox(height: 16),
              // Ada, Pafta (ReadOnly)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _islandController,
                      readOnly: true, // Düzenlenemez
                      decoration: InputDecoration(
                        labelText: 'Ada',
                        filled: true, // Arkaplanı gri yapmak için
                        fillColor: Colors.grey[200], // Gri arkaplan
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _parcelController,
                      readOnly: true, // Düzenlenemez
                      decoration: InputDecoration(
                        labelText: 'Pafta',
                        filled: true, // Arkaplanı gri yapmak için
                        fillColor: Colors.grey[200], // Gri arkaplan
                      ),
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
                          labelText: 'Peşin Fiyat (KDV Hariç) *',
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
                          labelText: 'Vadeli Fiyat (KDV Hariç)', suffixText: '₺'),
                      keyboardType: TextInputType.number,
                      // Vadeli fiyat zorunlu değilse validator kaldırılabilir
                      // validator: (value) => ...
                    ),
                  ),
                ],
              ),

              // **** YENİ ALAN: KDV ORANI ****
              const SizedBox(height: 16),
              TextFormField(
                controller: _vatRateController,
                decoration: const InputDecoration(
                  labelText: 'KDV Oranı (%) *',
                  prefixIcon: Icon(Icons.percent),
                  suffixText: '%',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[\,\.]?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'KDV Oranı boş bırakılamaz';
                  }
                  final rate = double.tryParse(value.replaceAll(',', '.'));
                  if (rate == null || rate < 0 || rate > 100) {
                    return 'Geçerli bir oran girin (0-100)';
                  }
                  return null;
                },
              ),
              // **** YENİ ALAN SONU ****

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

              // --- YENİ KISIM: Görsel Ekleme ---
              const SizedBox(height: 24),
              _buildSectionTitle('Görseller'),
              _buildImagePickerSection(),
              // --- YENİ KISIM SONU ---

              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                // GÜNCELLEME: _isSaving olarak değiştirildi
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSubmit,
                  // GÜNCELLEME: _isSaving olarak değiştirildi
                  child: _isSaving
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

  // --- YENİ WIDGET: Başlık ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
  // --- YENİ WIDGET SONU ---

  // --- YENİ WIDGET: Görsel Seçme Alanı ---
  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Görsel Seç'),
        ),
        const SizedBox(height: 16),
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              final selectedImage = _selectedImages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(selectedImage.file.path, fit: BoxFit.cover)
                        : Image.file(File(selectedImage.file.path), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  // GÖRSEL TİPİ SEÇİMİ (Basit Dropdown)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedImage.type,
                          isDense: true,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18,),
                          dropdownColor: Colors.black87,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          items: const [
                            // Backend'deki ImageType enum değerleri ile eşleşmeli
                            DropdownMenuItem(value: 'INTERIOR', child: Text('İç Görünüm')),
                            DropdownMenuItem(value: 'EXTERIOR', child: Text('Dış Görünüm')),
                            DropdownMenuItem(value: 'FLOOR_PLAN', child: Text('Kat Planı')),
                            DropdownMenuItem(value: 'SITE_PLAN', child: Text('Vaziyet Planı')),
                          ],
                          onChanged: (value) {
                            if (value != null && mounted) {
                              setState(() {
                                selectedImage.type = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
// --- YENİ WIDGET SONU ---

} // Sınıf sonu
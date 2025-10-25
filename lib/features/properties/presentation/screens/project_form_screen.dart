// lib/features/properties/presentation/screens/project_form_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/validators.dart';
import '../providers/property_provider.dart';

class ProjectFormScreen extends StatefulWidget {
  // Düzenleme modu için proje ID'si alabilir (şimdilik sadece ekleme)
  // final int? projectId;

  const ProjectFormScreen({
    super.key,
    // this.projectId,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _islandController = TextEditingController();
  final _parcelController = TextEditingController();
  final _blockController = TextEditingController();

  // Image variables
  final ImagePicker _picker = ImagePicker();
  XFile? _projectImageFile;
  XFile? _sitePlanImageFile;

  // bool get isEditing => widget.projectId != null; // Düzenleme modu için
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // if (isEditing) {
    //   _loadProjectData(); // Düzenleme modu için veri yükleme
    // }
  }

  // void _loadProjectData() { // Düzenleme modu için
  //   // ... Proje verilerini yükleme kodu ...
  // }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _islandController.dispose();
    _parcelController.dispose();
    _blockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isProjectImage) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920, // İsteğe bağlı boyutlandırma
        maxHeight: 1080,
        imageQuality: 85, // İsteğe bağlı kalite
      );
      if (pickedFile != null) {
        setState(() {
          if (isProjectImage) {
            _projectImageFile = pickedFile;
          } else {
            _sitePlanImageFile = pickedFile;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Görsel seçilemedi: $e');
    }
  }

  void _showImageSourceActionSheet(BuildContext context, bool isProjectImage) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeriden Seç'),
                  onTap: () {
                    _pickImage(ImageSource.gallery, isProjectImage);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamerayı Kullan'),
                onTap: () {
                  _pickImage(ImageSource.camera, isProjectImage);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'location': _locationController.text.trim(),
      'description': _descriptionController.text.trim(),
      'island': _islandController.text.trim(),
      'parcel': _parcelController.text.trim(),
      'block': _blockController.text.trim(),
    };

    final provider = context.read<PropertyProvider>();
    bool success = false;

    // if (isEditing) {
    //   // success = await provider.updateProject(widget.projectId!, data, _projectImageFile, _sitePlanImageFile);
    // } else {
    success = await provider.createProject(
        data, _projectImageFile, _sitePlanImageFile);
    // }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Proje listesini yenilemek için provider'daki listeyi güncelle
      await provider.loadProjects();

      // **** GÜNCELLEME BAŞLANGICI ****
      if (context.canPop()) {
        context.pop(); // Form ekranını kapat (eğer geri gidilebiliyorsa)
      } else {
        // Eğer geri gidilemiyorsa (belki doğrudan bu sayfaya gelindi),
        // ana proje listesine yönlendir.
        context.go('/properties'); // Ana proje listesi route'u '/properties' varsayılıyor.
      }
      // **** GÜNCELLEME SONU ****

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            /*isEditing ? 'Proje güncellendi' :*/ 'Proje başarıyla oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'İşlem başarısız oldu');
    }
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

  Widget _buildImagePicker(
      String label, XFile? imageFile, bool isProjectImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showImageSourceActionSheet(context, isProjectImage),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: imageFile == null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 40, color: Colors.grey.shade600),
                const SizedBox(height: 8),
                Text('Görsel Seç',
                    style: TextStyle(color: Colors.grey.shade700)),
              ],
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: kIsWeb
                  ? Image.network(imageFile.path, fit: BoxFit.cover)
                  : Image.file(File(imageFile.path), fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(/*isEditing ? 'Projeyi Düzenle' :*/ 'Yeni Proje Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Proje Adı *'),
                validator: (value) =>
                    Validators.required(value, fieldName: 'Proje Adı'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Konum'),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _islandController,
                      decoration: const InputDecoration(labelText: 'Ada'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _parcelController,
                      decoration: const InputDecoration(labelText: 'Pafta'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _blockController,
                decoration: const InputDecoration(
                    labelText: 'Blok (Genel)',
                    hintText: 'Proje tek blok ise doldurun'),
              ),
              const SizedBox(height: 24),
              _buildImagePicker('Proje Görseli', _projectImageFile, true),
              const SizedBox(height: 16),
              _buildImagePicker(
                  'Proje Vaziyet Planı', _sitePlanImageFile, false),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Text(/*isEditing ? 'Güncelle' :*/ 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/features/auth/presentation/screens/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
// DÜZELTME 1: CustomDrawer içe aktarma yolu (Proje yapısına göre varsayılmıştır)
import '../../../../shared/widgets/custom_drawer.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool profileUpdateSuccess = false;
    bool imageUploadSuccess = true;

    // 1. Profil resmini yükle (eğer seçilmişse)
    if (_imageFile != null) {
      imageUploadSuccess = await authProvider.updateProfilePicture(_imageFile!);
      if (!imageUploadSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Profil fotoğrafı güncellenemedi'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Hata durumunda işlemi durdur
      }
    }

    // 2. Diğer profil bilgilerini güncelle
    final data = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_number': _phoneController.text.trim(),
    };

    // DÜZELTME 2: 'updateUserProfile' yerine 'updateProfile' kullanılıyor (Dosya 61'e göre)
    profileUpdateSuccess = await authProvider.updateProfile(data);

    if (!mounted) return;

    if (profileUpdateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil başarıyla güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Profil bilgileri güncellenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return 'U';
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    // DÜZELTME 3: 'avatarUrl' yerine 'profilePicture' kullanılıyor
    final imageUrl = user?.profilePicture;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
      ),
      // DÜZELTME 4: CustomDrawer eklendi
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profil Fotoğrafı
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      backgroundImage: _imageFile != null
                          ? (kIsWeb
                          ? NetworkImage(_imageFile!.path)
                          : FileImage(File(_imageFile!.path))) as ImageProvider?
                          : (imageUrl != null
                          ? NetworkImage(imageUrl)
                          : null),
                      child: _imageFile == null && imageUrl == null
                          ? Text(
                        _getInitial(user?.firstName),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Ad
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Ad',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                // DÜZELTME 5: 'validateName' yerine 'required' kullanılıyor (Dosya 9'a göre)
                validator: (value) => Validators.required(value, fieldName: 'Ad'),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              // Soyad
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Soyad',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                // DÜZELTME 6: 'validateName' yerine 'required' kullanılıyor (Dosya 9'a göre)
                validator: (value) => Validators.required(value, fieldName: 'Soyad'),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              // E-posta
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),

              const SizedBox(height: 16),

              // Telefon
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+90 555 123 45 67',
                ),
                keyboardType: TextInputType.phone,
                // DÜZELTME 7: 'Validators.validatePhone' yerine 'Validators.phone' kullanılıyor (Dosya 9'a göre)
                validator: Validators.phone,
              ),

              const SizedBox(height: 24),

              // Kaydet Butonu
              Consumer<AuthProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _handleSave,
                      child: provider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Kaydet',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: () {
                  context.push('/change-password');
                },
                icon: const Icon(Icons.lock_outline),
                label: const Text('Şifre Değiştir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
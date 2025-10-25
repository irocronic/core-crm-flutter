// lib/features/users/presentation/screens/user_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // ✅ YENİ
import '../providers/user_provider.dart';

class UserFormScreen extends StatefulWidget {
  final int? userId;

  const UserFormScreen({
    super.key,
    this.userId,
  });

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  // Dropdown values
  String _selectedRole = 'SATIS_TEMSILCISI';
  int? _selectedTeamId;
  bool _isActive = true;

  bool get isEditing => widget.userId != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    // Satış müdürlerini 'takım lideri' seçimi için yükle
    userProvider.loadSalesManagers();

    if (isEditing) {
      _isLoading = true;
      _loadUserData();
    }
  }

  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<UserProvider>();
      final user = await provider.loadUserById(widget.userId!);
      if (user != null && mounted) {
        setState(() {
          _usernameController.text = user.username;
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber ?? '';
          _selectedRole = user.role;
          _selectedTeamId = user.team;
          _isActive = user.isActiveEmployee;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Kullanıcı bilgileri yüklenemedi.');
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'username': _usernameController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'role': _selectedRole,
      'is_active_employee': _isActive,
      'team': _selectedTeamId,
    };

    if (!isEditing) {
      data['password'] = _passwordController.text;
      data['password_confirm'] = _passwordConfirmController.text;
    }

    final provider = context.read<UserProvider>();
    bool success = false;
    try {
      if (isEditing) {
        success = await provider.updateUser(widget.userId!, data);
      } else {
        success = await provider.createUser(data);
      }

      if (!mounted) return;

      if (success) {
        context.read<UserProvider>().loadUsers(); // Listeyi yenile
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Kullanıcı güncellendi' : 'Kullanıcı oluşturuldu'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackBar(provider.errorMessage ?? 'İşlem başarısız oldu');
      }
    } catch (e) {
      _showErrorSnackBar('Hata: ${e.toString()}');
    }
  }

  // ✅ YENİ EKLENDİ
  void _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Sil'),
        content: Text('"${_firstNameController.text} ${_lastNameController.text}" adlı kullanıcıyı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<UserProvider>();
      final success = await provider.deleteUser(widget.userId!);
      if (mounted) {
        if (success) {
          context.read<UserProvider>().loadUsers(); // Listeyi yenile
          context.go('/users'); // Liste ekranına dön
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı silindi'), backgroundColor: Colors.green));
        } else {
          _showErrorSnackBar(provider.errorMessage ?? 'Silme işlemi başarısız oldu');
        }
      }
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>(); // ✅ YENİ

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kullanıcıyı Düzenle' : 'Yeni Kullanıcı Ekle'),
        // ✅ YENİ: SİLME BUTONU
        actions: [
          if (isEditing && authProvider.isAdmin && widget.userId != authProvider.currentUser?.id)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _handleDelete,
              tooltip: 'Kullanıcıyı Sil',
            ),
        ],
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
              _buildSectionTitle('Temel Bilgiler'),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Kullanıcı Adı *'),
                validator: (value) => Validators.required(value, fieldName: 'Kullanıcı Adı'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Ad *'),
                      validator: (value) => Validators.required(value, fieldName: 'Ad'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Soyad *'),
                      validator: (value) => Validators.required(value, fieldName: 'Soyad'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-posta *'),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
              ),
              if (!isEditing) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Şifre *'),
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmController,
                  decoration: const InputDecoration(labelText: 'Şifre Tekrar *'),
                  obscureText: true,
                  validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionTitle('Rol ve Ekip Bilgileri'),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol *'),
                items: const [
                  DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                  DropdownMenuItem(value: 'SATIS_MUDUR', child: Text('Satış Müdürü')),
                  DropdownMenuItem(value: 'SATIS_TEMSILCISI', child: Text('Satış Temsilcisi')),
                  DropdownMenuItem(value: 'ASISTAN', child: Text('Asistan')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
              ),
              const SizedBox(height: 16),
              Consumer<UserProvider>(
                builder: (context, provider, _) {
                  return DropdownButtonFormField<int>(
                    value: _selectedTeamId,
                    decoration: const InputDecoration(labelText: 'Bağlı Olduğu Ekip Lideri'),
                    hint: const Text('Ekip Lideri Seçin'),
                    items: provider.salesManagers.map((manager) {
                      return DropdownMenuItem<int>(
                        value: manager.id,
                        child: Text(manager.fullName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedTeamId = value);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif Çalışan'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 32),
              Consumer<UserProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      child: provider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Text(isEditing ? 'Güncelle' : 'Kaydet'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
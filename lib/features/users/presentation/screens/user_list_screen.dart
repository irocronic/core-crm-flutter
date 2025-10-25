// lib/features/users/presentation/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // ✅ YENİ IMPORT
import '../providers/user_provider.dart';
import '../widgets/user_card.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/custom_drawer.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
  }

  // ✅ YENİ EKLENDİ: Silme Onay Dialog'u
  void _showDeleteDialog(int userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Sil'),
        content: Text('"$userName" adlı kullanıcıyı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<UserProvider>();
              final success = await provider.deleteUser(userId);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Kullanıcı silindi' : provider.errorMessage ?? 'Silme işlemi başarısız oldu'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
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
    // ✅ GÜNCELLEME: AuthProvider'ı burada dinleyerek rol bilgisine erişiyoruz
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Yönetimi'),
      ),
      drawer: const CustomDrawer(),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Kullanıcılar yükleniyor...');
          }

          if (provider.errorMessage != null) {
            return ErrorDisplay(
              message: provider.errorMessage!,
              onRetry: () => provider.loadUsers(),
            );
          }

          final users = provider.users;
          if (users.isEmpty) {
            return const Center(child: Text('Gösterilecek kullanıcı bulunamadı.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadUsers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                // ✅ YENİ: Kendini silme butonunu gösterme
                final bool canDelete = authProvider.isAdmin && user.id != currentUser?.id;

                return UserCard(
                  user: user,
                  onTap: () {
                    // Kullanıcı düzenlemeye sadece Admin veya Satış Müdürü gidebilir.
                    if (authProvider.isAdmin || authProvider.isSalesManager) {
                      context.go('/users/${user.id}/edit');
                    }
                  },
                  // ✅ YENİ: Silme fonksiyonu eklendi
                  onDelete: canDelete ? () => _showDeleteDialog(user.id, user.fullName) : null,
                );
              },
            ),
          );
        },
      ),
      // ✅ GÜNCELLEME: FloatingActionButton'ı sadece Admin görebilir
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton(
        onPressed: () {
          context.go('/users/new');
        },
        tooltip: 'Yeni Kullanıcı Ekle',
        child: const Icon(Icons.add),
      )
          : null, // Yetkisi yoksa butonu gösterme
    );
  }
}
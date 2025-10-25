// lib/shared/widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // 🔥 Güvenli initial alma fonksiyonu
  String _getInitial(String? name) {
    if (name == null || name.isEmpty) {
      return 'U'; // Default: User
    }
    return name.substring(0, 1).toUpperCase();
  }

  // 🔥 Güvenli full name alma fonksiyonu
  String _getFullName(String? firstName, String? lastName) {
    if ((firstName == null || firstName.isEmpty) &&
        (lastName == null || lastName.isEmpty)) {
      return 'Kullanıcı';
    }

    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    // ✅ YENİ: Rol kontrolleri
    final bool isManager = user?.isSalesManager ?? false;
    final bool isAdmin = user?.isAdmin ?? false;
    final bool isSalesRep = user?.isSalesRep ?? false; // 🔥 YENİ

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getInitial(user?.firstName), // 🔥 Güvenli çağrı
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            accountName: Text(
              _getFullName(user?.firstName, user?.lastName), // 🔥 Güvenli çağrı
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(user?.roleDisplay ?? 'Kullanıcı'),
          ),

          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
          ),

          const Divider(),

          // ✅ GÜNCELLEME: Yönetim Paneli Bölümü (Sadece Admin ve Yöneticiler için)
          if (isAdmin || isManager) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'YÖNETİM',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (isManager)
              ListTile(
                leading: const Icon(Icons.groups),
                title: const Text('Ekibim'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/my-team');
                },
              ),
            if (isAdmin || isManager)
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: const Text('Kullanıcı Yönetimi'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/users');
                },
              ),
            const Divider(),
          ],

          // CRM Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'CRM',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Müşteriler'),
            onTap: () {
              Navigator.pop(context);
              context.go('/customers');
            },
          ),

          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Randevular'),
            onTap: () {
              Navigator.pop(context);
              context.go('/appointments');
            },
          ),

          const Divider(),

          // Sales Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'SATIŞ',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home_work),
            title: const Text('Gayrimenkuller'),
            onTap: () {
              Navigator.pop(context);
              context.go('/properties');
            },
          ),

          // ✅ GÜNCELLEME: Sadece Admin ve Satış Müdürü görebilir
          if (isAdmin || isManager)
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.purple),
              title: const Text('Gayrimenkul İstatistikleri'),
              onTap: () {
                Navigator.pop(context);
                context.go('/properties/stats');
              },
            ),

          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Tüm Rezervasyonlar'),
            onTap: () {
              Navigator.pop(context);
              context.go('/reservations', extra: 'all');
            },
          ),

          // 🔥 YENİ LİNKLER (Sadece Satış Temsilcisi ve üstü görebilir)
          if (isSalesRep || isManager || isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.playlist_add_check_circle_outlined, color: Colors.green),
              title: const Text('Aktif Rezervasyonlarım'),
              onTap: () {
                Navigator.pop(context);
                context.go('/reservations', extra: 'active');
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale, color: Colors.blue),
              title: const Text('Satışlarım'),
              onTap: () {
                Navigator.pop(context);
                context.go('/reservations', extra: 'my-sales');
              },
            ),
          ],

          const Divider(),

          // ✅ GÜNCELLEME: Sadece Admin ve Satış Müdürü görebilir
          if (isAdmin || isManager)
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Raporlar'),
              onTap: () {
                Navigator.pop(context);
                context.go('/reports');
              },
            ),

          const Divider(),

          // Settings & Logout
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ayarlar sayfası yakında eklenecek'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Dialog'u kapat
              Navigator.pop(context); // Drawer'ı kapat

              await context.read<AuthProvider>().logout();

              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
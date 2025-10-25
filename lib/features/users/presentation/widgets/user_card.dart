// lib/features/users/presentation/widgets/user_card.dart
import 'package:flutter/material.dart';
import '../../../auth/data/models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // ✅ YENİ EKLENDİ

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onDelete, // ✅ YENİ EKLENDİ
  });

  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return 'U';
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: Text(
            _getInitial(user.firstName),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.roleDisplay ?? user.role),
            if (user.teamName != null)
              Text(
                'Ekip: ${user.teamName}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ GÜNCELLEME: onDelete callback'i varsa silme butonunu göster
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Kullanıcıyı Sil',
              ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
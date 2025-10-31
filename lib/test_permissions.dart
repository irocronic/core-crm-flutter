import 'package:flutter/material.dart';
import 'core/utils/permission_handler.dart';

class TestPermissionsScreen extends StatelessWidget {
  const TestPermissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İzin Testi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final granted = await PermissionHelper.requestStoragePermission(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      granted ? '✅ Depolama izni verildi' : '❌ İzin reddedildi',
                    ),
                  ),
                );
              },
              child: const Text('Depolama İzni İste'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final granted = await PermissionHelper.requestCameraPermission(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      granted ? '✅ Kamera izni verildi' : '❌ İzin reddedildi',
                    ),
                  ),
                );
              },
              child: const Text('Kamera İzni İste'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final permissions = await PermissionHelper.checkAllPermissions();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('İzin Durumu'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: permissions.entries.map((e) {
                        return Text(
                          '${e.key}: ${e.value ? "✅" : "❌"}',
                        );
                      }).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kapat'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Tüm İzinleri Kontrol Et'),
            ),
          ],
        ),
      ),
    );
  }
}
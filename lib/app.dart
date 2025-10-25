// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/routes.dart';
import 'config/theme.dart'; // Bu importun çalıştığından emin ol
import 'features/auth/presentation/providers/auth_provider.dart';

class RealtyFlowApp extends StatelessWidget {
  const RealtyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // ✅ GÜNCELLEME: MaterialApp.router'ın yapısı sadeleştirildi ve düzeltildi.
        return MaterialApp.router(
          title: 'RealtyFlow CRM',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme, // Artık AppTheme sınıfından erişiliyor
          darkTheme: AppTheme.darkTheme, // Artık AppTheme sınıfından erişiliyor
          themeMode: ThemeMode.system,

          // Routing (Basit ve doğru kullanım)
          routerConfig: AppRouter.router(authProvider),

          // Localization Delegates
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Supported Locales
          supportedLocales: const [
            Locale('tr', 'TR'), // Türkçe
            Locale('en', 'US'), // İngilizce
          ],

          // Varsayılan Locale
          locale: const Locale('tr', 'TR'),
        );
      },
    );
  }
}
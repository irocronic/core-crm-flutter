// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'config/constants.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/network/network_info.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/customers/presentation/providers/customer_provider.dart';
import 'features/customers/presentation/providers/activity_provider.dart';
import 'features/customers/presentation/providers/note_provider.dart';
import 'features/properties/presentation/providers/property_provider.dart';
import 'features/reservations/presentation/providers/reservation_provider.dart';
import 'features/appointments/presentation/providers/appointment_provider.dart';
import 'features/sales/presentation/providers/payment_provider.dart';
import 'features/contracts/data/services/contract_service.dart';
import 'features/contracts/presentation/providers/contract_provider.dart';
import 'features/reports/presentation/providers/sales_report_provider.dart';
import 'features/reports/domain/usecases/get_sales_reports.dart';
import 'features/reports/domain/usecases/get_sales_report_by_id.dart';
import 'features/reports/data/repositories/sales_report_repository_impl.dart';
import 'features/reports/data/datasources/sales_report_remote_datasource.dart';
import 'features/users/presentation/providers/user_provider.dart';

// Firebase Background Message Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('📩 Background Message: ${message.messageId}');
  print('📦 Data: ${message.data}');
  print('🔔 Notification: ${message.notification?.title}');
}

void main() async {
  // Flutter binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 RealtyFlow uygulaması başlatılıyor...');

  // Firebase başlat
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase başlatıldı');

    // Background message handler'ı kaydet
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Firebase Messaging background handler kaydedildi');

    // Bildirim servisini başlat
    await NotificationService.initialize();
    print('✅ Notification Service başlatıldı');
  } catch (e) {
    print('❌ Firebase başlatma hatası: $e');
  }

  // Secure Storage başlat
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  final storageService = SecureStorageService(secureStorage);
  print('✅ Secure Storage başlatıldı');

  // Dio instance oluştur
  final dio = Dio();
  print('✅ Dio başlatıldı');

  // API Client başlat
  final apiClient = ApiClient(
    dio: dio,
    secureStorage: storageService,
    baseUrl: ApiConstants.baseUrl,
  );
  print('✅ API Client başlatıldı (Base URL: ${ApiConstants.baseUrl})');

  // Network Info (İnternet bağlantı kontrolü)
  final networkInfo = NetworkInfoImpl(Connectivity());
  print('✅ Network Info başlatıldı');

  // ==========================================
  // 🔥 Sales Report Dependencies
  // ==========================================
  final salesReportRemoteDataSource = SalesReportRemoteDataSourceImpl(
    apiClient: apiClient,
  );

  final salesReportRepository = SalesReportRepositoryImpl(
    remoteDataSource: salesReportRemoteDataSource,
    networkInfo: networkInfo,
  );

  // ✅ Use Cases (Sadece backend'den veri çekmek için)
  final getSalesReportsUseCase = GetSalesReports(salesReportRepository);
  final getSalesReportByIdUseCase = GetSalesReportById(salesReportRepository);

  print('✅ Sales Report UseCases başlatıldı');

  // Uygulamayı başlat
  runApp(
    MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) {
            print('🔐 AuthProvider oluşturuluyor...');
            final authProvider = AuthProvider(apiClient, storageService);

            apiClient.setOnUnauthorizedCallback(() async {
              print('🔑 [ApiClient Callback] Token expired - logout yapılıyor');
              await authProvider.logout();
            });

            return authProvider;
          },
        ),

        // User Provider
        ChangeNotifierProvider(
          create: (context) {
            print('👨‍💼 UserProvider oluşturuluyor...');
            return UserProvider(apiClient);
          },
        ),

        // Customer Provider
        ChangeNotifierProvider(
          create: (context) {
            print('👥 CustomerProvider oluşturuluyor...');
            return CustomerProvider(
              apiClient,
              context.read<AuthProvider>(),
            );
          },
        ),

        // Activity Provider
        ChangeNotifierProvider(
          create: (context) {
            print('📋 ActivityProvider oluşturuluyor...');
            return ActivityProvider(
              apiClient,
              context.read<AuthProvider>(),
            );
          },
        ),

        // Note Provider
        ChangeNotifierProvider(
          create: (context) {
            print('📝 NoteProvider oluşturuluyor...');
            return NoteProvider(apiClient);
          },
        ),

        // Property Provider
        ChangeNotifierProvider(
          create: (context) {
            print('🏢 PropertyProvider oluşturuluyor...');
            return PropertyProvider(
              apiClient,
              context.read<AuthProvider>(),
            );
          },
        ),

        // Reservation Provider
        ChangeNotifierProvider(
          create: (context) {
            print('📝 ReservationProvider oluşturuluyor...');
            return ReservationProvider(
              apiClient,
              context.read<AuthProvider>(),
            );
          },
        ),

        // Appointment Provider
        ChangeNotifierProvider(
          create: (context) {
            print('📅 AppointmentProvider oluşturuluyor...');
            return AppointmentProvider(
              apiClient,
              context.read<AuthProvider>(),
            );
          },
        ),

        // Payment Provider
        ChangeNotifierProvider(
          create: (context) {
            print('💳 PaymentProvider oluşturuluyor...');
            return PaymentProvider(
              apiClient,
              context.read<AuthProvider>(),
            );
          },
        ),

        // Contract Provider
        ChangeNotifierProvider(
          create: (context) {
            print('📄 ContractProvider oluşturuluyor...');
            return ContractProvider(
              ContractService(apiClient),
            );
          },
        ),

        // Sales Report Provider (✅ Export artık Flutter'da yapılıyor)
        ChangeNotifierProvider(
          create: (context) {
            print('📊 SalesReportProvider oluşturuluyor...');
            return SalesReportProvider(
              repository: salesReportRepository,
              getSalesReportsUseCase: getSalesReportsUseCase,
              getSalesReportByIdUseCase: getSalesReportByIdUseCase,
              // ✅ exportSalesReportUseCase KALDIRILDI
              // Export işlemi artık Flutter tarafında yapılıyor (PdfExportService, ExcelExportService, CsvExportService)
            );
          },
        ),
      ],
      child: const RealtyFlowApp(),
    ),
  );

  print('✅ RealtyFlow uygulaması başlatıldı');
}
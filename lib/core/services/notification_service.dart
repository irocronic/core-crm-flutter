// lib/core/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    // 1. Uygulama terminated durumdayken bildirime tıklandığında
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationNavigation(message.data);
      }
    });

    // 2. Uygulama background'dayken bildirime tıklandığında
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationNavigation(message.data);
    });

    // 3. Uygulama foreground'dayken bildirim geldiğinde (isteğe bağlı)
    FirebaseMessaging.onMessage.listen((message) {
      print("🔔 Foreground'da bildirim alındı: ${message.notification?.title}");
      // Burada kullanıcıya bir in-app notification (örn: SnackBar) gösterebilirsiniz.
    });
  }

  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    print("📲 Bildirim verisi işleniyor: $data");
    final String? type = data['type'];
    if (type == null) return;

    // GoRouter'a erişmek için GlobalKey kullanıyoruz
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      print("❌ Navigasyon için context bulunamadı!");
      return;
    }

    try {
      switch (type) {
        case 'payment_reminder':
        case 'overdue_payment':
          final reservationId = data['reservation_id'];
          if (reservationId != null) {
            print("Navigasyon -> Ödeme Takibi, Rezervasyon ID: $reservationId");
            context.go('/reservations/$reservationId/payments');
          }
          break;

        case 'daily_report':
          final reportId = data['report_id'];
          if (reportId != null) {
            print("Navigasyon -> Rapor Detayı, Rapor ID: $reportId");
            context.go('/reports/$reportId');
          }
          break;

        case 'customer_assigned':
        case 'customer_transferred':
          final customerId = data['customer_id'];
          if (customerId != null) {
            print("Navigasyon -> Müşteri Detayı, Müşteri ID: $customerId");
            context.go('/customers/$customerId');
          }
          break;

        default:
          print("Tanımsız bildirim türü: $type");
          context.go('/dashboard');
      }
    } catch (e) {
      print("❌ Bildirim yönlendirme hatası: $e");
    }
  }
}
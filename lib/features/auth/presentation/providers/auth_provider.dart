// lib/features/auth/presentation/providers/auth_provider.dart
import 'dart:io';
// ✅ YENİ: Web platformu için importlar
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
//---
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorageService _storage;
  late final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // 🔥 YENİ: State değişkenleri
  int _todaysActivitiesCount = 0;
  int _todaysSalesCount = 0;
  // 🔥🔥🔥 YENİ EKLENDİ: Tüm istatistikleri tutacak map 🔥🔥🔥
  Map<String, dynamic>? _statistics;


  AuthProvider(this._apiClient, this._storage) {
    _authService = AuthService(_apiClient);
    _checkLoginStatus();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // 🔥 YENİ: Getters
  int get todaysActivitiesCount => _todaysActivitiesCount;
  int get todaysSalesCount => _todaysSalesCount;
  // 🔥🔥🔥 YENİ EKLENDİ: statistics getter 🔥🔥🔥
  Map<String, dynamic>? get statistics => _statistics;

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isSalesManager => _currentUser?.isSalesManager ?? false;
  bool get isSalesRep => _currentUser?.isSalesRep ?? false;
  bool get isAssistant => _currentUser?.isAssistant ?? false;

  // Check login status on app start
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _storage.isLoggedIn();
    if (isLoggedIn) {
      try {
        await loadUserProfile();
        // 🔥 YENİ: Profil yüklendikten sonra istatistikleri de yükle
        await getUserStatistics();
        _isAuthenticated = true;
      } catch (e) {
        await logout();
      }
    }
    notifyListeners();
  }

  // Login
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _authService.login(
        username: username,
        password: password,
      );
      await _storage.saveAccessToken(tokens['access']);
      await _storage.saveRefreshToken(tokens['refresh']);

      await loadUserProfile();
      // 🔥 YENİ: Login sonrası istatistikleri yükle
      await getUserStatistics();

      await _registerFcmToken();

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // Load User Profile
  Future<void> loadUserProfile() async {
    try {
      _currentUser = await _authService.getProfile();
      await _storage.saveUserId(_currentUser!.id.toString());
      await _storage.saveUserRole(_currentUser!.role);
      notifyListeners();
    } catch (e) {
      throw Exception('Profil yüklenemedi: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fcmToken = await _storage.getFcmToken();
      if (fcmToken != null) {
        await _authService.deactivateFcmToken(fcmToken);
      }

      await _authService.logout();
      await _storage.clearAll();

      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
      // 🔥 YENİ: İstatistikleri sıfırla
      _todaysActivitiesCount = 0;
      _todaysSalesCount = 0;
      // 🔥🔥🔥 YENİ EKLENDİ: statistics map'ini sıfırla 🔥🔥🔥
      _statistics = null;
    } catch (e) {
      await _storage.clearAll();
      _currentUser = null;
      _isAuthenticated = false;
      // 🔥 YENİ: İstatistikleri sıfırla
      _todaysActivitiesCount = 0;
      _todaysSalesCount = 0;
      // 🔥🔥🔥 YENİ EKLENDİ: statistics map'ini sıfırla 🔥🔥🔥
      _statistics = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.updateProfile(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ GÜNCELLEME: Profil Fotoğrafı Güncelleme Metodu
  // Artık `XFile` alıyor ve platforma göre `AuthService`'i çağırıyor.
  Future<bool> updateProfilePicture(XFile imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Web için: Dosyayı byte olarak oku
        final Uint8List fileBytes = await imageFile.readAsBytes();
        _currentUser = await _authService.updateProfilePicture(
          fileBytes: fileBytes,
          fileName: imageFile.name,
        );
      } else {
        // Mobil için: Dosya yolunu kullan
        _currentUser = await _authService.updateProfilePicture(
          filePath: imageFile.path,
          fileName: imageFile.name,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  // Change Password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 🔥 GÜNCELLEME: İstatistikleri alıp state'i günceller
  Future<void> getUserStatistics() async {
    try {
      final stats = await _authService.getUserStatistics();
      // 🔥🔥🔥 YENİ EKLENDİ: Tüm istatistik map'ini ata 🔥🔥🔥
      _statistics = stats;
      _todaysActivitiesCount = stats['todays_activities'] as int? ?? 0;
      _todaysSalesCount = stats['todays_sales'] as int? ?? 0;
      notifyListeners(); // State güncellendiği için dinleyicileri bilgilendir
    } catch (e) {
      _errorMessage = 'İstatistikler alınamadı: $e';
      _todaysActivitiesCount = 0; // Hata durumunda sıfırla
      _todaysSalesCount = 0; // Hata durumunda sıfırla
      // 🔥🔥🔥 YENİ EKLENDİ: statistics map'ini sıfırla 🔥🔥🔥
      _statistics = null;
      notifyListeners(); // Hata durumunda da bilgilendir
      // throw Exception('İstatistikler alınamadı: $e'); // Opsiyonel: Hatanın yukarıya fırlatılması
    }
  }

  // Register FCM Token
  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      await _storage.saveFcmToken(fcmToken);

      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      String deviceName = '';
      try {
        if (kIsWeb) {
          final webInfo = await deviceInfo.webBrowserInfo;
          deviceId = webInfo.vendor ?? 'unknown_web';
          deviceName = webInfo.browserName.name;
        } else if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
          deviceName = '${androidInfo.brand} ${androidInfo.model}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
          deviceName = '${iosInfo.name} ${iosInfo.model}';
        }
      } catch (e) {
        deviceId = 'unknown';
        deviceName = 'Unknown Device';
      }

      await _authService.registerFcmToken(
        registrationId: fcmToken,
        deviceId: deviceId,
        name: deviceName,
        type: kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios'),
      );
    } catch (e) {
      print('FCM token kaydedilemedi: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
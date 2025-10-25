import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../../config/constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // ============================================================
  // 🔥 GENEL METODLAR (Generic Methods)
  // ============================================================

  /// ✅ Secure Storage'dan değer oku
  /// [key] - Okunan key
  /// Returns: Depolanan değer veya null
  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) {
        debugPrint('📖 [SecureStorage] Read key: $key');
      }
      return value;
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error reading key "$key": $e');
      return null;
    }
  }

  /// ✅ Secure Storage'a değer yaz
  /// [key] - Yazılan key
  /// [value] - Yazılan değer
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      debugPrint('✅ [SecureStorage] Write key: $key');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error writing key "$key": $e');
    }
  }

  /// ✅ Secure Storage'dan değer sil
  /// [key] - Silinen key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      debugPrint('🗑️ [SecureStorage] Deleted key: $key');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error deleting key "$key": $e');
    }
  }

  /// ✅ Tüm verileri sil
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('🗑️ [SecureStorage] All data deleted');
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error deleting all data: $e');
    }
  }

  /// ✅ Key var mı kontrol et
  /// [key] - Kontrol edilen key
  /// Returns: true if key exists, false otherwise
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error checking key "$key": $e');
      return false;
    }
  }

  /// ✅ Tüm verileri oku
  /// Returns: Map of all key-value pairs
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('❌ [SecureStorage] Error reading all data: $e');
      return {};
    }
  }

  // ============================================================
  // 🔥 AUTH TOKEN METODLARI (Authentication)
  // ============================================================

  /// ✅ Access Token Kaydet
  /// [token] - JWT access token
  Future<void> saveAccessToken(String token) async {
    await write(StorageKeys.accessToken, token);
    debugPrint('🔐 [Auth] Access token saved');
  }

  /// ✅ Access Token Oku
  /// Returns: Stored access token or null
  Future<String?> getAccessToken() async {
    return await read(StorageKeys.accessToken);
  }

  /// ✅ Refresh Token Kaydet
  /// [token] - JWT refresh token
  Future<void> saveRefreshToken(String token) async {
    await write(StorageKeys.refreshToken, token);
    debugPrint('🔄 [Auth] Refresh token saved');
  }

  /// ✅ Refresh Token Oku
  /// Returns: Stored refresh token or null
  Future<String?> getRefreshToken() async {
    return await read(StorageKeys.refreshToken);
  }

  /// ✅ Her iki token'ı da kaydet
  /// [accessToken] - JWT access token
  /// [refreshToken] - JWT refresh token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
    debugPrint('🔐 [Auth] Both tokens saved successfully');
  }

  /// ✅ Her iki token'ı da sil
  Future<void> clearTokens() async {
    await Future.wait([
      delete(StorageKeys.accessToken),
      delete(StorageKeys.refreshToken),
    ]);
    debugPrint('🗑️ [Auth] Tokens cleared');
  }

  /// ✅ Token varsa kontrol et
  /// Returns: true if access token exists and is not empty
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // 👤 KULLANICI BİLGİSİ METODLARI (User Information)
  // ============================================================

  /// ✅ User ID Kaydet
  /// [userId] - User's unique identifier
  Future<void> saveUserId(String userId) async {
    await write(StorageKeys.userId, userId);
    debugPrint('👤 [User] User ID saved: $userId');
  }

  /// ✅ User ID Oku
  /// Returns: Stored user ID or null
  Future<String?> getUserId() async {
    return await read(StorageKeys.userId);
  }

  /// ✅ User Email Kaydet
  /// [email] - User's email address
  Future<void> saveUserEmail(String email) async {
    await write(StorageKeys.userEmail, email);
    debugPrint('📧 [User] Email saved: $email');
  }

  /// ✅ User Email Oku
  /// Returns: Stored user email or null
  Future<String?> getUserEmail() async {
    return await read(StorageKeys.userEmail);
  }

  /// ✅ User Name Kaydet
  /// [name] - User's full name
  Future<void> saveUserName(String name) async {
    await write(StorageKeys.userName, name);
    debugPrint('👤 [User] Name saved: $name');
  }

  /// ✅ User Name Oku
  /// Returns: Stored user name or null
  Future<String?> getUserName() async {
    return await read(StorageKeys.userName);
  }

  /// ✅ User Role Kaydet
  /// [role] - User's role (e.g., SATIS_TEMSILCISI, YONETICI)
  Future<void> saveUserRole(String role) async {
    await write(StorageKeys.userRole, role);
    debugPrint('🔑 [User] Role saved: $role');
  }

  /// ✅ User Role Oku
  /// Returns: Stored user role or null
  Future<String?> getUserRole() async {
    return await read(StorageKeys.userRole);
  }

  /// ✅ Tüm Kullanıcı Bilgisini Kaydet
  /// [userId] - User's unique identifier
  /// [email] - User's email address
  /// [name] - User's full name
  /// [role] - User's role
  Future<void> saveUserInfo({
    required String userId,
    required String email,
    required String name,
    required String role,
  }) async {
    await Future.wait([
      saveUserId(userId),
      saveUserEmail(email),
      saveUserName(name),
      saveUserRole(role),
    ]);
    debugPrint('👤 [User] All user information saved');
  }

  // ============================================================
  // 🔐 GİRİŞ DURUMU METODLARI (Login Status)
  // ============================================================

  /// ✅ Giriş Durumunu Ayarla
  /// [value] - true if logged in, false if logged out
  Future<void> setLoggedIn(bool value) async {
    await write(StorageKeys.isLoggedIn, value.toString());
    debugPrint('🔐 [Auth] Logged in status: $value');
  }

  /// ✅ Kullanıcı Giriş Yaptı Mı Kontrol Et
  /// Returns: true if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // 🔔 BİLDİRİM METODLARI (Notifications)
  // ============================================================

  /// ✅ FCM Token Kaydet
  /// [token] - Firebase Cloud Messaging token
  Future<void> saveFcmToken(String token) async {
    await write(StorageKeys.fcmToken, token);
    debugPrint('🔔 [Notification] FCM token saved');
  }

  /// ✅ FCM Token Oku
  /// Returns: Stored FCM token or null
  Future<String?> getFcmToken() async {
    return await read(StorageKeys.fcmToken);
  }

  /// ✅ FCM Token Sil
  Future<void> clearFcmToken() async {
    await delete(StorageKeys.fcmToken);
    debugPrint('🗑️ [Notification] FCM token cleared');
  }

  // ============================================================
  // 🎨 UYGULAMA AYARLARI METODLARI (App Preferences)
  // ============================================================

  /// ✅ Theme Kaydet
  /// [theme] - Theme name (e.g., 'light', 'dark')
  Future<void> saveTheme(String theme) async {
    await write(StorageKeys.theme, theme);
    debugPrint('🎨 [Preferences] Theme saved: $theme');
  }

  /// ✅ Theme Oku
  /// Returns: Stored theme or null
  Future<String?> getTheme() async {
    return await read(StorageKeys.theme);
  }

  /// ✅ Language Kaydet
  /// [language] - Language code (e.g., 'tr', 'en')
  Future<void> saveLanguage(String language) async {
    await write(StorageKeys.language, language);
    debugPrint('🌐 [Preferences] Language saved: $language');
  }

  /// ✅ Language Oku
  /// Returns: Stored language or null
  Future<String?> getLanguage() async {
    return await read(StorageKeys.language);
  }

  // ============================================================
  // 💾 CACHE METODLARI (Cache Management)
  // ============================================================

  /// ✅ Son Senkronizasyon Zamanını Kaydet
  /// [timestamp] - ISO 8601 formatted timestamp
  Future<void> saveLastSyncTime(String timestamp) async {
    await write(StorageKeys.lastSyncTime, timestamp);
    debugPrint('⏱️ [Cache] Last sync time saved: $timestamp');
  }

  /// ✅ Son Senkronizasyon Zamanını Oku
  /// Returns: Stored timestamp or null
  Future<String?> getLastSyncTime() async {
    return await read(StorageKeys.lastSyncTime);
  }

  // ============================================================
  // 🧹 TEMIZLEME METODLARI (Cleanup Methods)
  // ============================================================

  /// ✅ Sadece Auth Verilerini Temizle
  /// Tokens, user info, ve login status silinir
  Future<void> clearAuthData() async {
    await Future.wait([
      delete(StorageKeys.accessToken),
      delete(StorageKeys.refreshToken),
      delete(StorageKeys.userId),
      delete(StorageKeys.userEmail),
      delete(StorageKeys.userName),
      delete(StorageKeys.userRole),
      delete(StorageKeys.isLoggedIn),
    ]);
    debugPrint('🗑️ [Auth] Auth data cleared');
  }

  /// ✅ Tüm Verileri Temizle (Logout)
  /// Tüm depolanan veriler silinir
  Future<void> clearAll() async {
    await deleteAll();
    debugPrint('🗑️ [Storage] All data cleared');
  }

  /// ✅ Çıkış Yap (Logout Flow)
  /// Auth verilerini ve FCM tokenını sil
  Future<void> logout() async {
    await Future.wait([
      clearAuthData(),
      clearFcmToken(),
    ]);
    debugPrint('🚪 [Auth] User logged out successfully');
  }

  // ============================================================
  // 🔍 DEBUG METODLARI (Debug Methods)
  // ============================================================

  /// ✅ Tüm Storage Verilerini Yazdır (DEBUG ONLY)
  Future<void> printAllData() async {
    try {
      final allData = await readAll();
      debugPrint('=== 📦 [SecureStorage] All Data ===');
      allData.forEach((key, value) {
        // Sensitive veriler maskelensin
        final displayValue = _maskSensitiveData(key, value);
        debugPrint('$key: $displayValue');
      });
      debugPrint('=== End of Storage Data ===');
    } catch (e) {
      debugPrint('❌ Error printing storage data: $e');
    }
  }

  /// ✅ Hassas Verileri Maskeleme Helper
  String _maskSensitiveData(String key, String value) {
    if (key.contains('token') || key.contains('password')) {
      if (value.length > 8) {
        return '${value.substring(0, 4)}****${value.substring(value.length - 4)}';
      }
      return '****';
    }
    return value;
  }
}
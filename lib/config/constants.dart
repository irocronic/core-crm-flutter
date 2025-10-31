// lib/config/constants.dart

class ApiConstants {
  // static const String baseUrl = 'http://192.168.1.103:8000/api/v1';
  // static const String baseUrl = 'https://core-crm-ilk2.onrender.com/api/v1';
  static const String baseUrl = 'https://core-crm-ilk2.onrender.com/api/v1';

  // ==========================================
  // 🔥 Auth Endpoints
  // ==========================================
  static const String login = '/users/auth/login/';
  static const String logout = '/users/auth/logout/';
  static const String register = '/users/auth/register/';
  static const String refresh = '/users/auth/refresh/';
  static const String profile = '/users/profile/';
  static const String updateProfile = '/users/update_profile/';
  static const String changePassword = '/users/change_password/';
  static const String statistics = '/users/statistics/';
  static const String registerFcmDevice = '/users/fcm-devices/';
  static const String deactivateFcmDevice = '/users/fcm-devices/deactivate/';
  static const String deactivateAllFcmDevices = '/users/fcm-devices/deactivate_all/';

  static const String users = '/users/';
  static const String myTeam = '/users/my_team/';
  static const String salesReps = '/users/sales_reps/';

  // ==========================================
  // 🔥 Customer Endpoints
  // ==========================================
  static const String customers = '/crm/customers/';
  static const String myCustomers = '/crm/customers/my_customers/';
  static const String hotLeads = '/crm/customers/hot_leads/';
  static const String customerStats = '/crm/customers/statistics/';
  static const String assignCustomers = '/crm/customers/assign_customers/';
  static const String customerTimeline = '/crm/customers/{id}/timeline/';

  // ==========================================
  // 🔥 Activity Endpoints
  // ==========================================
  static const String activities = '/crm/activities/';
  static const String upcomingFollowUps = '/crm/activities/upcoming_followups/';

  // ==========================================
  // 🔥 Property Endpoints
  // ==========================================
  static const String properties = '/properties/';
  static const String availableProperties = '/properties/available/';
  static const String propertyStats = '/properties/stats/';
  static const String propertyStatistics = '/properties/statistics/';
  static const String projects = '/properties/projects/';

  // ==========================================
  // 🔥 Reservation Endpoints
  // ==========================================
  static const String reservations = '/sales/reservations/';
  static const String myReservations = '/sales/reservations/my_sales/';
  static const String activeReservations = '/sales/reservations/active/';
  static const String reservationStats = '/sales/reservations/stats/';

  // ==========================================
  // 🔥 Contract Endpoints
  // ==========================================
  static const String contracts = '/sales/contracts/';
  static const String myContracts = '/sales/contracts/my_contracts/';
  static const String contractStats = '/sales/contracts/stats/';
  static const String pendingContracts = '/sales/contracts/pending/';
  static const String signedContracts = '/sales/contracts/signed/';

  // ==========================================
  // 🔥 Sales Report Endpoints
  // ==========================================
  static const String reports = '/sales/reports/';
  static const String generateReport = '/sales/reports/generate/';

  /// ✅ YENİ: Export endpoint için helper metot
  /// Kullanım: ApiConstants.exportReport('123') => '/sales/reports/123/export/'
  static String exportReport(String reportId) => '/sales/reports/$reportId/export/';

  // ==========================================
  // 🔥 Appointment Endpoints
  // ==========================================
  static const String appointments = '/crm/appointments/';
  static const String todayAppointments = '/crm/appointments/today/';
  static const String upcomingAppointments = '/crm/appointments/upcoming/';
  static const String appointmentStats = '/crm/appointments/stats/';

  // ==========================================
  // 🔥 Notification Endpoints
  // ==========================================
  static const String fcmToken = '/users/fcm-devices/';
  static const String notifications = '/notifications/notifications/';
  static const String markAsRead = '/notifications/notifications/mark-as-read/';

  // ==========================================
  // 🔥 YENİ: Settings (Sales) Endpoints
  // ==========================================
  static const String sellerCompanies = '/sales/seller-companies/';
  static const String buyerDetails = '/sales/buyer-details/';
  static String buyerDetailsByCustomer(int customerId) => '/sales/buyer-details/by_customer/$customerId/';


  // ==========================================
  // ⏱️ Timeout Settings
  // ==========================================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 30);
}

class StorageKeys {
  // ============ AUTH STORAGE KEYS ============
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userRole = 'user_role';
  static const String isLoggedIn = 'is_logged_in';

  // ============ APP PREFERENCES STORAGE KEYS ============
  static const String theme = 'theme';
  static const String language = 'language';

  // ============ NOTIFICATION STORAGE KEYS ============
  static const String fcmToken = 'fcm_token';

  // ============ CACHE STORAGE KEYS ============
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedUserData = 'cached_user_data';
  static const String cachedCustomers = 'cached_customers';
}

class AppConfig {
  // Debug Mode
  static const bool debugMode = true;

  // App Version
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Token Expiry (hours)
  static const int tokenExpiryHours = 24;

  // Retry Configuration
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;

  // Cache Duration (minutes)
  static const int cacheDurationMinutes = 30;

  // Pagination
  static const int defaultPageSize = 20;
}

class UiConstants {
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Padding & Margin
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeHeading = 20.0;

  // Animation Durations (milliseconds)
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
}

class ErrorMessages {
  // Network Errors
  static const String networkError = 'İnternet bağlantısı kontrol edin';
  static const String serverError = 'Sunucu hatası oluştu';
  static const String timeoutError = 'İstek zaman aşımına uğradı';
  static const String unauthorizedError = 'Yetkilendirme başarısız oldu';
  static const String forbiddenError = 'Bu işlem için yetkiniz yok';
  static const String notFoundError = 'Kayıt bulunamadı';

  // Validation Errors
  static const String emptyFieldError = 'Bu alan boş bırakılamaz';
  static const String invalidEmailError = 'Geçerli bir e-posta girin';
  static const String invalidPhoneError = 'Geçerli bir telefon numarası girin';
  static const String passwordTooShortError = 'Şifre en az 6 karakter olmalı';
  static const String passwordMismatchError = 'Şifreler eşleşmiyor';

  // General Errors
  static const String unknownError = 'Bilinmeyen hata oluştu';
  static const String dataLoadError = 'Veri yüklenemedi';
  static const String dataSaveError = 'Veri kaydedilemedi';
  static const String dataDeleteError = 'Veri silinemedi';
  static const String operationCancelledError = 'İşlem iptal edildi';
}

class SuccessMessages {
  static const String loginSuccess = 'Giriş başarılı';
  static const String logoutSuccess = 'Çıkış başarılı';
  static const String dataSaveSuccess = 'Veri başarıyla kaydedildi';
  static const String dataDeleteSuccess = 'Veri başarıyla silindi';
  static const String dataUpdateSuccess = 'Veri başarıyla güncellendi';
  static const String operationSuccess = 'İşlem başarıyla tamamlandı';
}
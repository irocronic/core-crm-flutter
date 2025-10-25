// lib/features/customers/presentation/providers/activity_provider.dart
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/activity_service.dart';
// **** YENİ IMPORT ****
import '../../../../shared/models/pagination_model.dart';

class ActivityProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;
  late final ActivityService _activityService;

  ActivityProvider(this._apiClient, this._authProvider) {
    _activityService = ActivityService(_apiClient);
  }

  // State
  List<ActivityModel> _activities = [];
  List<ActivityModel> _upcomingFollowUps = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _meetingSubTypeResult;
  bool _isCheckingSubType = false;

  // **** YENİ DASHBOARD STATE'LERİ ****
  List<ActivityModel> _dashboardActivities = [];
  bool _isDashboardActivitiesLoading = false;
  String? _dashboardActivitiesError;
  DateTimeRange? _dashboardDateFilter;
  int _dashboardCurrentPage = 1;
  bool _dashboardHasMore = true;
  // **** YENİ DASHBOARD STATE'LERİ SONU ****

  // Getters
  List<ActivityModel> get activities => _activities;
  List<ActivityModel> get upcomingFollowUps => _upcomingFollowUps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get meetingSubTypeResult => _meetingSubTypeResult;
  bool get isCheckingSubType => _isCheckingSubType;

  // **** YENİ DASHBOARD GETTER'LARI ****
  List<ActivityModel> get dashboardActivities => _dashboardActivities;
  bool get isDashboardActivitiesLoading => _isDashboardActivitiesLoading;
  String? get dashboardActivitiesError => _dashboardActivitiesError;
  DateTimeRange? get dashboardDateFilter => _dashboardDateFilter;
  bool get dashboardHasMore => _dashboardHasMore;
  // **** YENİ DASHBOARD GETTER'LARI SONU ****

  Future<void> checkMeetingSubType(int customerId) async {
    _isCheckingSubType = true;
    _meetingSubTypeResult = null;
    notifyListeners();

    try {
      final existingMeetings = await _activityService.getActivitiesByCustomer(
        customerId,
        activityType: 'GORUSME',
        pageSize: 1,
      );

      _meetingSubTypeResult = existingMeetings.isNotEmpty ? 'Ara Gelen' : 'İlk Gelen';
      print('ℹ️ Alt Tür Kontrol Sonucu: $_meetingSubTypeResult');

    } catch (e) {
      print('❌ Alt tür kontrol hatası (Provider): $e');
      _meetingSubTypeResult = 'Hata: Kontrol Edilemedi';
      _errorMessage = 'Görüşme türü kontrol edilemedi: $e';
    } finally {
      _isCheckingSubType = false;
      notifyListeners();
    }
  }

  void clearMeetingSubTypeResult() {
    _meetingSubTypeResult = null;
    notifyListeners();
  }

  // **** YENİ METOT: Dashboard için Tüm Aktiviteleri Yükle ****
  Future<void> loadDashboardActivities({DateTimeRange? dateRange, bool refresh = false}) async {
    if (refresh) {
      _dashboardCurrentPage = 1;
      _dashboardHasMore = true;
      _dashboardActivities.clear();
      _dashboardDateFilter = dateRange; // Refresh ile filtre de sıfırlanabilir veya güncellenebilir
    }

    // Zaten yükleniyorsa veya daha fazla veri yoksa çık
    if (_isDashboardActivitiesLoading || !_dashboardHasMore) return;

    _isDashboardActivitiesLoading = true;
    _dashboardActivitiesError = null;
    // Eğer dateRange null değilse ve refresh değilse, filtreyi güncelle
    if (dateRange != null && !refresh) {
      _dashboardDateFilter = dateRange;
    }
    notifyListeners();

    try {
      final result = await _activityService.getAllActivities(
        page: _dashboardCurrentPage,
        startDate: _dashboardDateFilter?.start,
        endDate: _dashboardDateFilter?.end,
      );

      if (_dashboardCurrentPage == 1) {
        _dashboardActivities = result.results;
      } else {
        _dashboardActivities.addAll(result.results);
      }

      _dashboardHasMore = result.next != null;
      if (_dashboardHasMore) {
        _dashboardCurrentPage++;
      }

      // Tarihe göre sırala (en yeniden en eskiye)
      _dashboardActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    } catch (e) {
      _dashboardActivitiesError = 'Aktiviteler yüklenemedi: ${e.toString()}';
      if (_dashboardCurrentPage == 1) { // İlk sayfada hata olursa listeyi temizle
        _dashboardActivities = [];
      }
    } finally {
      _isDashboardActivitiesLoading = false;
      notifyListeners();
    }
  }
  // **** YENİ METOT SONU ****


  Future<void> loadUpcomingFollowUps() async {
    try {
      _upcomingFollowUps = await _activityService.getUpcomingFollowUps();
    } catch (e) {
      _upcomingFollowUps = [];
      debugPrint("Yaklaşan takipler yüklenemedi: $e");
    }
    notifyListeners();
  }

  Future<void> loadActivitiesByCustomer(int customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _activityService.getActivitiesByCustomer(customerId);
    } catch (e) {
      _errorMessage = e.toString();
      _activities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createActivity(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newActivity = await _activityService.createActivity(data);
      _activities.insert(0, newActivity);
      if (data.containsKey('next_follow_up_date')) {
        loadUpcomingFollowUps();
      }
      // **** YENİ: Dashboard listesini de güncelle ****
      _dashboardActivities.insert(0, newActivity);
      _dashboardActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // **** YENİ SONU ****
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> updateActivity(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedActivity = await _activityService.updateActivity(id, data);

      final index = _activities.indexWhere((a) => a.id == id);
      if (index != -1) {
        _activities[index] = updatedActivity;
      }
      loadUpcomingFollowUps();
      // **** YENİ: Dashboard listesini de güncelle ****
      final dashboardIndex = _dashboardActivities.indexWhere((a) => a.id == id);
      if (dashboardIndex != -1) {
        _dashboardActivities[dashboardIndex] = updatedActivity;
        _dashboardActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      // **** YENİ SONU ****
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteActivity(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _activityService.deleteActivity(id);
      _activities.removeWhere((a) => a.id == id);
      loadUpcomingFollowUps();
      // **** YENİ: Dashboard listesini de güncelle ****
      _dashboardActivities.removeWhere((a) => a.id == id);
      // **** YENİ SONU ****
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    // **** YENİ: Dashboard hatasını da temizle ****
    _dashboardActivitiesError = null;
    // **** YENİ SONU ****
    notifyListeners();
  }

  void clearActivities() {
    _activities = [];
    notifyListeners();
  }
}
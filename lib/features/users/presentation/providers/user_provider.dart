// lib/features/users/presentation/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/team_model.dart';
import '../../data/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final UserService _userService;

  UserProvider(this._apiClient) {
    _userService = UserService(_apiClient);
  }

  // State
  List<UserModel> _users = [];
  TeamModel? _team;
  List<UserModel> _salesReps = [];
  // ✅ YENİ: Formda kullanılacak satış müdürleri listesi
  List<UserModel> _salesManagers = [];
  UserModel? _selectedUser;
  // ✅ YENİ
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get users => _users;
  TeamModel? get team => _team;
  List<UserModel> get salesReps => _salesReps;
  // ✅ YENİ
  List<UserModel> get salesManagers => _salesManagers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Methods
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _userService.getUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ YENİ
  Future<UserModel?> loadUserById(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedUser = await _userService.getUserById(userId);
      return _selectedUser;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyTeam() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _team = await _userService.getMyTeam();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSalesReps() async {
    try {
      _salesReps = await _userService.getSalesReps();
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ✅ YENİ
  Future<void> loadSalesManagers() async {
    try {
      // getSalesReps() tüm satış temsilcilerini getirir,
      // ama bize sadece müdürler lazım. API'de buna özel bir endpoint
      // yoksa, tüm kullanıcıları çekip filtreleyebiliriz.
      // Şimdilik varsayımsal bir endpoint kullanalım, eğer yoksa getUsers() ile filtreleriz.
      final allUsers = await _userService.getUsers();
      _salesManagers = allUsers.where((user) => user.isSalesManager).toList();
    } catch (e) {
      _errorMessage = "Ekip liderleri yüklenemedi: $e";
    }
    notifyListeners();
  }

  // ✅ YENİ
  Future<bool> createUser(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _userService.createUser(data);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ YENİ
  Future<bool> updateUser(int userId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedUser = await _userService.updateUser(userId, data);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ YENİ EKLENDİ
  Future<bool> deleteUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _userService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSalesReps() {
    _salesReps = [];
    notifyListeners();
  }
}
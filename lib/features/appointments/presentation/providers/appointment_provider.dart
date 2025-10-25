// lib/features/appointments/presentation/providers/appointment_provider.dart
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/appointment_model.dart';
import '../../data/services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;
  late final AppointmentService _appointmentService;

  AppointmentProvider(this._apiClient, this._authProvider) {
    _appointmentService = AppointmentService(_apiClient);
  }

  // State
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _todayAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentModel> get todayAppointments => _todayAppointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  // Load Appointments
  Future<void> loadAppointments({DateTime? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _appointmentService.getAppointments(
        date: date?.toIso8601String().split('T')[0],
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Today's Appointments
  Future<void> loadTodayAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayAppointments = await _appointmentService.getTodayAppointments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select Date
  void selectDate(DateTime date) {
    _selectedDate = date;
    loadAppointments(date: date);
  }

  // Create Appointment
  Future<bool> createAppointment(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAppointment = await _appointmentService.createAppointment(data);
      _appointments.add(newAppointment);
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

  // Complete Appointment
  Future<bool> completeAppointment(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _appointmentService.completeAppointment(id);
      
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments.removeAt(index);
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

  // Cancel Appointment
  Future<bool> cancelAppointment(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _appointmentService.cancelAppointment(id);
      
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments.removeAt(index);
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

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
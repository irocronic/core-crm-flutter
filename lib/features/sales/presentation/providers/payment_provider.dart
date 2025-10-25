// lib/features/sales/presentation/providers/payment_provider.dart

import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/payment_model.dart';
import '../../data/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;
  late final PaymentService _paymentService;

  PaymentProvider(this._apiClient, this._authProvider) {
    _paymentService = PaymentService(_apiClient);
  }

  // State
  List<PaymentModel> _payments = [];
  List<PaymentModel> _pendingPayments = [];
  List<PaymentModel> _overduePayments = [];
  PaymentModel? _selectedPayment;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PaymentModel> get payments => _payments;
  List<PaymentModel> get pendingPayments => _pendingPayments;
  List<PaymentModel> get overduePayments => _overduePayments;
  PaymentModel? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load Payments (by reservation)
  Future<void> loadPaymentsByReservation(int reservationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _payments = await _paymentService.getPaymentsByReservation(reservationId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Pending Payments
  Future<void> loadPendingPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingPayments = await _paymentService.getPendingPayments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Overdue Payments
  Future<void> loadOverduePayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _overduePayments = await _paymentService.getOverduePayments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Payment Detail
  Future<void> loadPaymentDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPayment = await _paymentService.getPaymentById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Payment
  Future<bool> createPayment(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPayment = await _paymentService.createPayment(data);
      _payments.insert(0, newPayment);
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

  // Update Payment
  Future<bool> updatePayment(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedPayment = await _paymentService.updatePayment(id, data);
      
      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }
      
      if (_selectedPayment?.id == id) {
        _selectedPayment = updatedPayment;
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

  // Mark Payment as Paid
  Future<bool> markPaymentAsPaid({
    required int paymentId,
    required String paymentDate,
    required String paymentMethod,
    String? receiptNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedPayment = await _paymentService.markAsPaid(
        paymentId: paymentId,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
        receiptNumber: receiptNumber,
      );
      
      // Update in list
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }
      
      // Remove from pending/overdue lists
      _pendingPayments.removeWhere((p) => p.id == paymentId);
      _overduePayments.removeWhere((p) => p.id == paymentId);
      
      if (_selectedPayment?.id == paymentId) {
        _selectedPayment = updatedPayment;
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

  // Delete Payment
  Future<bool> deletePayment(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _paymentService.deletePayment(id);
      _payments.removeWhere((p) => p.id == id);
      _pendingPayments.removeWhere((p) => p.id == id);
      _overduePayments.removeWhere((p) => p.id == id);
      
      if (_selectedPayment?.id == id) {
        _selectedPayment = null;
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

  // Clear selected payment
  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }

  // Clear all payments
  void clearPayments() {
    _payments = [];
    _pendingPayments = [];
    _overduePayments = [];
    notifyListeners();
  }
}
// lib/features/customers/presentation/providers/note_provider.dart
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final NoteService _noteService;

  NoteProvider(this._apiClient) {
    _noteService = NoteService(_apiClient);
  }

  // State
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load Notes by Customer
  Future<void> loadNotesByCustomer(int customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = await _noteService.getNotesByCustomer(customerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Note
  Future<bool> createNote(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newNote = await _noteService.createNote(data);
      _notes.insert(0, newNote); // Yeni notu listenin başına ekle
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

  // Clear notes
  void clearNotes() {
    _notes = [];
    notifyListeners();
  }
}
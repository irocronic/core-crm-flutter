// lib/features/properties/presentation/widgets/add_document_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// YENİ IMPORT'LAR
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import '../providers/property_provider.dart';
import '../../../../core/utils/validators.dart';

class AddDocumentDialog extends StatefulWidget {
  final int propertyId;
  const AddDocumentDialog({super.key, required this.propertyId});

  @override
  State<AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<AddDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedDocType = 'DIGER';

  // GÜNCELLEME: Platforma özel state'ler
  File? _selectedFile; // Mobil için
  Uint8List? _selectedFileBytes; // Web için
  String? _selectedFileName; // Web için dosya adı

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        // GÜNCELLEME: Web için byte verisini okumayı etkinleştir
        withData: kIsWeb,
      );
      if (result != null) {
        setState(() {
          if (kIsWeb) {
            // Web platformunda byte ve isim al
            _selectedFileBytes = result.files.single.bytes;
            _selectedFileName = result.files.single.name;
            _selectedFile = null; // Mobil state'ini temizle
          } else {
            // Mobil platformda yol al
            _selectedFile = File(result.files.single.path!);
            _selectedFileName = result.files.single.name;
            _selectedFileBytes = null; // Web state'ini temizle
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dosya seçilemedi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // GÜNCELLEME: Dosyanın seçilip seçilmediğini platforma göre kontrol et
    if (_selectedFile == null && _selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir dosya seçin'), backgroundColor: Colors.red),
      );
      return;
    }

    final provider = context.read<PropertyProvider>();
    // GÜNCELLEME: Provider'a platforma göre doğru veriyi gönder
    final success = await provider.uploadDocument(
      propertyId: widget.propertyId,
      title: _titleController.text.trim(),
      docType: _selectedDocType,
      // Mobil ise path, değilse null gönder
      filePath: kIsWeb ? null : _selectedFile!.path,
      // Web ise byte, değilse null gönder
      fileBytes: kIsWeb ? _selectedFileBytes : null,
      // Her iki durumda da dosya adını gönder
      fileName: _selectedFileName!,
    );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Belge başarıyla yüklendi' : provider.errorMessage ?? 'Yükleme başarısız'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Belge Ekle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Belge Başlığı *'),
                validator: (value) => Validators.required(value, fieldName: 'Başlık'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDocType,
                decoration: const InputDecoration(labelText: 'Belge Tipi *'),
                items: const [
                  DropdownMenuItem(value: 'RUHSAT', child: Text('İnşaat Ruhsatı')),
                  DropdownMenuItem(value: 'TAPU', child: Text('Tapu')),
                  DropdownMenuItem(value: 'ISKAN', child: Text('İskan Belgesi')),
                  DropdownMenuItem(value: 'KAT_IRTIFAKI', child: Text('Kat İrtifakı')),
                  DropdownMenuItem(value: 'DIGER', child: Text('Diğer')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDocType = value);
                },
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFileName == null ? 'Dosya Seç' : 'Dosya Değiştir'),
              ),
              if (_selectedFileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _selectedFileName!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: context.watch<PropertyProvider>().isLoading ? null : _handleSubmit,
          child: const Text('Yükle'),
        ),
      ],
    );
  }
}
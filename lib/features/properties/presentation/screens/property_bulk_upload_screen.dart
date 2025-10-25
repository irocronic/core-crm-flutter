// lib/features/properties/presentation/screens/property_bulk_upload_screen.dart

import 'dart:convert'; //
import 'dart:io'; //
import 'package:flutter/foundation.dart' show kIsWeb; //
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart'; //
import 'package:csv/csv.dart'; //
import 'package:go_router/go_router.dart'; //
// YENİ IMPORT'LAR
import 'package:path_provider/path_provider.dart'; //
import 'package:universal_html/html.dart' as html; //
import 'package:open_file/open_file.dart'; //

import '../providers/property_provider.dart'; //

class PropertyBulkUploadScreen extends StatefulWidget {
  const PropertyBulkUploadScreen({super.key}); //

  @override
  State<PropertyBulkUploadScreen> createState() =>
      _PropertyBulkUploadScreenState(); //
}

class _PropertyBulkUploadScreenState extends State<PropertyBulkUploadScreen> {
  PlatformFile? _pickedFile; //
  bool _isProcessing = false; //
  String? _processingMessage; //

  Future<void> _pickCsvFile() async { //
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles( //
        type: FileType.custom, //
        allowedExtensions: ['csv'], //
        withData: true, // Dosya içeriğini byte olarak okumak için önemli //
      );

      if (result != null) { //
        setState(() { //
          _pickedFile = result.files.first; //
        });
      }
    } catch (e) { //
      _showErrorSnackBar('Dosya seçilirken bir hata oluştu: $e'); //
    }
  }

  Future<void> _handleUpload() async { //
    if (_pickedFile == null) { //
      _showErrorSnackBar('Lütfen önce bir CSV dosyası seçin.'); //
      return; //
    }

    setState(() { //
      _isProcessing = true; //
      _processingMessage = 'Dosya okunuyor ve veriler işleniyor...'; //
    });

    try {
      // Artık Flutter tarafında parse etmiyoruz, direkt backend'e gönderiyoruz.
      // PlatformFile objesini provider'a gönderelim.
      final provider = context.read<PropertyProvider>();

      setState(() { //
        _processingMessage = 'Dosya API\'ye yükleniyor...'; // Mesaj güncellendi
      });

      // Provider'a dosyayı yüklemesini söyle
      final success = await provider.uploadBulkPropertiesCsv(_pickedFile!); // <-- Yeni provider metodu

      if (mounted) { //
        if (success) { //
          ScaffoldMessenger.of(context).showSnackBar( //
            const SnackBar( //
              content: Text('Mülkler başarıyla eklendi!'), //
              backgroundColor: Colors.green, //
            ),
          );
          context.go('/properties'); //
        } else { //
          _showErrorSnackBar(provider.errorMessage ?? 'Toplu ekleme işlemi başarısız oldu.'); //
        }
      }
    } catch (e) { //
      _showErrorSnackBar('İşlem sırasında hata: ${e.toString()}'); //
    } finally {
      if (mounted) { //
        setState(() { //
          _isProcessing = false; //
          _processingMessage = null; //
        });
      }
    }
  }

  Future<void> _downloadSampleCsv() async { //
    // Provider üzerinden indirme işlemini başlat
    final provider = context.read<PropertyProvider>();
    setState(() {
      _isProcessing = true;
      _processingMessage = 'Örnek şablon indiriliyor...';
    });
    try {
      final success = await provider.downloadSampleCsv();
      if (!success && mounted) {
        _showErrorSnackBar(provider.errorMessage ?? 'Dosya indirilemedi.');
      }
      // Başarılı indirme mesajını provider halledebilir veya burada gösterilebilir.
      // Mobil için OpenFile ile açma seçeneği sunulabilir.
      else if (success && !kIsWeb && mounted) {
        // Provider'dan dosya yolunu alıp açmayı deneyebiliriz (opsiyonel)
        // if (provider.downloadedFilePath != null) {
        //   OpenFile.open(provider.downloadedFilePath);
        // }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Örnek dosya indirildi.')),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Örnek dosya indirilirken bir hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingMessage = null;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) { //
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar( //
      SnackBar( //
        content: Text(message), //
        backgroundColor: Colors.red, //
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //
      appBar: AppBar( //
        title: const Text('Toplu Mülk Ekle (CSV)'), //
      ),
      body: Center( //
        child: Padding( //
          padding: const EdgeInsets.all(24.0), //
          child: Column( //
            mainAxisAlignment: MainAxisAlignment.center, //
            crossAxisAlignment: CrossAxisAlignment.stretch, //
            children: [ //
              const Icon( //
                Icons.upload_file, //
                size: 80, //
                color: Colors.grey, //
              ),
              const SizedBox(height: 24), //
              const Text( //
                'CSV Dosyası Yükle', //
                textAlign: TextAlign.center, //
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), //
              ),
              const SizedBox(height: 8), //
              Text( //
                'Lütfen belirtilen formata uygun bir CSV dosyası seçin. Başlık satırı Django modelindeki alan adlarıyla eşleşmelidir.', //
                textAlign: TextAlign.center, //
                style: TextStyle(color: Colors.grey[600]), //
              ), //
              const SizedBox(height: 32), //
              OutlinedButton.icon( //
                onPressed: _isProcessing ? null : _pickCsvFile, //
                icon: const Icon(Icons.attach_file), //
                label: const Text('Dosya Seç'), //
                style: OutlinedButton.styleFrom( //
                  padding: const EdgeInsets.symmetric(vertical: 16), //
                ), //
              ), //
              if (_pickedFile != null) //
                Padding( //
                  padding: const EdgeInsets.only(top: 16.0), //
                  child: Text( //
                    'Seçilen dosya: ${_pickedFile!.name}', //
                    textAlign: TextAlign.center, //
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), //
                  ), //
                ),
              const SizedBox(height: 32), //
              ElevatedButton.icon( //
                onPressed: (_pickedFile == null || _isProcessing) ? null : _handleUpload, //
                icon: const Icon(Icons.cloud_upload), //
                label: const Text('Yükle ve Kaydet'), //
                style: ElevatedButton.styleFrom( //
                  padding: const EdgeInsets.symmetric(vertical: 16), //
                ),
              ),
              if (_isProcessing) //
                Padding( //
                  padding: const EdgeInsets.only(top: 24.0), //
                  child: Column( //
                    children: [ //
                      const CircularProgressIndicator(), //
                      const SizedBox(height: 16), //
                      Text(_processingMessage ?? 'İşleniyor...'), //
                    ],
                  ),
                ),

              const Spacer(), // Araya boşluk ekler //

              // YENİ BUTON
              TextButton.icon( //
                onPressed: _isProcessing ? null : _downloadSampleCsv, // İndirme sırasında tekrar basılmasını engelle
                icon: const Icon(Icons.download, size: 18), //
                label: const Text('Örnek CSV Şablonu İndir'), //
              ),
            ],
          ),
        ),
      ),
    );
  }
}
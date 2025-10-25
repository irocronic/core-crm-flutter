// lib/features/properties/presentation/widgets/document_list_widget.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/property_model.dart';

class DocumentListWidget extends StatelessWidget {
  final List<PropertyDocument> documents;
  // YENİ CALLBACK
  final Function(int documentId)? onDelete;


  const DocumentListWidget({super.key, required this.documents, this.onDelete});

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('Henüz belge yüklenmemiş.')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.blue),
            title: Text(doc.title),
            subtitle: Text(doc.documentTypeDisplay),
            // GÜNCELLEME: Silme butonu eklendi
            trailing: onDelete != null
                ? IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => onDelete!(doc.id),
            )
                : const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (doc.fileUrl != null) {
                _openDocument(doc.fileUrl!);
              }
            },
          ),
        );
      },
    );
  }
}
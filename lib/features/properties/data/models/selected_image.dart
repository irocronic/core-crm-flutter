// lib/features/properties/data/models/selected_image.dart
// Yeni: SelectedImage sınıfı data katmanına taşındı, böylece servisler ve provider'lar presentation'a bağımlı olmaz.

import 'package:image_picker/image_picker.dart';

class SelectedImage {
  final XFile file;
  String type; // 'INTERIOR', 'EXTERIOR', 'FLOOR_PLAN', 'SITE_PLAN'
  String? title;

  SelectedImage({
    required this.file,
    this.type = 'INTERIOR',
    this.title,
  });
}
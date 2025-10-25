// lib/features/customers/data/models/note_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'note_model.g.dart';

@JsonSerializable()
class NoteModel {
  final int id;
  final int customer;
  final String content;

  @JsonKey(name: 'is_important')
  final bool isImportant;

  @JsonKey(name: 'created_by')
  final int? createdBy;

  @JsonKey(name: 'created_by_name')
  final String? createdByName;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.customer,
    required this.content,
    required this.isImportant,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoteModelToJson(this);
}
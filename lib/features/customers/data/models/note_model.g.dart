// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteModel _$NoteModelFromJson(Map<String, dynamic> json) => NoteModel(
  id: (json['id'] as num).toInt(),
  customer: (json['customer'] as num).toInt(),
  content: json['content'] as String,
  isImportant: json['is_important'] as bool,
  createdBy: (json['created_by'] as num?)?.toInt(),
  createdByName: json['created_by_name'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$NoteModelToJson(NoteModel instance) => <String, dynamic>{
  'id': instance.id,
  'customer': instance.customer,
  'content': instance.content,
  'is_important': instance.isImportant,
  'created_by': instance.createdBy,
  'created_by_name': instance.createdByName,
  'created_at': instance.createdAt.toIso8601String(),
};

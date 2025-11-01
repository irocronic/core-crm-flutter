// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectInfo _$ProjectInfoFromJson(Map<String, dynamic> json) =>
    ProjectInfo(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$ProjectInfoToJson(ProjectInfo instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

PropertyImage _$PropertyImageFromJson(Map<String, dynamic> json) =>
    PropertyImage(
          id: (json['id'] as num).toInt(),
          imageUrl: json['image'] as String,
          imageType: json['image_type'] as String,
          title: json['title'] as String?,
    );

Map<String, dynamic> _$PropertyImageToJson(PropertyImage instance) =>
    <String, dynamic>{
          'id': instance.id,
          'image': instance.imageUrl,
          'image_type': instance.imageType,
          'title': instance.title,
    };

PropertyDocument _$PropertyDocumentFromJson(Map<String, dynamic> json) =>
    PropertyDocument(
          id: (json['id'] as num).toInt(),
          fileUrl: json['document'] as String?,
          documentType: json['document_type'] as String,
          documentTypeDisplay: json['document_type_display'] as String,
          title: json['title'] as String,
    );

Map<String, dynamic> _$PropertyDocumentToJson(PropertyDocument instance) =>
    <String, dynamic>{
          'id': instance.id,
          'document': instance.fileUrl,
          'document_type': instance.documentType,
          'document_type_display': instance.documentTypeDisplay,
          'title': instance.title,
    };

PropertyModel _$PropertyModelFromJson(Map<String, dynamic> json) =>
    PropertyModel(
          id: (json['id'] as num).toInt(),
          project: ProjectInfo.fromJson(json['project'] as Map<String, dynamic>),
          block: json['block'] as String,
          floor: (json['floor'] as num).toInt(),
          unitNumber: json['unit_number'] as String,
          facade: json['facade'] as String,
          facadeDisplay: json['facade_display'] as String?,
          propertyType: json['property_type'] as String,
          propertyTypeDisplay: json['property_type_display'] as String?,
          roomCount: json['room_count'] as String,
          grossAreaM2: (json['gross_area_m2'] as num).toDouble(),
          netAreaM2: (json['net_area_m2'] as num).toDouble(),
          cashPrice: (json['cash_price'] as num).toDouble(),
          installmentPrice: (json['installment_price'] as num?)?.toDouble(),
          status: json['status'] as String,
          statusDisplay: json['status_display'] as String?,
          description: json['description'] as String?,
          createdBy: (json['created_by'] as num?)?.toInt(),
          createdByName: json['created_by_name'] as String?,
          createdAt: DateTime.parse(json['created_at'] as String),
          updatedAt: DateTime.parse(json['updated_at'] as String),
          thumbnail: json['thumbnail'] as String?,
          images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => PropertyImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
              [],
          documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => PropertyDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
              [],
          paymentPlans:
          (json['payment_plans'] as List<dynamic>?)
              ?.map((e) => PaymentPlanModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
              [],
          // **** YENİ KDV ALANLARI ****
          vatRate: (json['vat_rate'] as num).toDouble(),
          cashPriceWithVat: (json['cash_price_with_vat'] as num).toDouble(),
          installmentPriceWithVat:
          (json['installment_price_with_vat'] as num?)?.toDouble(),
          vatAmountCash: (json['vat_amount_cash'] as num).toDouble(),
          vatAmountInstallment: (json['vat_amount_installment'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PropertyModelToJson(PropertyModel instance) =>
    <String, dynamic>{
          'id': instance.id,
          'project': instance.project.toJson(),
          'block': instance.block,
          'floor': instance.floor,
          'unit_number': instance.unitNumber,
          'facade': instance.facade,
          'facade_display': instance.facadeDisplay,
          'property_type': instance.propertyType,
          'property_type_display': instance.propertyTypeDisplay,
          'room_count': instance.roomCount,
          'gross_area_m2': instance.grossAreaM2,
          'net_area_m2': instance.netAreaM2,
          'cash_price': instance.cashPrice,
          'installment_price': instance.installmentPrice,
          'status': instance.status,
          'status_display': instance.statusDisplay,
          'description': instance.description,
          'created_by': instance.createdBy,
          'created_by_name': instance.createdByName,
          'created_at': instance.createdAt.toIso8601String(),
          'updated_at': instance.updatedAt.toIso8601String(),
          'thumbnail': instance.thumbnail,
          'images': instance.images.map((e) => e.toJson()).toList(),
          'documents': instance.documents.map((e) => e.toJson()).toList(),
          'payment_plans': instance.paymentPlans.map((e) => e.toJson()).toList(),
          // **** YENİ KDV ALANLARI ****
          'vat_rate': instance.vatRate,
          'cash_price_with_vat': instance.cashPriceWithVat,
          'installment_price_with_vat': instance.installmentPriceWithVat,
          'vat_amount_cash': instance.vatAmountCash,
          'vat_amount_installment': instance.vatAmountInstallment,
    };
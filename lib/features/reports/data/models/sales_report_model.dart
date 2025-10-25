// /lib/features/reports/data/models/sales_report_model.dart

import '../../domain/entities/sales_report_entity.dart';

class SalesReportModel extends SalesReportEntity {
  const SalesReportModel({
    required super.id,
    required super.reportType,
    required super.startDate,
    required super.endDate,
    required super.statistics,
    required super.reportTypeDisplay,
  });

  // YENİ: API'den gelen string'i enum'a çeviren helper
  static ReportType _reportTypeFromString(String typeString) {
    switch (typeString) {
      case 'GENEL_Ozet':
      case 'GUNLUK':
      case 'HAFTALIK':
      case 'AYLIK':
      case 'YILLIK':
        return ReportType.salesSummary;
      case 'TEMSILCI_PERFORMANS':
        return ReportType.repPerformance;
      case 'MUSTERI_KAYNAK':
        return ReportType.customerSource;
      default:
        return ReportType.unknown;
    }
  }

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    return SalesReportModel(
      id: json['id'] as int,
      // YENİ: Rapor türünü string'den enum'a çeviriyoruz
      reportType: _reportTypeFromString(json['report_type'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      // GÜNCELLEME: 'statistics' alanını doğrudan alıyoruz
      statistics: json['statistics'] as Map<String, dynamic>,
      reportTypeDisplay: json['report_type_display'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_type': reportType.toString(), // Basitlik için
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'statistics': statistics,
      'report_type_display': reportTypeDisplay,
    };
  }
}

// ProductSaleModel artık doğrudan kullanılmıyor ama silmeyebiliriz.
class ProductSaleModel extends ProductSaleEntity {
  const ProductSaleModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.totalRevenue,
  });

  factory ProductSaleModel.fromJson(Map<String, dynamic> json) {
    return ProductSaleModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'totalRevenue': totalRevenue,
    };
  }
}
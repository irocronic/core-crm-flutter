// /lib/features/reports/domain/entities/sales_report_entity.dart

// YENİ: Rapor türlerini tanımlayan enum
enum ReportType {
  salesSummary,
  repPerformance,
  customerSource,
  unknown, // API'den gelen bilinmeyen türler için
}

class SalesReportEntity {
  final int id;
  // YENİ: Rapor türünü tutar
  final ReportType reportType;
  // GÜNCELLEME: Eskiden 'date' idi, 'startDate' olarak güncellendi
  final DateTime startDate;
  // YENİ: Bitiş tarihi
  final DateTime endDate;
  // GÜNCELLEME: Sabit alanlar yerine dinamik map
  final Map<String, dynamic> statistics;
  final String reportTypeDisplay;

  const SalesReportEntity({
    required this.id,
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.statistics,
    required this.reportTypeDisplay,
  });
}

class ProductSaleEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double totalRevenue;

  const ProductSaleEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalRevenue,
  });
}

enum ReportPeriod {
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

class ReportFilterEntity {
  final ReportPeriod period;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;
  // YENİ: Rapor oluştururken hangi türün istendiğini belirtir
  final ReportType? reportTypeToGenerate;

  const ReportFilterEntity({
    required this.period,
    this.startDate,
    this.endDate,
    this.category,
    this.reportTypeToGenerate, // YENİ
  });

  /// ✅ FIXED: toQueryParams - Tutarlı API parametreleri
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'period': _getApiPeriodValue(period), // ✅ Düzeltildi: period.name yerine API değeri
    };
    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String().split('T')[0]; // ✅ Django formatı
    }
    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String().split('T')[0]; // ✅ Django formatı
    }
    if (category != null && category!.isNotEmpty) {
      params['category'] = category;
    }

    return params;
  }

  /// GÜNCELLEME: Rapor oluşturma için API'ye gönderilecek veriyi hazırlar
  Map<String, dynamic> toApiData() {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case ReportPeriod.daily:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case ReportPeriod.weekly:
        start = now.subtract(const Duration(days: 7));
        end = now;
        break;
      case ReportPeriod.monthly:
        start = DateTime(now.year, now.month - 1, now.day);
        end = now;
        break;
      case ReportPeriod.yearly:
        start = DateTime(now.year - 1, now.month, now.day);
        end = now;
        break;
      case ReportPeriod.custom:
        if (startDate == null || endDate == null) {
          throw Exception('Özel tarih aralığı için başlangıç ve bitiş tarihleri gerekli');
        }
        start = startDate!;
        end = endDate!;
        break;
    }

    // API'ye gönderilecek veri
    final data = {
      'start_date': start.toIso8601String().split('T')[0],
      'end_date': end.toIso8601String().split('T')[0],
      // YENİ: Rapor türünü de gönderiyoruz
      'report_type': _getApiReportTypeValue(reportTypeToGenerate),
    };

    return data;
  }

  // YENİ: Flutter enum'ını Django API string'ine çeviren helper
  String _getApiReportTypeValue(ReportType? type) {
    switch (type) {
      case ReportType.salesSummary:
        return 'GENEL_Ozet';
      case ReportType.repPerformance:
        return 'TEMSILCI_PERFORMANS';
      case ReportType.customerSource:
        return 'MUSTERI_KAYNAK';
      default:
      // Varsayılan olarak genel özet raporu oluştur
        return 'GENEL_Ozet';
    }
  }

  /// ✅ FIXED: _getApiPeriodValue - Tutarlı API değerleri
  String _getApiPeriodValue(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.daily:
        return 'GUNLUK';
      case ReportPeriod.weekly:
        return 'HAFTALIK';
      case ReportPeriod.monthly:
        return 'AYLIK';
      case ReportPeriod.yearly:
        return 'YILLIK';
      case ReportPeriod.custom:
        return 'CUSTOM';
    }
  }
}
// lib/features/properties/data/models/property_stats_model.dart

class PropertyStatisticsModel {
  final int totalProperties;
  final int available;
  final int reserved;
  final int sold;
  final int passive;
  final Map<String, int> byType;
  final PriceStats priceStats;
  final AreaStats areaStats;

  PropertyStatisticsModel({
    required this.totalProperties,
    required this.available,
    required this.reserved,
    required this.sold,
    required this.passive,
    required this.byType,
    required this.priceStats,
    required this.areaStats,
  });

  factory PropertyStatisticsModel.fromJson(Map<String, dynamic> json) {
    return PropertyStatisticsModel(
      totalProperties: json['total_properties'] ?? 0,
      available: json['available'] ?? 0,
      reserved: json['reserved'] ?? 0,
      sold: json['sold'] ?? 0,
      passive: json['passive'] ?? 0,
      byType: Map<String, int>.from(json['by_type'] ?? {}),
      priceStats: PriceStats.fromJson(json['price_stats'] ?? {}),
      areaStats: AreaStats.fromJson(json['area_stats'] ?? {}),
    );
  }
}

class PriceStats {
  final double? avgCashPrice;
  final double? minCashPrice;
  final double? maxCashPrice;

  PriceStats({
    this.avgCashPrice,
    this.minCashPrice,
    this.maxCashPrice,
  });

  factory PriceStats.fromJson(Map<String, dynamic> json) {
    return PriceStats(
      avgCashPrice: (json['avg_cash_price'] as num?)?.toDouble(),
      minCashPrice: (json['min_cash_price'] as num?)?.toDouble(),
      maxCashPrice: (json['max_cash_price'] as num?)?.toDouble(),
    );
  }
}

class AreaStats {
  final double? avgGrossArea;
  final double? avgNetArea;

  AreaStats({
    this.avgGrossArea,
    this.avgNetArea,
  });

  factory AreaStats.fromJson(Map<String, dynamic> json) {
    return AreaStats(
      avgGrossArea: (json['avg_gross_area'] as num?)?.toDouble(),
      avgNetArea: (json['avg_net_area'] as num?)?.toDouble(),
    );
  }
}
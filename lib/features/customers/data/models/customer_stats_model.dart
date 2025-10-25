// lib/features/customers/data/models/customer_stats_model.dart
import 'package:flutter/material.dart';

class CustomerStatsModel {
      final int totalCustomers;
      final int hotLeads;
      final int withAppointmentsToday;
      final Map<String, int> bySource;

      CustomerStatsModel({
            required this.totalCustomers,
            required this.hotLeads,
            required this.withAppointmentsToday,
            required this.bySource,
      });

      factory CustomerStatsModel.fromJson(Map<String, dynamic> json) {
            return CustomerStatsModel(
                  totalCustomers: json['total_customers'] ?? 0,
                  hotLeads: json['hot_leads'] ?? 0,
                  withAppointmentsToday: json['with_appointments_today'] ?? 0,
                  bySource: Map<String, int>.from(json['by_source'] ?? {}),
            );
      }

      // Grafik için en çok kullanılan 5 kaynağı alır
      Map<String, int> get topSources {
            var sortedEntries = bySource.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

            var top5 = sortedEntries.take(5).toList();
            var othersValue = sortedEntries.skip(5).fold(0, (sum, item) => sum + item.value);

            var result = <String, int>{};
            for (var entry in top5) {
                  result[entry.key] = entry.value;
            }
            if (othersValue > 0) {
                  result['Diğer'] = othersValue;
            }
            return result;
      }

      Color getSourceColor(String source) {
            // Grafik renkleri için basit bir haritalama
            final colors = [
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.red,
                  Colors.teal,
            ];
            final index = bySource.keys.toList().indexOf(source);
            return colors[index % colors.length];
      }
}
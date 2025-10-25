// lib/features/customers/data/models/timeline_event_model.dart

import 'package:flutter_realtyflow_crm/features/customers/data/models/activity_model.dart';
import 'package:flutter_realtyflow_crm/features/appointments/data/models/appointment_model.dart';

enum TimelineEventType { activity, appointment, unknown }

class TimelineEventModel {
      final TimelineEventType type;
      final DateTime date;
      final dynamic data;

      TimelineEventModel({
            required this.type,
            required this.date,
            required this.data,
      });

      factory TimelineEventModel.fromJson(Map<String, dynamic> json) {
            final eventTypeString = json['type'] as String?;
            TimelineEventType eventType;
            dynamic eventData;

            switch (eventTypeString) {
                  case 'activity':
                        eventType = TimelineEventType.activity;
                        eventData = ActivityModel.fromJson(json['data'] as Map<String, dynamic>);
                        break;
                  case 'appointment':
                        eventType = TimelineEventType.appointment;
                        eventData = AppointmentModel.fromJson(json['data'] as Map<String, dynamic>);
                        break;
                  default:
                        eventType = TimelineEventType.unknown;
                        eventData = null;
            }

            return TimelineEventModel(
                  type: eventType,
                  date: DateTime.parse(json['date'] as String),
                  data: eventData,
            );
      }
}
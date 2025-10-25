// lib/features/customers/presentation/widgets/customer_timeline_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/customer_provider.dart';
import '../../data/models/timeline_event_model.dart';
import '../../data/models/activity_model.dart';
import '../../../appointments/data/models/appointment_model.dart';

class CustomerTimelineWidget extends StatelessWidget {
  const CustomerTimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        if (provider.isTimelineLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.timeline.isEmpty) {
          return const Center(
            child: Text('Zaman tüneli için henüz bir olay yok.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: provider.timeline.length,
          itemBuilder: (context, index) {
            final event = provider.timeline[index];
            return TimelineEventCard(event: event);
          },
        );
      },
    );
  }
}

class TimelineEventCard extends StatelessWidget {
  final TimelineEventModel event;

  const TimelineEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isActivity = event.type == TimelineEventType.activity;
    final iconData = isActivity ? (event.data as ActivityModel).activityTypeIcon : Icons.event;
    final iconColor = isActivity ? (event.data as ActivityModel).activityTypeColor : Colors.orange;
    final title = isActivity ? (event.data as ActivityModel).activityTypeDisplayText : 'Randevu';
    final notes = isActivity ? (event.data as ActivityModel).notes : (event.data as AppointmentModel).notes;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Date
            Column(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(iconData, color: iconColor),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd.MM.yy', 'tr_TR').format(event.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormat('HH:mm', 'tr_TR').format(event.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (notes != null && notes.isNotEmpty)
                    Text(
                      notes,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  const SizedBox(height: 8),
                  _buildSpecificDetails(context, event.data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificDetails(BuildContext context, dynamic data) {
    if (data is ActivityModel) {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          Chip(
            avatar: Icon(Icons.person, size: 16, color: Colors.grey[700]),
            label: Text(data.createdByName ?? 'Bilinmeyen', style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.grey[200],
            padding: const EdgeInsets.all(4),
          ),
          if (data.outcomeScoreDisplay != null)
            Chip(
              avatar: Icon(Icons.trending_up, size: 16, color: data.outcomeScoreColor),
              label: Text(data.outcomeScoreDisplay!, style: TextStyle(fontSize: 12, color: data.outcomeScoreColor)),
              backgroundColor: data.outcomeScoreColor.withOpacity(0.1),
              padding: const EdgeInsets.all(4),
            ),
        ],
      );
    } else if (data is AppointmentModel) {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          Chip(
            avatar: Icon(Icons.person, size: 16, color: Colors.grey[700]),
            label: Text(data.salesRepName ?? 'Bilinmeyen', style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.grey[200],
            padding: const EdgeInsets.all(4),
          ),
          if (data.location != null && data.location!.isNotEmpty)
            Chip(
              avatar: Icon(Icons.location_on, size: 16, color: Colors.blue[700]),
              label: Text(data.location!, style: TextStyle(fontSize: 12, color: Colors.blue[700])),
              backgroundColor: Colors.blue.withOpacity(0.1),
              padding: const EdgeInsets.all(4),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
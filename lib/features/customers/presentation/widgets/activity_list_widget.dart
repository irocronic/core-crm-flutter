// lib/features/customers/presentation/widgets/activity_list_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../data/models/activity_model.dart';

class ActivityListWidget extends StatelessWidget {
  final List<ActivityModel> activities;
  final bool isLoading;
  final VoidCallback? onAddActivity;

  const ActivityListWidget({
    super.key,
    required this.activities,
    this.isLoading = false,
    this.onAddActivity,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz aktivite yok',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              if (onAddActivity != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onAddActivity,
                  icon: const Icon(Icons.add),
                  label: const Text('İlk Aktiviteyi Ekle'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityCard(activity: activity);
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activity.activityTypeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    activity.activityTypeIcon,
                    color: activity.activityTypeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityTypeDisplayText,  // 🔥 DÜZELTME
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormatter.relativeTime(activity.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: activity.outcomeScoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: activity.outcomeScoreColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.outcomeScoreValue}%',
                        style: TextStyle(
                          color: activity.outcomeScoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Notes
            if (activity.notes != null && activity.notes!.isNotEmpty) ...[
              Text(
                activity.notes!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],

            // Next Follow Up Date
            if (activity.nextFollowUpDate != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 18,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sonraki Takip',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm')
                                .format(activity.nextFollowUpDate!),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Footer - Created By
            Row(
              children: [
                if (activity.createdByName != null) ...[
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activity.createdByName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatDateTime(activity.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
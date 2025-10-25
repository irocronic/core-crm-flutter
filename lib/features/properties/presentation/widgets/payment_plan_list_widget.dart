// lib/features/properties/presentation/widgets/payment_plan_list_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/payment_plan_model.dart';

class PaymentPlanListWidget extends StatelessWidget {
  final List<PaymentPlanModel> paymentPlans;
  // YENİ CALLBACK
  final Function(int planId)? onDelete;

  const PaymentPlanListWidget({super.key, required this.paymentPlans, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (paymentPlans.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('Bu mülk için ödeme planı oluşturulmamış.')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paymentPlans.length,
      itemBuilder: (context, index) {
        final plan = paymentPlans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              plan.planType == 'PESIN' ? Icons.money_off : Icons.calendar_today,
              color: plan.planType == 'PESIN' ? Colors.green : Colors.orange,
            ),
            title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(plan.detailsDisplay),
            // GÜNCELLEME: Silme butonu eklendi
            trailing: onDelete != null
                ? IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => onDelete!(plan.id),
            )
                : null,
          ),
        );
      },
    );
  }
}
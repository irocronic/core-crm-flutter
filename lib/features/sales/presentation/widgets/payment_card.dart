// lib/features/sales/presentation/widgets/payment_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/payment_model.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsPaid;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.onMarkAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: payment.isOverdue ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: payment.isOverdue
            ? BorderSide(color: Colors.red.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Payment Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPaymentTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getPaymentTypeColor(),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPaymentTypeIcon(),
                          size: 14,
                          color: _getPaymentTypeColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          payment.paymentTypeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getPaymentTypeColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Amount
                  Text(
                    CurrencyFormatter.format(payment.amount),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Due Date
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Vade Tarihi',
                value: DateFormatter.formatDate(
                  DateTime.parse(payment.dueDate),
                ),
                color: payment.isOverdue ? Colors.red : null,
              ),

              // Payment Date (if paid)
              if (payment.paymentDate != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: Icons.check_circle,
                  label: 'Ödeme Tarihi',
                  value: DateFormatter.formatDate(
                    DateTime.parse(payment.paymentDate!),
                  ),
                  color: Colors.green,
                ),
              ],

              // Payment Method
              if (payment.paymentMethodText != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: Icons.payment,
                  label: 'Ödeme Yöntemi',
                  value: payment.paymentMethodText!,
                ),
              ],

              // Receipt Number
              if (payment.receiptNumber != null &&
                  payment.receiptNumber!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: Icons.receipt,
                  label: 'Makbuz No',
                  value: payment.receiptNumber!,
                ),
              ],

              // Installment Number
              if (payment.installmentNumber != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: Icons.numbers,
                  label: 'Taksit',
                  value: '${payment.installmentNumber}. Taksit',
                ),
              ],

              const SizedBox(height: 12),

              // Status Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: payment.statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          payment.statusIcon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          payment.statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Mark as Paid Button (only for pending/overdue)
                  if (!payment.isPaid && onMarkAsPaid != null) ...[
                    ElevatedButton.icon(
                      onPressed: onMarkAsPaid,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Tahsil Et'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getPaymentTypeColor() {
    switch (payment.paymentType) {
      case 'KAPARO':
        return Colors.purple;
      case 'PESINAT':
        return Colors.blue;
      case 'TAKSIT':
        return Colors.orange;
      case 'KALAN_ODEME':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentTypeIcon() {
    switch (payment.paymentType) {
      case 'KAPARO':
        return Icons.attach_money;
      case 'PESINAT':
        return Icons.money;
      case 'TAKSIT':
        return Icons.calendar_month;
      case 'KALAN_ODEME':
        return Icons.check_circle;
      default:
        return Icons.payment;
    }
  }
}
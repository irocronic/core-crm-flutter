// lib/features/sales/presentation/widgets/mark_as_paid_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/payment_model.dart';

class MarkAsPaidDialog extends StatefulWidget {
  final PaymentModel payment;
  final Function(String paymentDate, String paymentMethod, String? receiptNumber) onConfirm;

  const MarkAsPaidDialog({
    super.key,
    required this.payment,
    required this.onConfirm,
  });

  @override
  State<MarkAsPaidDialog> createState() => _MarkAsPaidDialogState();
}

class _MarkAsPaidDialogState extends State<MarkAsPaidDialog> {
  final _formKey = GlobalKey<FormState>();
  final _receiptNumberController = TextEditingController();
  
  String _selectedPaymentMethod = 'NAKIT';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _receiptNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      widget.onConfirm(
        formattedDate,
        _selectedPaymentMethod,
        _receiptNumberController.text.trim().isEmpty
            ? null
            : _receiptNumberController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ödeme Tahsil Et',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.payment.amount),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Payment Date
                Text(
                  'Ödeme Tarihi *',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMMM yyyy', 'tr_TR')
                                .format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Method
                Text(
                  'Ödeme Yöntemi *',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.payment),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'NAKIT',
                      child: Text('Nakit'),
                    ),
                    DropdownMenuItem(
                      value: 'KREDI_KARTI',
                      child: Text('Kredi Kartı'),
                    ),
                    DropdownMenuItem(
                      value: 'HAVALE',
                      child: Text('Banka Havalesi'),
                    ),
                    DropdownMenuItem(
                      value: 'CEK',
                      child: Text('Çek'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Receipt Number
                Text(
                  'Makbuz/Dekont No (Opsiyonel)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _receiptNumberController,
                  decoration: InputDecoration(
                    hintText: 'Makbuz veya dekont numarası',
                    prefixIcon: const Icon(Icons.receipt),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _handleConfirm,
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text('Tahsil Et'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
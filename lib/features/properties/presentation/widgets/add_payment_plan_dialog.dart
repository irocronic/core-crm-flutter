// lib/features/properties/presentation/widgets/add_payment_plan_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/property_provider.dart';
import '../../../../core/utils/validators.dart';

class AddPaymentPlanDialog extends StatefulWidget {
  final int propertyId;
  const AddPaymentPlanDialog({super.key, required this.propertyId});

  @override
  State<AddPaymentPlanDialog> createState() => _AddPaymentPlanDialogState();
}

class _AddPaymentPlanDialogState extends State<AddPaymentPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  String _planType = 'VADELI';
  final _nameController = TextEditingController();
  final _downPaymentPercentController = TextEditingController();
  final _installmentCountController = TextEditingController();
  final _interestRateController = TextEditingController(text: '0');

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'plan_type': _planType,
      'name': _nameController.text.trim(),
    };

    if (_planType == 'VADELI') {
      data['down_payment_percent'] = _downPaymentPercentController.text.trim();
      data['installment_count'] = _installmentCountController.text.trim();
      data['interest_rate'] = _interestRateController.text.trim();
    }

    final provider = context.read<PropertyProvider>();
    final success = await provider.createPaymentPlan(widget.propertyId, data);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Ödeme planı oluşturuldu' : provider.errorMessage ?? 'Oluşturma başarısız'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Ödeme Planı'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _planType,
                decoration: const InputDecoration(labelText: 'Plan Tipi *'),
                items: const [
                  DropdownMenuItem(value: 'VADELI', child: Text('Vadeli')),
                  DropdownMenuItem(value: 'PESIN', child: Text('Peşin')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _planType = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plan Adı *'),
                validator: (value) => Validators.required(value, fieldName: 'Plan Adı'),
              ),
              if (_planType == 'VADELI') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _downPaymentPercentController,
                  decoration: const InputDecoration(labelText: 'Peşinat Yüzdesi (%) *'),
                  keyboardType: TextInputType.number,
                  validator: (value) => Validators.numeric(value, fieldName: 'Peşinat Yüzdesi'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _installmentCountController,
                  decoration: const InputDecoration(labelText: 'Taksit Sayısı *'),
                  keyboardType: TextInputType.number,
                  validator: (value) => Validators.numeric(value, fieldName: 'Taksit Sayısı'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _interestRateController,
                  decoration: const InputDecoration(labelText: 'Vade Farkı Oranı (%)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
        ElevatedButton(
          onPressed: context.watch<PropertyProvider>().isLoading ? null : _handleSubmit,
          child: const Text('Oluştur'),
        ),
      ],
    );
  }
}
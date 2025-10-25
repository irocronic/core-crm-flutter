// lib/features/sales/presentation/presentation/screens/overdue_payments_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// ✅ DÜZELTİLDİ: Doğru import yolları
import '../../../presentation/providers/payment_provider.dart';
import '../../widgets/payment_card.dart';
import '../../widgets/mark_as_paid_dialog.dart';

class OverduePaymentsScreen extends StatefulWidget {
  const OverduePaymentsScreen({super.key});

  @override
  State<OverduePaymentsScreen> createState() => _OverduePaymentsScreenState();
}

class _OverduePaymentsScreenState extends State<OverduePaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadOverduePayments();
    });
  }

  void _showMarkAsPaidDialog(dynamic payment, PaymentProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MarkAsPaidDialog(
        payment: payment,
        onConfirm: (paymentDate, paymentMethod, receiptNumber) async {
          final success = await provider.markPaymentAsPaid(
            paymentId: payment.id,
            paymentDate: paymentDate,
            paymentMethod: paymentMethod,
            receiptNumber: receiptNumber,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Ödeme başarıyla tahsil edildi' : provider.errorMessage ?? 'İşlem başarısız'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gecikmiş Ödemeler'),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.overduePayments.isEmpty) {
            return Center(child: Text('Hata: ${provider.errorMessage}'));
          }

          if (provider.overduePayments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Gecikmiş ödeme bulunmuyor.', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadOverduePayments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.overduePayments.length,
              itemBuilder: (context, index) {
                final payment = provider.overduePayments[index];
                return PaymentCard(
                  payment: payment,
                  onTap: () => context.go('/reservations/${payment.reservation}/payments'),
                  onMarkAsPaid: () => _showMarkAsPaidDialog(payment, provider),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
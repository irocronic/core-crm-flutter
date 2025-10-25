// lib/features/reservations/presentation/screens/payment_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../sales/presentation/providers/payment_provider.dart';
import '../../../sales/presentation/widgets/payment_card.dart';
import '../../../sales/presentation/widgets/mark_as_paid_dialog.dart';
import '../providers/reservation_provider.dart';

class PaymentTrackingScreen extends StatefulWidget {
  final int reservationId;

  const PaymentTrackingScreen({
    super.key,
    required this.reservationId,
  });

  @override
  State<PaymentTrackingScreen> createState() => _PaymentTrackingScreenState();
}

class _PaymentTrackingScreenState extends State<PaymentTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final reservationProvider = context.read<ReservationProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    
    await Future.wait([
      reservationProvider.loadReservationDetail(widget.reservationId),
      paymentProvider.loadPaymentsByReservation(widget.reservationId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme Takibi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer2<ReservationProvider, PaymentProvider>(
          builder: (context, reservationProvider, paymentProvider, _) {
            // Loading durumu
            if (reservationProvider.isLoading || paymentProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Error durumu
            if (reservationProvider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        reservationProvider.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Rezervasyon kontrolü
            final reservation = reservationProvider.selectedReservation;
            if (reservation == null) {
              return const Center(
                child: Text(
                  'Rezervasyon bulunamadı',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // Ödemeler
            final payments = paymentProvider.payments;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Özet Kartı
                  _buildSummaryCard(reservation, payments),
                  
                  // Ödemeler Listesi
                  _buildPaymentsList(payments, paymentProvider),
                  
                  // Alt boşluk
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(dynamic reservation, List<dynamic> payments) {
    // Toplam tutar - null check
    double totalAmount = reservation.propertyInfo?.cashPrice ?? 
                         reservation.propertyInfo?.installmentPrice ?? 
                         0;
    
    // Ödenen tutar - kapora + alınan ödemeler
    double paidAmount = reservation.depositAmount ?? 0;
    
    // Alınan ödemeleri ekle
    for (var payment in payments) {
      if (payment.status == 'ALINDI') {
        paidAmount += payment.amount;
      }
    }
    
    // Kalan tutar
    double remainingAmount = totalAmount - paidAmount;
    
    // Tamamlanma yüzdesi
    double completionPercentage = totalAmount > 0 
        ? (paidAmount / totalAmount) * 100 
        : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Müşteri ve Mülk Bilgisi
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.customerInfo?.fullName ?? 'Müşteri',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reservation.propertyInfo?.fullAddress ?? 'Adres bilgisi yok',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tamamlanma Oranı',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${completionPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  minHeight: 14,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Tutar Bilgileri
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmountInfo(
                'Toplam',
                totalAmount,
                Colors.white70,
                Icons.account_balance_wallet,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildAmountInfo(
                'Ödenen',
                paidAmount,
                Colors.white,
                Icons.check_circle,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildAmountInfo(
                'Kalan',
                remainingAmount,
                Colors.yellowAccent,
                Icons.pending,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInfo(String label, double amount, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<dynamic> payments, PaymentProvider provider) {
    if (payments.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.payment,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz ödeme kaydı yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ödeme planı oluşturulduğunda burada görünecektir',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Ödemeleri duruma göre grupla
    final paidPayments = payments.where((p) => p.isPaid).toList();
    final pendingPayments = payments.where((p) => p.isPending).toList();
    final overduePayments = payments.where((p) => p.isOverdueStatus).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ödeme Geçmişi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${payments.length} ödeme',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // İstatistik kartları
          if (overduePayments.isNotEmpty || pendingPayments.isNotEmpty) ...[
            Row(
              children: [
                if (overduePayments.isNotEmpty)
                  Expanded(
                    child: _buildStatCard(
                      'Gecikmiş',
                      overduePayments.length.toString(),
                      Colors.red,
                      Icons.warning,
                    ),
                  ),
                if (overduePayments.isNotEmpty && pendingPayments.isNotEmpty)
                  const SizedBox(width: 12),
                if (pendingPayments.isNotEmpty)
                  Expanded(
                    child: _buildStatCard(
                      'Bekleyen',
                      pendingPayments.length.toString(),
                      Colors.orange,
                      Icons.pending,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Ödemeler listesi
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return PaymentCard(
                payment: payment,
                onTap: () {
                  // Detay sayfası açılabilir
                },
                onMarkAsPaid: payment.isPaid
                    ? null
                    : () {
                        _showMarkAsPaidDialog(payment, provider);
                      },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkAsPaidDialog(dynamic payment, PaymentProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MarkAsPaidDialog(
        payment: payment,
        onConfirm: (paymentDate, paymentMethod, receiptNumber) async {
          // Dialog'u kapat
          Navigator.of(dialogContext).pop();

          // Loading göster
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Ödeme kaydediliyor...'),
                    ],
                  ),
                ),
              ),
            ),
          );

          // API çağrısı
          final success = await provider.markPaymentAsPaid(
            paymentId: payment.id,
            paymentDate: paymentDate,
            paymentMethod: paymentMethod,
            receiptNumber: receiptNumber,
          );

          // Loading'i kapat
          if (mounted) {
            Navigator.of(context).pop();
          }

          // Sonuç mesajı
          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${CurrencyFormatter.format(payment.amount)} tutarındaki ödeme başarıyla tahsil edildi',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              // Verileri yenile
              await _loadData();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.errorMessage ?? 'Ödeme tahsil edilemedi. Lütfen tekrar deneyin.',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: 'Tekrar Dene',
                    textColor: Colors.white,
                    onPressed: () {
                      _showMarkAsPaidDialog(payment, provider);
                    },
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
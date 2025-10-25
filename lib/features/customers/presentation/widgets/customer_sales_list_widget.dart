// lib/features/customers/presentation/widgets/customer_sales_list_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../reservations/presentation/providers/reservation_provider.dart';
import '../../../reservations/presentation/widgets/reservation_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
// YENİ IMPORT: Rezervasyon Detay Ekranı için import eklendi.
import '../../../reservations/presentation/screens/reservation_detail_screen.dart';

class CustomerSalesListWidget extends StatefulWidget {
  final int customerId;
  const CustomerSalesListWidget({super.key, required this.customerId});

  @override
  State<CustomerSalesListWidget> createState() =>
      _CustomerSalesListWidgetState();
}

class _CustomerSalesListWidgetState extends State<CustomerSalesListWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSales();
    });
  }

  Future<void> _loadSales() async {
    await context
        .read<ReservationProvider>()
        .loadSalesByCustomer(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationProvider>(
      builder: (context, provider, _) {
        if (provider.isCustomerSalesLoading) {
          return const LoadingIndicator(message: 'Satışlar yükleniyor...');
        }

        if (provider.customerSalesErrorMessage != null) {
          return ErrorDisplay(
            message: provider.customerSalesErrorMessage!,
            onRetry: _loadSales,
          );
        }

        if (provider.customerSales.isEmpty) {
          return const EmptyState(
            icon: Icons.point_of_sale_outlined,
            title: 'Satış Bulunamadı',
            subtitle:
            'Bu müşteriye ait tamamlanmış bir satış (rezervasyon) bulunmuyor.',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadSales,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.customerSales.length,
            itemBuilder: (context, index) {
              final sale = provider.customerSales[index];
              return ReservationCard(
                reservation: sale,
                onTap: () {
                  // GÜNCELLEME: Yönlendirme Ödeme Takibi ekranı yerine Rezervasyon Detay ekranına yapılıyor.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailScreen(
                        reservationId: sale.id,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
// lib/features/reservations/presentation/screens/reservations_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/custom_drawer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/reservation_model.dart';
import '../providers/reservation_provider.dart';
import 'reservation_detail_screen.dart';
import 'payment_tracking_screen.dart';

class ReservationsListScreen extends StatefulWidget {
  // 🔥 YENİ PARAMETRE
  final String? filter;
  const ReservationsListScreen({super.key, this.filter});

  @override
  State<ReservationsListScreen> createState() => _ReservationsListScreenState();
}

class _ReservationsListScreenState extends State<ReservationsListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔥 GÜNCELLENDİ: Gelen filtreye göre provider'ı ayarla
      _updateProviderFilter();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        final provider = context.read<ReservationProvider>();
        if (provider.hasMore && !provider.isLoadingMore) {
          provider.loadReservations();
        }
      }
    });
  }

  // 🔥 GÜNCELLEME: Eğer widget'ın filtresi değişirse (örneğin drawer'dan başka bir linke tıklanırsa),
  // provider'ı tekrar güncelle
  @override
  void didUpdateWidget(covariant ReservationsListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateProviderFilter();
      });
    }
  }

  // 🔥 YENİ METOT
  void _updateProviderFilter() {
    final provider = context.read<ReservationProvider>();
    ReservationListType newType;
    switch (widget.filter) {
      case 'active':
        newType = ReservationListType.active;
        break;
      case 'my-sales':
        newType = ReservationListType.mySales;
        break;
      case 'all':
      default:
        newType = ReservationListType.all;
        break;
    }
    provider.setListType(newType);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 🔥 YENİ METOT: Dinamik başlık
  String _getTitle(ReservationListType type) {
    switch (type) {
      case ReservationListType.active:
        return 'Aktif Rezervasyonlarım';
      case ReservationListType.mySales:
        return 'Satışlarım';
      case ReservationListType.all:
      default:
        return 'Tüm Rezervasyonlar';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Provider'ı dinleyerek başlığı dinamik hale getiriyoruz
    final listType = context.watch<ReservationProvider>().listType;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(listType)),
      ),
      drawer: const CustomDrawer(),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.reservations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadReservations(refresh: true),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReservations(refresh: true),
            child: Column(
              children: [
                // YENİ: İstatistik Paneli
                if (provider.statistics != null)
                  _buildStatisticsHeader(provider.statistics!),

                // Mevcut Liste
                Expanded(
                  child: provider.reservations.isEmpty
                      ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz rezervasyon yok',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ))
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.reservations.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.reservations.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final reservation = provider.reservations[index];
                      return _ReservationCard(reservation: reservation);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/reservations/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  // YENİ WIDGET: İstatistik Paneli
  Widget _buildStatisticsHeader(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: [
          _buildStatItem('Toplam', stats['total_reservations']?.toString() ?? '0', Colors.blueGrey),
          _buildStatItem('Aktif', stats['active']?.toString() ?? '0', Colors.green),
          _buildStatItem('Satışa Dönüştü', stats['converted_to_sales']?.toString() ?? '0', Colors.blue),
          _buildStatItem('İptal Edildi', stats['cancelled']?.toString() ?? '0', Colors.red),
        ],
      ),
    );
  }

  // YENİ WIDGET: İstatistik Öğesi
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationDetailScreen(
                reservationId: reservation.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: reservation.statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reservation.statusDisplay ?? reservation.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'REZ-${reservation.id}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Popup Menu
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        onSelected: (value) {
                          switch (value) {
                            case 'detail':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationDetailScreen(
                                    reservationId: reservation.id,
                                  ),
                                ),
                              );
                              break;
                            case 'payment':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentTrackingScreen(
                                    reservationId: reservation.id,
                                  ),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'detail',
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 20),
                                SizedBox(width: 12),
                                Text('Detaylar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'payment',
                            child: Row(
                              children: [
                                Icon(Icons.payment, color: Colors.blue, size: 20),
                                SizedBox(width: 12),
                                Text('Ödeme Takibi'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Customer
              Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.customerInfo?.fullName ?? 'Müşteri',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          reservation.customerInfo?.phoneNumber ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Property
              Row(
                children: [
                  const Icon(Icons.home_work, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservation.propertyInfo?.fullAddress ?? 'Gayrimenkul',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kaparo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(reservation.depositAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tarih',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        DateFormatter.formatDate(reservation.reservationDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
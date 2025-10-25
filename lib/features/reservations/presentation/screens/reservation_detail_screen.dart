// lib/features/reservations/presentation/screens/reservation_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/reservation_provider.dart';
import '../../data/models/reservation_model.dart';
import 'payment_tracking_screen.dart';
// Düzeltme: Doğru import path'leri
import '../../../contracts/presentation/screens/contract_detail_screen.dart';
import '../../../contracts/data/models/contract_model.dart';
import '../../../contracts/presentation/providers/contract_provider.dart';

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;

  const ReservationDetailScreen({
    super.key,
    required this.reservationId,
  });

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationProvider>().loadReservationDetail(widget.reservationId);
      _loadContracts();
    });
  }

  Future<void> _loadContracts() async {
    try {
      await context.read<ContractProvider>().loadContracts(
        refresh: true,
      );
    } catch (e) {
      print('Sözleşmeler yüklenemedi: $e');
    }
  }

  // ✅ YENİ FONKSİYON: Satışa Dönüştürme Onay Dialog'u
  void _showConvertToSaleDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Satışa Dönüştür'),
        content: const Text(
          'Bu rezervasyonu kalıcı olarak satışa dönüştürmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve mülkün durumu "Satıldı" olarak güncellenir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<ReservationProvider>();
              final success = await provider.convertToSale(widget.reservationId);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rezervasyon başarıyla satışa dönüştürüldü!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'İşlem başarısız oldu'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Onayla ve Dönüştür'),
          ),
        ],
      ),
    );
  }

  void _showCreateContractDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sözleşme Oluştur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu rezervasyon için rezervasyon sözleşmesi oluşturulacak.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Devam etmek istiyor musunuz?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _createContract();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  Future<void> _createContract() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Sözleşme oluşturuluyor...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final contractProvider = context.read<ContractProvider>();
      final success = await contractProvider.createContract(
        contractType: ContractType.reservation,
        contractDate: DateTime.now(),
        reservationId: widget.reservationId,
        notes: 'Rezervasyon sözleşmesi',
      );
      if (mounted) Navigator.pop(context);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Sözleşme başarıyla oluşturuldu'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        final contract = contractProvider.selectedContract;
        if (contract != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContractDetailScreen(
                contractId: contract.id,
              ),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    contractProvider.error ?? 'Sözleşme oluşturulamadı',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showContractsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text(
                        'Sözleşmeler',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<ContractProvider>(
                    builder: (context, provider, _) {
                      final contracts = provider.contracts
                          .where((c) => c.reservationId == widget.reservationId)
                          .toList();

                      if (provider.isLoading && contracts.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (contracts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Henüz sözleşme yok',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Bu rezervasyon için henüz sözleşme oluşturulmamış',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showCreateContractDialog();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Sözleşme Oluştur'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: contracts.length,
                        itemBuilder: (context, index) {
                          final contract = contracts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getContractStatusColor(contract.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.description,
                                  color: _getContractStatusColor(contract.status),
                                ),
                              ),
                              title: Text(
                                contract.contractNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    contract.contractType.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getContractStatusColor(contract.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      contract.status.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContractDetailScreen(
                                      contractId: contract.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getContractStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.draft:
        return Colors.grey;
      case ContractStatus.pendingApproval:
        return Colors.orange;
      case ContractStatus.signed:
        return Colors.green;
      case ContractStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon Detayı'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'contracts',
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Sözleşmeler'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'create_contract',
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Sözleşme Oluştur'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.go('/reservations/${widget.reservationId}/edit');
                  break;
                case 'contracts':
                  _showContractsBottomSheet();
                  break;
                case 'create_contract':
                  _showCreateContractDialog();
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
          ),
        ],
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedReservation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
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
                ],
              ),
            );
          }

          final reservation = provider.selectedReservation;
          if (reservation == null) {
            return const Center(child: Text('Rezervasyon bulunamadı'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          reservation.customerInfo?.fullName.substring(0, 1).toUpperCase() ?? 'R',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        reservation.customerInfo?.fullName ?? 'Müşteri',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: reservation.statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reservation.statusDisplay ?? reservation.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ YENİ: Satışa Dönüştürme Butonu (koşullu)
                if (reservation.status == 'AKTIF')
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showConvertToSaleDialog,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Satışa Dönüştür'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                Container(
                  margin: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: _showContractsBottomSheet,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade600,
                              Colors.purple.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.description,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sözleşmeler',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sözleşmeleri görüntüle veya oluştur',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Contact Info
                _buildSection(
                  context,
                  title: 'İletişim Bilgileri',
                  icon: Icons.contact_phone,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.phone,
                      label: 'Telefon',
                      value: reservation.customerInfo?.phoneNumber ?? '-',
                    ),
                    if (reservation.customerInfo?.email != null)
                      _buildInfoRow(
                        context,
                        icon: Icons.email,
                        label: 'E-posta',
                        value: reservation.customerInfo!.email!,
                      ),
                  ],
                ),

                // Lead Info
                _buildSection(
                  context,
                  title: 'Rezervasyon Bilgileri',
                  icon: Icons.info,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.home,
                      label: 'Gayrimenkul',
                      value: reservation.propertyInfo?.fullAddress ?? '-',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.attach_money,
                      label: 'Kaparo',
                      value: CurrencyFormatter.format(reservation.depositAmount),
                    ),
                    if (reservation.salesRepName != null)
                      _buildInfoRow(
                        context,
                        icon: Icons.person,
                        label: 'Satış Temsilcisi',
                        value: reservation.salesRepName!,
                      ),
                  ],
                ),

                _buildPaymentTrackingCard(context, reservation),

                if (reservation.notes != null && reservation.notes!.isNotEmpty)
                  _buildSection(
                    context,
                    title: 'Notlar',
                    icon: Icons.note,
                    children: [
                      Text(
                        reservation.notes!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                // Meta Info
                _buildSection(
                  context,
                  title: 'Sistem Bilgileri',
                  icon: Icons.info_outline,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.person_add,
                      label: 'Oluşturan',
                      value: reservation.recordedByName ?? '-',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Rezervasyon Tarihi',
                      value: DateFormatter.formatDateTime(reservation.reservationDate),
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.update,
                      label: 'Güncelleme',
                      value: DateFormatter.formatDateTime(reservation.updatedAt),
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
        Widget? action,
      }) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (action != null) action,
                ],
              ),
              const Divider(height: 24),
              ...children,
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
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTrackingCard(BuildContext context, dynamic reservation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentTrackingScreen(
                  reservationId: reservation.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payment,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ödeme Takibi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ödeme geçmişini görüntüle ve tahsilat yap',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezervasyonu Sil'),
        content: const Text(
          'Bu rezervasyonu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final provider = context.read<ReservationProvider>();
              final success = await provider.cancelReservation(
                widget.reservationId,
                'Kullanıcı tarafından silindi',
              );

              if (mounted) {
                if (success) {
                  context.go('/reservations');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rezervasyon silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Silinemedi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
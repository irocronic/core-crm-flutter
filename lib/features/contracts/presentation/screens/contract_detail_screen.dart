// lib/features/contracts/presentation/screens/contract_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // ✅ YENİ IMPORT
import '../../data/models/contract_model.dart';
import '../providers/contract_provider.dart';
import '../widgets/contract_status_badge.dart';

/// Contract Detail Screen
class ContractDetailScreen extends StatefulWidget {
  final int contractId;

  const ContractDetailScreen({
    Key? key,
    required this.contractId,
  }) : super(key: key);

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContractProvider>().loadContractById(widget.contractId);
    });
  }

  Future<void> _markAsSigned() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sözleşmeyi İmzala'),
        content: const Text(
          'Bu sözleşmeyi imzalanmış olarak işaretlemek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('İmzala'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context
          .read<ContractProvider>()
          .markAsSigned(widget.contractId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Sözleşme başarıyla imzalandı'
                  : context.read<ContractProvider>().error ?? 'İmzalama başarısız oldu',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelContract() async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sözleşmeyi İptal Et'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('İptal nedenini belirtiniz:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'İptal nedeni',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen iptal nedenini belirtiniz'),
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<ContractProvider>().cancelContract(
        id: widget.contractId,
        reason: reasonController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Sözleşme başarıyla iptal edildi'
                  : context.read<ContractProvider>().error ?? 'İptal işlemi başarısız oldu',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _generatePdf() async {
    final success = await context
        .read<ContractProvider>()
        .generatePdf(widget.contractId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'PDF başarıyla oluşturuldu'
                : 'PDF oluşturulamadı',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF açılamadı'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Sözleşme Detayı',
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ContractProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedContract == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.selectedContract == null) {
            return _buildErrorWidget(provider.error!);
          }

          final contract = provider.selectedContract;
          if (contract == null) {
            return const Center(child: Text('Sözleşme bulunamadı'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(contract),
                const SizedBox(height: 16),
                _buildInfoCard(contract),
                const SizedBox(height: 16),
                if (contract.reservationDetails != null)
                  _buildReservationCard(contract.reservationDetails!),
                if (contract.saleDetails != null)
                  _buildSaleCard(contract.saleDetails!),
                const SizedBox(height: 16),
                _buildPdfCard(contract),
                const SizedBox(height: 16),
                if (contract.notes != null && contract.notes!.isNotEmpty)
                  _buildNotesCard(contract.notes!),
                const SizedBox(height: 16),
                // ✅ GÜNCELLEME: `context` parametresi eklendi
                _buildActionsCard(context, contract),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(ContractModel contract) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.contractNumber,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contract.contractType.displayName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ContractStatusBadge(status: contract.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ContractModel contract) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Genel Bilgiler', style: AppTextStyles.h3),
            const Divider(height: 24),
            _buildInfoRow(
              'Sözleşme Tarihi',
              dateFormat.format(contract.contractDate),
            ),
            if (contract.signedDate != null)
              _buildInfoRow(
                'İmzalanma Tarihi',
                dateFormat.format(contract.signedDate!),
              ),
            if (contract.cancelledDate != null)
              _buildInfoRow(
                'İptal Tarihi',
                dateFormat.format(contract.cancelledDate!),
              ),
            if (contract.cancellationReason != null)
              _buildInfoRow(
                'İptal Nedeni',
                contract.cancellationReason!,
              ),
            _buildInfoRow(
              'Oluşturan',
              contract.createdByName ?? 'Bilinmiyor',
            ),
            _buildInfoRow(
              'Oluşturulma Tarihi',
              dateFormat.format(contract.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(ReservationDetails reservation) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rezervasyon Bilgileri', style: AppTextStyles.h3),
            const Divider(height: 24),
            _buildInfoRow('Rezervasyon No', reservation.reservationNumber),
            _buildInfoRow('Müşteri', reservation.customer.fullName),
            _buildInfoRow('Mülk', reservation.property.title),
            _buildInfoRow(
              'Rezervasyon Tarihi',
              dateFormat.format(reservation.reservationDate),
            ),
            _buildInfoRow(
              'Rezervasyon Tutarı',
              currencyFormat.format(double.tryParse(reservation.reservationAmount) ?? 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleCard(SaleDetails sale) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Satış Bilgileri', style: AppTextStyles.h3),
            const Divider(height: 24),
            _buildInfoRow('Satış No', sale.saleNumber),
            _buildInfoRow('Müşteri', sale.customer.fullName),
            _buildInfoRow('Mülk', sale.property.title),
            _buildInfoRow(
              'Satış Tarihi',
              dateFormat.format(sale.saleDate),
            ),
            _buildInfoRow(
              'Satış Fiyatı',
              currencyFormat.format(double.tryParse(sale.salePrice) ?? 0),
            ),
            _buildInfoRow('Ödeme Planı', sale.paymentPlan),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfCard(ContractModel contract) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sözleşme Belgesi', style: AppTextStyles.h3),
            const Divider(height: 24),
            if (contract.contractFile != null)
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                title: const Text('Sözleşme PDF'),
                subtitle: const Text('Tıklayın görüntülemek için'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openPdf(contract.contractFile!),
              )
            else
              Column(
                children: [
                  const Text('Henüz PDF oluşturulmamış'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _generatePdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF Oluştur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notlar', style: AppTextStyles.h3),
            const Divider(height: 24),
            Text(
              notes,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ GÜNCELLEME: `context` parametresi eklendi ve rol kontrolleri yapıldı
  Widget _buildActionsCard(BuildContext context, ContractModel contract) {
    // AuthProvider'ı burada dinliyoruz.
    final authProvider = context.watch<AuthProvider>();

    // Django'daki yetkilere göre (IsSalesManager, IsSalesRep) buton görünürlüklerini ayarlıyoruz
    bool canSign = (authProvider.isSalesRep || authProvider.isSalesManager || authProvider.isAdmin) &&
        (contract.status == ContractStatus.draft || contract.status == ContractStatus.pendingApproval);

    bool canCancel = (authProvider.isSalesManager || authProvider.isAdmin) &&
        (contract.status != ContractStatus.cancelled && contract.status != ContractStatus.signed);

    if (!canSign && !canCancel) {
      return const SizedBox.shrink(); // Gösterilecek buton yoksa hiçbir şey çizme
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İşlemler', style: AppTextStyles.h3),
            const Divider(height: 24),
            if (canSign)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _markAsSigned,
                  icon: const Icon(Icons.check),
                  label: const Text('İmzalandı Olarak İşaretle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            if (canSign && canCancel) const SizedBox(height: 12),
            if (canCancel)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _cancelContract,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Sözleşmeyi İptal Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Bir Hata Oluştu', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context
                    .read<ContractProvider>()
                    .loadContractById(widget.contractId);
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
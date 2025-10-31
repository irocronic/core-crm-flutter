// lib/features/contracts/presentation/screens/contract_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
        title: Text(
          'Sözleşmeyi İmzala',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Bu sözleşmeyi imzalanmış olarak işaretlemek istediğinizden emin misiniz?',
          style: Theme.of(context).textTheme.bodyMedium,
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
        title: Text(
          'Sözleşmeyi İptal Et',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'İptal nedenini belirtiniz:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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

  // ============================================================
  // 🔥 YENİ: DOCX EXPORT METODLARI
  // ============================================================

  /// Export seçeneklerini göster
  Future<void> _showExportOptions() async {
    final provider = context.read<ContractProvider>();

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Seçenekleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // DOCX Export & Share
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primary),
              title: const Text('DOCX Olarak Paylaş'),
              subtitle: const Text('Word dosyası olarak başkalarıyla paylaş'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAndShareDocx(provider);
              },
            ),

            const Divider(),

            // DOCX Export & Open
            ListTile(
              leading: const Icon(Icons.open_in_new, color: AppColors.success),
              title: const Text('DOCX Olarak Aç'),
              subtitle: const Text('Word dosyası olarak görüntüle'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAndOpenDocx(provider);
              },
            ),

            const Divider(),

            // DOCX Save to Downloads
            ListTile(
              leading: const Icon(Icons.download, color: AppColors.info),
              title: const Text('DOCX İndir'),
              subtitle: const Text('İndirilenler klasörüne kaydet'),
              onTap: () async {
                Navigator.pop(context);
                await _saveDocxToDownloads(provider);
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// DOCX export ve paylaş
  Future<void> _exportAndShareDocx(ContractProvider provider) async {
    try {
      // Loading dialog göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('DOCX oluşturuluyor...'),
                ],
              ),
            ),
          ),
        ),
      );

      final success = await provider.exportAndShareDocx(widget.contractId);

      if (mounted) {
        Navigator.pop(context); // Loading dialog'u kapat

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'DOCX başarıyla paylaşıldı'
                  : provider.error ?? 'DOCX paylaşılamadı',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Loading dialog'u kapat

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// DOCX export ve aç
  Future<void> _exportAndOpenDocx(ContractProvider provider) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('DOCX açılıyor...'),
                ],
              ),
            ),
          ),
        ),
      );

      final success = await provider.exportAndOpenDocx(widget.contractId);

      if (mounted) {
        Navigator.pop(context);

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.error ?? 'DOCX açılamadı',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// DOCX Downloads'a kaydet
  Future<void> _saveDocxToDownloads(ContractProvider provider) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('DOCX kaydediliyor...'),
                ],
              ),
            ),
          ),
        ),
      );

      final filePath = await provider.saveDocxToDownloads(widget.contractId);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              filePath != null
                  ? 'DOCX kaydedildi: ${filePath.split('/').last}'
                  : provider.error ?? 'DOCX kaydedilemedi',
            ),
            backgroundColor: filePath != null ? AppColors.success : AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ============================================================
  // YENİ METODLAR SONU
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Sözleşme Detayı',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 🔥 YENİ: Export button
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _showExportOptions,
            tooltip: 'Export',
          ),
        ],
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
            return Center(
              child: Text(
                'Sözleşme bulunamadı',
                style: theme.textTheme.bodyLarge,
              ),
            );
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
    final theme = Theme.of(context);

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
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contract.contractType.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel Bilgiler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
    final theme = Theme.of(context);
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
            Text(
              'Rezervasyon Bilgileri',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
              currencyFormat.format(reservation.depositAmount), // ✅ depositAmount kullan
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleCard(SaleDetails sale) {
    final theme = Theme.of(context);
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
            Text(
              'Satış Bilgileri',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
              currencyFormat.format(sale.salePrice), // ✅ Direkt double kullan
            ),
            _buildInfoRow('Ödeme Planı', sale.paymentPlan ?? '-'), // ✅ Null-safe
          ],
        ),
      ),
    );
  }

  Widget _buildPdfCard(ContractModel contract) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sözleşme Belgesi',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            if (contract.contractFile != null)
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                title: Text(
                  'Sözleşme PDF',
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Tıklayın görüntülemek için',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openPdf(contract.contractFile!),
              )
            else
              Column(
                children: [
                  Text(
                    'Henüz PDF oluşturulmamış',
                    style: theme.textTheme.bodyMedium,
                  ),
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
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notlar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Text(
              notes,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, ContractModel contract) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    bool canSign = (authProvider.isSalesRep || authProvider.isSalesManager || authProvider.isAdmin) &&
        (contract.status == ContractStatus.draft || contract.status == ContractStatus.pendingApproval);

    bool canCancel = (authProvider.isSalesManager || authProvider.isAdmin) &&
        (contract.status != ContractStatus.cancelled && contract.status != ContractStatus.signed);

    if (!canSign && !canCancel) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İşlemler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Bir Hata Oluştu',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
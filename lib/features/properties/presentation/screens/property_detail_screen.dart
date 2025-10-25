// lib/features/properties/presentation/screens/property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../../data/models/property_model.dart';
import '../widgets/document_list_widget.dart';
import '../widgets/payment_plan_list_widget.dart';
import '../widgets/add_document_dialog.dart';
import '../widgets/add_payment_plan_dialog.dart';
// YENİ IMPORT: Hesaplayıcı ekranı
import 'payment_plan_calculator_screen.dart';
// EKLENEN KOD: CustomDrawer bileşenini içe aktarma
import '../../../../shared/widgets/custom_drawer.dart';


class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;
  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadPropertyDetail(widget.propertyId);
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gayrimenkulü Sil'),
        content: const Text('Bu gayrimenkulü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<PropertyProvider>();
              final success = await provider.deleteProperty(widget.propertyId);

              if (mounted) {
                if (success) {
                  context.go('/properties');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gayrimenkul silindi'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.errorMessage ?? 'Silinemedi'), backgroundColor: Colors.red),
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

  void _showGenericDeleteDialog({
    required String title,
    required String content,
    required Future<bool> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<PropertyProvider>();
              final success = await onConfirm();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Başarıyla silindi' : provider.errorMessage ?? 'Silinemedi'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDocumentDialog(propertyId: widget.propertyId),
    );
  }

  void _showAddPaymentPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPaymentPlanDialog(propertyId: widget.propertyId),
    );
  }

  Future<void> _pickAndUploadImages() async {
    final provider = context.read<PropertyProvider>();
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty) {
        final success = await provider.uploadImages(widget.propertyId, pickedFiles);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Görseller başarıyla yüklendi' : provider.errorMessage ?? 'Yükleme başarısız'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görsel seçilemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      // EKLENEN KOD: CustomDrawer buraya eklenmiştir.
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Gayrimenkul Detayı'),
        actions: [
          if (authProvider.isAdmin || authProvider.isSalesManager) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/properties/${widget.propertyId}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteDialog,
            ),
          ]
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedProperty == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.selectedProperty == null) {
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

          final property = provider.selectedProperty;
          if (property == null) {
            return const Center(child: Text('Gayrimenkul bulunamadı'));
          }

          final projectName = property.project.name.isNotEmpty ? property.project.name : 'Proje Adı Yok';
          final statusText = property.statusDisplay ?? property.status;
          final blockText = property.block.isNotEmpty ? property.block : 'Blok Yok';
          final unitNumberText = property.unitNumber.isNotEmpty ? property.unitNumber : '-';
          final floorText = property.floor.toString();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(context, property.images, authProvider.isAdmin || authProvider.isSalesManager),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: property.statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        projectName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$blockText Blok - Kat: $floorText - No: $unitNumberText',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              title: 'Peşin Fiyat',
                              value: CurrencyFormatter.format(property.cashPrice),
                              icon: Icons.payments,
                              color: Colors.green,
                            ),
                          ),
                          if (property.installmentPrice != null) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoCard(
                                context,
                                title: 'Vadeli Fiyat',
                                value: CurrencyFormatter.format(property.installmentPrice!),
                                icon: Icons.credit_card,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      //******************************************
                      // YENİ BUTONUN KARTI
                      //******************************************
                      _buildPaymentCalculatorCard(context, property),
                      const SizedBox(height: 24),
                      //******************************************
                      // YENİ KART SONU
                      //******************************************

                      _buildSection(
                        context,
                        title: 'Özellikler',
                        children: [
                          _buildDetailRow('Tip', property.propertyTypeDisplay ?? property.propertyType),
                          _buildDetailRow('Oda Sayısı', property.roomCount),
                          _buildDetailRow('Brüt Alan', '${property.grossAreaM2.toStringAsFixed(2)} m²'),
                          _buildDetailRow('Net Alan', '${property.netAreaM2.toStringAsFixed(2)} m²'),
                          _buildDetailRow('Cephe', property.facadeDisplay ?? property.facade),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        context,
                        title: 'Ödeme Planları',
                        action: (authProvider.isAdmin || authProvider.isSalesManager)
                            ? IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: _showAddPaymentPlanDialog,
                        )
                            : null,
                        children: [
                          PaymentPlanListWidget(
                            paymentPlans: property.paymentPlans,
                            onDelete: (authProvider.isAdmin || authProvider.isSalesManager)
                                ? (planId) {
                              _showGenericDeleteDialog(
                                title: 'Ödeme Planını Sil',
                                content: 'Bu ödeme planını silmek istediğinizden emin misiniz?',
                                onConfirm: () => provider.deletePaymentPlan(property.id, planId),
                              );
                            }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        context,
                        title: 'Belgeler',
                        action: (authProvider.isAdmin || authProvider.isSalesManager)
                            ? IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: _showAddDocumentDialog,
                        )
                            : null,
                        children: [
                          DocumentListWidget(
                            documents: property.documents,
                            onDelete: (authProvider.isAdmin || authProvider.isSalesManager)
                                ? (docId) {
                              _showGenericDeleteDialog(
                                title: 'Belgeyi Sil',
                                content: 'Bu belgeyi silmek istediğinizden emin misiniz?',
                                onConfirm: () => provider.deleteDocument(property.id, docId),
                              );
                            }
                                : null,
                          ),
                        ],
                      ),
                      if (property.description != null && property.description!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSection(
                          context,
                          title: 'Açıklama',
                          children: [Text(property.description!)],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<PropertyProvider>(
        builder: (context, provider, _) {
          final property = provider.selectedProperty;
          if (property == null || !property.isAvailable) return const SizedBox();

          if (authProvider.isSalesRep || authProvider.isSalesManager || authProvider.isAdmin) {
            return FloatingActionButton.extended(
              onPressed: () => context.go('/reservations/new', extra: property),
              icon: const Icon(Icons.event_available),
              label: const Text('Rezervasyon Oluştur'),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  // YENİ WIDGET: Ödeme Planı Hesaplayıcı Kartı
  Widget _buildPaymentCalculatorCard(BuildContext context, PropertyModel property) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            // **** GÜNCELLEME BAŞLANGICI ****
            // Navigasyon sırasında 'extra' olarak cashPrice'ı gönderiyoruz
            context.push('/properties/${property.id}/calculate-plan', extra: property.cashPrice);
            // **** GÜNCELLEME SONU ****
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade600,
                  Colors.teal.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                    Icons.calculate,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ödeme Planı Çalış',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bugünkü değer hesaplaması yapın',
                        style: TextStyle(
                          color: Colors.white70,
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


  Widget _buildImageGallery(BuildContext context, List<PropertyImage> images, bool canEdit) {
    return Container(
      height: 250,
      color: Colors.grey[300],
      child: Stack(
        children: [
          if (images.isNotEmpty)
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image, size: 60));
                      },
                    ),
                    if (canEdit)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showGenericDeleteDialog(
                              title: 'Görseli Sil',
                              content: 'Bu görseli silmek istediğinizden emin misiniz?',
                              onConfirm: () => context.read<PropertyProvider>().deleteImage(widget.propertyId, image.id),
                            );
                          },
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.7)
                          ),
                        ),
                      ),
                  ],
                );
              },
            )
          else
            const Center(child: Icon(Icons.home_work, size: 80, color: Colors.grey)),
          if (canEdit)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _pickAndUploadImages,
                mini: true,
                child: const Icon(Icons.add_a_photo),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required List<Widget> children,
        Widget? action,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (action != null) action,
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
} // Sınıf sonu
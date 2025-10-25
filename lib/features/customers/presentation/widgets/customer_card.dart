// lib/features/customers/presentation/widgets/customer_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onTap;
  // 🔥 YENİ PARAMETRELER
  final VoidCallback? onLongPress;
  final bool isSelected;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    // 🔥 YENİ PARAMETRELER
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // 🔥 GÜNCELLEME: Seçiliyse rengi değiştir
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // 🔥 GÜNCELLEME: Seçiliyse kenarlık ekle
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        // 🔥 YENİ: Uzun basma eylemi
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - İsim ve Lead Status
              Row(
                children: [
                  // Avatar
                  // 🔥 GÜNCELLEME: Seçim modunda avatar yerine check ikonu göster
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isSelected
                        ? Theme.of(context).primaryColor
                        : customer.leadStatusColor.withOpacity(0.2),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : Text(
                      customer.initials,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: customer.leadStatusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // İsim ve Lead Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: customer.leadStatusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            customer.leadStatusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: customer.leadStatusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Win Probability (varsa)
                  if (customer.winProbability != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: customer.winProbabilityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: customer.winProbabilityColor,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '%${customer.winProbability!.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: customer.winProbabilityColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // İletişim Bilgileri
              _buildInfoRow(
                Icons.phone,
                customer.phoneNumber,
                Colors.blue,
              ),

              if (customer.email != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.email,
                  customer.email!,
                  Colors.green,
                ),
              ],

              // Bütçe (varsa)
              if (customer.budgetMin != null || customer.budgetMax != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.attach_money,
                  _formatBudget(),
                  Colors.orange,
                ),
              ],

              // İlgilendiği (varsa)
              if (customer.interestedIn != null &&
                  customer.interestedIn!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.home,
                  customer.interestedIn!,
                  Colors.purple,
                ),
              ],

              const SizedBox(height: 12),

              // Footer - Tarih, Aktivite, Randevu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Oluşturulma Tarihi
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd.MM.yyyy').format(customer.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Aktivite Sayısı
                  if (customer.activitiesCount != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.history,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.activitiesCount} aktivite',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Bugün Randevu Var mı?
                  if (customer.hasAppointmentToday == true) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 12,
                            color: Colors.red,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Bugün',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatBudget() {
    if (customer.budgetMin != null && customer.budgetMax != null) {
      return '${_formatCurrency(customer.budgetMin!)} - ${_formatCurrency(customer.budgetMax!)}';
    } else if (customer.budgetMin != null) {
      return 'Min: ${_formatCurrency(customer.budgetMin!)}';
    } else if (customer.budgetMax != null) {
      return 'Max: ${_formatCurrency(customer.budgetMax!)}';
    }
    return 'Belirtilmemiş';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
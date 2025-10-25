// /Users/koray/Desktop/Crm/flutter/flutter_realtyflow_crm/lib/features/contracts/presentation/widgets/contract_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/contract_model.dart';
import 'contract_status_badge.dart';

/// Contract Card Widget
class ContractCard extends StatelessWidget {
  final ContractModel contract;
  final VoidCallback onTap;

  const ContractCard({
    Key? key,
    required this.contract,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contract.contractNumber,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contract.contractType.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ContractStatusBadge(status: contract.status),
                ],
              ),

              const Divider(height: 24),

              // Customer & Property Info
              if (contract.reservationDetails != null) ...[
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Müşteri',
                  value: contract.reservationDetails!.customer.fullName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.home_outlined,
                  label: 'Mülk',
                  value: contract.reservationDetails!.property.title,
                ),
              ],

              if (contract.saleDetails != null) ...[
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Müşteri',
                  value: contract.saleDetails!.customer.fullName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.home_outlined,
                  label: 'Mülk',
                  value: contract.saleDetails!.property.title,
                ),
              ],

              const SizedBox(height: 8),

              // Date Info
              _buildInfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Sözleşme Tarihi',
                value: dateFormat.format(contract.contractDate),
              ),

              // PDF Status
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    contract.contractFile != null
                        ? Icons.picture_as_pdf
                        : Icons.picture_as_pdf_outlined,
                    size: 16,
                    color: contract.contractFile != null
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contract.contractFile != null
                        ? 'PDF Mevcut'
                        : 'PDF Yok',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: contract.contractFile != null
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
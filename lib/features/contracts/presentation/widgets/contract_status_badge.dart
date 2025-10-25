// lib/features/contracts/presentation/widgets/contract_status_badge.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/contract_model.dart';

/// Contract Status Badge Widget
class ContractStatusBadge extends StatelessWidget {
  final ContractStatus status;

  const ContractStatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: _getTextColor(),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: AppTextStyles.bodySmall.copyWith(
              color: _getTextColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ContractStatus.draft:
        return Colors.grey.shade200;
      case ContractStatus.pendingApproval:
        return Colors.orange.shade100;
      case ContractStatus.signed:
        return Colors.green.shade100;
      case ContractStatus.cancelled:
        return Colors.red.shade100;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case ContractStatus.draft:
        return Colors.grey.shade700;
      case ContractStatus.pendingApproval:
        return Colors.orange.shade800;
      case ContractStatus.signed:
        return Colors.green.shade800;
      case ContractStatus.cancelled:
        return Colors.red.shade800;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case ContractStatus.draft:
        return Icons.edit_outlined;
      case ContractStatus.pendingApproval:
        return Icons.pending_outlined;
      case ContractStatus.signed:
        return Icons.check_circle_outline;
      case ContractStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
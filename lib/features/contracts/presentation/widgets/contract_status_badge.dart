// lib/features/contracts/presentation/widgets/contract_status_badge.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/contract_model.dart';

/// Contract Status Badge Widget with Theme Support
class ContractStatusBadge extends StatelessWidget {
  final ContractStatus status;

  const ContractStatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: _getTextColor(isDark),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getTextColor(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Tema'ya göre arka plan rengi döndürür
  Color _getBackgroundColor(bool isDark) {
    switch (status) {
      case ContractStatus.draft:
        return isDark
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade200;

      case ContractStatus.pendingApproval:
        return isDark
            ? Colors.orange.shade900.withOpacity(0.4)
            : Colors.orange.shade100;

      case ContractStatus.signed:
        return isDark
            ? Colors.green.shade900.withOpacity(0.4)
            : Colors.green.shade100;

      case ContractStatus.cancelled:
        return isDark
            ? Colors.red.shade900.withOpacity(0.4)
            : Colors.red.shade100;
    }
  }

  /// Tema'ya göre metin/ikon rengi döndürür
  Color _getTextColor(bool isDark) {
    switch (status) {
      case ContractStatus.draft:
        return isDark
            ? Colors.grey.shade300
            : Colors.grey.shade700;

      case ContractStatus.pendingApproval:
        return isDark
            ? Colors.orange.shade200
            : Colors.orange.shade800;

      case ContractStatus.signed:
        return isDark
            ? Colors.green.shade200
            : Colors.green.shade800;

      case ContractStatus.cancelled:
        return isDark
            ? Colors.red.shade200
            : Colors.red.shade800;
    }
  }

  /// Status'a göre ikon döndürür
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
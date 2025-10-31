// lib/features/contracts/data/models/contract_extensions.dart

import 'package:flutter/material.dart';
import 'contract_model.dart';

/// Contract Status Extension Methods
extension ContractStatusX on ContractStatus {
  /// Sözleşme imzalanabilir mi?
  bool get canBeSigned =>
      this == ContractStatus.draft ||
          this == ContractStatus.pendingApproval;

  /// Sözleşme iptal edilebilir mi?
  bool get canBeCancelled =>
      this != ContractStatus.cancelled &&
          this != ContractStatus.signed;

  /// Sözleşme düzenlenebilir mi?
  bool get canBeEdited =>
      this == ContractStatus.draft;

  /// Sözleşme silinebilir mi?
  bool get canBeDeleted =>
      this == ContractStatus.draft ||
          this == ContractStatus.cancelled;

  /// Status için ikon
  IconData get icon {
    switch (this) {
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

  /// Status için renk (Light theme)
  Color get lightColor {
    switch (this) {
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

  /// Status için renk (Dark theme)
  Color get darkColor {
    switch (this) {
      case ContractStatus.draft:
        return Colors.grey.shade300;
      case ContractStatus.pendingApproval:
        return Colors.orange.shade200;
      case ContractStatus.signed:
        return Colors.green.shade200;
      case ContractStatus.cancelled:
        return Colors.red.shade200;
    }
  }

  /// Status için arka plan rengi (Light theme)
  Color get lightBackgroundColor {
    switch (this) {
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

  /// Status için arka plan rengi (Dark theme)
  Color get darkBackgroundColor {
    switch (this) {
      case ContractStatus.draft:
        return Colors.grey.shade800.withOpacity(0.5);
      case ContractStatus.pendingApproval:
        return Colors.orange.shade900.withOpacity(0.4);
      case ContractStatus.signed:
        return Colors.green.shade900.withOpacity(0.4);
      case ContractStatus.cancelled:
        return Colors.red.shade900.withOpacity(0.4);
    }
  }
}

/// Contract Type Extension Methods
extension ContractTypeX on ContractType {
  /// Tip için ikon
  IconData get icon {
    switch (this) {
      case ContractType.reservation:
        return Icons.bookmark_outlined;
      case ContractType.sales:
        return Icons.shopping_cart_outlined;
      case ContractType.preSales:
        return Icons.handshake_outlined;
    }
  }

  /// Tip için renk
  Color get color {
    switch (this) {
      case ContractType.reservation:
        return Colors.blue;
      case ContractType.sales:
        return Colors.green;
      case ContractType.preSales:
        return Colors.orange;
    }
  }
}

/// Contract Model Extension Methods
extension ContractModelX on ContractModel {
  /// Sözleşme aktif mi?
  bool get isActive =>
      status == ContractStatus.draft ||
          status == ContractStatus.pendingApproval ||
          status == ContractStatus.signed;

  /// Sözleşme beklemede mi?
  bool get isPending =>
      status == ContractStatus.draft ||
          status == ContractStatus.pendingApproval;

  /// Sözleşme tamamlanmış mı?
  bool get isCompleted =>
      status == ContractStatus.signed;

  /// Sözleşme iptal edilmiş mi?
  bool get isCancelled =>
      status == ContractStatus.cancelled;

  /// PDF mevcut mu?
  bool get hasPdf =>
      contractFile != null && contractFile!.isNotEmpty;

  /// Rezervasyon sözleşmesi mi?
  bool get isReservation =>
      contractType == ContractType.reservation;

  /// Satış sözleşmesi mi?
  bool get isSale =>
      contractType == ContractType.sales;

  /// Ön sözleşme mi?
  bool get isPreSale =>
      contractType == ContractType.preSales;

  /// Müşteri adı (varsa)
  String? get customerName {
    if (reservationDetails != null) {
      return reservationDetails!.customer.fullName;
    }
    if (saleDetails != null) {
      return saleDetails!.customer.fullName;
    }
    return null;
  }

  /// Mülk adı (varsa)
  String? get propertyName {
    if (reservationDetails != null) {
      return reservationDetails!.property.title;
    }
    if (saleDetails != null) {
      return saleDetails!.property.title;
    }
    return null;
  }

  /// Sözleşme tutarı (varsa)
  String? get amount {
    if (reservationDetails != null) {
      return reservationDetails!.reservationAmount;
    }
    if (saleDetails != null) {
      return saleDetails!.salePrice;
    }
    return null;
  }

  /// Sözleşme yaşı (gün cinsinden)
  int get ageInDays {
    return DateTime.now().difference(contractDate).inDays;
  }

  /// İmzalanma süresi (gün cinsinden, eğer imzalandıysa)
  int? get signedInDays {
    if (signedDate == null) return null;
    return signedDate!.difference(contractDate).inDays;
  }
}
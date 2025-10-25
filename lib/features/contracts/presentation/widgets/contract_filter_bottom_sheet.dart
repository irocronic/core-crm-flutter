// lib/features/contracts/presentation/widgets/contract_filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/contract_model.dart';
import '../providers/contract_provider.dart';

/// Contract Filter Bottom Sheet
class ContractFilterBottomSheet extends StatefulWidget {
  const ContractFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<ContractFilterBottomSheet> createState() =>
      _ContractFilterBottomSheetState();
}

class _ContractFilterBottomSheetState extends State<ContractFilterBottomSheet> {
  ContractType? _selectedType;
  ContractStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ContractProvider>();
    _selectedType = provider.filterType;
    _selectedStatus = provider.filterStatus;
    _startDate = provider.startDate;
    _endDate = provider.endDate;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _applyFilters() {
    final provider = context.read<ContractProvider>();

    provider.setFilterType(_selectedType);
    provider.setFilterStatus(_selectedStatus);
    provider.setDateRange(_startDate, _endDate);

    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrele',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contract Type Filter
                  Text('Sözleşme Tipi', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Tümü',
                        selected: _selectedType == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = null;
                          });
                        },
                      ),
                      ...ContractType.values.map((type) {
                        return _buildFilterChip(
                          label: type.displayName,
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? type : null;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),

                  const Divider(height: 32),

                  // Contract Status Filter
                  Text('Durum', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Tümü',
                        selected: _selectedStatus == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = null;
                          });
                        },
                      ),
                      ...ContractStatus.values.map((status) {
                        return _buildFilterChip(
                          label: status.displayName,
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = selected ? status : null;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),

                  const Divider(height: 32),

                  // Date Range Filter
                  Text('Tarih Aralığı', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectStartDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDate != null
                                ? dateFormat.format(_startDate!)
                                : 'Başlangıç',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectEndDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _endDate != null
                                ? dateFormat.format(_endDate!)
                                : 'Bitiş',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Temizle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Uygula'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
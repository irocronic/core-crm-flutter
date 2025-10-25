// lib/features/reports/presentation/widgets/report_filter_dialog.dart

import 'package:flutter/material.dart';
import '../../domain/entities/sales_report_entity.dart';

class ReportFilterDialog extends StatefulWidget {
  final ReportFilterEntity currentFilter;
  final Function(ReportFilterEntity) onApplyFilter;
  final bool isGenerateMode;

  const ReportFilterDialog({
    super.key,
    required this.currentFilter,
    required this.onApplyFilter,
    this.isGenerateMode = false,
  });

  @override
  State<ReportFilterDialog> createState() => _ReportFilterDialogState();
}

class _ReportFilterDialogState extends State<ReportFilterDialog> {
  late ReportPeriod _selectedPeriod;
  // YENİ: Rapor türü için state
  ReportType _selectedReportType = ReportType.salesSummary;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _category;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.currentFilter.period;
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
    _category = widget.currentFilter.category;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _getPeriodLabel(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.daily:
        return 'Günlük';
      case ReportPeriod.weekly:
        return 'Haftalık';
      case ReportPeriod.monthly:
        return 'Aylık';
      case ReportPeriod.yearly:
        return 'Yıllık';
      case ReportPeriod.custom:
        return 'Özel Tarih Aralığı';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isGenerateMode ? 'Yeni Rapor Oluştur' : 'Rapor Filtrele'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GÜNCELLEME: Sadece rapor oluştururken gösterilecek
            if (widget.isGenerateMode) ...[
              Text(
                'Rapor Türü',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReportType>(
                value: _selectedReportType,
                items: const [
                  DropdownMenuItem(
                    value: ReportType.salesSummary,
                    child: Text('Genel Satış Özeti'),
                  ),
                  DropdownMenuItem(
                    value: ReportType.repPerformance,
                    child: Text('Temsilci Performans Raporu'),
                  ),
                  DropdownMenuItem(
                    value: ReportType.customerSource,
                    child: Text('Müşteri Kaynak Raporu'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedReportType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
            ],

            Text(
              'Zaman Periyodu',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...ReportPeriod.values.map((period) => RadioListTile<ReportPeriod>(
              title: Text(_getPeriodLabel(period)),
              value: period,
              groupValue: _selectedPeriod,
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                  if (value != ReportPeriod.custom) {
                    _startDate = null;
                    _endDate = null;
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            )),
            if (_selectedPeriod == ReportPeriod.custom) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Tarih Aralığı',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _startDate != null
                      ? 'Başlangıç: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                      : 'Başlangıç Tarihi Seçin',
                ),
                onTap: () => _selectDate(context, true),
                dense: true,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _endDate != null
                      ? 'Bitiş: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                      : 'Bitiş Tarihi Seçin',
                ),
                onTap: () => _selectDate(context, false),
                dense: true,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedPeriod == ReportPeriod.custom &&
                (_startDate == null || _endDate == null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lütfen başlangıç ve bitiş tarihlerini seçin'),
                ),
              );
              return;
            }

            final filter = ReportFilterEntity(
              period: _selectedPeriod,
              startDate: _startDate,
              endDate: _endDate,
              category: _category,
              // YENİ: Seçilen rapor türünü de filtreye ekle
              reportTypeToGenerate: _selectedReportType,
            );

            widget.onApplyFilter(filter);
            // DİKKAT! Sadece parent showDialog'un sonucunu kullanacağız,
            // burada pop çağırmıyoruz (parent fonksiyon pop ile kapatacak).
          },
          child: Text(widget.isGenerateMode ? 'Oluştur' : 'Uygula'),
        ),
      ],
    );
  }
}
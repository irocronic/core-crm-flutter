// lib/features/customers/presentation/widgets/activity_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/validators.dart';
import '../providers/activity_provider.dart';

class ActivityFormDialog extends StatefulWidget {
  final int customerId;
  final VoidCallback? onSuccess;

  const ActivityFormDialog({
    super.key,
    required this.customerId,
    this.onSuccess,
  });

  @override
  State<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String _selectedActivityType = 'TELEFON';
  int _selectedOutcomeScore = 50;
  DateTime? _nextFollowUpDate;

  // Local UI state for meeting sub-type and loading indicator
  String? _subTypeDisplay;
  bool _isCheckingSubType = false;

  final List<Map<String, dynamic>> _activityTypes = [
    {'value': 'GORUSME', 'label': 'Yüz Yüze Görüşme', 'icon': Icons.person},
    {'value': 'TELEFON', 'label': 'Telefon Görüşmesi', 'icon': Icons.phone},
    {'value': 'EMAIL', 'label': 'E-posta', 'icon': Icons.email},
    {'value': 'RANDEVU', 'label': 'Randevu', 'icon': Icons.event},
    {'value': 'WHATSAPP', 'label': 'WhatsApp', 'icon': Icons.chat},
  ];

  final List<Map<String, dynamic>> _outcomeScores = [
    {'value': 10, 'label': '%10 - Düşük İlgi', 'color': Colors.red},
    {'value': 25, 'label': '%25 - Az İlgili', 'color': Colors.orange},
    {'value': 50, 'label': '%50 - Orta Düzey İlgi', 'color': Colors.blue},
    {'value': 75, 'label': '%75 - Yüksek İlgi', 'color': Colors.green},
    {'value': 100, 'label': '%100 - Çok Yakın', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    // İlk açılışta TELEFON seçili, alt tür kontrolü gerekmez
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // 🔥 GÜNCELLEME: Tam widget lifecycle yönetimi
  Future<void> _checkAndSetSubType(String activityType) async {
    // Sadece 'Yüz Yüze Görüşme' seçiliyse kontrol et
    if (activityType != 'GORUSME') {
      if (mounted) {
        setState(() {
          _subTypeDisplay = null;
          _isCheckingSubType = false;
        });
      }
      return;
    }

    // Widget dispose olmamışsa devam et
    if (!mounted) return;

    setState(() {
      _isCheckingSubType = true;
      _subTypeDisplay = null;
    });

    try {
      final activityProvider = context.read<ActivityProvider>();

      // Async işlem başlat
      await activityProvider.checkMeetingSubType(widget.customerId);

      // Widget hala mount edilmiş mi kontrol et
      if (!mounted) return;

      // Provider'dan sonucu al
      final providerResult = activityProvider.meetingSubTypeResult;

      setState(() {
        _subTypeDisplay = providerResult ?? 'Kontrol Edilemedi';
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Alt tür kontrolünde genel hata (Dialog): $e');
      debugPrint('📄 Stack Trace: $stackTrace');

      // Widget hala mount edilmiş mi kontrol et
      if (!mounted) return;

      setState(() {
        _subTypeDisplay = 'Kontrol Edilemedi';
      });
    } finally {
      // Widget hala mount edilmiş mi kontrol et
      if (!mounted) return;

      setState(() {
        _isCheckingSubType = false;
      });
    }
  }

  Future<void> _selectFollowUpDate() async {
    // Widget mount kontrolü
    if (!mounted) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextFollowUpDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    // Widget hala mount edilmiş mi kontrol et
    if (!mounted || picked == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _nextFollowUpDate ?? now.add(const Duration(hours: 1)),
      ),
    );

    // Widget hala mount edilmiş mi kontrol et
    if (!mounted || time == null) return;

    setState(() {
      _nextFollowUpDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _handleSubmit() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) return;

    // Widget mount kontrolü
    if (!mounted) return;

    final data = <String, dynamic>{
      'customer': widget.customerId,
      'activity_type': _selectedActivityType,
      'notes': _notesController.text.trim(),
      'outcome_score': _selectedOutcomeScore,
    };

    if (_nextFollowUpDate != null) {
      data['next_follow_up_date'] = _nextFollowUpDate!.toIso8601String();
    }

    final provider = context.read<ActivityProvider>();

    final success = await provider.createActivity(data);

    // Widget hala mount edilmiş mi kontrol et
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktivite başarıyla eklendi'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Aktivite eklenemedi'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ActivityProvider'ı dinleyerek yüklenme durumunu al
    final bool isLoadingSubmit = context.watch<ActivityProvider>().isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yeni Aktivite',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Müşteri görüşme kaydı',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Activity Type
                Text(
                  'Aktivite Tipi *',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _activityTypes.map((type) {
                    final isSelected = _selectedActivityType == type['value'];
                    return InkWell(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _selectedActivityType = type['value'];
                          });
                          // Async işlem başlat
                          _checkAndSetSubType(_selectedActivityType);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type['icon'] as IconData,
                              size: 18,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type['label'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Alt Tür Bilgisi
                Visibility(
                  visible: _selectedActivityType == 'GORUSME',
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _isCheckingSubType
                        ? const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Görüşme durumu kontrol ediliyor...'),
                      ],
                    )
                        : TextFormField(
                      key: ValueKey(_subTypeDisplay),
                      initialValue: _subTypeDisplay ?? '-',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Görüşme Türü',
                        prefixIcon: Icon(
                          _subTypeDisplay == 'İlk Gelen'
                              ? Icons.fiber_new_outlined
                              : _subTypeDisplay == 'Ara Gelen'
                              ? Icons.replay_outlined
                              : _subTypeDisplay == 'Hata: API Sorunu'
                              ? Icons.error_outline
                              : Icons.help_outline,
                          color: _subTypeDisplay == 'İlk Gelen'
                              ? Colors.green
                              : _subTypeDisplay == 'Ara Gelen'
                              ? Colors.orange
                              : _subTypeDisplay == 'Hata: API Sorunu'
                              ? Colors.red
                              : Colors.grey,
                        ),
                        filled: true,
                        fillColor: _subTypeDisplay == 'Hata: API Sorunu'
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Görüşme Notları *',
                    hintText: 'Görüşme detaylarını yazın...',
                    prefixIcon: const Icon(Icons.note_alt),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Görüşme notları'),
                ),

                const SizedBox(height: 24),

                // Outcome Score
                Text(
                  'Müşteri İlgi Seviyesi *',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._outcomeScores.map((score) {
                  final isSelected = _selectedOutcomeScore == score['value'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _selectedOutcomeScore = score['value'];
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (score['color'] as Color).withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? score['color'] as Color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: score['value'],
                              groupValue: _selectedOutcomeScore,
                              onChanged: (value) {
                                if (mounted && value != null) {
                                  setState(() {
                                    _selectedOutcomeScore = value;
                                  });
                                }
                              },
                              activeColor: score['color'] as Color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                score['label'],
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? score['color'] as Color
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Next Follow Up Date
                Text(
                  'Sonraki Takip Tarihi (Opsiyonel)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectFollowUpDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _nextFollowUpDate == null
                                ? 'Tarih seçin'
                                : DateFormat('dd.MM.yyyy HH:mm', 'tr_TR')
                                .format(_nextFollowUpDate!),
                            style: TextStyle(
                              color: _nextFollowUpDate == null
                                  ? Colors.grey[600]
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (_nextFollowUpDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _nextFollowUpDate = null;
                                });
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoadingSubmit
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isLoadingSubmit ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoadingSubmit
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Aktivite Ekle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
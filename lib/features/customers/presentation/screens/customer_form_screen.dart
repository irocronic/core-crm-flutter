// lib/features/customers/presentation/screens/customer_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../providers/customer_provider.dart';
// EKLENEN KOD: CustomDrawer bileşenini içe aktarma
import '../../../../shared/widgets/custom_drawer.dart';

class CustomerFormScreen extends StatefulWidget {
  final int? customerId;

  const CustomerFormScreen({
    super.key,
    this.customerId,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _interestedInController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedSource = 'DIGER';

  final List<Map<String, String>> _sources = [
    {'value': 'REFERANS', 'label': 'Referans'},
    {'value': 'WEB_SITESI', 'label': 'Web Sitesi'},
    {'value': 'SOSYAL_MEDYA', 'label': 'Sosyal Medya'},
    {'value': 'TABELA', 'label': 'Tabela'},
    {'value': 'OFIS_ZIYARETI', 'label': 'Ofis Ziyareti'},
    {'value': 'FUAR', 'label': 'Fuar'},
    {'value': 'DIGER', 'label': 'Diğer'},
  ];

  bool get isEditing => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadCustomerData();
    }
  }

  void _loadCustomerData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CustomerProvider>();
      await provider.loadCustomerDetail(widget.customerId!);

      final customer = provider.selectedCustomer;
      if (customer != null && mounted) {
        setState(() {
          _fullNameController.text = customer.fullName;
          _phoneController.text = customer.phoneNumber;
          _emailController.text = customer.email ?? '';
          _interestedInController.text = customer.interestedIn ?? '';

          _budgetMinController.text = customer.budgetMin != null
              ? customer.budgetMin!.toStringAsFixed(0)
              : '';
          _budgetMaxController.text = customer.budgetMax != null
              ? customer.budgetMax!.toStringAsFixed(0)
              : '';

          _notesController.text = customer.notes ?? '';
          _selectedSource = customer.source;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _interestedInController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'full_name': _fullNameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'source': _selectedSource,
      if (_emailController.text.trim().isNotEmpty) 'email': _emailController.text.trim(),
      if (_interestedInController.text.trim().isNotEmpty) 'interested_in': _interestedInController.text.trim(),
      'budget_min': double.tryParse(_budgetMinController.text.trim()),
      'budget_max': double.tryParse(_budgetMaxController.text.trim()),
      if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
    };

    final provider = context.read<CustomerProvider>();
    bool success = false;

    if (isEditing) {
      success = await provider.updateCustomer(widget.customerId!, data);
    } else {
      success = await provider.createCustomer(data);
    }

    if (!mounted) return;

    if (success) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Müşteri güncellendi' : 'Müşteri eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // ✅ GÜNCELLEME: Genel hata mesajını sadece validation hatası yoksa göster.
      // Hatalar zaten form alanlarında gösterilecek.
      if (provider.validationErrors.isEmpty) {
        _showErrorSnackBar(provider.errorMessage ?? 'İşlem başarısız');
      }
      // Formun yeniden çizilerek hataları göstermesi için setState çağırıyoruz.
      setState(() {});
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ✅ YENİ: Hata mesajını alan helper fonksiyon
  String? _getErrorText(String fieldName) {
    // `read` kullanıyoruz çünkü bu metot build içinde değil, anlık değeri okuması yeterli.
    final errors = context.read<CustomerProvider>().validationErrors;
    if (errors.containsKey(fieldName)) {
      // API'den gelen hata bir liste olabilir, ilkini alıyoruz.
      final errorValue = errors[fieldName];
      if (errorValue is List && errorValue.isNotEmpty) {
        return errorValue.first;
      }
      return errorValue.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ GÜNCELLEME: `Consumer` ile sarmalayarak `validationErrors` değiştiğinde
    // arayüzün yeniden çizilmesini sağlıyoruz.
    return Consumer<CustomerProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          // EKLENEN KOD: CustomDrawer buraya eklenmiştir.
          drawer: const CustomDrawer(),
          appBar: AppBar(
            title: Text(isEditing ? 'Müşteri Düzenle' : 'Yeni Müşteri'),
          ),
          body: provider.isLoading && isEditing
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Ad Soyad *',
                      prefixIcon: const Icon(Icons.person),
                      errorText: _getErrorText('full_name'), // ✅ HATA GÖSTERİMİ
                    ),
                    validator: (value) =>
                        Validators.required(value, fieldName: 'Ad Soyad'),
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Telefon *',
                      prefixIcon: const Icon(Icons.phone),
                      hintText: '+90 555 123 45 67',
                      errorText: _getErrorText('phone_number'), // ✅ HATA GÖSTERİMİ
                    ),
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: const Icon(Icons.email),
                      errorText: _getErrorText('email'), // ✅ HATA GÖSTERİMİ
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return Validators.email(value);
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedSource,
                    decoration: InputDecoration(
                      labelText: 'Müşteri Kaynağı *',
                      prefixIcon: const Icon(Icons.source),
                      errorText: _getErrorText('source'), // ✅ HATA GÖSTERİMİ
                    ),
                    items: _sources.map((source) {
                      return DropdownMenuItem(
                        value: source['value'],
                        child: Text(source['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSource = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _interestedInController,
                    decoration: InputDecoration(
                      labelText: 'İlgilendiği Daire Tipleri',
                      prefixIcon: const Icon(Icons.home),
                      hintText: 'Örn: 2+1, 3+1',
                      errorText: _getErrorText('interested_in'), // ✅ HATA GÖSTERİMİ
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _budgetMinController,
                          decoration: InputDecoration(
                            labelText: 'Min. Bütçe',
                            prefixIcon: const Icon(Icons.attach_money),
                            suffixText: '₺',
                            errorText: _getErrorText('budget_min'), // ✅ HATA GÖSTERİMİ
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (double.tryParse(value) == null) {
                                return 'Geçerli bir sayı girin';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _budgetMaxController,
                          decoration: InputDecoration(
                            labelText: 'Max. Bütçe',
                            prefixIcon: const Icon(Icons.attach_money),
                            suffixText: '₺',
                            errorText: _getErrorText('budget_max'), // ✅ HATA GÖSTERİMİ
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (double.tryParse(value) == null) {
                                return 'Geçerli bir sayı girin';
                              }

                              final minText = _budgetMinController.text.trim();
                              if (minText.isNotEmpty) {
                                final min = double.tryParse(minText);
                                final max = double.tryParse(value);

                                if (min != null && max != null && max < min) {
                                  return 'Max bütçe min\'den küçük olamaz';
                                }
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notlar',
                      prefixIcon: const Icon(Icons.note),
                      alignLabelWithHint: true,
                      errorText: _getErrorText('notes'), // ✅ HATA GÖSTERİMİ
                    ),
                    maxLines: 4,
                  ),

                  const SizedBox(height: 24),

                  // Genel bir hata varsa (alanlarla ilgili değilse) burada gösterilebilir
                  if (provider.errorMessage != null && provider.validationErrors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      child: provider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        isEditing ? 'Güncelle' : 'Kaydet',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
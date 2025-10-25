// lib/features/reservations/presentation/screens/reservation_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/reservation_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../properties/presentation/providers/property_provider.dart';
import '../../../properties/data/models/property_model.dart';
// **** GÜNCELLEME BAŞLANGICI ****
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../users/presentation/providers/user_provider.dart';
// **** GÜNCELLEME SONU ****

class ReservationFormScreen extends StatefulWidget {
  final PropertyModel? initialProperty;

  const ReservationFormScreen({
    super.key,
    this.initialProperty,
  });

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCustomerId;
  int? _selectedPropertyId;
  int? _selectedPaymentPlanId;
  // **** GÜNCELLEME BAŞLANGICI ****
  int? _selectedSalesRepId;
  // **** GÜNCELLEME SONU ****

  final _depositAmountController = TextEditingController();
  final _receiptNumberController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'NAKIT';
  DateTime? _expiryDate;

  bool _isLoadingCustomers = true;
  bool _isLoadingProperties = true;
  bool _isLoadingPaymentPlans = false;
  // **** GÜNCELLEME BAŞLANGICI ****
  bool _isLoadingUsers = true;
  // **** GÜNCELLEME SONU ****

  @override
  void initState() {
    super.initState();
    if (widget.initialProperty != null) {
      _selectedPropertyId = widget.initialProperty!.id;
    }
    _loadInitialData();
    if (_selectedPropertyId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPaymentPlans(_selectedPropertyId!);
      });
    }
  }

  Future<void> _loadInitialData() async {
    // **** GÜNCELLEME BAŞLANGICI ****
    // AuthProvider ve UserProvider'ı çağır
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    // Varsayılan satış temsilcisini giriş yapan kullanıcı olarak ata
    setState(() {
      _selectedSalesRepId = authProvider.currentUser?.id;
    });

    // Tüm verileri paralel olarak yükle
    await Future.wait([
      context.read<CustomerProvider>().loadCustomers(refresh: true),
      context.read<PropertyProvider>().loadAvailableProperties(refresh: true),
      // Satış müdürleri ve adminler için temsilci listesini yükle
      if (authProvider.isAdmin || authProvider.isSalesManager)
        userProvider.loadSalesReps(),
    ]);
    // **** GÜNCELLEME SONU ****

    if (mounted) {
      setState(() {
        _isLoadingCustomers = false;
        _isLoadingProperties = false;
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _loadPaymentPlans(int propertyId) async {
    setState(() {
      _isLoadingPaymentPlans = true;
      _selectedPaymentPlanId = null;
      _depositAmountController.clear();
    });

    try {
      await context.read<PropertyProvider>().loadPropertyDetail(propertyId);

      if (mounted) {
        setState(() {
          _isLoadingPaymentPlans = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPaymentPlans = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ödeme planları yüklenemedi: $e')),
        );
      }
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen müşteri seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen gayrimenkul seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ödeme planı seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // **** GÜNCELLEME BAŞLANGICI ****
    // 'sales_rep' alanı data map'ine ekleniyor.
    final data = {
      'customer': _selectedCustomerId,
      'property': _selectedPropertyId,
      'payment_plan_selected': _selectedPaymentPlanId,
      'deposit_amount': double.parse(_depositAmountController.text.trim()),
      'deposit_payment_method': _selectedPaymentMethod,
      'deposit_receipt_number': _receiptNumberController.text.trim(),
      'notes': _notesController.text.trim(),
      'sales_rep': _selectedSalesRepId, // Bu satır eklendi
    };
    // **** GÜNCELLEME SONU ****

    if (_expiryDate != null) {
      data['expiry_date'] = _expiryDate!.toIso8601String().split('T')[0];
    }

    final provider = context.read<ReservationProvider>();
    final success = await provider.createReservation(data);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervasyon başarıyla oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/reservations');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Rezervasyon oluşturulamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _depositAmountController.dispose();
    _receiptNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Rezervasyon'),
      ),
      body: _isLoadingCustomers || _isLoadingProperties || _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomerSelector(),
              const SizedBox(height: 16),
              // **** GÜNCELLEME BAŞLANGICI ****
              // Yeni widget çağrısı
              _buildSalesRepSelector(),
              const SizedBox(height: 16),
              // **** GÜNCELLEME SONU ****
              _buildPropertySelector(),
              const SizedBox(height: 16),
              _buildPaymentPlanSelector(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _depositAmountController,
                decoration: const InputDecoration(
                  labelText: 'Kaparo Bedeli (TL) *',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: '₺',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    Validators.numeric(value, fieldName: 'Kaparo bedeli'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Ödeme Yöntemi *',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(value: 'NAKIT', child: Text('Nakit')),
                  DropdownMenuItem(
                      value: 'KREDI_KARTI', child: Text('Kredi Kartı')),
                  DropdownMenuItem(
                      value: 'DEKONT',
                      child: Text('Banka Havalesi/Dekont')),
                  DropdownMenuItem(value: 'CEK', child: Text('Çek')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _receiptNumberController,
                decoration: const InputDecoration(
                  labelText: 'Makbuz/Dekont No',
                  prefixIcon: Icon(Icons.receipt),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectExpiryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Son Geçerlilik Tarihi',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _expiryDate == null
                        ? 'Tarih seçin (Opsiyonel)'
                        : '${_expiryDate!.day}.${_expiryDate!.month}.${_expiryDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Consumer<ReservationProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                      provider.isLoading ? null : _handleSubmit,
                      child: provider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Text(
                        'Rezervasyon Oluştur',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customers = provider.customers;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Müşteri Seçimi *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedCustomerId,
              decoration: const InputDecoration(
                labelText: 'Müşteri',
                prefixIcon: Icon(Icons.person),
                hintText: 'Müşteri seçin',
              ),
              items: customers.map((customer) {
                return DropdownMenuItem<int>(
                  value: customer.id,
                  child: Text(
                    '${customer.fullName} - ${customer.phoneNumber}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomerId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen müşteri seçin';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  // **** GÜNCELLEME BAŞLANGICI ****
  // Yeni widget
  Widget _buildSalesRepSelector() {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final currentUser = authProvider.currentUser;

    // Sadece Admin ve Satış Müdürü bu alanı değiştirebilir
    if (authProvider.isAdmin || authProvider.isSalesManager) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Satış Temsilcisi *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedSalesRepId,
            decoration: const InputDecoration(
              labelText: 'Satış Temsilcisi',
              prefixIcon: Icon(Icons.person_pin_outlined),
              hintText: 'Temsilci seçin',
            ),
            items: userProvider.salesReps.map((rep) {
              return DropdownMenuItem<int>(
                value: rep.id,
                child: Text(rep.fullName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSalesRepId = value;
              });
            },
            validator: (value) =>
            value == null ? 'Lütfen bir temsilci seçin' : null,
          ),
        ],
      );
    }

    // Diğer roller için (Satış Temsilcisi vb.) sadece kendi adını gösteren, değiştirilemez bir alan
    return TextFormField(
      initialValue: currentUser?.fullName ?? 'Bilinmiyor',
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Satış Temsilcisi',
        prefixIcon: Icon(Icons.person),
        filled: true,
      ),
    );
  }
  // **** GÜNCELLEME SONU ****

  Widget _buildPropertySelector() {
    return Consumer<PropertyProvider>(
      builder: (context, provider, _) {
        final properties =
        provider.properties.where((p) => p.isAvailable).toList();

        if (widget.initialProperty != null &&
            !properties.any((p) => p.id == widget.initialProperty!.id)) {
          properties.insert(0, widget.initialProperty!);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gayrimenkul Seçimi *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedPropertyId,
              decoration: const InputDecoration(
                labelText: 'Gayrimenkul',
                prefixIcon: Icon(Icons.home_work),
                hintText: 'Müsait gayrimenkul seçin',
              ),
              items: properties.map((property) {
                return DropdownMenuItem<int>(
                  value: property.id,
                  child: Text(
                    '${property.project.name} - ${property.block} Blok - No:${property.unitNumber}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPropertyId = value;
                });
                if (value != null) {
                  _loadPaymentPlans(value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen gayrimenkul seçin';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentPlanSelector() {
    if (_selectedPropertyId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Ödeme planlarını görmek için önce gayrimenkul seçin.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_isLoadingPaymentPlans) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<PropertyProvider>(
      builder: (context, provider, _) {
        final property = provider.selectedProperty;

        if (property == null || property.id != _selectedPropertyId) {
          return const SizedBox.shrink();
        }

        final hasBackendPlans = property.paymentPlans.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ödeme Planı *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (hasBackendPlans)
              ...property.paymentPlans.map((plan) {
                return _buildPaymentPlanCard(
                  id: plan.id,
                  name: plan.name,
                  price: (plan.details['installment_price'] ??
                      plan.details['cash_price'] ??
                      property.cashPrice)
                      .toDouble(),
                  isSelected: _selectedPaymentPlanId == plan.id,
                  onTap: () {
                    setState(() {
                      _selectedPaymentPlanId = plan.id;
                      _depositAmountController.text =
                          (plan.details['down_payment_amount'] ?? '')
                              .toString();
                    });
                  },
                );
              }).toList(),
            if (!hasBackendPlans) ...[
              _buildPaymentPlanCard(
                id: -1,
                name: 'Peşin Ödeme',
                price: property.cashPrice,
                isSelected: _selectedPaymentPlanId == -1,
                onTap: () {
                  setState(() {
                    _selectedPaymentPlanId = -1;
                    _depositAmountController.text =
                        property.cashPrice.toStringAsFixed(0);
                  });
                },
              ),
              const SizedBox(height: 8),
              if (property.installmentPrice != null)
                _buildPaymentPlanCard(
                  id: -2,
                  name: 'Vadeli Ödeme',
                  price: property.installmentPrice!,
                  isSelected: _selectedPaymentPlanId == -2,
                  onTap: () {
                    setState(() {
                      _selectedPaymentPlanId = -2;
                      _depositAmountController.clear();
                    });
                  },
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPaymentPlanCard({
    required int id,
    required String name,
    required double price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color:
            isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: id,
              groupValue: _selectedPaymentPlanId,
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(price),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
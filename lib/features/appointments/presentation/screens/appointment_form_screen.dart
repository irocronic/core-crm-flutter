// lib/features/appointments/presentation/screens/appointment_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../users/presentation/providers/user_provider.dart';
import '../providers/appointment_provider.dart';

class AppointmentFormScreen extends StatefulWidget {
  // Düzenleme modu için opsiyonel ID
  // final int? appointmentId;

  const AppointmentFormScreen({
    super.key,
    // this.appointmentId,
  });

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  int? _selectedCustomerId;
  int? _selectedSalesRepId;
  DateTime? _selectedDateTime;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  // bool get isEditing => widget.appointmentId != null; // Düzenleme modu için
  bool _isLoadingDependencies = true; // Müşteri ve Temsilci yükleniyor mu?

  @override
  void initState() {
    super.initState();
    // build tamamlandıktan sonra bağımlılıkları yükle (notifyListeners() build sırasında setState hatasını önler)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDependencies();
    });
  }

  Future<void> _loadDependencies() async {
    final authProvider = context.read<AuthProvider>();
    final customerProvider = context.read<CustomerProvider>();
    final userProvider = context.read<UserProvider>();

    // Varsayılan satış temsilcisini ata (kendisi)
    setState(() {
      _selectedSalesRepId = authProvider.currentUser?.id;
    });

    // Müşterileri ve (gerekirse) satış temsilcilerini yükle
    try {
      await Future.wait([
        customerProvider.loadCustomers(refresh: true), // Tüm müşterileri yükle
        if (authProvider.isAdmin || authProvider.isSalesManager)
          userProvider.loadSalesReps(), // Müdür veya admin ise temsilcileri yükle
      ]);
    } catch (e) {
      _showErrorSnackBar('Gerekli veriler yüklenemedi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDependencies = false;
        });
      }
    }

    // if (isEditing) {
    //   _loadAppointmentData(); // Düzenleme modu için veri yükleme
    // }
  }

  // void _loadAppointmentData() { // Düzenleme modu için
  //   // ... Randevu verilerini yükleme ve controller'ları doldurma ...
  // }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now.add(const Duration(hours: 1))),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      _showErrorSnackBar('Lütfen bir müşteri seçin.');
      return;
    }
    if (_selectedSalesRepId == null) {
      _showErrorSnackBar('Lütfen bir satış temsilcisi seçin.');
      return;
    }
    if (_selectedDateTime == null) {
      _showErrorSnackBar('Lütfen randevu tarih ve saatini seçin.');
      return;
    }

    final data = {
      'customer': _selectedCustomerId,
      'sales_rep': _selectedSalesRepId,
      // API'nin beklediği format (örn: ISO 8601)
      'appointment_date': _selectedDateTime!.toIso8601String(),
      'location': _locationController.text.trim(),
      'notes': _notesController.text.trim(),
    };

    final provider = context.read<AppointmentProvider>();
    bool success = false;

    // if (isEditing) {
    //   // success = await provider.updateAppointment(widget.appointmentId!, data);
    // } else {
    try {
      success = await provider.createAppointment(data);
    } catch (e) {
      // provider.createAppointment zaten hata yakalayıp errorMessage setliyorsa burada ek işlem yapmaya gerek yok
      success = false;
    }
    // }

    if (!mounted) return;

    if (success) {
      // Takvim ekranındaki listeyi yenilemek için
      try {
        await provider.loadAppointments(date: _selectedDateTime);
      } catch (_) {
        // yenileme başarısız olursa bile kullanıcıya başarılı mesajı göster
      }

      // Güvenli şekilde pop veya yönlendir
      if (Navigator.of(context).canPop()) {
        context.pop();
      } else {
        // Eğer geri dönecek route yoksa ana randevular sayfasına yönlendir
        context.go('/appointments');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(/*isEditing ? 'Randevu güncellendi' :*/ 'Randevu başarıyla oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'İşlem başarısız oldu');
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

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = context.watch<AppointmentProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(/*isEditing ? 'Randevuyu Düzenle' :*/ 'Yeni Randevu Oluştur'),
      ),
      body: _isLoadingDependencies
          ? const LoadingIndicator(message: 'Müşteriler ve temsilciler yükleniyor...')
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomerSelector(),
              const SizedBox(height: 16),
              _buildSalesRepSelector(authProvider),
              const SizedBox(height: 16),
              _buildDateTimePicker(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Randevu Yeri',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'Örn: Satış Ofisi, Şantiye',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: appointmentProvider.isLoading ? null : _handleSubmit,
                  child: appointmentProvider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Text(/*isEditing ? 'Güncelle' :*/ 'Randevuyu Kaydet'),
                ),
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
        if (provider.isLoading && provider.customers.isEmpty) {
          return const InputDecorator(
            decoration: InputDecoration(
              labelText: 'Müşteri *',
              prefixIcon: Icon(Icons.person_outline),
              contentPadding: EdgeInsets.zero, // İçeriği sıfırla
            ),
            child: SizedBox(
                height: 20, // Yükseklik ayarı
                child: Center(child: LinearProgressIndicator())),
          );
        }
        return DropdownButtonFormField<int>(
          value: _selectedCustomerId,
          decoration: const InputDecoration(
            labelText: 'Müşteri *',
            prefixIcon: Icon(Icons.person_outline),
            hintText: 'Müşteri seçin',
          ),
          items: provider.customers.map((customer) {
            return DropdownMenuItem<int>(
              value: customer.id,
              child: Text(
                '${customer.fullName} (${customer.phoneNumber})',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCustomerId = value;
            });
          },
          validator: (value) => value == null ? 'Lütfen bir müşteri seçin' : null,
          isExpanded: true, // Uzun isimlerin sığması için
        );
      },
    );
  }

  Widget _buildSalesRepSelector(AuthProvider authProvider) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = authProvider.currentUser;

    // Sadece Admin ve Satış Müdürü bu alanı değiştirebilir
    if (authProvider.isAdmin || authProvider.isSalesManager) {
      if (userProvider.isLoading && userProvider.salesReps.isEmpty) {
        return const InputDecorator(
          decoration: InputDecoration(
            labelText: 'Satış Temsilcisi *',
            prefixIcon: Icon(Icons.support_agent_outlined),
            contentPadding: EdgeInsets.zero,
          ),
          child: SizedBox(
              height: 20,
              child: Center(child: LinearProgressIndicator())),
        );
      }
      return DropdownButtonFormField<int>(
        value: _selectedSalesRepId,
        decoration: const InputDecoration(
          labelText: 'Satış Temsilcisi *',
          prefixIcon: Icon(Icons.support_agent_outlined),
          hintText: 'Temsilci seçin',
        ),
        items: userProvider.salesReps.map((rep) {
          return DropdownMenuItem<int>(
            value: rep.id,
            child: Text(rep.fullName, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSalesRepId = value;
          });
        },
        validator: (value) =>
        value == null ? 'Lütfen bir temsilci seçin' : null,
        isExpanded: true,
      );
    }

    // Diğer roller için (Satış Temsilcisi vb.) sadece kendi adını gösteren, değiştirilemez alan
    return TextFormField(
      initialValue: currentUser?.fullName ?? 'Bilinmiyor',
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Satış Temsilcisi',
        prefixIcon: Icon(Icons.person),
        filled: true,
        fillColor: Colors.black12, // Değiştirilemez olduğunu belirtmek için
      ),
    );
  }

  Widget _buildDateTimePicker() {
    final dateFormat = DateFormat('dd MMMM yyyy, EEEE HH:mm', 'tr_TR');
    return InkWell(
      onTap: _selectDateTime,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Randevu Tarihi ve Saati *',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _selectedDateTime == null
              ? 'Tarih ve saat seçin'
              : dateFormat.format(_selectedDateTime!),
          style: TextStyle(
            fontSize: 16,
            color: _selectedDateTime == null ? Colors.grey[600] : null,
          ),
        ),
      ),
    );
  }
}
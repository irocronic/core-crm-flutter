// lib/features/settings/presentation/screens/seller_company_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/seller_company_provider.dart';

class SellerCompanyFormScreen extends StatefulWidget {
  final int? companyId;

  const SellerCompanyFormScreen({
    super.key,
    this.companyId,
  });

  @override
  State<SellerCompanyFormScreen> createState() => _SellerCompanyFormScreenState();
}

class _SellerCompanyFormScreenState extends State<SellerCompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _companyNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _mersisNumberController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isActive = true;

  bool get isEditing => widget.companyId != null;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SellerCompanyProvider>();
    provider.clearFormErrors(); // Formu açarken eski hataları temizle

    if (isEditing) {
      _isLoadingData = true;
      _loadCompanyData();
    }
  }

  Future<void> _loadCompanyData() async {
    final provider = context.read<SellerCompanyProvider>();
    final success = await provider.loadCompanyById(widget.companyId!);

    if (success && provider.selectedCompany != null && mounted) {
      final company = provider.selectedCompany!;
      setState(() {
        _companyNameController.text = company.companyName;
        _businessAddressController.text = company.businessAddress;
        _businessPhoneController.text = company.businessPhone;
        _taxOfficeController.text = company.taxOffice;
        _taxNumberController.text = company.taxNumber;
        _mersisNumberController.text = company.mersisNumber;
        _notesController.text = company.notes ?? '';
        _isActive = company.isActive;
        _isLoadingData = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingData = false);
      _showErrorSnackBar(provider.errorMessage ?? 'Firma bilgileri yüklenemedi.');
      // Yükleme başarısız olursa bir önceki sayfaya dön
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _taxOfficeController.dispose();
    _taxNumberController.dispose();
    _mersisNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'company_name': _companyNameController.text.trim(),
      'business_address': _businessAddressController.text.trim(),
      'business_phone': _businessPhoneController.text.trim(),
      'tax_office': _taxOfficeController.text.trim(),
      'tax_number': _taxNumberController.text.trim(),
      'mersis_number': _mersisNumberController.text.trim(),
      'notes': _notesController.text.trim(),
      'is_active': _isActive,
    };

    final provider = context.read<SellerCompanyProvider>();
    bool success = false;

    if (isEditing) {
      success = await provider.updateCompany(widget.companyId!, data);
    } else {
      success = await provider.createCompany(data);
    }

    if (!mounted) return;

    if (success) {
      // Liste ekranındaki veriyi yenile
      provider.loadCompanies(refresh: true);

      if (context.canPop()) {
        context.pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Firma güncellendi' : 'Firma oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Hata mesajı (Validation veya genel hata)
      _showErrorSnackBar(provider.errorMessage ?? 'İşlem başarısız oldu');
      // Validation hataları formda gösterilsin diye setState tetikle
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

  /// Provider'dan validation hatasını alan helper
  String? _getErrorText(String fieldName) {
    final errors = context.read<SellerCompanyProvider>().validationErrors;
    if (errors.containsKey(fieldName)) {
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
    // isLoading (kaydetme) durumu için provider'ı izle
    final provider = context.watch<SellerCompanyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Satıcı Firmayı Düzenle' : 'Yeni Satıcı Firma'),
      ),
      body: _isLoadingData
          ? const LoadingIndicator(message: 'Firma bilgileri yükleniyor...')
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'Firma Adı *',
                  prefixIcon: const Icon(Icons.business),
                  errorText: _getErrorText('company_name'),
                ),
                validator: (value) => Validators.required(value, fieldName: 'Firma Adı'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessAddressController,
                decoration: InputDecoration(
                  labelText: 'İş Adresi *',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  errorText: _getErrorText('business_address'),
                ),
                maxLines: 3,
                validator: (value) => Validators.required(value, fieldName: 'İş Adresi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessPhoneController,
                decoration: InputDecoration(
                  labelText: 'İş Telefonu *',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  hintText: '+90 555 123 45 67',
                  errorText: _getErrorText('business_phone'),
                ),
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxOfficeController,
                decoration: InputDecoration(
                  labelText: 'Vergi Dairesi *',
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                  errorText: _getErrorText('tax_office'),
                ),
                validator: (value) => Validators.required(value, fieldName: 'Vergi Dairesi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxNumberController,
                decoration: InputDecoration(
                  labelText: 'Vergi Numarası (10 Hane) *',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  errorText: _getErrorText('tax_number'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (value) {
                  final required = Validators.required(value, fieldName: 'Vergi Numarası');
                  if (required != null) return required;
                  if (value!.length != 10) return 'Vergi numarası 10 haneli olmalıdır.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mersisNumberController,
                decoration: InputDecoration(
                  labelText: 'Mersis Numarası (16 Hane) *',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  errorText: _getErrorText('mersis_number'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                validator: (value) {
                  final required = Validators.required(value, fieldName: 'Mersis Numarası');
                  if (required != null) return required;
                  if (value!.length != 16) return 'Mersis numarası 16 haneli olmalıdır.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notlar',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  errorText: _getErrorText('notes'),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Firma Aktif'),
                subtitle: const Text('Aktif firmalar sözleşmelerde seçilebilir.'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 24),

              // Genel hata
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(isEditing ? 'Güncelle' : 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/features/customers/presentation/widgets/customer_buyer_details_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../sales/data/models/buyer_details_model.dart';
import '../../../sales/presentation/providers/buyer_details_provider.dart';

class CustomerBuyerDetailsWidget extends StatefulWidget {
  final int customerId;
  const CustomerBuyerDetailsWidget({super.key, required this.customerId});

  @override
  State<CustomerBuyerDetailsWidget> createState() =>
      _CustomerBuyerDetailsWidgetState();
}

class _CustomerBuyerDetailsWidgetState
    extends State<CustomerBuyerDetailsWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Form Controllers
  final _tcController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _notesController = TextEditingController();

  BuyerDetailType _buyerType = BuyerDetailType.gercek;

  @override
  void initState() {
    super.initState();
    // Veriyi yükle ve formu doldur
    _loadAndPopulateData();
  }

  @override
  void dispose() {
    _tcController.dispose();
    _companyNameController.dispose();
    _taxOfficeController.dispose();
    _taxNumberController.dispose();
    _businessPhoneController.dispose();
    _businessAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadAndPopulateData() {
    final provider = context.read<BuyerDetailsProvider>();
    final details = provider.buyerDetails;

    if (details != null) {
      // Veri varsa, form controller'larını doldur
      _buyerType = details.typeEnum;
      _tcController.text = details.tcNumber ?? '';
      _companyNameController.text = details.companyName ?? '';
      _taxOfficeController.text = details.taxOffice ?? '';
      _taxNumberController.text = details.taxNumber ?? '';
      _businessPhoneController.text = details.businessPhone ?? '';
      _businessAddressController.text = details.businessAddress ?? '';
      _notesController.text = details.notes ?? '';
      _isEditing = false; // Başlangıçta görüntüleme modunda
    } else {
      // Veri yoksa, düzenleme modunda başla (yeni kayıt)
      _isEditing = true;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BuyerDetailsProvider>();
    final data = <String, dynamic>{
      'buyer_type': _buyerType == BuyerDetailType.gercek ? 'GERCEK_KISI' : 'TUZEL_KISI',
      'tc_number': _tcController.text.trim(),
      'company_name': _companyNameController.text.trim(),
      'tax_office': _taxOfficeController.text.trim(),
      'tax_number': _taxNumberController.text.trim(),
      'business_phone': _businessPhoneController.text.trim(),
      'business_address': _businessAddressController.text.trim(),
      'notes': _notesController.text.trim(),
    };

    final success = await provider.createOrUpdateBuyerDetails(widget.customerId, data);

    if (mounted) {
      if (success) {
        setState(() => _isEditing = false); // Görüntüleme moduna geç
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alıcı detayları başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Kayıt başarısız'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerDetailsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.buyerDetails == null) {
          return const LoadingIndicator(message: 'Alıcı detayları yükleniyor...');
        }

        // Eğer düzenleme modunda değilsek (kayıt varsa)
        if (!_isEditing && provider.buyerDetails != null) {
          return _buildViewMode(context, provider.buyerDetails!);
        }

        // Düzenleme/Oluşturma modu
        return _buildEditMode(context, provider);
      },
    );
  }

  // Veri Görüntüleme Modu
  Widget _buildViewMode(BuildContext context, BuyerDetailsModel details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          icon: Icons.badge,
          label: 'Alıcı Tipi',
          value: details.buyerTypeDisplay ?? details.buyerType,
        ),
        if (details.typeEnum == BuyerDetailType.gercek)
          _buildInfoRow(
            context,
            icon: Icons.person,
            label: 'TC Kimlik No',
            value: details.tcNumber ?? '-',
          ),
        if (details.typeEnum == BuyerDetailType.tuzel) ...[
          _buildInfoRow(
            context,
            icon: Icons.business,
            label: 'Firma Adı',
            value: details.companyName ?? '-',
          ),
          _buildInfoRow(
            context,
            icon: Icons.account_balance,
            label: 'Vergi Dairesi',
            value: details.taxOffice ?? '-',
          ),
          _buildInfoRow(
            context,
            icon: Icons.pin,
            label: 'Vergi Numarası',
            value: details.taxNumber ?? '-',
          ),
          _buildInfoRow(
            context,
            icon: Icons.phone,
            label: 'İş Telefonu',
            value: details.businessPhone ?? '-',
          ),
          _buildInfoRow(
            context,
            icon: Icons.location_city,
            label: 'İş Adresi',
            value: details.businessAddress ?? '-',
          ),
        ],
        if (details.notes != null && details.notes!.isNotEmpty)
          _buildInfoRow(
            context,
            icon: Icons.note,
            label: 'Notlar',
            value: details.notes!,
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Düzenle'),
            onPressed: () => setState(() => _isEditing = true),
          ),
        ),
      ],
    );
  }

  // Form (Düzenleme/Oluşturma) Modu
  Widget _buildEditMode(BuildContext context, BuyerDetailsProvider provider) {
    // Hata mesajlarını almak için helper
    String? getErrorText(String fieldName) {
      final errors = provider.validationErrors;
      if (errors.containsKey(fieldName)) {
        final errorValue = errors[fieldName];
        if (errorValue is List && errorValue.isNotEmpty) {
          return errorValue.first;
        }
        return errorValue.toString();
      }
      return null;
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Alıcı Tipi Seçimi
          SegmentedButton<BuyerDetailType>(
            segments: const [
              ButtonSegment(
                value: BuyerDetailType.gercek,
                label: Text('Gerçek Kişi'),
                icon: Icon(Icons.person),
              ),
              ButtonSegment(
                value: BuyerDetailType.tuzel,
                label: Text('Tüzel Kişi (Firma)'),
                icon: Icon(Icons.business),
              ),
            ],
            selected: {_buyerType},
            onSelectionChanged: (Set<BuyerDetailType> newSelection) {
              setState(() {
                _buyerType = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 16),

          // Dinamik Alanlar
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _buyerType == BuyerDetailType.gercek
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            // Gerçek Kişi Alanları
            firstChild: TextFormField(
              controller: _tcController,
              decoration: InputDecoration(
                labelText: 'TC Kimlik Numarası *',
                prefixIcon: const Icon(Icons.person_outline),
                errorText: getErrorText('tc_number'),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) {
                if (_buyerType == BuyerDetailType.gercek) {
                  final required = Validators.required(value, fieldName: 'TC Kimlik No');
                  if (required != null) return required;
                  if (value!.length != 11) return 'TC Kimlik No 11 haneli olmalıdır.';
                }
                return null;
              },
            ),
            // Tüzel Kişi Alanları
            secondChild: Column(
              children: [
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    labelText: 'Firma Adı *',
                    prefixIcon: const Icon(Icons.business_outlined),
                    errorText: getErrorText('company_name'),
                  ),
                  validator: (value) => _buyerType == BuyerDetailType.tuzel
                      ? Validators.required(value, fieldName: 'Firma Adı')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxOfficeController,
                  decoration: InputDecoration(
                    labelText: 'Vergi Dairesi *',
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                    errorText: getErrorText('tax_office'),
                  ),
                  validator: (value) => _buyerType == BuyerDetailType.tuzel
                      ? Validators.required(value, fieldName: 'Vergi Dairesi')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxNumberController,
                  decoration: InputDecoration(
                    labelText: 'Vergi Numarası (10 Hane) *',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    errorText: getErrorText('tax_number'),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (_buyerType == BuyerDetailType.tuzel) {
                      final required = Validators.required(value, fieldName: 'Vergi Numarası');
                      if (required != null) return required;
                      if (value!.length != 10) return 'Vergi numarası 10 haneli olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _businessPhoneController,
                  decoration: InputDecoration(
                    labelText: 'İş Telefonu',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    errorText: getErrorText('business_phone'),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return Validators.phone(value);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _businessAddressController,
                  decoration: InputDecoration(
                    labelText: 'İş Adresi',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    errorText: getErrorText('business_address'),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Ortak Alan: Notlar
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notlar',
              prefixIcon: const Icon(Icons.note_alt_outlined),
              alignLabelWithHint: true,
              errorText: getErrorText('notes'),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          // Butonlar
          Row(
            children: [
              // Kayıt zaten varsa ve düzenleme modundaysak "İptal" butonu göster
              if (provider.buyerDetails != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text('İptal'),
                  ),
                ),
              if (provider.buyerDetails != null) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(provider.buyerDetails == null ? 'Oluştur' : 'Kaydet'),
                  onPressed: provider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Görüntüleme modu için kullanılan helper
  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
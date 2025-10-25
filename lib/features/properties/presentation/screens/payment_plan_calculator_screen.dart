// lib/features/properties/presentation/screens/payment_plan_calculator_screen.dart

import 'package:flutter/material.dart';
import 'dart:math'; // 'pow' fonksiyonu ve 'max' için gerekli.
import 'package:flutter/services.dart'; // Sayısal klavye ve TextInputFormatter için gerekli.
import 'package:intl/intl.dart'; // Tarih ve sayı formatlama için eklendi.
import 'package:intl/date_symbol_data_local.dart'; // Yerel tarih verileri için eklendi.

// Para formatlaması için özel TextInputFormatter.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return const TextEditingValue();
    }

    double value = double.parse(newText);

    final formatter = NumberFormat('#,##0', 'tr_TR');
    String formattedText = formatter.format(value);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// Ara ödeme girişi için Controller'ları ve tarih bilgisini tutan sınıf
class InterimPaymentControllers {
  final TextEditingController monthController;
  final TextEditingController amountController;
  final VoidCallback onMonthChanged; // Ay değiştiğinde tarihi güncellemek için callback
  String dateDescription = '';

  InterimPaymentControllers({required this.onMonthChanged})
      : monthController = TextEditingController(),
        amountController = TextEditingController() {
    // Ay Controller'ına listener ekleyerek tarih açıklamasını güncelle
    monthController.addListener(_updateDateDescription);
  }

  void _updateDateDescription() {
    final int? monthCount = int.tryParse(monthController.text);
    if (monthCount != null && monthCount > 0) {
      final now = DateTime.now();
      // Ay eklerken yıl atlamasını doğru hesapla
      final targetDate = DateTime(now.year, now.month + monthCount, now.day);
      final formatter = DateFormat('MMMM yyyy', 'tr_TR');
      dateDescription = formatter.format(targetDate);
    } else {
      dateDescription = '';
    }
    onMonthChanged(); // State'i güncellemek için dışarıyı bilgilendir
  }

  void dispose() {
    monthController.removeListener(_updateDateDescription);
    monthController.dispose();
    amountController.dispose();
  }
}


// Her bir ödeme dönemi için Controller'ları tutan yardımcı sınıf.
class PaymentPeriodControllers {
  final TextEditingController taksitController;
  final TextEditingController araOdemeController;

  PaymentPeriodControllers()
      : taksitController = TextEditingController(),
        araOdemeController = TextEditingController();

  void addListeners(VoidCallback listener) {
    taksitController.addListener(listener);
    araOdemeController.addListener(listener);
  }

  void removeListeners(VoidCallback listener) {
    taksitController.removeListener(listener);
    araOdemeController.removeListener(listener);
  }

  void dispose() {
    taksitController.dispose();
    araOdemeController.dispose();
  }
}

class PaymentPlanCalculatorScreen extends StatefulWidget {
  // **** GÜNCELLEME BAŞLANGICI ****
  // Constructor'a opsiyonel initialCashPrice parametresi ekliyoruz
  final double? initialCashPrice;
  // **** GÜNCELLEME SONU ****

  const PaymentPlanCalculatorScreen({ super.key, this.initialCashPrice }); // Parametreyi alıyoruz

  @override
  State<PaymentPlanCalculatorScreen> createState() => _PaymentPlanCalculatorScreenState();
}

class _PaymentPlanCalculatorScreenState extends State<PaymentPlanCalculatorScreen> {
  final _wizardFormKey = GlobalKey<FormState>();
  final _calculatorFormKey = GlobalKey<FormState>(); // Hesaplama formu için ayrı key

  // Sihirbaz Controller'ları
  final _wizardOranController = TextEditingController(text: '1.67');
  final _wizardPesinatController = TextEditingController();
  final _wizardTaksitSayisiController = TextEditingController(text: '36');
  final _wizardTaksitTutariController = TextEditingController();
  final _wizardAraOdemeSayisiController = TextEditingController();
  List<InterimPaymentControllers> _wizardAraOdemeControllerleri = [];

  // Hesaplama Controller'ları
  final _calcOranController = TextEditingController(); // Oran buraya aktarılacak
  List<PaymentPeriodControllers> _paymentPeriods = []; // Sihirbazdan oluşturulacak

  double _totalPresentValue = 0.0;
  List<DataRow> _resultRows = [];
  bool _planGenerated = false; // Plan oluşturuldu mu?
  bool _isWizardVisible = true; // *** YENİ: Sihirbaz görünürlük durumu ***

  // Formatlayıcılar
  final _currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: 'TL', decimalDigits: 2, customPattern: '#,##0.00 ¤');
  final _inputFormatter = NumberFormat('#,##0', 'tr_TR');

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    // Sihirbaz ara ödeme sayısı controller'ına listener ekle
    _wizardAraOdemeSayisiController.addListener(_updateInterimPaymentFields);

    // **** GÜNCELLEME BAŞLANGICI ****
    // Gelen peşin fiyat varsa peşinat alanını doldur
    if (widget.initialCashPrice != null) {
      _wizardPesinatController.text = _inputFormatter.format(widget.initialCashPrice);
    }
    // **** GÜNCELLEME SONU ****
  }

  @override
  void dispose() {
    // Sihirbaz Controller'ları
    _wizardOranController.dispose();
    _wizardPesinatController.dispose();
    _wizardTaksitSayisiController.dispose();
    _wizardTaksitTutariController.dispose();
    _wizardAraOdemeSayisiController.removeListener(_updateInterimPaymentFields);
    _wizardAraOdemeSayisiController.dispose();
    for (var controllerSet in _wizardAraOdemeControllerleri) {
      controllerSet.dispose();
    }

    // Hesaplama Controller'ları
    _calcOranController.removeListener(_calculate);
    _calcOranController.dispose();
    _disposePaymentPeriods(); // Listener'ları ve controller'ları temizle

    super.dispose();
  }

  // Hesaplama dönemi controller'larını ve listener'larını temizler
  void _disposePaymentPeriods() {
    for (var period in _paymentPeriods) {
      period.removeListeners(_calculate);
      period.dispose();
    }
    _paymentPeriods = [];
  }

  // Sihirbazdaki ara ödeme sayısı değiştikçe alanları günceller
  void _updateInterimPaymentFields() {
    // Odak kaybolduğunda bu fonksiyonun çalışması hatayı önler.
    FocusScope.of(context).unfocus();
    final int count = int.tryParse(_wizardAraOdemeSayisiController.text) ?? 0;
    // Mevcut controller sayısı ile istenen sayı farklıysa güncelle
    if (count != _wizardAraOdemeControllerleri.length) {
      setState(() {
        // Eski controller'ları dispose et
        for (var controllerSet in _wizardAraOdemeControllerleri) {
          controllerSet.dispose();
        }
        // Yenilerini oluştur
        _wizardAraOdemeControllerleri = List.generate(
          count,
              (_) => InterimPaymentControllers(onMonthChanged: () => setState(() {})), // Ay değişince rebuild için
        );
      });
    }
  }

  // Formatlanmış metni temizleyen yardımcı fonksiyon
  String _unformatCurrency(String text) {
    return text.replaceAll('.', '');
  }

  // Sihirbaz verilerini kullanarak ödeme planını oluşturur ve hesaplama bölümünü gösterir
  void _generatePlanAndCalculate() {
    if (!_wizardFormKey.currentState!.validate()) {
      return;
    }
    // Önceki hesaplama dönemlerini temizle
    _disposePaymentPeriods();

    // Sihirbaz verilerini al
    final double oran = double.tryParse(_wizardOranController.text.replaceAll(',', '.')) ?? 1.67;
    final double pesinat = double.tryParse(_unformatCurrency(_wizardPesinatController.text)) ?? 0.0;
    final int taksitSayisi = int.tryParse(_wizardTaksitSayisiController.text) ?? 0;
    final String taksitTutari = _unformatCurrency(_wizardTaksitTutariController.text); // String olarak al
    final araOdemeler = _wizardAraOdemeControllerleri.map((set) {
      return {
        'ay': int.tryParse(set.monthController.text) ?? 0,
        'tutar': _unformatCurrency(set.amountController.text), // String olarak al
      };
    }).where((odeme) => odeme['ay'] as int > 0).toList(); // Ay > 0 kontrolü

    // En büyük ayı bul (peşinat hariç)
    int enBuyukAy = taksitSayisi;
    if (araOdemeler.isNotEmpty) {
      final int enBuyukAraOdemeAyi = araOdemeler.map((e) => e['ay'] as int).reduce(max);
      enBuyukAy = max(taksitSayisi, enBuyukAraOdemeAyi);
    }
    final int toplamDonemSayisi = enBuyukAy + 1; // 0. dönem peşinat için

    // Hesaplama dönemi listesini oluştur
    List<PaymentPeriodControllers> olusturulanDonemler = List.generate(
      toplamDonemSayisi,
          (_) => PaymentPeriodControllers(),
    );

    // Peşinatı 0. döneme ekle
    if (pesinat > 0) {
      olusturulanDonemler[0].araOdemeController.text = _inputFormatter.format(pesinat); // Formatla
    }

    // Taksitleri ilgili dönemlere ekle
    for (int i = 1; i <= taksitSayisi; i++) {
      if (i < olusturulanDonemler.length && taksitTutari.isNotEmpty) {
        olusturulanDonemler[i].taksitController.text = _inputFormatter.format(double.parse(taksitTutari)); // Formatla
      }
    }

    // Ara ödemeleri ilgili dönemlere ekle
    for (var odeme in araOdemeler) {
      final int ay = odeme['ay'] as int;
      final String tutar = odeme['tutar'] as String;
      if (ay < olusturulanDonemler.length && tutar.isNotEmpty) {
        // Eğer o ayda zaten taksit varsa ara ödemeyi ona ekle, yoksa direkt ata
        // BU KISIM ŞİMDİLİK YORUMDA, ÇÜNKÜ İKİ AYRI ALAN VAR
        // double mevcutAraOdeme = double.tryParse(_unformatCurrency(olusturulanDonemler[ay].araOdemeController.text)) ?? 0.0;
        // olusturulanDonemler[ay].araOdemeController.text = _inputFormatter.format(mevc utAraOdeme + double.parse(tutar));
        olusturulanDonemler[ay].araOdemeController.text = _inputFormatter.format(double.parse(tutar)); // Direkt ata ve formatla
      }
    }

    // State'i güncelle ve hesaplamayı tetikle
    setState(() {
      _paymentPeriods = olusturulanDonemler;
      _calcOranController.text = oran.toString(); // Hesaplama oranını ayarla
      _planGenerated = true; // Hesaplama bölümünü göster
      _isWizardVisible = false; // *** YENİ: Plan oluşturulunca sihirbazı gizle ***
    });

    // Listener'ları ekle ve ilk hesaplamayı yap
    _calcOranController.addListener(_calculate);
    for (final period in _paymentPeriods) {
      period.addListeners(_calculate);
    }
    _calculate(); // Plan oluşturulduktan sonra hesapla
  }


  // Hesaplama fonksiyonu
  void _calculate() {
    final double? monthlyRatePercent = double.tryParse(_calcOranController.text.replaceAll(',', '.'));
    if (monthlyRatePercent == null || monthlyRatePercent <= 0) {
      setState(() {
        _totalPresentValue = 0.0;
        _resultRows = [];
      });
      return;
    }
    final double monthlyRate = monthlyRatePercent / 100.0;

    double tempTotal = 0.0;
    List<DataRow> tempRows = [];

    for (int i = 0; i < _paymentPeriods.length; i++) {
      final periodModel = _paymentPeriods[i];
      final double installment = double.tryParse(_unformatCurrency(periodModel.taksitController.text)) ?? 0.0;
      final double interimPayment = double.tryParse(_unformatCurrency(periodModel.araOdemeController.text)) ?? 0.0;
      final double totalAmount = installment + interimPayment;

      if (totalAmount > 0) {
        final int periodNo = i; // 0. dönem peşinat/ilk ödeme
        final double discountFactor = pow(1 + monthlyRate, i).toDouble();
        final double presentValue = totalAmount / discountFactor;

        tempTotal += presentValue;
        tempRows.add(DataRow(cells: [
          DataCell(Text(periodNo.toString())),
          DataCell(Text(_currencyFormatter.format(totalAmount))),
          DataCell(Text(discountFactor.toStringAsFixed(4))),
          DataCell(Text(_currencyFormatter.format(presentValue))),
        ]));
      }
    }

    setState(() {
      _totalPresentValue = tempTotal;
      _resultRows = tempRows;
    });
  }

  // Hesaplama bölümü için dönem ekleme
  void _addPeriodToCalculator() {
    final newPeriod = PaymentPeriodControllers();
    newPeriod.addListeners(_calculate);
    setState(() {
      _paymentPeriods.add(newPeriod);
    });
    _calculate();
  }

  // Hesaplama bölümü için dönem silme
  void _removePeriodFromCalculator(int index) {
    if (_paymentPeriods.length > 1 || (_paymentPeriods.length == 1 && index == 0)) { // 0. dönemin silinmesini engelle
      setState(() {
        final removedPeriod = _paymentPeriods[index];
        removedPeriod.removeListeners(_calculate);
        removedPeriod.dispose();
        _paymentPeriods.removeAt(index);
      });
      _calculate();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peşinat dönemi (0. Dönem) silinemez.')),
      );
    }
  }

  // **** YENİ: Hesaplayıcıyı sıfırlama fonksiyonu ****
  void _resetCalculator() {
    setState(() {
      _disposePaymentPeriods(); // Controller'ları temizle
      _totalPresentValue = 0.0;
      _resultRows = [];
      _planGenerated = false;
      _isWizardVisible = true;
      // İsteğe bağlı: Sihirbazdaki alanları da temizleyebilirsiniz
      // _wizardPesinatController.clear();
      // _wizardTaksitSayisiController.text = '36'; // Veya varsayılan değere döndür
      // _wizardTaksitTutariController.clear();
      // _wizardAraOdemeSayisiController.clear();
      // _updateInterimPaymentFields(); // Ara ödeme alanlarını temizler
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme Planı Hesaplayıcı'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // **** GÜNCELLEME: body'yi Column ile sarıyoruz ****
      body: Column(
        children: [
          // **** GÜNCELLEME: Sabit Referans Fiyat Kartı ****
          if (widget.initialCashPrice != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0), // Padding eklendi
              child: Card(
                color: Colors.blueGrey.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.blueGrey.shade100)),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blueGrey.shade700, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Referans Peşin Fiyat: ',
                        style: TextStyle(color: Colors.blueGrey.shade800),
                      ),
                      Text(
                        _currencyFormatter.format(widget.initialCashPrice!),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // **** GÜNCELLEME: Kalan içeriği Expanded + SingleChildScrollView içine alıyoruz ****
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // **** GÜNCELLEME: Referans kartı yukarı taşındığı için buradan kaldırıldı ****
                    // if (widget.initialCashPrice != null) ...[ ... ],

                    _buildWizardHeader(), // Başlık ve Gizle/Göster butonu

                    AnimatedCrossFade( // Sihirbaz formu
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _isWizardVisible
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: _buildWizardForm(),
                      secondChild: Container(),
                      firstCurve: Curves.easeInOut,
                      secondCurve: Curves.easeInOut,
                      sizeCurve: Curves.easeInOut,
                    ),

                    if (_planGenerated) ...[ // Hesaplama bölümü
                      const SizedBox(height: 32),
                      const Divider(thickness: 2),
                      const SizedBox(height: 16),
                      _buildCalculatorSection(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // *** YENİ: Sihirbaz Başlığı Widget'ı (Gizle/Göster Butonlu) ***
  Widget _buildWizardHeader() {
    // Plan henüz oluşturulmadıysa, sadece başlığı göster
    if (!_planGenerated) {
      return _buildSectionTitle('1. Plan Bilgilerini Girin');
    }

    // Plan oluşturulduysa, başlığı ve toggle butonunu göster
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('1. Plan Bilgilerini Girin'),
        TextButton.icon(
          icon: Icon(
            _isWizardVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: Colors.teal.shade700,
          ),
          label: Text(
            _isWizardVisible ? 'Gizle' : 'Göster',
            style: TextStyle(color: Colors.teal.shade700),
          ),
          onPressed: () {
            setState(() {
              _isWizardVisible = !_isWizardVisible;
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }


  // *** GÜNCELLENDİ: Bu fonksiyon artık sadece Form'u içeriyor ***
  // (Başlık _buildWizardHeader'a taşındı)
  Widget _buildWizardForm() {
    return Form(
      key: _wizardFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // _buildSectionTitle('1. Plan Bilgilerini Girin'), // <-- Buradan kaldırıldı
          TextFormField(
            controller: _wizardOranController,
            decoration: const InputDecoration(labelText: 'Aylık İndirgeme Oranı (%)', prefixIcon: Icon(Icons.percent)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[\,\.]?\d*'))],
            validator: (value) => (value == null || value.isEmpty || (double.tryParse(value.replaceAll(',', '.')) ?? 0) <= 0) ? 'Geçerli bir oran giriniz.' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _wizardPesinatController,
            decoration: const InputDecoration(labelText: 'Peşinat Tutarı', prefixIcon: Icon(Icons.money)),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
            // Peşinat zorunlu değilse validator kaldırılabilir veya güncellenebilir
            validator: (value) => (value == null || value.isEmpty) ? 'Lütfen peşinat giriniz.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(

            controller: _wizardTaksitSayisiController,
            decoration: const InputDecoration(labelText: 'Toplam Taksit Ay Sayısı', prefixIcon: Icon(Icons.calendar_today)),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // Taksit sayısı zorunlu değilse validator kaldırılabilir veya güncellenebilir
            validator: (value) => (value == null || value.isEmpty) ? 'Lütfen taksit sayısını giriniz.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _wizardTaksitTutariController,

            decoration: const InputDecoration(labelText: 'Aylık Taksit Tutarı', prefixIcon: Icon(Icons.payment)),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
            // Taksit tutarı zorunlu değilse validator kaldırılabilir veya güncellenebilir
            validator: (value) => (value == null || value.isEmpty) ? 'Lütfen taksit tutarını giriniz.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _wizardAraOdemeSayisiController,

            decoration: const InputDecoration(labelText: 'Kaç Adet Ara Ödeme Olacak?', hintText: 'Örn: 0, 1, 2...', prefixIcon: Icon(Icons.add_card)),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onEditingComplete: _updateInterimPaymentFields, // Alanları güncelle
          ),
          const SizedBox(height: 16),

          // Dinamik Ara Ödeme Alanları
          if (_wizardAraOdemeControllerleri.isNotEmpty)
            Card(
              elevation: 0,
              color: Colors.teal.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.teal.shade100)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ara Ödeme Detayları",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.teal.shade800)),
                    const SizedBox(height: 12),
                    ...List.generate(_wizardAraOdemeControllerleri.length,
                            (index) {
                          final controllerSet = _wizardAraOdemeControllerleri[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Helper text için
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: controllerSet.monthController,
                                    decoration: InputDecoration(
                                      labelText: '${index + 1}. Ödeme Kaçıncı Ay?',
                                      helperText: controllerSet.dateDescription, // Tarihi göster
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (value) => (value == null ||
                                        value.isEmpty ||
                                        (int.tryParse(value) ?? 0) <= 0)
                                        ? 'Ay > 0 girin.'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: controllerSet.amountController,
                                    decoration: InputDecoration(
                                      labelText: '${index + 1}. Ödeme Tutarı',
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      CurrencyInputFormatter()
                                    ],
                                    validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Tutar girin.'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Planı Oluştur ve Hesapla'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: _generatePlanAndCalculate,
          ),
        ],
      ),
    );
  }

  // Hesaplama Bölümü Widget'ı
  Widget _buildCalculatorSection() {
    return Form( // Hesaplama formu için ayrı key
      key: _calculatorFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // **** GÜNCELLEME: Temizle butonu eklendi ****
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('2. Hesaplama ve Düzenleme'),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.teal.shade700),
                tooltip: 'Planı Temizle ve Sihirbaza Dön',
                onPressed: _resetCalculator,
              ),
            ],
          ),
          // **** GÜNCELLEME SONU ****

          // *** Toplam Bugünkü Değer Kartı ***
          const SizedBox(height: 16),
          Card(
            color: Colors.teal.shade50,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Toplam Bugünkü Değer',
                      style: TextStyle(fontSize: 16, color: Colors.teal.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currencyFormatter.format(_totalPresentValue),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Oran (Sihirbazdan gelen, düzenlenebilir)
          TextFormField(
            controller: _calcOranController,
            decoration: InputDecoration(
              labelText: 'Aylık İndirgeme Oranı (%)',
              hintText: 'Örn: 1.67',
              prefixIcon: const Icon(Icons.percent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.teal.withOpacity(0.05),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[\,\.]?\d*'))],
            validator: (value) { // Validator burada da olmalı
              if (value == null || value.isEmpty) return 'Lütfen oran giriniz.';
              final rate = double.tryParse(value.replaceAll(',', '.'));
              if (rate == null || rate <= 0) return 'Geçerli bir oran giriniz (> 0).';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Ödeme Dönemleri Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ödeme Dönemleri', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.teal.shade700)),
              TextButton.icon( // Dönem Ekle Butonu
                icon: const Icon(Icons.add_circle_outline, color: Colors.teal, size: 20),
                label: const Text('Dönem Ekle', style: TextStyle(color: Colors.teal)),
                onPressed: _addPeriodToCalculator,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dinamik Ödeme Dönemi Listesi (Hesaplama için)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentPeriods.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 25),
                        child: Text(
                          "$index.",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.teal.shade600),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _paymentPeriods[index].taksitController,
                          decoration: InputDecoration(
                            labelText: 'Aylık Taksit',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.teal.withOpacity(0.03),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _paymentPeriods[index].araOdemeController,
                          decoration: InputDecoration(
                            labelText: 'Ara Ödeme',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.teal.withOpacity(0.03),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                        ),
                      ),
                      // **** GÜNCELLEME: Sadece 0. dönem değilse silme butonu göster ****
                      if (index != 0)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _removePeriodFromCalculator(index),
                          tooltip: 'Bu dönemi sil',
                          padding: const EdgeInsets.only(top: 15),
                          constraints: const BoxConstraints(),
                        )
                      else // 0. dönem için boşluk bırak
                        const SizedBox(width: 48), // IconButton genişliği kadar
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Sonuçlar Bölümü
          const Divider(thickness: 1.5),
          const SizedBox(height: 16),
          Text('Hesaplama Sonuçları', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.teal.shade700)),
          const SizedBox(height: 16),

          if (_resultRows.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 25,
                headingRowColor: MaterialStateProperty.all(Colors.teal.shade100),
                dataRowMinHeight: 40,
                dataRowMaxHeight: 50,
                border: TableBorder.all(
                  width: 1,
                  color: Colors.teal.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                columns: const [
                  DataColumn(label: Text('Dönem', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Toplam Tutar', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('İskonto Katsayısı', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Bugünkü Değer', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                ],
                rows: _resultRows,
              ),
            )
          else
            const Center(child: Text("Hesaplama için ödeme giriniz.", style: TextStyle(color: Colors.grey))),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Başlık widget'ı
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
      ),
    );
  }
} // Sınıf Sonu
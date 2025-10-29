// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/custom_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../sales/presentation/providers/payment_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../customers/presentation/providers/activity_provider.dart'; // Bu import zaten var
import '../../../customers/data/models/customer_stats_model.dart';
import '../../../customers/data/models/activity_model.dart'; // Bu import zaten var
import '../widgets/stat_card.dart';
import '../widgets/sales_chart.dart';
import '../widgets/monthly_revenue_chart.dart';

import '../../../reservations/presentation/providers/reservation_provider.dart';
import '../../../reservations/data/models/reservation_model.dart';
import '../../../../core/utils/date_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  bool _isLoading = true;
  final List<double> _monthlyRevenueData = [
    50000, 75000, 120000, 95000, 150000, 180000, 160000, 210000, 250000, 200000, 280000, 320000
  ];
  // **** YENİ: Aktivite listesi için ScrollController ****
  final ScrollController _activityScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
    // **** YENİ: Aktivite listesi için scroll listener ****
    _activityScrollController.addListener(_onActivityScroll);
  }

  // **** YENİ: Aktivite listesi scroll listener metodu ****
  void _onActivityScroll() {
    if (_activityScrollController.position.pixels >=
        _activityScrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<ActivityProvider>();
      // Dashboard için yükleme durumunu ve daha fazla veri olup olmadığını kontrol et
      if (provider.dashboardHasMore && !provider.isDashboardActivitiesLoading) {
        provider.loadDashboardActivities(); // Sonraki sayfayı yükle
      }
    }
  }

  // **** YENİ: dispose içinde listener'ı kaldır ****
  @override
  void dispose() {
    _activityScrollController.removeListener(_onActivityScroll);
    _activityScrollController.dispose();
    super.dispose();
  }


  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = context.read<AuthProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final customerProvider = context.read<CustomerProvider>();
      final activityProvider = context.read<ActivityProvider>();
      final reservationProvider = context.read<ReservationProvider>();

      await Future.wait([
        authProvider.getUserStatistics(),
        paymentProvider.loadOverduePayments(),
        paymentProvider.loadPendingPayments(),
        customerProvider.loadCustomerStats(),
        activityProvider.loadUpcomingFollowUps(),
        reservationProvider.loadDashboardSales(),
        // **** YENİ: Dashboard aktivitelerini de yükle ****
        activityProvider.loadDashboardActivities(refresh: true), // İlk yükleme için refresh
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dashboard verileri yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDateRangePicker() async {
    final reservationProvider = context.read<ReservationProvider>();
    final initialRange = reservationProvider.dashboardDateFilter ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
      helpText: 'Tarih Aralığı Seçin',
      cancelText: 'İptal',
      confirmText: 'Uygula',
      saveText: 'Kaydet',
    );

    if (pickedDateRange != null && mounted) {
      await reservationProvider.loadDashboardSales(dateRange: pickedDateRange);
    }
  }

  // **** YENİ: Aktivite tablosu için tarih filtresi ****
  Future<void> _showActivityDateRangePicker() async {
    final activityProvider = context.read<ActivityProvider>();
    final initialRange = activityProvider.dashboardDateFilter ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
      helpText: 'Aktivite Tarih Aralığı Seçin',
      cancelText: 'İptal',
      confirmText: 'Uygula',
      saveText: 'Kaydet',
    );

    if (pickedDateRange != null && mounted) {
      // Refresh: true ile filtreyi uygula ve ilk sayfayı yükle
      await activityProvider.loadDashboardActivities(dateRange: pickedDateRange, refresh: true);
    }
  }


  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return 'U';
    return name.substring(0, 1).toUpperCase();
  }

  String _getFullName(String? firstName, String? lastName) {
    if ((firstName == null || firstName.isEmpty) &&
        (lastName == null || lastName.isEmpty)) {
      return 'Kullanıcı';
    }
    return '$firstName $lastName'.trim();
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) {
      return 4;
    } else if (width > 800) {
      return 3;
    } else {
      return 2;
    }
  }

  // **** YENİ: Dinamik childAspectRatio hesaplayıcı ****
  double _computeCardAspectRatio(double screenWidth, int crossAxisCount) {
    // Kart başına düşen yaklaşık genişliği hesapla
    // Padding: LayoutBuilder içinde uygulanan padding ile uyumlu olacak şekilde yaklaşık bir değer kullanıyoruz
    const horizontalPadding = 32.0; // SingleChildScrollView padding: EdgeInsets.all(16) -> iki taraf toplam 32
    final totalCrossSpacing = (crossAxisCount - 1) * 16.0; // crossAxisSpacing kullandığımız değer
    final availableWidth = screenWidth - horizontalPadding - totalCrossSpacing;
    final widthPerCard = availableWidth / crossAxisCount;

    // Mobilde daha yüksek kart isteği: daha küçük aspect ratio -> daha yüksek kart
    final double desiredHeight;
    if (screenWidth <= 400) {
      desiredHeight = 160.0; // çok dar ekranlar için
    } else if (screenWidth <= 600) {
      desiredHeight = 150.0;
    } else if (screenWidth <= 800) {
      desiredHeight = 140.0;
    } else {
      desiredHeight = 120.0; // geniş ekranlarda daha kısa kart
    }

    // childAspectRatio = width / height
    final ratio = widthPerCard / desiredHeight;
    // Güvenlik: çok küçük veya çok büyük değerlere sınır koy
    return ratio.clamp(0.8, 3.0);
  }
  // **** HESAPLAMA SONU ****

  Widget _buildResponsiveCharts(BuildContext context, double width, AuthProvider authProvider) {
    final bool isWideScreen = width > 800;
    final int reservations = (authProvider.currentUser?.isSalesRep ?? false)
        ? (authProvider.statistics?['total_reservations'] as int? ?? 0)
        : (authProvider.currentUser?.isSalesManager ?? false)
        ? (authProvider.statistics?['team_total_reservations'] as int? ?? 0)
        : (authProvider.statistics?['total_reservations'] as int? ?? 0);

    final int sales = (authProvider.currentUser?.isSalesRep ?? false)
        ? (authProvider.statistics?['total_sales'] as int? ?? 0)
        : (authProvider.currentUser?.isSalesManager ?? false)
        ? (authProvider.statistics?['team_total_sales'] as int? ?? 0)
        : (authProvider.statistics?['total_sales'] as int? ?? 0);

    final Widget salesChart = SalesChart(
      totalReservations: reservations,
      totalSales: sales,
    );
    final Widget revenueChart = MonthlyRevenueChart(
      monthlyData: _monthlyRevenueData,
    );

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: salesChart),
          const SizedBox(width: 16),
          Expanded(child: revenueChart),
        ],
      );
    } else {
      return Column(
        children: [
          salesChart,
          const SizedBox(height: 16),
          revenueChart,
        ],
      );
    }
  }


  // **** GÜNCELLENEN METOT BAŞLANGICI ****
  Widget _buildCrmStats(CustomerStatsModel stats, double screenWidth) {
    // **** YENİ: Dinamik en-boy oranı hesaplaması ****
    // Diğer (Genel Durum vb.) grid'lerin bu genişlikte kaç sütun kullandığını al
    final int mainGridColumnCount = _getCrossAxisCount(screenWidth);

    // Bu ("CRM Analizi") grid'in kaç sütun kullanacağını belirle
    // Not: Orijinal koddaki '600' breakpoint'ini, diğer grid'lerle (800) tutarlı olması
    // için '800' olarak değiştirmek daha iyi bir responsive davranış sağlar.
    final int crmGridColumnCount = screenWidth > 800 ? 3 : 2; // **** DEĞİŞİKLİK: 600 -> 800 ****

    // CRM grid'i için dinamik en-boy oranını compute fonksiyonuyla al
    double crmChildAspectRatio = _computeCardAspectRatio(screenWidth, crmGridColumnCount);

    // Eğer isterseniz ana grid ile boyutları eşitlemek için farklı scaling uygulanabilir.
    // (Önceki mantık korunmak istenirse burada ek hesaplama yapılabilir.)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'CRM Analizi',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: crmGridColumnCount, // **** DEĞİŞİKLİK: Hesaplanan değer kullanıldı ****
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: crmChildAspectRatio, // **** DEĞİŞİKLİK: Dinamik hesaplanan değer kullanıldı ****
          children: [
            StatCard(
              title: 'Toplam Müşteri',
              value: stats.totalCustomers.toString(),
              icon: Icons.people,
              color: Colors.blueGrey,
              onTap: () => context.go('/customers'),
            ),
            StatCard(
              title: 'Sıcak Müşteriler',
              value: stats.hotLeads.toString(),
              icon: Icons.local_fire_department,
              color: Colors.red,
            ),
            StatCard(
              title: 'Bugünkü Randevular',
              value: stats.withAppointmentsToday.toString(),
              icon: Icons.calendar_today,
              color: Colors.deepPurple,
              onTap: () => context.go('/appointments'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Müşteri Kaynak Dağılımı',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: stats.topSources.entries.map((entry) {
                        return PieChartSectionData(
                          color: stats.getSourceColor(entry.key),
                          value: entry.value.toDouble(),
                          title: '${entry.value}',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: stats.topSources.entries.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: stats.getSourceColor(entry.key),
                        ),
                        const SizedBox(width: 6),
                        Text(entry.key),
                      ],
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
  // **** GÜNCELLENEN METOT SONU ****

  Widget _buildUpcomingFollowUps(List<ActivityModel> activities) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Yaklaşan Takipler',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length > 5 ? 5 : activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final now = DateTime.now();
            final followUpDate = activity.nextFollowUpDate!;
            final isToday = now.year == followUpDate.year &&
                now.month == followUpDate.month &&
                now.day == followUpDate.day;
            final isTomorrow = now.year == followUpDate.year &&
                now.month == followUpDate.month &&
                now.day + 1 == followUpDate.day;
            String dateText;
            Color dateColor;

            if (isToday) {
              dateText = 'Bugün ${DateFormat.Hm('tr_TR').format(followUpDate)}';
              dateColor = Colors.red;
            } else if (isTomorrow) {
              dateText = 'Yarın ${DateFormat.Hm('tr_TR').format(followUpDate)}';
              dateColor = Colors.orange;
            } else {
              dateText = DateFormat('dd MMM, EEEE HH:mm', 'tr_TR').format(followUpDate);
              dateColor = Theme.of(context).primaryColor;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(activity.activityTypeIcon, color: activity.activityTypeColor),
                title: Text(
                  activity.customerName ?? 'İsimsiz Müşteri',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  dateText,
                  style: TextStyle(color: dateColor, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.go('/customers/${activity.customerId}'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCombinedSalesCard({
    required int reservationCount,
    required int salesCount,
    required AuthProvider authProvider,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          if (authProvider.isSalesRep) {
            context.go('/reservations', extra: 'my-sales');
          } else {
            context.go('/reservations', extra: 'all');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_available, color: Colors.orange, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      reservationCount.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        'Rezervasyonlar',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.grey[300],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.purple, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      salesCount.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        'Satışlar',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesTable(BuildContext context) {
    final reservationProvider = context.watch<ReservationProvider>();
    final salesData = reservationProvider.dashboardSales;
    final isLoading = reservationProvider.isDashboardSalesLoading;
    final error = reservationProvider.dashboardSalesError;
    final selectedDateRange = reservationProvider.dashboardDateFilter;
    final dateFormat = DateFormat('dd.MM.yyyy');

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Satışlar ve Aktif Rezervasyonlar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  tooltip: 'Tarihe Göre Filtrele',
                  onPressed: _showDateRangePicker,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            if (selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filtre: ${dateFormat.format(selectedDateRange.start)} - ${dateFormat.format(selectedDateRange.end)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Temizle'),
                      onPressed: () {
                        reservationProvider.loadDashboardSales(dateRange: null);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
            else if (error != null)
              Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Hata: $error', style: const TextStyle(color: Colors.red))))
            else if (salesData.isEmpty)
                const Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Bu kriterlere uygun kayıt bulunamadı.')))
              else
              // **** DEĞİŞİKLİK BAŞLANGICI ****
              // LayoutBuilder eklendi -> Kartın tam genişliğini almak için
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // ConstrainedBox eklendi -> DataTable'ı minimum genişliğe zorlamak için
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          columnSpacing: 18.0,
                          headingRowColor: MaterialStateProperty.all(colorScheme.onSurface.withOpacity(0.05)),
                          columns: const [
                            DataColumn(label: Text('Müşteri')),
                            DataColumn(label: Text('Mülk')),
                            DataColumn(label: Text('Temsilci')),
                            DataColumn(label: Text('Tarih')),
                            DataColumn(label: Text('Durum')),
                          ],
                          rows: salesData.map((sale) {
                            final isSold = sale.status == 'SATISA_DONUSTU';
                            return DataRow(
                              cells: [
                                DataCell(Text(sale.customerInfo?.fullName ?? '-')),
                                DataCell(Text(
                                  '${sale.propertyInfo?.block ?? ''} Blok, No:${sale.propertyInfo?.unitNumber ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                )),
                                DataCell(Text(sale.salesRepName ?? '-')),
                                DataCell(Text(DateFormatter.formatDate(sale.reservationDate))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSold ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isSold ? 'Satışa Döndü' : 'Rezervasyonlu',
                                      style: TextStyle(
                                        color: isSold ? Colors.green.shade800 : Colors.orange.shade800,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onSelectChanged: (_) {
                                context.go('/reservations/${sale.id}/payments');
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
            // **** DEĞİŞİKLİK SONU ****
          ],
        ),
      ),
    );
  }

  // **** YENİ: Aktivite Tablosu Widget'ı ****
  Widget _buildActivitiesTable(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final activitiesData = activityProvider.dashboardActivities;
    final isLoading = activityProvider.isDashboardActivitiesLoading;
    final error = activityProvider.dashboardActivitiesError;
    final selectedDateRange = activityProvider.dashboardDateFilter;
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tüm Aktiviteler',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  tooltip: 'Aktiviteleri Tarihe Göre Filtrele',
                  onPressed: _showActivityDateRangePicker, // Aktivite filtresi için
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            if (selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filtre: ${dateFormat.format(selectedDateRange.start)} - ${dateFormat.format(selectedDateRange.end)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Temizle'),
                      onPressed: () {
                        // Filtreyi temizle ve verileri yeniden yükle
                        activityProvider.loadDashboardActivities(dateRange: null, refresh: true);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (isLoading && activitiesData.isEmpty) // Sadece ilk yüklemede göster
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
            else if (error != null && activitiesData.isEmpty) // Sadece ilk yüklemede hata varsa göster
              Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Hata: $error', style: const TextStyle(color: Colors.red))))
            else if (activitiesData.isEmpty)
                const Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Bu kriterlere uygun aktivite bulunamadı.')))
              else
              // Aktivite listesi için ListView.builder ve ScrollController
                SizedBox(
                  // Tablonun yüksekliğini sınırla veya Expanded kullan
                  height: 400, // Örnek yükseklik, ihtiyaca göre ayarla
                  child: ListView.builder(
                    controller: _activityScrollController, // Controller'ı bağla
                    itemCount: activitiesData.length + (activityProvider.dashboardHasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Yükleme göstergesi
                      if (index == activitiesData.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Aktivite kartı
                      final activity = activitiesData[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: activity.activityTypeColor.withOpacity(0.1),
                            child: Icon(activity.activityTypeIcon, color: activity.activityTypeColor, size: 20),
                          ),
                          title: Text(activity.customerName ?? 'İsimsiz Müşteri'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activity.activityTypeDisplayText),
                              if (activity.notes != null && activity.notes!.isNotEmpty)
                                Text(
                                  activity.notes!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(dateFormat.format(activity.createdAt)),
                              Text(
                                timeFormat.format(activity.createdAt),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Aktivite detayına veya müşteri detayına git
                            context.go('/customers/${activity.customerId}');
                          },
                        ),
                      );
                    },
                  ),
                ),
            // Daha fazla veri yükleniyorsa gösterge
            if (isLoading && activitiesData.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final paymentProvider = context.watch<PaymentProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final activityProvider = context.watch<ActivityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final int crossAxisCount = _getCrossAxisCount(screenWidth);
            // **** YENİ: Kart aspect ratio'u dinamik hesapla ****
            final double dynamicCardAspectRatio = _computeCardAspectRatio(screenWidth, crossAxisCount);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Text(
                              _getInitial(user?.firstName),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hoş geldin,',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  _getFullName(user?.firstName, user?.lastName),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.roleDisplay ?? 'Kullanıcı',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => context.go('/profile/edit'),
                            tooltip: 'Profili Düzenle',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Taşınan: Hızlı Erişim bölümü (Hoş geldin kartından hemen sonra gösterilecek)
                  const SizedBox(height: 24),
                  Text(
                    'Hızlı Erişim',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: dynamicCardAspectRatio, // **** DEĞİŞİKLİK: dinamik aspect ratio kullanıldı ****
                    children: [
                      _QuickActionCard(
                        title: 'Müşteriler',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () => context.go('/customers'),
                      ),
                      _QuickActionCard(
                        title: 'Gayrimenkuller',
                        icon: Icons.home_work,
                        color: Colors.green,
                        onTap: () => context.go('/properties'),
                      ),
                      _QuickActionCard(
                        title: 'Randevular',
                        icon: Icons.event,
                        color: Colors.orange,
                        onTap: () => context.go('/appointments'),
                      ),
                      if (authProvider.isAdmin || authProvider.isSalesManager)
                        _QuickActionCard(
                          title: 'Raporlar',
                          icon: Icons.analytics,
                          color: Colors.purple,
                          onTap: () => context.go('/reports'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildUpcomingFollowUps(activityProvider.upcomingFollowUps),

                  const SizedBox(height: 24),

                  Text(
                    'Genel Durum',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: dynamicCardAspectRatio, // **** DEĞİŞİKLİK: dinamik aspect ratio kullanıldı ****
                    children: [
                      StatCard(
                        title: 'Bugünkü Aktiviteler',
                        value: authProvider.todaysActivitiesCount.toString(),
                        icon: Icons.list_alt,
                        color: Colors.teal,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Yakında: Bugünkü aktiviteler listesi')),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Bugünkü Satışlar',
                        value: authProvider.todaysSalesCount.toString(),
                        icon: Icons.monetization_on,
                        color: Colors.deepOrange,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Yakında: Bugünkü satışlar listesi')),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Gecikmiş Ödemeler',
                        value: paymentProvider.overduePayments.length.toString(),
                        icon: Icons.warning_amber_rounded,
                        color: Colors.red,
                        onTap: () => context.go('/payments/overdue'),
                      ),
                      StatCard(
                        title: 'Bekleyen Ödemeler',
                        value: paymentProvider.pendingPayments.length.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                        onTap: () => context.go('/payments/pending'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (authProvider.statistics != null) ...[
                    if (user?.isSalesRep ?? false) ...[
                      GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: dynamicCardAspectRatio, // **** DEĞİŞİKLİK: dinamik aspect ratio kullanıldı ****
                        children: [
                          StatCard(
                            title: 'Müşterilerim',
                            value: authProvider.statistics!['total_customers']?.toString() ?? '0',
                            icon: Icons.people,
                            color: Colors.blue,
                            onTap: () => context.go('/customers'),
                          ),
                          StatCard(
                            title: 'Aktiviteler',
                            value: authProvider.statistics!['total_activities']?.toString() ?? '0',
                            icon: Icons.assignment,
                            color: Colors.green,
                          ),
                          _buildCombinedSalesCard(
                            reservationCount: authProvider.statistics!['total_reservations'] ?? 0,
                            salesCount: authProvider.statistics!['total_sales'] ?? 0,
                            authProvider: authProvider,
                          ),
                        ],
                      ),
                    ],
                    if (customerProvider.stats != null && !customerProvider.isStatsLoading)
                      _buildCrmStats(customerProvider.stats!, screenWidth),
                    const SizedBox(height: 24),
                    Text(
                      'Performans ve Gelir Analizi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildResponsiveCharts(context, screenWidth, authProvider),
                  ] else if (!authProvider.isLoading) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('İstatistikler yüklenemedi', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(onPressed: _loadAllData, icon: const Icon(Icons.refresh), label: const Text('Tekrar Dene')),
                          ],
                        ),
                      ),
                    ),
                  ],

                  _buildSalesTable(context),

                  // **** YENİ: Aktivite Tablosu ****
                  _buildActivitiesTable(context),

                  const SizedBox(height: 24),

                  // Not: "Hızlı Erişim" bölümü yukarıya taşındı, alt kısımdaki tekrar eden bölüm kaldırıldı.

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
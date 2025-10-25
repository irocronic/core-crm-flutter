// lib/features/appointments/presentation/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
// GÜNCELLEME: Yerelleştirme için import
import 'package:intl/date_symbol_data_local.dart';
// **** YENİ IMPORT ****
import 'package:intl/intl.dart'; // DateFormat için bu satır eklendi
// **** YENİ IMPORT SONU ****


import '../../../../shared/widgets/custom_drawer.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/appointment_model.dart';
import '../providers/appointment_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<AppointmentModel>> _appointments = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null); // Bu satır doğru yerde
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    final provider = context.read<AppointmentProvider>();
    await provider.loadAppointments();

    final appointments = provider.appointments;
    final Map<DateTime, List<AppointmentModel>> appointmentMap = {};

    for (var appointment in appointments) {
      if (appointment.id == null) continue;

      final date = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );

      if (appointmentMap[date] == null) {
        appointmentMap[date] = [];
      }
      appointmentMap[date]!.add(appointment);
    }

    if (mounted) {
      setState(() {
        _appointments = appointmentMap;
      });
    }
  }

  List<AppointmentModel> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _appointments[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevular'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && _appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && _appointments.isEmpty) {
            return Center(child: Text('Hata: ${provider.errorMessage}'));
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(8),
                child: TableCalendar<AppointmentModel>(
                  locale: 'tr_TR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    // **** GÜNCELLEME: DateFormat burada kullanılıyor ****
                    titleTextFormatter: (date, locale) =>
                        DateFormat.yMMMM(locale).format(date),
                    // **** GÜNCELLEME SONU ****
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                    weekendStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            width: 16.0,
                            height: 16.0,
                            child: Center(
                              child: Text(
                                '${events.length}',
                                style: const TextStyle().copyWith(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: _buildAppointmentsList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/appointments/new');
        },
        child: const Icon(Icons.add),
        tooltip: 'Yeni Randevu Ekle',
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_selectedDay == null) {
      return const Center(child: Text('Lütfen bir tarih seçin'));
    }

    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Bu tarihte randevu yok',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final appointment = events[index];
        return _AppointmentCard(
          appointment: appointment,
          onComplete: () async {
            if (appointment.id == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hata: Randevu ID bulunamadı.'), backgroundColor: Colors.red),
              );
              return;
            }
            final provider = context.read<AppointmentProvider>();
            final success = await provider.completeAppointment(appointment.id!);

            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Randevu tamamlandı'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadAppointments();
            } else if (!success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.errorMessage ?? 'İşlem başarısız'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onCancel: () async {
            if (appointment.id == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hata: Randevu ID bulunamadı.'), backgroundColor: Colors.red),
              );
              return;
            }
            final provider = context.read<AppointmentProvider>();
            final success = await provider.cancelAppointment(appointment.id!);

            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Randevu iptal edildi'),
                  backgroundColor: Colors.orange,
                ),
              );
              _loadAppointments();
            } else if (!success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.errorMessage ?? 'İşlem başarısız'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }
}

// _AppointmentCard widget'ı olduğu gibi kalır...
class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                      color: appointment.statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appointment.statusColor, width: 1)
                  ),
                  child: Text(
                    // Düzeltilmiş: Text kesinlikle non-null bir String almalı
                    (appointment.statusDisplay ?? appointment.status) ?? 'Bilinmiyor',
                    style: TextStyle(
                      color: appointment.statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time_filled_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatTime(appointment.appointmentDate),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey[800]
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),

            Row(
              children: [
                Icon(Icons.person_outline, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.customerName ?? 'Müşteri Bilgisi Yok',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (appointment.customerPhone != null)
                        Text(
                          appointment.customerPhone!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (appointment.location != null && appointment.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.location!,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],

            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  appointment.notes!,
                  style: TextStyle(
                      color: Colors.blueGrey[800],
                      fontSize: 13,
                      fontStyle: FontStyle.italic
                  ),
                ),
              ),
            ],

            if (appointment.status == 'PLANLANDI') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('İptal'),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.orange[800],
                        textStyle: const TextStyle(fontSize: 13)
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Tamamla'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 13),
                        padding: const EdgeInsets.symmetric(horizontal: 16)
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
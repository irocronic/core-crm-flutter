// lib/config/routes.dart

import 'package:flutter/material.dart'; //
import 'package:go_router/go_router.dart'; //

import '../core/services/notification_service.dart'; //
import '../features/auth/presentation/providers/auth_provider.dart'; //
import '../features/auth/presentation/screens/login_screen.dart'; //
import '../features/auth/presentation/screens/profile_edit_screen.dart'; //
import '../features/auth/presentation/screens/change_password_screen.dart'; //
import '../features/dashboard/presentation/screens/dashboard_screen.dart'; //
import '../features/customers/presentation/screens/customers_list_screen.dart'; //
import '../features/customers/presentation/screens/customer_detail_screen.dart'; //
import '../features/customers/presentation/screens/customer_form_screen.dart'; //
import '../features/properties/presentation/screens/projects_list_screen.dart'; //
import '../features/properties/presentation/screens/properties_list_screen.dart'; //
import '../features/properties/presentation/screens/property_detail_screen.dart'; //
import '../features/properties/presentation/screens/property_form_screen.dart'; //
import '../features/properties/presentation/screens/property_stats_screen.dart'; //
import '../features/properties/presentation/screens/property_bulk_upload_screen.dart'; //
import '../features/reservations/presentation/screens/reservations_list_screen.dart'; //
import '../features/reservations/presentation/screens/reservation_form_screen.dart'; //
import '../features/reservations/presentation/screens/payment_tracking_screen.dart'; //
import '../features/appointments/presentation/screens/calendar_screen.dart'; //
import '../features/reports/presentation/screens/reports_screen.dart'; //
import '../features/reports/presentation/screens/sales_report_detail_screen.dart'; //
import '../features/users/presentation/screens/user_list_screen.dart'; //
import '../features/users/presentation/screens/my_team_screen.dart'; //
import '../features/users/presentation/screens/user_form_screen.dart'; //
import '../features/sales/presentation/presentation/screens/overdue_payments_screen.dart'; //
import '../features/sales/presentation/presentation/screens/pending_payments_screen.dart'; //
import '../features/properties/presentation/screens/project_form_screen.dart'; //
import '../features/properties/data/models/property_model.dart'; //
import '../features/properties/presentation/screens/payment_plan_calculator_screen.dart'; //
import '../features/appointments/presentation/screens/appointment_form_screen.dart'; //
// **** YENİ IMPORT'LAR ****
import '../features/settings/presentation/screens/settings_list_screen.dart';
import '../features/settings/presentation/screens/seller_company_form_screen.dart';


class AppRouter {
  static GoRouter router(AuthProvider authProvider) { //
    return GoRouter( //
      navigatorKey: NotificationService.navigatorKey, //
      initialLocation: '/login', //
      redirect: (context, state) { //
        final isLoggedIn = authProvider.isAuthenticated; //
        final isLoginRoute = state.matchedLocation == '/login'; //

        if (!isLoggedIn && !isLoginRoute) { //
          return '/login'; //
        }

        if (isLoggedIn && isLoginRoute) { //
          return '/dashboard'; //
        }

        return null; //
      },
      refreshListenable: authProvider, //
      routes: [ //

        // Auth
        GoRoute( //
          path: '/login', //
          builder: (context, state) => const LoginScreen(), //
        ),
        GoRoute( //
          path: '/change-password', //
          builder: (context, state) => const ChangePasswordScreen(), //
        ),
        // Profile
        GoRoute( //
          path: '/profile/edit', //
          builder: (context, state) => const ProfileEditScreen(), //
        ),

        // Kullanıcı Yönetimi Rotaları
        GoRoute( //
          path: '/users', //
          builder: (context, state) => const UserListScreen(), //
        ),
        GoRoute( //
          path: '/users/new', //
          builder: (context, state) => const UserFormScreen(), //
        ),
        GoRoute( //
          path: '/users/:id/edit', //
          builder: (context, state) { //
            final id = int.parse(state.pathParameters['id']!); //
            return UserFormScreen(userId: id); //
          },

        ),
        GoRoute( //
          path: '/my-team', //
          builder: (context, state) => const MyTeamScreen(), //
        ),
        // Dashboard
        GoRoute( //
          path: '/dashboard', //
          builder: (context, state) => const DashboardScreen(), //
        ),
        // Customers
        GoRoute( //
          path: '/customers', //
          builder: (context, state) => const CustomersListScreen(), //

        ),
        GoRoute( //
          path: '/customers/new', //
          builder: (context, state) => const CustomerFormScreen(), //
        ),
        GoRoute( //
          path: '/customers/:id', //
          builder: (context, state) { //
            final id = int.parse(state.pathParameters['id']!); //
            return CustomerDetailScreen(customerId: id); //
          },
        ),
        GoRoute( //
          path: '/customers/:id/edit', //
          builder: (context, state) { //
            final id = int.parse(state.pathParameters['id']!); //
            return CustomerFormScreen(customerId: id); //
          },
        ),

        // --- PROPERTIES BÖLÜMÜ ---
        GoRoute( //
          path: '/properties', // Ana properties yolu projeleri listeler //
          builder: (context, state) => const ProjectsListScreen(), //
        ),
        GoRoute( //
          path: '/projects/new', //
          builder: (context, state) => const ProjectFormScreen(), //
        ),
        GoRoute( //
          path: '/properties/project/:id', //
          builder: (context, state) { //
            final id = int.parse(state.pathParameters['id']!); //
            final projectName = state.extra as String?; //
            return PropertiesListScreen(projectId: id, projectName: projectName); //
          },
        ),
        GoRoute( //
          path: '/properties/stats', //
          builder: (context, //
              state) => const PropertyStatsScreen(), //
        ),
        // 🔥 YENİ ROUTE TANIMI
        GoRoute( //
          path: '/properties/bulk-upload', //
          builder: (context, state) => const PropertyBulkUploadScreen(), //
        ),
        GoRoute( //
          path: '/properties/new', //
          builder: (context, state) => const PropertyFormScreen(), //
        ),
        GoRoute( //
          path: '/properties/:id', //
          builder: (context, state) { //
            final id = int.parse(state.pathParameters['id']!); //
            return PropertyDetailScreen(propertyId: id); //
          },
        ),
        GoRoute( //
          path: '/properties/:id/edit', //
          builder: (context, state) { //
            final id = int.parse(state.pathParameters['id']!); //
            return PropertyFormScreen(propertyId: id); //
          },
        ),
        GoRoute( //
          path: '/properties/:id/calculate-plan', //
          builder: (context, state) { //
            final cashPrice = state.extra as double?; //
            return PaymentPlanCalculatorScreen(initialCashPrice: cashPrice); //
          },
        ),
        // --- PROPERTIES BÖLÜMÜ SONU ---

        // Reservations
        GoRoute( //
          path: '/reservations', //
          builder: (context, state) { //
            final filter = state.extra as String?; //
            return ReservationsListScreen(filter: filter); //
          },
        ),
        GoRoute( //
            path: '/reservations/new', //
            builder: (context, state) { //
              final property //
              = state.extra as PropertyModel?; // extra'yı al //
              return ReservationFormScreen(initialProperty: property); // Forma gönder //
            }
        ),
        GoRoute( //
          path: '/reservations/:id/payments', //
          builder: (context, state) { //
            final id = int.parse(state.pathParameters['id']!); //
            return PaymentTrackingScreen(reservationId: id); //
          },
        ),

        // Ödeme listeleme sayfaları
        GoRoute( //
          path: '/payments/overdue', //
          builder: (context, state) => const OverduePaymentsScreen(), //
        ),
        GoRoute( //
          path: '/payments/pending', //
          builder: (context, state) => const PendingPaymentsScreen(), //
        ),

        // Appointments
        GoRoute( //
          path: '/appointments', //
          builder: (context, state) => const CalendarScreen(), //
        ),
        GoRoute( //
          path: '/appointments/new', //
          builder: (context, state) => const AppointmentFormScreen(), //
        ),

        // Reports
        GoRoute( //
          path: '/reports', //
          builder: (context, state) => const ReportsScreen(), //
        ),
        GoRoute( //
          path: '/reports/:id', //
          builder: (context, state) { //
            final id = state.pathParameters['id']!; //
            return SalesReportDetailScreen(reportId: id);
          },
        ),

        // **** YENİ AYARLAR ROTALARI ****
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsListScreen(),
        ),
        GoRoute(
          path: '/settings/seller-company/new',
          builder: (context, state) => const SellerCompanyFormScreen(),
        ),
        GoRoute(
          path: '/settings/seller-company/:id/edit',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return SellerCompanyFormScreen(companyId: id);
          },
        ),
        // **** YENİ ROTALAR SONU ****
      ],
    );
  }
}
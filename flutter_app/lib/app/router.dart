import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/financial_records/presentation/record_list_screen.dart';
import '../features/financial_records/presentation/record_detail_screen.dart';
import '../features/financial_records/presentation/add_record_screen.dart';
import '../features/reminders/presentation/reminder_config_screen.dart';
import '../features/financial_records/models/financial_record.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final authState = context.read<AuthProvider>().state;
    final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (authState == AuthState.unauthenticated && !isLoggingIn) {
      return '/login';
    }

    if (authState == AuthState.authenticated && isLoggingIn) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/records/owed',
      builder: (context, state) => const RecordListScreen(initialDirection: Direction.owedToMe),
    ),
    GoRoute(
      path: '/records/i_owe',
      builder: (context, state) => const RecordListScreen(initialDirection: Direction.iOwe),
    ),
    GoRoute(
      path: '/records/all',
      builder: (context, state) => const RecordListScreen(),
    ),
    GoRoute(
      path: '/records/add',
      builder: (context, state) => const AddRecordScreen(),
    ),
    GoRoute(
      path: '/records/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RecordDetailScreen(recordId: id);
      },
    ),
    GoRoute(
      path: '/records/detail/:id/reminders',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ReminderConfigScreen(recordId: id);
      },
    ),
  ],
);

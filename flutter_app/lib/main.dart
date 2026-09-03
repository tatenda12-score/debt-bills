import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/router.dart';
import 'core/storage/secure_storage.dart';
import 'core/network/api_client.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/financial_records/services/financial_record_service.dart';
import 'features/reminders/services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final secureStorage = SecureStorage();
  final apiClient = ApiClient(secureStorage);
  final authService = AuthService(apiClient);
  final recordService = FinancialRecordService(apiClient);
  final reminderService = ReminderService(apiClient);

  final authProvider = AuthProvider(authService, secureStorage);
  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        Provider.value(value: recordService),
        Provider.value(value: reminderService),
      ],
      child: const FinancialReminderApp(),
    ),
  );
}

class FinancialReminderApp extends StatelessWidget {
  const FinancialReminderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Financial Reminder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

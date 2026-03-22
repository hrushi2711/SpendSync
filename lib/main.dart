import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/card_model.dart';
import 'models/transaction_model.dart';
import 'models/user_model.dart';
import 'repositories/card_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/user_repository.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CardModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  final userRepo = UserRepository();
  await userRepo.init();

  final cardRepo = CardRepository();
  await cardRepo.init();

  final txRepo = TransactionRepository();
  await txRepo.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userRepo),
        ChangeNotifierProvider.value(value: cardRepo),
        ChangeNotifierProvider.value(value: txRepo),
        ChangeNotifierProvider(create: (_) => AuthProvider(userRepo)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const CreditTrackerApp(),
    ),
  );
}

class CreditTrackerApp extends StatelessWidget {
  const CreditTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    // If user just logged in, attempt to migrate orphaned data to their account
    if (authProvider.isLoggedIn) {
      final userId = authProvider.currentUserId;
      context.read<CardRepository>().migrateOrphanedData(userId);
      context.read<TransactionRepository>().migrateOrphanedData(userId);
    }

    return MaterialApp(
      title: 'SpendSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      home: authProvider.isLoggedIn ? const AppShell() : const LoginScreen(),
    );
  }
}

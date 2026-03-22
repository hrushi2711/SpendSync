import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/card_model.dart';
import 'models/transaction_model.dart';
import 'repositories/card_repository.dart';
import 'repositories/transaction_repository.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CardModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  final cardRepo = CardRepository();
  await cardRepo.init();

  final txRepo = TransactionRepository();
  await txRepo.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cardRepo),
        ChangeNotifierProvider.value(value: txRepo),
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
    return MaterialApp(
      title: 'SpendSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      home: const AppShell(),
    );
  }
}

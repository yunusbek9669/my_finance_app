import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/finance/presentation/screens/home/home_screen.dart';

void main() async {
  // Flutter binding'larini ishga tushirish
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Hive'ni ishga tushirish (keyinroq qo'shamiz)
  // await Hive.initFlutter();

  // Ilovani ishga tushirish
  runApp(
    // ProviderScope - Riverpod uchun
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Yoki ThemeMode.system

      // Asosiy ekran
      home: const HomeScreen(),
    );
  }
}
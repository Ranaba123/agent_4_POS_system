import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/localization_service.dart';
import 'services/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for desktop platforms (Windows, Linux, macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Load saved theme preference
  final isDarkMode = await AppTheme.getIsDarkMode();
  
  runApp(AntiGravityPOS(initialDarkMode: isDarkMode));
}

class AntiGravityPOS extends StatefulWidget {
  final bool initialDarkMode;
  
  const AntiGravityPOS({super.key, this.initialDarkMode = false});
  
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_AntiGravityPOSState>();
    state?.setLocale(locale);
  }
  
  static void toggleTheme(BuildContext context) {
    final state = context.findAncestorStateOfType<_AntiGravityPOSState>();
    state?.toggleTheme();
  }
  
  static bool isDarkMode(BuildContext context) {
    final state = context.findAncestorStateOfType<_AntiGravityPOSState>();
    return state?._isDarkMode ?? false;
  }

  @override
  State<AntiGravityPOS> createState() => _AntiGravityPOSState();
}

class _AntiGravityPOSState extends State<AntiGravityPOS> {
  Locale _locale = const Locale('en');
  late bool _isDarkMode;
  Future<AppStrings>? _stringsFuture;
  
  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
    _stringsFuture = _loadInitial();
  }

  Future<AppStrings> _loadInitial() async {
    final results = await Future.wait([
      LocalizationService.load(_locale.languageCode),
      Future.delayed(const Duration(seconds: 3)),
    ]);
    return results[0] as AppStrings; // Cast to AppStrings?
  }
  
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      _stringsFuture = LocalizationService.load(_locale.languageCode);
    });
  }
  
  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    AppTheme.setIsDarkMode(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naya Potha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      home: FutureBuilder<AppStrings>(
        future: _stringsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
              return HomeScreen(strings: snapshot.data!, isDarkMode: _isDarkMode);
          }
          return SplashScreen(isDarkMode: _isDarkMode);
        },
      ),
    );
  }
}

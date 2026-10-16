import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_database.dart';
import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final database = AppDatabase();
  await database.initialize();
  runApp(ApPonteApp(preferences: preferences, database: database));
}

class ApPonteApp extends StatefulWidget {
  const ApPonteApp({super.key, required this.preferences, required this.database});

  final SharedPreferences preferences;
  final AppDatabase database;

  @override
  State<ApPonteApp> createState() => _ApPonteAppState();
}

class _ApPonteAppState extends State<ApPonteApp> {
  late bool _darkMode = widget.preferences.getBool('dark_mode') ?? false;

  Future<void> _setDarkMode(bool value) async {
    setState(() => _darkMode = value);
    await widget.preferences.setBool('dark_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApPonte · Quartiere Ponte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: AppShell(
        database: widget.database,
        darkMode: _darkMode,
        onThemeChanged: _setDarkMode,
      ),
    );
  }
}

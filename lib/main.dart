import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/ecran_dossiers.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const AppleNoteApp());
}

class AppleNoteApp extends StatefulWidget {
  const AppleNoteApp({super.key});

  @override
  State<AppleNoteApp> createState() => _AppleNoteAppState();
}

class _AppleNoteAppState extends State<AppleNoteApp> {
  bool _modeSombre = false;

  void _toggleTheme() {
    setState(() {
      _modeSombre = !_modeSombre;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      themeMode: _modeSombre ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: EcranDossiers(toggleTheme: _toggleTheme, isDark: _modeSombre),
    );
  }
}

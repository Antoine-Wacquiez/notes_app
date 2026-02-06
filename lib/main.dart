import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/ecran_dossiers.dart';

void main() {
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
    const couleurJaune = Color(0xFFFFCC00);
    const grisFondClair = Color(0xFFF2F2F7);
    const grisFondSombre = Color(0xFF000000);

    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      themeMode: _modeSombre ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: grisFondClair,
        primaryColor: couleurJaune,
        appBarTheme: const AppBarTheme(
          backgroundColor: grisFondClair,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: couleurJaune,
        ),
      ),

      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: grisFondSombre,
        appBarTheme: const AppBarTheme(
          backgroundColor: grisFondSombre,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: couleurJaune,
        ),
      ),

      home: EcranDossiers(toggleTheme: _toggleTheme, isDark: _modeSombre),
    );
  }
}

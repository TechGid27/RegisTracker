import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RegisTrackApp());
}

class RegisTrackApp extends StatelessWidget {
  const RegisTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF4F46E5); // Indigo
    const bg = Color(0xFFF6F7FF);
    const text = Color(0xFF0F172A); // Slate-900
    const subtleBorder = Color(0xFFE7E9F4);

    return MaterialApp(
      title: 'RegisTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: bg,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: subtleBorder),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: seed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: subtleBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: subtleBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: seed, width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          labelStyle: const TextStyle(color: Color(0xFF64748B)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: text),
          bodyMedium: TextStyle(color: Color(0xFF334155)),
          titleLarge: TextStyle(color: text, fontWeight: FontWeight.bold),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}


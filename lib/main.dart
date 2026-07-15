import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'features/splash/splash_screen.dart';

void main() {
  runApp(const RideMateApp());
}

class RideMateApp extends StatefulWidget {
  const RideMateApp({super.key});

  @override
  State<RideMateApp> createState() => _RideMateAppState();
}

class _RideMateAppState extends State<RideMateApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "RideMate",

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),

      themeMode: _themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4CF0),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111318),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C6FFF),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1C1F26),
          elevation: 0,
        ),
      ),
      home: SplashScreen(
        themeMode: _themeMode,
        toggleTheme: toggleTheme,

      ),
    );
  }
}
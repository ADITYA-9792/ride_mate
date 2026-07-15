import 'package:flutter/material.dart';

import 'auth/login/login_screen.dart';

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
      _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RideMate',

      themeMode: _themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4CF0),
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C6FFF),
          brightness: Brightness.dark,
        ),
      ),

      home: LoginScreen(
        themeMode: _themeMode,
        toggleTheme: toggleTheme,
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth/welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const SplashScreen({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(
            themeMode: widget.themeMode,
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B4CF0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Color(0xFF5B4CF0),
                size: 70,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "RideMate",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Zero Platform Fee",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_screen.dart';
import '../../shared/constants/app_fonts.dart';
import '../login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _logoScale = Tween<double>(begin: .85, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, .45, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, .35)),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(.35, .70)),
    );

    _controller.forward();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    Widget nextScreen;

    if (!onboardingCompleted) {
      nextScreen = const OnboardingScreen();
    } else if (user != null) {
      nextScreen = const HomeScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => nextScreen,
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // 300ms → Fast
  // 600ms → Normal
  // 800ms → Slow
  // 1200ms → Very slow
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/splash_bg.png", fit: BoxFit.cover),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Image.asset(
                        "assets/images/inkly_logo.png",
                        width: 320,
                      ),
                    ),
                  ),

                  FadeTransition(
                    opacity: _textOpacity,
                    child: const Column(
                      children: [
                        Text(
                          "A diary that listens.",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: AppFonts.handwriting1,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3B2D24),
                          ),
                        ),

                        Text(
                          "A diary that remembers.",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: AppFonts.handwriting1,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3B2D24),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

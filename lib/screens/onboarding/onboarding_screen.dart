import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/constants/app_fonts.dart';

import '../login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<OnboardingModel> pages = [
    const OnboardingModel(
      image: "assets/images/onb1.png",
      title: "Welcome to\nInkly",
      subtitle: "A beautiful place to\nwrite your thoughts.",
      buttonTitle: "Next",
    ),
    const OnboardingModel(
      image: "assets/images/onb2.png",
      title: "Make journaling\na habit",
      subtitle: "Reminders, themes and\nmore to help you\nstay consistent.",
      buttonTitle: "Get Started",
    ),
  ];

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("onboarding_completed", true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/bg_image.png", fit: BoxFit.cover),

          SafeArea(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = pages[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 55),

                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 38,
                          fontFamily: AppFonts.handwriting1,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff4A2D18),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        page.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: AppFonts.handwriting1,
                          height: 1.5,
                          color: Color(0xff75624E),
                        ),
                      ),

                      const Spacer(),

                      Image.asset(
                        page.image,
                        width: page.image == "assets/images/onb1.png"
                            ? 280
                            : 345,
                        fit: BoxFit.contain,
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          const Spacer(),

                          SizedBox(
                            width: currentPage == pages.length - 1 ? 340 : 150,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                if (currentPage == pages.length - 1) {
                                  finishOnboarding();
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B4528),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                currentPage == pages.length - 1
                                    ? "Get Started"
                                    : "Next",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 55),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingModel {
  final String image;
  final String title;
  final String subtitle;
  final String buttonTitle;

  const OnboardingModel({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonTitle,
  });
}

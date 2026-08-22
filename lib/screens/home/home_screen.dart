import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim().split(" ").first
        : "there";

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    // Greeting
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${_greeting()}, $name 👋",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF211A16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Search
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search your diary...",
                          hintStyle: const TextStyle(
                            color: Color(0xFF9A9692),
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFAAA6A2),
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFAAA6A2),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 42),

                    // Recent Entries
                    const Text(
                      "Recent Entries",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF211A16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }


  Widget _entryCard({
    required String title,
    required String date,
    required String preview,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 145),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFECE3D9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Journal rings
          Positioned(
            left: -4,
            top: 13,
            bottom: 13,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => Container(
                  width: 20,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9B989),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(44, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF29231F),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7E7872),
                  ),
                ),

                const SizedBox(height: 13),

                Padding(
                  padding: const EdgeInsets.only(right: 35),
                  child: Text(
                    preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF514A44),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


 }

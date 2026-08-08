import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final loginStatus = arguments?["loginStatus"] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(title: const Text("Inkly")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            if (user?.photoURL != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user!.photoURL!),
              ),

            const SizedBox(height: 20),

            Text(
              user?.displayName ?? "No Name",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              user?.email ?? "No Email",
              style: const TextStyle(fontSize: 17),
            ),

            const SizedBox(height: 20),

            Text("UID: ${user?.uid ?? "No UID"}", textAlign: TextAlign.center),

            const SizedBox(height: 20),

            Text("Provider: Google", style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: loginStatus == "New User"
                    ? Colors.green.shade100
                    : Colors.blue.shade100,
              ),
              child: Text(
                loginStatus,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: loginStatus == "New User"
                      ? Colors.green.shade800
                      : Colors.blue.shade800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService.instance.signOut();

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

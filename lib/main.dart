import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'shared/constants/app_fonts.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint("✅ Firebase Initialized");

  runApp(const InklyApp());
}

class InklyApp extends StatelessWidget {
  const InklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: AppFonts.poppins),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppPages.onGenerateRoute,
    );
  }
}

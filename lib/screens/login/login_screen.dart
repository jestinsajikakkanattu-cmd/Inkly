import 'package:flutter/material.dart';
import '../../shared/constants/app_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/bg_image.png", fit: BoxFit.cover),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  Center(
                    child: Image.asset("assets/images/inkly_logo.png", width: 230),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Welcome back!",
                    style: TextStyle(
                      fontSize: 37,
                      fontFamily: AppFonts.handwriting1,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff4A2D18),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Sign in to continue your journey\nand keep your memories safe.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      height: 1.5,
                      fontFamily: AppFonts.handwriting1,
                      color: Color(0xff75624E),
                    ),
                  ),

                  const SizedBox(height: 25),

                  _loginButton(
                    image: "assets/login_images/google.png",
                    title: "Continue with Google",
                    onTap: () {},
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text("OR"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 15),

                  _loginButton(
                    image: "assets/login_images/email.png",
                    title: "Continue with Email",
                    onTap: () {},
                  ),

                  const SizedBox(height: 5),

                  // Image.asset(
                  //   "assets/login_images/leaf_pen_text.png",
                  //   width: 365,
                  // ),
                  const SizedBox(height: 45),
                  Row(
                    children: [
                      Expanded(
                        child: _feature(
                          image: "assets/login_images/secure.png",
                          title: "Secure",
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 45,
                        color: const Color(0xFFD8C8B6),
                      ),

                      Expanded(
                        child: _feature(
                          image: "assets/login_images/cloud.png",
                          title: "Synced",
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 45,
                        color: const Color(0xFFD8C8B6),
                      ),

                      Expanded(
                        child: _feature(
                          image: "assets/login_images/lock.png",
                          title: "Private",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "By continuing, you agree to our",
                    style: TextStyle(fontSize: 15, color: Color(0xff75624E)),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Terms",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(" & "),

                      Text(
                        "Privacy Policy",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginButton({
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3F2A1E),
          elevation: 5,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Image.asset(image, width: 50, height: 50),

            // const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature({required String image, required String title}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          image,
          width: 70, // Adjust icon size here
          height: 45,
        ),

        // const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF5B4638),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../shared/constants/app_fonts.dart';
import 'sign_up_screen.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ---------------------------------------------------------
  // FORGOT PASSWORD
  // ---------------------------------------------------------

  Future<void> _showForgotPasswordDialog() async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();

    bool isValid = false;
    bool isSending = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFCF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                "Forgot Password?",
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Enter your email address.\n"
                      "We'll send a reset link.",
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {
                        setDialogState(() {
                          isValid = RegExp(
                            r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value.trim());
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }

                        if (!RegExp(
                          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return "Enter a valid email";
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSending
                            ? null
                            : () {
                                Navigator.pop(dialogContext);
                              },
                        child: const Text("Cancel"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: !isValid || isSending
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                setDialogState(() {
                                  isSending = true;
                                });

                                try {
                                  await AuthService.instance.sendPasswordReset(
                                    email: emailController.text.trim(),
                                  );

                                  if (!dialogContext.mounted) {
                                    return;
                                  }

                                  Navigator.pop(dialogContext);

                                  if (!mounted) return;

                                  _showResetSuccessDialog();
                                } catch (e) {
                                  setDialogState(() {
                                    isSending = false;
                                  });

                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceFirst(
                                          "Exception: ",
                                          "",
                                        ),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        child: isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Send"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
  }

  void _showResetSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Icon(Icons.check_circle, size: 60, color: Colors.green),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reset Link Sent",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              Text(
                "If your email exists,\n"
                "you'll receive a password reset link shortly.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("OK"),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // EMAIL SIGN IN
  // ---------------------------------------------------------

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
        arguments: {"loginStatus": AuthService.instance.loginStatus},
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------
  // LINK GOOGLE DIALOG
  // ---------------------------------------------------------

  Future<bool?> _showLinkGoogleDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Link Google Account?",
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "You already have an Inkly account "
            "with this email.\n\n"
            "Would you like to link Google so you "
            "can use either Google or your email "
            "and password to sign in?",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Not Now"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Link Google"),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                    ),

                    Image.asset("assets/images/inkly_logo.png", width: 200),

                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 42,
                        fontFamily: AppFonts.handwriting1,
                        color: Color(0xFF4A2D18),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }

                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return "Enter a valid email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }

                        if (value.length < 6) {
                          return "Minimum 6 characters";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // FORGOT PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : _showForgotPasswordDialog,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Color(0xFF6B4528)),
                        ),
                      ),
                    ),

                    // SIGN IN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4528),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CREATE ACCOUNT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Color(0xFF75624E),
                            fontSize: 15,
                          ),
                        ),

                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Color(0xFF6B4528),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

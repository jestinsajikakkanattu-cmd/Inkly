import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/profile_image_service.dart';
import '../settings/settings_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileImageChanged;

  const ProfileScreen({super.key, this.onProfileImageChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool _isLoadingImage = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _profileImage = null;
        _isLoadingImage = false;
      });

      return;
    }

    final path = await ProfileImageService.instance.getImagePath(user.uid);

    if (!mounted) return;

    setState(() {
      _profileImage = path != null ? File(path) : null;
      _isLoadingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : "User";

    final email = user?.email ?? "No email";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/bg_image.png", fit: BoxFit.cover),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 55, 22, 30),
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // Profile image
                  GestureDetector(
                    onTap: _changeProfilePicture,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _buildProfileImage(user),

                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B4528),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Name
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF211A16),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Email
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF655B54),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Joined date
                  Text(
                    "Joined on ${_joinedDate(user)}",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF81766E),
                    ),
                  ),

                  const SizedBox(height: 38),

                  // Stats
                  Row(
                    children: [
                      _statItem("Entries", "0"),
                      _divider(),
                      _statItem("Streak", "0 days"),
                      _divider(),
                      _statItem("Favorites", "0"),
                    ],
                  ),

                  const SizedBox(height: 42),

                  // Edit Profile
                  _profileOption(
                    icon: Icons.person_outline_rounded,
                    title: "Edit Profile",
                    onTap: () {
                      print("✅ Edit Profile tapped");
                    },
                  ),

                  const SizedBox(height: 14),

                  // Settings
                  _profileOption(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    highlighted: false,
                    onTap: () {
                      print("✅ Settings tapped");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Sign Out
                  _profileOption(
                    icon: Icons.logout_rounded,
                    title: "Sign Out",
                    onTap: () async {
                      print("✅ Sign Out tapped");

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFFFFFBF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              "Sign Out?",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF211A16),
                              ),
                            ),
                            content: const Text(
                              "Are you sure you want to sign out?",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF655B54),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Color(0xFF655B54)),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B4528),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Yes, Sign Out"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed != true) return;

                      try {
                        await GoogleSignIn().signOut();
                        await FirebaseAuth.instance.signOut();

                        if (!context.mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/login",
                          (route) => false,
                        );

                        print("✅ User signed out successfully");
                      } catch (e) {
                        print("❌ Sign out error: $e");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(User? user) {
    // Still loading local image
    if (_isLoadingImage) {
      return Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE7D8C6),
        ),
        child: const Padding(
          padding: EdgeInsets.all(42),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF6B4528),
          ),
        ),
      );
    }

    // 1. User's manually selected local image
    if (_profileImage != null) {
      return ClipOval(
        child: Image.file(
          _profileImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    // 2. Google/Firebase profile image
    final photoURL = user?.photoURL;

    if (photoURL != null && photoURL.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoURL,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _defaultAvatar();
          },
        ),
      );
    }

    // 3. Default avatar
    return _defaultAvatar();
  }

  Future<void> _changeProfilePicture() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      final file = File(image.path);

      final savedPath = await ProfileImageService.instance.saveImage(
        file,
        user.uid,
      );

      if (!mounted) return;

      setState(() {
        _profileImage = File(savedPath);
      });

      // Tell MainScreen that profile image changed
      widget.onProfileImageChanged?.call();

      print("✅ Profile image saved locally");
      print("👤 UID: ${user.uid}");
      print("📁 Path: $savedPath");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully")),
      );
    } catch (e) {
      print("❌ Profile image error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile picture")),
      );
    }
  }

  Widget _statItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF655B54)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: Color(0xFF211A16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 58, width: 1, color: const Color(0xFFE7DED5));
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF8).withOpacity(.82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlighted
                ? const Color(0xFFE7C39B)
                : const Color(0xFFECE3D9),
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: const Color(0xFF29231F)),

            const SizedBox(width: 20),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF211A16),
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: Color(0xFF29231F),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE7D8C6),
      ),
      child: const Icon(Icons.person, size: 65, color: Color(0xFF6B4528)),
    );
  }

  String _joinedDate(User? user) {
    final creationTime = user?.metadata.creationTime;

    if (creationTime == null) {
      return "Unknown";
    }

    return "${creationTime.day.toString().padLeft(2, '0')} "
        "${_monthName(creationTime.month)} "
        "${creationTime.year}";
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return months[month - 1];
  }
}

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/profile_image_service.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  File? _profileImage;

  String? _loadedUserId;

  @override
  void initState() {
    super.initState();

    _loadProfileImage(
      FirebaseAuth.instance.currentUser,
    );
  }

  Future<void> _loadProfileImage(User? user) async {
    if (user == null) {
      if (!mounted) return;

      setState(() {
        _profileImage = null;
        _loadedUserId = null;
      });

      return;
    }

    // Don't load the same user's image repeatedly
    if (_loadedUserId == user.uid) {
      return;
    }

    _loadedUserId = user.uid;

    final path = await ProfileImageService.instance.getImagePath(
      user.uid,
    );

    if (!mounted) return;

    setState(() {
      _profileImage = path != null ? File(path) : null;
    });

    print("✅ Loaded profile image for UID: ${user.uid}");
    print("📁 Local image: $path");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user =
            snapshot.data ?? FirebaseAuth.instance.currentUser;

        // Detect account change
        if (user?.uid != _loadedUserId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadProfileImage(user);
            }
          });
        }

        final pages = [
          const HomeScreen(),

          const Center(
            child: Text("Calendar"),
          ),

          const Center(
            child: Text("Reminders"),
          ),

          ProfileScreen(
            onProfileImageChanged: () {
              _refreshProfileImage(user);
            },
          ),
        ];

        return Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: _buildBottomBar(user),
        );
      },
    );
  }

  Future<void> _refreshProfileImage(User? user) async {
    if (user == null) return;

    final path =
        await ProfileImageService.instance.getImagePath(
      user.uid,
    );

    if (!mounted) return;

    setState(() {
      _profileImage = path != null ? File(path) : null;
      _loadedUserId = user.uid;
    });

    print("🔄 Profile tab image updated");
    print("👤 UID: ${user.uid}");
    print("📁 Image: $path");
  }

  Widget _buildBottomBar(User? user) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF8),
        border: Border(
          top: BorderSide(
            color: Color(0xFFECE3D9),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _navItem(
              icon: Icons.home_rounded,
              title: "Home",
              index: 0,
            ),
          ),

          Expanded(
            child: _navItem(
              icon: Icons.calendar_month_outlined,
              title: "Calendar",
              index: 1,
            ),
          ),

          Expanded(
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  print("✅ New Diary tapped");
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B4528),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: _navItem(
              icon: Icons.notifications_none_rounded,
              title: "Reminders",
              index: 2,
            ),
          ),

          Expanded(
            child: _profileItem(
              user,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        print("✅ $title tab tapped");
      },
      child: SizedBox(
        height: 82,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: selected
                  ? const Color(0xFF6B4528)
                  : const Color(0xFF655B54),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? const Color(0xFF6B4528)
                    : const Color(0xFF655B54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(User? user) {
    final photoURL = user?.photoURL;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = 3;
        });

        print("✅ Profile tapped");
      },
      child: SizedBox(
        height: 82,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: _profileImage != null
                  ? Image.file(
                      _profileImage!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    )
                  : photoURL != null && photoURL.isNotEmpty
                      ? Image.network(
                          photoURL,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _defaultProfile();
                          },
                        )
                      : _defaultProfile(),
            ),

            const SizedBox(height: 4),

            Text(
              "Profile",
              style: TextStyle(
                fontSize: 11,
                fontWeight: _selectedIndex == 3
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: _selectedIndex == 3
                    ? const Color(0xFF6B4528)
                    : const Color(0xFF655B54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultProfile() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE7D8C6),
      ),
      child: const Icon(
        Icons.person,
        size: 20,
        color: Color(0xFF6B4528),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    print(" ✅ main screen build");
    final user = FirebaseAuth.instance.currentUser;
    print(" ✅ USER: ${user?.email}");
    print(" ✅ PHOTO URL: ${user?.photoURL}");

    final pages = [
      const HomeScreen(),
      const Center(child: Text("Calendar")),
      const Center(child: Text("Reminders")),
      const Center(child: Text("Profile")),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomBar(user),
    );
  }

  Widget _buildBottomBar(User? user) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF8),
        border: Border(top: BorderSide(color: Color(0xFFECE3D9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _navItem(icon: Icons.home_rounded, title: "Home", index: 0),
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
                  print(" ✅ New Diary tapped");
                  // New Diary later
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B4528),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 38),
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

          Expanded(child: _profileItem(user)),
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
          print("✅ $title tab tapped");
          _selectedIndex = index;
        });
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
        print(" ✅ Profile tapped");
      },
      child: SizedBox(
        height: 82,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: photoURL != null && photoURL.isNotEmpty
                  ? Image.network(
                      photoURL,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
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
      child: const Icon(Icons.person, size: 20, color: Color(0xFF6B4528)),
    );
  }

  Widget _profileImage(User? user) {
    final photoURL = user?.photoURL;

    if (photoURL != null && photoURL.isNotEmpty) {
      return CircleAvatar(radius: 16, backgroundImage: NetworkImage(photoURL));
    }

    return const CircleAvatar(
      radius: 16,
      backgroundColor: Color(0xFFE7D8C6),
      child: Icon(Icons.person, size: 20, color: Color(0xFF6B4528)),
    );
  }
}

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _privacyLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset("assets/images/bg_image.png", fit: BoxFit.cover),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 20, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 21,
                          color: Color(0xFF211A16),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Text(
                            "Settings",
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF211A16),
                            ),
                          ),
                        ),
                      ),

                      // Keeps title centered
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE7DED5)),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
                    child: Column(
                      children: [
                        // LANGUAGE
                        _settingsRow(
                          title: "Language",
                          trailing: "English",
                          onTap: () {
                            print("✅ Language tapped");
                          },
                        ),

                        // THEME
                        _settingsRow(
                          title: "Theme",
                          trailing: "Classic Paper",
                          onTap: () {
                            print("✅ Theme tapped");
                          },
                        ),

                        // FONT STYLE
                        _settingsRow(
                          title: "Font ",
                          trailing: "Dancing Script",
                          onTap: () {
                            print("✅ Font Style tapped");
                          },
                        ),

                        // NOTIFICATIONS
                        _settingsToggleRow(
                          title: "Notifications",
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });

                            print("✅ Notifications: $value");
                          },
                        ),

                        // PRIVACY LOCK
                        _settingsToggleRow(
                          title: "Privacy Lock",
                          value: _privacyLockEnabled,
                          onChanged: (value) {
                            setState(() {
                              _privacyLockEnabled = value;
                            });

                            print("✅ Privacy Lock: $value");
                          },
                        ),

                        // BACKUP & RESTORE
                        _settingsRow(
                          title: "Backup & Restore",
                          onTap: () {
                            print("✅ Backup & Restore tapped");
                          },
                        ),

                        // ABOUT INKLY
                        _settingsRow(
                          title: "About Inkly",
                          onTap: () {
                            print("✅ About Inkly tapped");
                          },
                        ),
                      ],
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

  // ---------------------------------------------------------
  // SETTINGS ROW
  // ---------------------------------------------------------

  Widget _settingsRow({
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE7DED5), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF29231F),
                ),
              ),
            ),

            if (trailing != null) ...[
              Text(
                trailing,
                style: const TextStyle(fontSize: 14, color: Color(0xFF81766E)),
              ),

              const SizedBox(width: 8),
            ],

            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF655B54),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // TOGGLE ROW
  // ---------------------------------------------------------

  Widget _settingsToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE7DED5), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF29231F),
              ),
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF39734B),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF9A9692),
          ),
        ],
      ),
    );
  }
}

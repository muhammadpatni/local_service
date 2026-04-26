import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_service/help_center_screen.dart';
import 'package:local_service/login_screen.dart';
import 'package:local_service/main.dart';
import 'package:local_service/privacy_policy_screen.dart';
import 'package:local_service/saved_addresses_screen.dart';
import 'package:local_service/terms_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _handleDeleteAccount(BuildContext context) async {
    // 1. Navigation state ko await se pehle save kar lein
    // Taa ke baad mein context mounted ka issue na aaye
    final navigator = Navigator.of(context, rootNavigator: true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;

        // 2. Firestore se data delete karein
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // 3. Google Sign-In session khatam karein
        try {
          await GoogleSignIn().signOut();
        } catch (e) {
          debugPrint("Google SignOut Error: $e");
        }

        // 4. Auth se account delete karein
        // (Note: Agar user ne bohut pehle login kiya tha toh yahan 'requires-recent-login' error aa sakta hai)
        await user.delete();
      }
    } catch (e) {
      debugPrint("Deletion process error: $e");
    } finally {
      // 5. Har haal mein Auth SignOut karein
      await FirebaseAuth.instance.signOut();

      // 6. Ab saved 'navigator' use karein page change karne ke liye.
      // Yahan context.mounted check ki zaroorat nahi kyunke navigator humne pehle hi bind kar liya tha.
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  final Color primaryBlue = const Color(0xFF0E6BBB);
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    // Current theme check karne ke liye
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Background color theme ke mutabiq khud change hoga
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),

          // --- ACCOUNT SECTION ---
          _buildSectionHeader("Account Settings"),
          _buildSettingTile(
            icon: Icons.person_outline,
            title: "Profile Information",
            subtitle: "Name, Email, Phone Number",
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
            },
          ),
          _buildSettingTile(
            icon: Icons.location_on_outlined,
            title: "Saved Addresses",
            subtitle: "Manage your service locations",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedAddressesScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          // --- APP PREFERENCES ---
          _buildSectionHeader("App Preferences"),

          // LIGHT / DARK MODE TOGGLE
          _buildSwitchTile(
            icon: isDarkMode ? Icons.dark_mode : Icons.light_mode_outlined,
            title: "Dark Mode",
            value: isDarkMode,
            onChanged: (val) {
              // main.dart ki theme change karne ki logic
              MyApp.of(
                context,
              )?.changeTheme(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),

          _buildSwitchTile(
            icon: Icons.notifications_none_outlined,
            title: "Push Notifications",
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() {
                notificationsEnabled = val;
              });
            },
          ),

          const SizedBox(height: 25),

          // --- SUPPORT SECTION ---
          _buildSectionHeader("More Information"),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: "Help Center",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsAndConditionsScreen(),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // --- DANGER ZONE ---
          _buildSectionHeader("Account Actions"),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
                size: 22,
              ),
            ),
            title: Text(
              "Delete Account",
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      "Confirm Delete",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      "Are you sure you want to permanently delete your account?.",
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Dialog band karein
                          _handleDeleteAccount(context); // Function call karein
                        },
                        child: Text(
                          "Delete",
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  "Noraya Local Services",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  "Version 1.0.1",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Reusable Helper Widgets ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: primaryBlue,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryBlue, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: Colors.black26,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryBlue, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: primaryBlue,
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_service/login_screen.dart';
import 'package:local_service/provider_profile_setting_screen.dart';
import 'package:local_service/safety_page.dart';
import 'package:local_service/user_profile_setting_screen.dart';
import 'package:local_service/user_setting_page.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  final Color primaryBlue = const Color(0xFF0E6BBB);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Header Section (Clean Profile)
            _buildHeader(context),

            // 2. Sleek Divider
            Divider(
              thickness: 1,
              height: 1,
              color: Colors.grey[200],
              indent: 20,
              endIndent: 20,
            ),

            // 3. Scrollable List Items
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                children: [
                  _buildMenuItem(Icons.history, "Request History", () {}),
                  _buildMenuItem(Icons.security_outlined, "Safety", () {
                    // 1. Pehle drawer ko band karein
                    Navigator.pop(context);

                    // 2. Phir Safety screen par jayein takay back option kaam kare
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SafetyScreen(),
                      ),
                    );
                  }),
                  _buildMenuItem(Icons.settings_outlined, "Settings", () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // --- LOGOUT BUTTON UPDATED ---
                  _buildMenuItem(Icons.logout, "Logout", () async {
                    // Firebase se sign out karein
                    await FirebaseAuth.instance.signOut();
                    await GoogleSignIn.instance.signOut();

                    // context.mounted check karna zaroori hai async ke baad
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }, isLogout: true),
                ],
              ),
            ),

            // --- 4. BOTTOM SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Switch Button with shadow
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5), // shadow direction
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        String userData =
                            user?.email ?? user?.phoneNumber ?? '';

                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProviderProfileSettingsScreen(
                              emailnumber: userData,
                              isSwitching: true, // <--- YAHAN TRUE PASS KAREIN
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Switch to Provider",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30), // Gap before social area
                  // Follow us text
                  Text(
                    "Follow us on",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Social Icons with circular borders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(Icons.facebook),
                      const SizedBox(width: 20),
                      _socialIcon(
                        Icons.camera_alt_outlined,
                      ), // generic Insta icon
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildHeader(BuildContext context) {
  //   return InkWell(
  //     onTap: () {
  //       // Drawer band karein
  //       Navigator.pop(context);

  //       // Profile Settings Screen open karein Edit Mode ke saath
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const UserProfileSettingsScreen(
  //             emailnumber: null,
  //             isEditMode: true, // Yahan true pass karna zaroori hai
  //           ),
  //         ),
  //       );
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.all(20.0),
  //       child: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(2),
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               border: Border.all(color: primaryBlue, width: 2),
  //             ),
  //             child: CircleAvatar(
  //               radius: 28,
  //               backgroundColor: primaryBlue.withOpacity(0.1),
  //               child: Icon(Icons.person, size: 30, color: primaryBlue),
  //             ),
  //           ),
  //           const SizedBox(width: 15),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   "Ahmed Raza",
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 17,
  //                     fontWeight: FontWeight.w700,
  //                     color: Colors.black87,
  //                   ),
  //                 ),
  //                 Text(
  //                   "View Profile",
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 13,
  //                     color: Colors.black45,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Icon(Icons.chevron_right, color: Colors.grey[400]),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String name = "Guest User";
        String? imageUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? "No Name";
          imageUrl = data['profileImage'];
        }

        return InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileSettingsScreen(
                  emailnumber: user?.email ?? user?.phoneNumber,
                  isEditMode: true,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryBlue, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryBlue.withValues(alpha: 0.1),
                    backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : null,
                    child: (imageUrl == null || imageUrl.isEmpty)
                        ? Icon(Icons.person, size: 30, color: primaryBlue)
                        : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "View Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isLogout
            ? Colors.red.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.black87,
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: isLogout
            ? null
            : const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Icon(icon, color: Colors.grey[700], size: 24),
    );
  }
}

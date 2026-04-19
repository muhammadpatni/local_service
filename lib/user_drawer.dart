// import 'package:flutter/material.dart';
// import 'package:local_service/login_screen.dart';

// class UserDrawer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text("Logout", style: TextStyle(color: Colors.red)),
//             onTap: () {
//               // Bina puche seedha Login screen pr bhejne k liye
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => LoginScreen(),
//                 ), // Aapki Login screen ka naam
//                 (route) => false,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_service/login_screen.dart';
import 'package:local_service/safety_page.dart';
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
            _buildHeader(),

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

                    // 2. Phir Safety screen par jayein takay back option kaam kare
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  _buildMenuItem(Icons.logout, "Logout", () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }, isLogout: true),
                ],
              ),
            ),

            // --- 4. BOTTOM SECTION (Updated based on image_5.png) ---
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
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5), // shadow direction
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // background container se lenge
                        foregroundColor: Colors.white,
                        elevation: 0, // original shadow
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

  Widget _buildHeader() {
    return InkWell(
      onTap: () {},
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
                backgroundColor: primaryBlue.withOpacity(0.1),
                child: Icon(Icons.person, size: 30, color: primaryBlue),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ahmed Raza",
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
        color: isLogout ? Colors.red.withOpacity(0.08) : Colors.transparent,
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

  // Reusable Social Icon with specific circular border from image
  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ), // sleek border
      ),
      child: Icon(icon, color: Colors.grey[700], size: 24),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:local_service/login_screen.dart';

// class UserDrawer extends StatelessWidget {
//   const UserDrawer({super.key});

//   final Color primaryBlue = const Color(0xFF0E6BBB);

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Column(
//         children: [
//           // 1. Profile Section with Arrow
//           InkWell(
//             onTap: () {
//               // Firebase integration ke baad yahan Profile settings par navigate karein
//             },
//             child: Container(
//               padding: const EdgeInsets.only(
//                 top: 60,
//                 left: 20,
//                 right: 20,
//                 bottom: 20,
//               ),
//               child: Row(
//                 children: [
//                   // Profile Picture
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundColor: Colors.grey[200],
//                     child: const Icon(
//                       Icons.person,
//                       size: 35,
//                       color: Colors.grey,
//                     ),
//                     // Baad mein image lagane ke liye:
//                     // backgroundImage: NetworkImage(userData.imageUrl),
//                   ),
//                   const SizedBox(width: 15),
//                   // User Name
//                   Expanded(
//                     child: Text(
//                       "User Name", // Baad mein Firebase se variable yahan ayega
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   // The Arrow you requested
//                   const Icon(Icons.chevron_right, color: Colors.black54),
//                 ],
//               ),
//             ),
//           ),

//           const Divider(thickness: 1),

//           // 2. Drawer Items
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               children: [
//                 _buildDrawerItem(
//                   icon: Icons.history,
//                   title: "Request History",
//                   onTap: () {},
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.security_outlined,
//                   title: "Safety",
//                   onTap: () {},
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.settings_outlined,
//                   title: "Settings",
//                   onTap: () {},
//                 ),
//                 const Divider(
//                   height: 30,
//                   thickness: 1,
//                   indent: 15,
//                   endIndent: 15,
//                 ),

//                 _buildDrawerItem(
//                   icon: Icons.logout,
//                   title: "Logout",
//                   iconColor: Colors.red,
//                   textColor: Colors.red,
//                   onTap: () {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const LoginScreen(),
//                       ),
//                       (route) => false,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // 3. Provider Mode Button
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryBlue,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   "Provider mode",
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.facebook, color: Colors.grey[600], size: 30),
//                 const SizedBox(width: 20),
//                 Icon(
//                   Icons.camera_alt_outlined,
//                   color: Colors.grey[600],
//                   size: 30,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     Color? iconColor,
//     Color? textColor,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: iconColor ?? Colors.black87, size: 24),
//       title: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: textColor ?? Colors.black87,
//         ),
//       ),
//       onTap: onTap,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:local_service/login_screen.dart';
// // Baqi pages ko yahan import karlein jese jese aap banati jayengi
// // import 'package:local_service/request_history.dart';

// class UserDrawer extends StatelessWidget {
//   const UserDrawer({super.key});

//   final Color primaryBlue = const Color(0xFF0E6BBB);

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Column(
//         children: [
//           // Drawer Header (Khali rakha hai jesa aapne kaha)
//           const SizedBox(height: 60),

//           // Drawer Items
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               children: [
//                 _buildDrawerItem(
//                   icon: Icons.history,
//                   title: "Request History",
//                   onTap: () {
//                     // Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestHistoryPage()));
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.security_outlined,
//                   title: "Safety",
//                   onTap: () {
//                     // Navigation logic here
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.settings_outlined,
//                   title: "Settings",
//                   onTap: () {
//                     // Navigation logic here
//                   },
//                 ),
//                 const Divider(
//                   height: 30,
//                   thickness: 1,
//                   indent: 15,
//                   endIndent: 15,
//                 ),

//                 // Logout Item (Red Color)
//                 _buildDrawerItem(
//                   icon: Icons.logout,
//                   title: "Logout",
//                   iconColor: Colors.red,
//                   textColor: Colors.red,
//                   onTap: () {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const LoginScreen(),
//                       ),
//                       (route) => false,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Provider Mode Button (Bottom me)
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Provider mode switch logic
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryBlue,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   "Provider mode",
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Social Icons (Jesa image me tha)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.facebook, color: Colors.grey[600], size: 30),
//                 const SizedBox(width: 20),
//                 Icon(
//                   Icons.camera_alt_outlined,
//                   color: Colors.grey[600],
//                   size: 30,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Custom Drawer Item Builder for Theme Consistency
//   Widget _buildDrawerItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     Color? iconColor,
//     Color? textColor,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: iconColor ?? Colors.black87, size: 24),
//       title: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: textColor ?? Colors.black87,
//         ),
//       ),
//       onTap: onTap,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart'; // Is package ko pubspec.yaml mein add karein

// class HelpCenterScreen extends StatelessWidget {
//   const HelpCenterScreen({super.key});

//   final Color primaryBlue = const Color(0xFF0E6BBB);

//   // Email ya Call karne ka function
//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri)) {
//       throw Exception('Could not launch $url');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: isDarkMode ? Colors.white : Colors.black,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Help Center",
//           style: GoogleFonts.poppins(
//             color: isDarkMode ? Colors.white : Colors.black,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "How can we help you?",
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 20),

//             // --- Contact Cards ---
//             Row(
//               children: [
//                 _contactCard(
//                   context,
//                   icon: Icons.email_outlined,
//                   title: "Email Us",
//                   onTap: () => _launchURL("mailto:support@noraya.com"),
//                 ),
//                 const SizedBox(width: 15),
//                 _contactCard(
//                   context,
//                   icon: Icons.call_outlined,
//                   title: "Call Us",
//                   onTap: () => _launchURL("tel:+923000000000"),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),
//             Text(
//               "Frequently Asked Questions",
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 15),

//             // --- FAQ List ---
//             _buildFaqItem(
//               context,
//               "How do I book a service?",
//               "Open the home screen, select a category, and choose your provider.",
//             ),
//             _buildFaqItem(
//               context,
//               "Can I cancel my booking?",
//               "Yes, you can cancel up to 2 hours before the service starts.",
//             ),
//             _buildFaqItem(
//               context,
//               "How to pay for service?",
//               "You can pay via cash or integrated wallet after the work is done.",
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _contactCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: primaryBlue.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(color: primaryBlue.withOpacity(0.2)),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: primaryBlue, size: 30),
//               const SizedBox(height: 10),
//               Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.w600,
//                   color: primaryBlue,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFaqItem(BuildContext context, String question, String answer) {
//     return ExpansionTile(
//       title: Text(
//         question,
//         style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
//       ),
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Text(
//             answer,
//             style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart'; // Logic ke liye lazmi hai

// class HelpCenterScreen extends StatelessWidget {
//   const HelpCenterScreen({super.key});

//   final Color primaryBlue = const Color(0xFF0E6BBB);

//   // --- LOGIC: Email aur Call Function ---
//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri)) {
//       throw Exception('Could not launch $url');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark
//           ? const Color(0xFF121212)
//           : const Color(0xFFF8FAFF),
//       body: CustomScrollView(
//         slivers: [
//           // --- MODERN HEADER ---
//           // --- UPDATED MODERN APPBAR (Spanish Blue Theme) ---
//           SliverAppBar(
//             expandedHeight: 200,
//             pinned: true,
//             elevation: 0,
//             // Jab app bar collapse (choti) ho jaye to is color ki dikhegi
//             backgroundColor: primaryBlue,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               centerTitle: true,
//               title: Text(
//                 "Help Center",
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               background: Container(
//                 decoration: BoxDecoration(
//                   // Spanish Blue Gradient for a premium feel
//                   gradient: LinearGradient(
//                     colors: [
//                       primaryBlue, // #0E6BBB
//                       const Color(0xFF0A5796), // Thora dark shade for depth
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Background icon for visual appeal
//                     Icon(
//                       Icons.support_agent_rounded,
//                       color: Colors.white.withOpacity(0.2),
//                       size: 80,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // --- CONTENT AREA ---
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Contact Support",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // --- CONTACT CARDS (Logic Included) ---
//                   Row(
//                     children: [
//                       _buildModernContactCard(
//                         context,
//                         icon: Icons.mail_outline_rounded,
//                         title: "Email Us",
//                         color: Colors.orange,
//                         onTap: () => _launchURL("mailto:support@noraya.com"),
//                       ),
//                       const SizedBox(width: 15),
//                       _buildModernContactCard(
//                         context,
//                         icon: Icons.phone_in_talk_outlined,
//                         title: "Call Us",
//                         color: Colors.green,
//                         onTap: () => _launchURL("tel:+923000000000"),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 35),

//                   // --- FAQ SECTION ---
//                   Text(
//                     "Common Questions",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   _buildModernFaq(
//                     context,
//                     "How to book a service?",
//                     "Select a category from the home screen and choose your provider.",
//                   ),
//                   _buildModernFaq(
//                     context,
//                     "Payment methods?",
//                     "We accept cash on delivery and all major digital wallets.",
//                   ),
//                   _buildModernFaq(
//                     context,
//                     "Is my data safe?",
//                     "Yes, Noraya uses end-to-end encryption for all user data.",
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- MODERN UI COMPONENTS ---

//   Widget _buildModernContactCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     bool isDark = Theme.of(context).brightness == Brightness.dark;

//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 25),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: color, size: 28),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildModernFaq(BuildContext context, String question, String answer) {
//     bool isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: ExpansionTile(
//         shape: const RoundedRectangleBorder(side: BorderSide.none),
//         collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
//         leading: Icon(Icons.help_outline, color: primaryBlue, size: 20),
//         title: Text(
//           question,
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: isDark ? Colors.white : Colors.black87,
//           ),
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 55, right: 20, bottom: 15),
//             child: Text(
//               answer,
//               style: GoogleFonts.poppins(
//                 fontSize: 13,
//                 color: Colors.grey,
//                 height: 1.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final Color primaryBlue = const Color(0xFF0E6BBB);

  // --- LOGIC: Email aur Call Function ---
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAFF),

      // --- MINIMAL APPBAR (Jaisa Privacy Policy mein hai) ---
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help Center",
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER TEXT ---
            Text(
              "How can we help you?",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // --- CONTACT CARDS ---
            Row(
              children: [
                _buildModernContactCard(
                  context,
                  icon: Icons.mail_outline_rounded,
                  title: "Email Us",
                  color: Colors.orange,
                  onTap: () => _launchURL("mailto:support@noraya.com"),
                ),
                const SizedBox(width: 15),
                _buildModernContactCard(
                  context,
                  icon: Icons.phone_in_talk_outlined,
                  title: "Call Us",
                  color: Colors.green,
                  onTap: () => _launchURL("tel:+923000000000"),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // --- FAQ SECTION ---
            Text(
              "Common Questions",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            _buildModernFaq(
              context,
              "How do I book a service?",
              "Select a category from the home screen and choose your provider.",
            ),
            _buildModernFaq(
              context,
              "Can I cancel my booking?",
              "Yes, you can cancel up to 2 hours before the service starts.",
            ),
            _buildModernFaq(
              context,
              "How to pay for service?",
              "We accept cash on delivery and all major digital wallets.",
            ),
            _buildModernFaq(
              context,
              "Is my data safe?",
              "Yes, Noraya uses end-to-end encryption for all user data.",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- MODERN UI COMPONENTS ---

  Widget _buildModernContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFaq(BuildContext context, String question, String answer) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Icon(Icons.help_outline, color: primaryBlue, size: 20),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 55, right: 20, bottom: 15),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

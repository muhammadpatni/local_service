// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:local_service/user_profile_setting_screen.dart';

// class SelectionScreen extends StatefulWidget {
//   final String emailcontact;
//   const SelectionScreen({super.key, required this.emailcontact});

//   @override
//   State<SelectionScreen> createState() => _SelectionScreenState();
// }

// class _SelectionScreenState extends State<SelectionScreen> {
//   final Color primaryBlue = const Color(0xFF0E6BBB);

//   @override
//   Widget build(BuildContext context) {
//     // Media Query for dynamic font and spacing scaling
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double textScale = MediaQuery.of(context).textScaleFactor;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               // Physics ensure smooth scrolling if text is too large
//               physics: const BouncingScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: ConstrainedBox(
//                   // Ye ensure karta hai ke content kam se kam poori screen cover kare
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: IntrinsicHeight(
//                     child: Column(
//                       children: [
//                         SizedBox(height: screenHeight * 0.05),

//                         // 1. Heading Section
//                         Text(
//                           "Are you a user or a provider?",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                             // Text scale handle karne ke liye thora chota rakha hai base size
//                             fontSize: 24 * (textScale > 1.2 ? 0.9 : 1.0),
//                             fontWeight: FontWeight.w700,
//                             color: const Color(0xFF1A1A1A),
//                             height: 1.2,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           "You can change the mode later",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                             fontSize: 15,
//                             color: Colors.black54,
//                           ),
//                         ),

//                         SizedBox(height: screenHeight * 0.04),

//                         // 2. Illustration Image (Responsive Container)
//                         // Agar text bohot bara ho jaye to image choti ho jayegi automatic
//                         Flexible(
//                           child: ConstrainedBox(
//                             constraints: BoxConstraints(
//                               maxHeight: screenHeight * 0.35,
//                             ),
//                             child: Image.asset(
//                               'assets/images/image3.jpeg',
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 120,
//                         ), // Fixed space for buttons, lekin agar text bara ho to ye space kam ho jayega
//                         // Spacer tab tak kaam karega jab tak text screen ke bahar nahi jata
//                         // const Spacer(),

//                         // 3. Selection Buttons Section
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 20),
//                           child: Column(
//                             children: [
//                               // User Button
//                               _buildButton(
//                                 text: "I am a User",
//                                 color: primaryBlue,
//                                 textColor: Colors.white,
//                                 isBorder: false,
//                                 onPressed: () {
//                                   Navigator.pushReplacement(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           UserProfileSettingsScreen(
//                                             emailnumber: widget.emailcontact,
//                                           ),
//                                     ),
//                                   );
//                                 },
//                               ),

//                               const SizedBox(height: 16),

//                               // Provider Button
//                               _buildButton(
//                                 text: "I am a Provider",
//                                 color: const Color(0xFFF1F4F8),
//                                 textColor: Colors.black87,
//                                 isBorder: false,
//                                 onPressed: () {
//                                   // Provider Logic
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // Helper method for clean and reusable button code
//   Widget _buildButton({
//     required String text,
//     required Color color,
//     required Color textColor,
//     required bool isBorder,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       // Min height set ki hai lekin agar text bara ho to height barh sakti hai
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: textColor,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: isBorder
//                 ? BorderSide(color: Colors.grey[300]!)
//                 : BorderSide.none,
//           ),
//         ),
//         child: Text(
//           text,
//           style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }

//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_service/login_screen.dart';
import 'package:local_service/provider_home_screen.dart';
import 'package:local_service/provider_profile_setting_screen.dart';
import 'package:local_service/user_profile_setting_screen.dart';

class SelectionScreen extends StatefulWidget {
  final String emailcontact;
  const SelectionScreen({super.key, required this.emailcontact});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  bool _isCheckingProvider = false;

  void _cancelAndLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Provider button tap - pehle check karo agar already provider hai
  Future<void> _onProviderTap() async {
    setState(() => _isCheckingProvider = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isCheckingProvider = false);
        return;
      }

      // Check karo agar already provider ka data hai
      DocumentSnapshot providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .get();

      if (!mounted) return;
      setState(() => _isCheckingProvider = false);

      if (providerDoc.exists) {
        // Already provider hai - direct provider home par bhejo
        // lastMode update karo
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'lastMode': 'provider'});

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
            (route) => false,
          );
        }
      } else {
        // Naya provider - setup screen par bhejo
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderProfileSettingsScreen(
                emailnumber: widget.emailcontact,
                isSwitching: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Provider check error: $e");
      setState(() => _isCheckingProvider = false);
      // Error par bhi setup screen par bhejo
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderProfileSettingsScreen(
              emailnumber: widget.emailcontact,
              isSwitching: false,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textScale = MediaQuery.of(context).textScaleFactor;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _cancelAndLogout();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _cancelAndLogout,
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              Text(
                                "Are you a user or a provider?",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24 * (textScale > 1.2 ? 0.9 : 1.0),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "You can change the mode later",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.04),

                              Flexible(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: screenHeight * 0.35,
                                  ),
                                  child: Image.asset(
                                    'assets/images/image3.jpeg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 120),

                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  children: [
                                    _buildButton(
                                      text: "I am a User",
                                      color: primaryBlue,
                                      textColor: Colors.white,
                                      isBorder: false,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserProfileSettingsScreen(
                                                  emailnumber:
                                                      widget.emailcontact,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildButton(
                                      text: "I am a Provider",
                                      color: const Color(0xFFF1F4F8),
                                      textColor: Colors.black87,
                                      isBorder: false,
                                      onPressed: _isCheckingProvider
                                          ? () {}
                                          : _onProviderTap,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Loading overlay for provider check
            if (_isCheckingProvider)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required bool isBorder,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isBorder
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

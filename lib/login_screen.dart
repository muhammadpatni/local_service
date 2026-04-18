// import 'package:flutter/material.dart';
// import 'package:local_service/phone_auth.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   // 1. PageController banayein takay dots update ho sakein
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               // Logo Section
//               _buildLogo(),

//               const Spacer(),

//               // 2. PageView for Slidable Images
//               SizedBox(
//                 height: 250,
//                 child: PageView(
//                   controller: _pageController,
//                   onPageChanged: (int page) {
//                     setState(() {
//                       _currentPage = page;
//                     });
//                   },
//                   children: [
//                     // Pehli Image ka Placeholder
//                     Container(
//                       color: Colors.grey[200],
//                       child: const Center(child: Text("Image 1 Placeholder")),
//                     ),
//                     // Doosri Image ka Placeholder
//                     Container(
//                       color: Colors.grey[300],
//                       child: const Center(child: Text("Image 2 Placeholder")),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 40),

//               const Text(
//                 "Your app for fair deals",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 "Choose rides that are right for you",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 18, color: Colors.black87),
//               ),

//               const SizedBox(height: 20),

//               // 3. Dynamic Slider Dots
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(2, (index) => _buildDot(index)),
//               ),

//               const Spacer(),

//               // Buttons Section
//               _buildButtons(),

//               const SizedBox(height: 20),
//               _buildFooterText(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Dot banane ka function
//   Widget _buildDot(int index) {
//     return Container(
//       height: 8,
//       width: 8,
//       margin: const EdgeInsets.only(right: 8),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         // Agar page match karta hai to dark, warna light color
//         color: _currentPage == index ? Colors.black : Colors.grey[300],
//       ),
//     );
//   }

//   // Baki UI Helper Methods (Sada code rakhne ke liye)
//   Widget _buildLogo() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             color: const Color(0xFFC6FF00),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Text(
//             "id",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//           ),
//         ),
//         const SizedBox(width: 8),
//         const Text(
//           "inDrive",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }

//   Widget _buildButtons() {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => PhoneAuth()),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFC6FF00),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               elevation: 0,
//             ),
//             child: const Text(
//               "Continue with phone",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: OutlinedButton(
//             onPressed: () {},
//             style: OutlinedButton.styleFrom(
//               backgroundColor: const Color(0xFFF2F2F2),
//               side: BorderSide.none,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             child: const Text(
//               "Continue with Google",
//               style: TextStyle(fontSize: 18, color: Colors.black),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFooterText() {
//     return const Padding(
//       padding: EdgeInsets.only(bottom: 20),
//       child: Text(
//         "Joining our app means you agree with our Terms of Use and Privacy Policy",
//         textAlign: TextAlign.center,
//         style: TextStyle(color: Colors.black54, fontSize: 13),
//       ),
//     );
//   }
// }

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:local_service/phone_auth.dart'; // Google Fonts import kiya
// // import 'package:local_service/phone_auth.dart'; // Aapka apna path

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   // Aapke bataye gaye colors
//   final Color primaryBlue = const Color(0xFF0E6BBB);
//   final Color whiteColor = Colors.white;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(
//         0xFFF8F9FA,
//       ), // Slightly off-white background takay glass effect nazar aaye
//       body: SafeArea(
//         // LayoutBuilder + SingleChildScrollView keyboard overflow rokne ke liye best hai
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: IntrinsicHeight(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 40),

//                         // 1. Premium Glassmorphism Logo Section
//                         _buildGlassLogo(),

//                         const SizedBox(height: 30),

//                         // 2. PageView for Slidable Images
//                         SizedBox(
//                           height: 220,
//                           child: PageView(
//                             controller: _pageController,
//                             onPageChanged: (int page) {
//                               setState(() {
//                                 _currentPage = page;
//                               });
//                             },
//                             children: [
//                               _buildImagePlaceholder("Premium Image 1"),
//                               _buildImagePlaceholder("Premium Image 2"),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 30),

//                         // Text Content
//                         Text(
//                           "Your app for fair deals",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                             fontSize: 26,
//                             fontWeight: FontWeight.w700,
//                             color: const Color(0xFF1A1A1A),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Choose rides that are right for you",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             color: Colors.black54,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         // 3. Dynamic Slider Dots
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: List.generate(
//                             2,
//                             (index) => _buildDot(index),
//                           ),
//                         ),

//                         const Spacer(), // Ye UI ko push kar ke bottom pe layega
//                         // 4. Buttons Section
//                         _buildButtons(),

//                         const SizedBox(height: 20),
//                         _buildFooterText(),
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

//   // --- Helper Widgets ---

//   // Glassmorphism Logo Design
//   Widget _buildGlassLogo() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // 1. Background Blue Glow
//         Container(
//           width: 100,
//           height: 100,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: primaryBlue.withOpacity(0.3),
//             boxShadow: [
//               BoxShadow(
//                 color: primaryBlue.withOpacity(0.2),
//                 blurRadius: 30,
//                 spreadRadius: 10,
//               ),
//             ],
//           ),
//         ),

//         // 2. Glass Container with Circular Logo
//         ClipRRect(
//           borderRadius: BorderRadius.circular(100),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//             child: Container(
//               width: 140, // Glass circle thora bara rakha hai
//               height: 140,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.2),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.5),
//                   width: 1.5,
//                 ),
//               ),
//               child: Center(
//                 // 3. Logo ko Circle mein fit karne ke liye CircleAvatar ya Container
//                 child: Container(
//                   width: 100, // Logo ka size
//                   height: 100,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     image: DecorationImage(
//                       image: AssetImage('assets/images/logo.png'),
//                       fit: BoxFit
//                           .cover, // Isse square pic round circle mein fit ho jayegi
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Image Placeholder styling
//   Widget _buildImagePlaceholder(String text) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         color: whiteColor,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: GoogleFonts.poppins(
//             color: primaryBlue.withOpacity(0.5),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   // Dynamic Dots
//   Widget _buildDot(int index) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       height: 8,
//       width: _currentPage == index ? 24 : 8,
//       margin: const EdgeInsets.only(right: 6),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: _currentPage == index ? primaryBlue : Colors.grey[300],
//       ),
//     );
//   }

//   // Beautiful Buttons
//   Widget _buildButtons() {
//     return Column(
//       children: [
//         // Primary Button (Blue)
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton(
//             onPressed: () {
//               // Aapki original functionality
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => PhoneAuth()),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryBlue,
//               foregroundColor: whiteColor,
//               shadowColor: primaryBlue.withOpacity(0.5),
//               elevation: 8,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             child: Text(
//               "Continue with phone",
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),

//         // Secondary Button (White outline)
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: OutlinedButton(
//             onPressed: () {},
//             style: OutlinedButton.styleFrom(
//               backgroundColor: whiteColor,
//               side: BorderSide(color: primaryBlue.withOpacity(0.3), width: 1.5),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Google Icon (Optional, acha lagta hai)
//                 Icon(Icons.g_mobiledata_rounded, color: primaryBlue, size: 32),
//                 const SizedBox(width: 8),
//                 Text(
//                   "Continue with Google",
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: const Color(0xFF1A1A1A),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Footer Text
//   Widget _buildFooterText() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Text(
//         "Joining our app means you agree with our\nTerms of Use and Privacy Policy",
//         textAlign: TextAlign.center,
//         style: GoogleFonts.poppins(
//           color: Colors.black45,
//           fontSize: 12,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import 'package:local_service/phone_auth.dart';
=======
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_service/phone_screen_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
>>>>>>> 362beddea64ffc558cf0a2225bc517436c2fa12f

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

<<<<<<< HEAD
  Future<void> signinwithgoogle() async {
=======
<<<<<<< HEAD
  final Color primaryBlue = const Color(0xFF0E6BBB);
  final Color whiteColor = Colors.white;
=======
  signinwithgoogle() async {
>>>>>>> d6d1c661209ae4f239511716b9c100918535eeac
    final GoogleSignInAccount? googleuser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? auth = await googleuser?.authentication;

    final credentials = GoogleAuthProvider.credential(
      idToken: auth?.idToken,
      accessToken: auth?.accessToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credentials);
  }
>>>>>>> 362beddea64ffc558cf0a2225bc517436c2fa12f

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background pure white kar diya
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // 1. Logo Section
                        _buildGlassLogo(),

                        const SizedBox(height: 30),

                        // 2. PageView for Actual Images
                        SizedBox(
                          height: 200, // Image height thori adjust ki hai
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (int page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
                            children: [
                              _buildSimpleImage('assets/images/image1.jpeg'),
                              _buildSimpleImage('assets/images/image2.jpeg'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          "Your Home Services, fair deals",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Choose experts that are right for you",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 3. Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            2,
                            (index) => _buildDot(index),
                          ),
                        ),

                        const Spacer(),

                        // 4. Buttons
                        _buildButtons(),

                        const SizedBox(height: 20),
                        _buildFooterText(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Simple Image Loader (No Border, No Shadow)
  Widget _buildSimpleImage(String path) {
    return Container(
      width: double.infinity,
      color: Colors.white, // Pure white background
      child: Image.asset(
        path,
        fit: BoxFit.contain, // Image cut nahi hogi
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_outlined, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildGlassLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryBlue.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _currentPage == index ? primaryBlue : Colors.grey[300],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhoneAuth()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: whiteColor,
              elevation: 0, // Flat premium look
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Continue with phone",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: () {
              signinwithgoogle();
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: whiteColor,
              side: BorderSide(color: primaryBlue.withOpacity(0.3), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.g_mobiledata_rounded,
                  size: 30,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  "Continue with Google",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        "Joining our app means you agree with our\nTerms of Use and Privacy Policy",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: Colors.black45, fontSize: 12),
      ),
    );
  }
}

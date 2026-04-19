import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_service/phone_auth.dart';
import 'package:local_service/user_profile_setting_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color primaryBlue = const Color(0xFF0E6BBB);

  // --- Logic: Google Sign In ---
  Future<void> signinwithgoogle() async {
    try {
      final GoogleSignInAccount? googleuser = await GoogleSignIn().signIn();
      if (googleuser == null) return;

      final GoogleSignInAuthentication auth = await googleuser.authentication;

      final credentials = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credentials);

      final user = userCredential.user;

      if (user != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileSettingsScreen(
              emailnumber: user.email, // 👈 yahan email pass ho rahi hai
            ),
          ),
        );
      }
    } catch (e) {
      log("Google Sign-In Error: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google Sign-In Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen ki height aur width nikal li taake responsive banaya ja saky
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // CustomScrollView aur SliverFillRemaining best hain overflow rokne ke liye
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody:
                  false, // Ye Spacer() ko kaam karne dega bina error ke
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // 1. Logo Section
                    SizedBox(height: screenHeight * 0.03),
                    Center(
                      child: Container(
                        // Clamp use kiya hai taake maximum size 130 hi rahe, lekin chhote phone pe thora chota ho jaye
                        height: (screenHeight * 0.15).clamp(90.0, 130.0),
                        width: (screenHeight * 0.15).clamp(90.0, 130.0),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // 2. Illustration PageView
                    SizedBox(
                      height: screenHeight * 0.28,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          Image.asset(
                            'assets/images/image1.jpeg',
                            fit: BoxFit.contain,
                          ),
                          Image.asset(
                            'assets/images/image2.jpeg',
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                    // 3. Dots
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) => _buildDot(index)),
                    ),

                    SizedBox(height: screenHeight * 0.025), // Flexible gap
                    // 4. Text Content
                    Text(
                      "Your Home Services,\nfair deals",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        // Font size responsive kiya hai (max 24)
                        fontSize: (screenWidth * 0.06).clamp(20.0, 24.0),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Choose experts that are right for you",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        // Font size responsive (max 15)
                        fontSize: (screenWidth * 0.04).clamp(13.0, 15.0),
                        color: Colors.black54,
                      ),
                    ),

                    // Ye Spacer() ab safe hai, choti screen pe bhi error nahi dega
                    const Spacer(),

                    // 5. Buttons Section
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          // Button ki height responsive (max 56)
                          height: (screenHeight * 0.07).clamp(48.0, 56.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PhoneAuth(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Continue with phone",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: (screenHeight * 0.07).clamp(48.0, 56.0),
                          child: OutlinedButton(
                            onPressed: () => signinwithgoogle(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.g_mobiledata_rounded,
                                  color: Colors.black,
                                  size: 35,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Continue with Google",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: screenHeight * 0.03,
                    ), // Footer se pehle ka gap
                    _buildFooterText(screenWidth),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? 22 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _currentPage == index ? primaryBlue : Colors.grey[300],
      ),
    );
  }

  // Footer text mein thori responsiveness add ki
  Widget _buildFooterText(double screenWidth) {
    return Text(
      "Joining our app means you agree with our\nTerms of Use and Privacy Policy",
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: Colors.black45,
        fontSize: (screenWidth * 0.03).clamp(9.0, 11.0),
      ),
    );
  }
}

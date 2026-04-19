// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_service/otp_screen.dart' show OtpScreen;

// class PhoneAuth extends StatefulWidget {
//   const PhoneAuth({super.key});

//   @override
//   State<PhoneAuth> createState() => _PhoneAuthState();
// }

// class _PhoneAuthState extends State<PhoneAuth> {
//   TextEditingController phoneController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Phone Authentication")),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 25),
//             child: TextField(
//               controller: phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 labelText: "Phone Number",
//                 prefixText: "+92 ",
//                 suffixIcon: const Icon(Icons.phone),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 30),

//           ElevatedButton(
//             onPressed: () async {
//               await FirebaseAuth.instance.verifyPhoneNumber(
//                 verificationCompleted: (PhoneAuthCredential credential) {},
//                 verificationFailed: (FirebaseAuthException ex) {},
//                 codeSent: (String verificationId, int? resendToken) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           OtpScreen(verificationId: verificationId),
//                     ),
//                   );
//                 },
//                 codeAutoRetrievalTimeout: (String verificationId) {},
//                 // Purana tariqa (Jo error de raha hai):
//                 // phoneNumber: phoneController.text.toString(),

//                 // Naya aur sahi tariqa:
//                 phoneNumber: "+92${phoneController.text.trim()}",
//               );
//               // Yahan OTP send karne ka logic add karein
//             },
//             child: Text(" Verify Phome Number"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_service/otp_screen.dart' show OtpScreen;

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  TextEditingController phoneController = TextEditingController();

  // Wahi primary blue jo login screen par tha
  final Color primaryBlue = const Color(0xFF0E6BBB);
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Back button ko customize kiya takay clean lage
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 1. Modern Header (Bina Image ke)
                  Text(
                    "Verify your phone",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We will send a 6-digit verification code to your number.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // 2. Styled Phone Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: "300 1234567",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        labelText: "Phone Number",
                        labelStyle: GoogleFonts.poppins(
                          color: primaryBlue,
                          fontSize: 14,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          margin: const EdgeInsets.only(right: 8),
                          child: Text(
                            "+92 ",
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 3. Premium Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() => isLoading = true);
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: "+92${phoneController.text.trim()}",
                          verificationCompleted:
                              (PhoneAuthCredential credential) {
                                setState(() => isLoading = false);
                              },
                          verificationFailed: (FirebaseAuthException ex) {
                            setState(() => isLoading = false);
                            String message = "Verification Failed";

                            if (ex.message != null &&
                                ex.message!.contains("BILLING_NOT_ENABLED")) {
                              message =
                                  "Number not registered. We are unable to send OTP. Use a registered number.";
                            } else if (ex.code == 'invalid-phone-number') {
                              message =
                                  "Incorrect format. Re-enter number in this format: 3xx-xxxxxxx";
                            } else {
                              message = ex.message ?? "Verification Failed";
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            setState(() => isLoading = false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OtpScreen(verificationId: verificationId),
                              ),
                            );
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {
                            setState(() => isLoading = false);
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Get OTP Code",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 4. Subtle security note
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Your number is safe with us",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryBlue, // same theme blue
                ),
              ),
            ),
        ],
      ),
    );
  }
}

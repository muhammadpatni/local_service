// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_service/home_page.dart';

// // ignore: must_be_immutable
// class OtpScreen extends StatefulWidget {
//   String verificationId;
//   OtpScreen({super.key, required this.verificationId});

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   TextEditingController otpController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("OTP Verification")),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: "Enter OTP",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 suffixIcon: const Icon(Icons.lock),
//               ),
//             ),
//           ),
//           SizedBox(height: 30),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 PhoneAuthCredential credential =
//                     await PhoneAuthProvider.credential(
//                       verificationId: widget.verificationId,
//                       smsCode: otpController.text.toString(),
//                     );

//                 FirebaseAuth.instance.signInWithCredential(credential).then((
//                   value,
//                 ) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => MyHomePage()),
//                   );
//                 });
//               } catch (ex) {
//                 log(ex.toString());
//               }
//             },
//             child: Text("Verify OTP"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_service/selection_screen.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String contact;
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.contact,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final Color primaryBlue = const Color(0xFF0E6BBB);

  @override
  Widget build(BuildContext context) {
    // Responsive width calculation: Screen width ko 6 boxes mein divide karne ke liye
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth =
        (screenWidth - 80) / 6; // Padding subtract kar ke 6 par divide kiya

    // --- Pinput ki Styling ---
    final defaultPinTheme = PinTheme(
      width: boxWidth,
      height: 60,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: primaryBlue, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Keyboard overflow se bachne ke liye
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Verify OTP",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter the 6-digit code sent to your number.",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 50),

                // --- Pinput Widget (Responsive & Error-free) ---
                Center(
                  child: Pinput(
                    length: 6,
                    controller: otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    // 'pinputAutoresize' hata diya gaya hai error fix karne ke liye
                    showCursor: true,
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Boxes mein barabar gap
                    onCompleted: (pin) => _verifyOtp(pin),
                  ),
                ),

                const SizedBox(height: 50),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      _verifyOtp(otpController.text);
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
                      "Verify & Proceed",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Verification Logic ---
  void _verifyOtp(String pin) async {
    if (pin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter full 6-digit code")),
      );
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: pin,
      );

      await FirebaseAuth.instance.signInWithCredential(credential).then((
        value,
      ) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectionScreen(emailcontact: widget.contact),
          ),
        );
      });
    } catch (ex) {
      log("OTP Error: ${ex.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP, please try again.")),
      );
    }
  }
}

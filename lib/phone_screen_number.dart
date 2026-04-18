import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneScreenNumber extends StatefulWidget {
  const PhoneScreenNumber({super.key});

  @override
  State<PhoneScreenNumber> createState() => _PhoneScreenNumberState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
String _verificationId = "";

void sendOTP(String phoneNumber) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Android par agar auto-retrieve ho jaye to ye khud login kar dega
      await _auth.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException e) {
      print("Verification Failed: ${e.message}");
    },
    codeSent: (String verificationId, int? resendToken) {
      // Is ID ko save kar lein, code verify karte waqt kaam aaye gi
      _verificationId = verificationId;
      print("OTP sent to $phoneNumber");
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      _verificationId = verificationId;
    },
  );
}

class _PhoneScreenNumberState extends State<PhoneScreenNumber> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  // Pakistan Phone Validation Logic
  String? validatePhoneNumber(String? value) {
    // Regular Expression: 3 se shuru ho aur total 10 digits hon
    // Example: 3001234567
    String pattern = r'^(3\d{9})$';
    RegExp regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (!regExp.hasMatch(value)) {
      return 'Enter a valid number (e.g., 3001234567)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Join us via phone\nnumber",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "We'll text a code to verify your phone",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Phone Input Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Pakistan Flag and Code Icon
                    Row(
                      children: [
                        Image.network(
                          'https://flagcdn.com/w40/pk.png', // Pakistan flag
                          width: 30,
                        ),
                        const Icon(Icons.arrow_drop_down),
                        const SizedBox(width: 8),
                        const Text(
                          "+92",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),

                    // Input Area
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: validatePhoneNumber,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            10,
                          ), // Pakistan local length
                        ],
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: "3XX XXXXXXX",
                          border: InputBorder.none,
                          errorStyle: TextStyle(height: 0), // Cleaner look
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Agar validation sahi ho toh yahan agla step likhen
                      print("Valid Number: +92${_phoneController.text}");
                      sendOTP("+92${_phoneController.text}");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC6FF00), // Lime color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Next",

                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

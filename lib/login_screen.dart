import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo Section
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC6FF00), // inDrive Lime Green
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "id",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "inDrive",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Image Placeholder
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[200], // Iski jagah aap apni image lagayein
                child: const Center(child: Text("Illustration Placeholder")),
              ),

              const SizedBox(height: 40),

              // Text Section
              const Text(
                "Your app for fair deals",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Choose rides that are right for you",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),

              const SizedBox(height: 20),

              // Page Indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Buttons Section
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC6FF00),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Continue with phone",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 30,
                  ), // Google Icon placeholder
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Terms & Privacy Text
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text.rich(
                  TextSpan(
                    text: "Joining our app means you agree with our ",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                    children: [
                      TextSpan(
                        text: "Terms of Use",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

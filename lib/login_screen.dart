import 'package:flutter/material.dart';
import 'package:local_service/phone_screen_number.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. PageController banayein takay dots update ho sakein
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
              _buildLogo(),

              const Spacer(),

              // 2. PageView for Slidable Images
              SizedBox(
                height: 250,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    // Pehli Image ka Placeholder
                    Container(
                      color: Colors.grey[200],
                      child: const Center(child: Text("Image 1 Placeholder")),
                    ),
                    // Doosri Image ka Placeholder
                    Container(
                      color: Colors.grey[300],
                      child: const Center(child: Text("Image 2 Placeholder")),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

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

              // 3. Dynamic Slider Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) => _buildDot(index)),
              ),

              const Spacer(),

              // Buttons Section
              _buildButtons(),

              const SizedBox(height: 20),
              _buildFooterText(),
            ],
          ),
        ),
      ),
    );
  }

  // Dot banane ka function
  Widget _buildDot(int index) {
    return Container(
      height: 8,
      width: 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Agar page match karta hai to dark, warna light color
        color: _currentPage == index ? Colors.black : Colors.grey[300],
      ),
    );
  }

  // Baki UI Helper Methods (Sada code rakhne ke liye)
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFC6FF00),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "id",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "inDrive",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
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
                MaterialPageRoute(builder: (context) => PhoneScreenNumber()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC6FF00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Continue with phone",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF2F2F2),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Continue with Google",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterText() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(
        "Joining our app means you agree with our Terms of Use and Privacy Policy",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
    );
  }
}

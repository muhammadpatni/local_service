import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final Color primaryBlue = const Color(0xFF0E6BBB);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
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
          "Privacy Policy",
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
            // --- HEADER ---
            Text(
              "Your Privacy Matters",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Effective Date: April 2026",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 40),

            // --- POLICY SECTIONS ---
            _buildPolicySection(
              "1. Information We Collect",
              "We collect information you provide directly to us, such as when you create an account, request a service, or contact customer support. This includes your name, email, phone number, and location.",
            ),
            _buildPolicySection(
              "2. How We Use Information",
              "We use your data to facilitate service bookings, process payments, and improve our platform's user experience. Your location is used only to connect you with nearby service providers.",
            ),
            _buildPolicySection(
              "3. Data Sharing",
              "We do not sell your personal data. We only share necessary details with the specific service provider you have booked to ensure the service can be completed.",
            ),
            _buildPolicySection(
              "4. Security",
              "We implement industry-standard security measures to protect your information. However, no method of transmission over the internet is 100% secure.",
            ),
            _buildPolicySection(
              "5. Your Rights",
              "You have the right to access, update, or delete your personal information at any time through the account settings in the app.",
            ),

            const SizedBox(height: 30),

            // --- CONTACT INFO ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    "Questions about our Privacy Policy?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Contact us at privacy@noraya.com",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

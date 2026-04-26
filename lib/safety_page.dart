import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  final Color primaryBlue = const Color(0xFF0E6BBB);
  final Color lightGrey = const Color(0xFFF8F9FA); // Thora aur saaf grey

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Custom Back Button jo Home/Drawer par wapis le jaye
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: lightGrey, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Safety Center",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branding Section
            Text(
              "Your safety is our \npriority",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Learn about the tools we use to keep you safe during every service.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Emergency Card (Highlighted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gpp_maybe, color: Colors.red, size: 40),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Emergency Helpline",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "Immediate assistance in case of trouble.",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.call, color: Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Safety Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.85,
              children: [
                _buildSafetyCard(
                  "Verified Experts",
                  Icons.verified_user,
                  "All providers pass background checks.",
                ),
                _buildSafetyCard(
                  "24/7 Support",
                  Icons.headset_mic,
                  "Always here to help you.",
                ),
                _buildSafetyCard(
                  "Secure Cash",
                  Icons.lock_outline,
                  "Safe and transparent pricing.",
                ),
                _buildSafetyCard(
                  "In-App Chat",
                  Icons.chat_bubble_outline,
                  "Keep your number private.",
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Bottom Message
            Center(
              child: Text(
                "Noraya Local Services: Trusted & Secure",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: primaryBlue.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard(String title, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

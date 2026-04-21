import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final Color primaryBlue = const Color(0xFF0E6BBB);

  // --- LOGIC: Email aur Call Function ---
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAFF),

      // --- MINIMAL APPBAR (Jaisa Privacy Policy mein hai) ---
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
          "Help Center",
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
            // --- HEADER TEXT ---
            Text(
              "How can we help you?",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // --- CONTACT CARDS ---
            Row(
              children: [
                _buildModernContactCard(
                  context,
                  icon: Icons.mail_outline_rounded,
                  title: "Email Us",
                  color: Colors.orange,
                  onTap: () => _launchURL("mailto:support@noraya.com"),
                ),
                const SizedBox(width: 15),
                _buildModernContactCard(
                  context,
                  icon: Icons.phone_in_talk_outlined,
                  title: "Call Us",
                  color: Colors.green,
                  onTap: () => _launchURL("tel:+923000000000"),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // --- FAQ SECTION ---
            Text(
              "Common Questions",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            _buildModernFaq(
              context,
              "How do I book a service?",
              "Select a category from the home screen and choose your provider.",
            ),
            _buildModernFaq(
              context,
              "Can I cancel my booking?",
              "Yes, you can cancel up to 2 hours before the service starts.",
            ),
            _buildModernFaq(
              context,
              "How to pay for service?",
              "We accept cash on delivery and all major digital wallets.",
            ),
            _buildModernFaq(
              context,
              "Is my data safe?",
              "Yes, Noraya uses end-to-end encryption for all user data.",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- MODERN UI COMPONENTS ---

  Widget _buildModernContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFaq(BuildContext context, String question, String answer) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Icon(Icons.help_outline, color: primaryBlue, size: 20),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 55, right: 20, bottom: 15),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_service/home_page.dart';

class UserProfileSettingsScreen extends StatefulWidget {
  final String? emailnumber;
  const UserProfileSettingsScreen({super.key, required this.emailnumber});

  @override
  State<UserProfileSettingsScreen> createState() =>
      _UserProfileSettingsScreenState();
}

class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  final Color fieldColor = const Color(
    0xFFF1F4F8,
  ); // Light greyish blue for fields
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isPhoneReadOnly = false;
  bool isEmailReadOnly = false;

  @override
  void dispose() {
    phoneController.removeListener(_phoneListener);
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    String? value = widget.emailnumber;

    if (value != null && value.startsWith("+92")) {
      phoneController.text = value;
      isPhoneReadOnly = true;
    } else {
      // 👇 default prefix add
      phoneController.text = "+92";
      phoneController.addListener(_phoneListener);
    }

    if (value != null && !value.startsWith("+92")) {
      emailController.text = value;
      isEmailReadOnly = true;
    }
  }

  void _phoneListener() {
    String text = phoneController.text;

    // agar user +92 delete kare to wapas laga do
    if (!text.startsWith("+92")) {
      phoneController.value = TextEditingValue(
        text: "+92",
        selection: TextSelection.collapsed(offset: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile settings",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // 1. Profile Image Section
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(
                                      0xFF0E6BBB, // Aapki image wala lime green color
                                    ), // Aapki image wala lime green color
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 2. Input Fields
                        _buildInputField(label: "Name", hint: "Ahmed"),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Email",
                          hint: "example@mail.com",
                          controller: emailController,
                          readOnly: isEmailReadOnly,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "City",
                          hint: "Karachi",
                          readOnly: false,
                        ),
                        _buildInputField(
                          label: "Phone number",
                          hint: "92**********99",
                          controller: phoneController,
                          readOnly: isPhoneReadOnly,
                          isPhone: true,
                        ),

                        // Spacer content ko phailata hai takay button niche jaye
                        const Spacer(),

                        // 3. Next/Save Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyHomePage(),
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
                                "Next",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
          },
        ),
      ),
    );
  }

  // Reusable Input Field Widget
  Widget _buildInputField({
    required String label,
    required String hint,
    bool isDropdown = false,
    bool isPhone = false,
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly || isDropdown,

            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,

            inputFormatters: isPhone
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
                : [],

            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.black38),
              suffixIcon: isDropdown
                  ? const Icon(Icons.chevron_right, color: Colors.black54)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

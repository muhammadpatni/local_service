import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cnic_scanner_screen.dart'; // Import scanner
import 'provider_face_verification_screen.dart';

class ProviderDocumentScreen extends StatefulWidget {
  final File? profileImageFile;
  final String? networkProfileImageUrl;
  final String name, phone, email;
  final List<String> services;

  const ProviderDocumentScreen({
    super.key,
    required this.profileImageFile,
    this.networkProfileImageUrl,
    required this.name,
    required this.phone,
    required this.email,
    required this.services,
  });

  @override
  State<ProviderDocumentScreen> createState() => _ProviderDocumentScreenState();
}

class _ProviderDocumentScreenState extends State<ProviderDocumentScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  File? cnicFront;
  File? cnicBack;

  // AUTO SCANNER CALL
  Future<void> _scanDocument(String side) async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CnicScannerScreen(side: side)),
    );

    if (result != null) {
      setState(() {
        if (side == 'front')
          cnicFront = result;
        else
          cnicBack = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Identity Verification",
          style: GoogleFonts.poppins(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDocCard(
              "CNIC Front Side",
              cnicFront,
              () => _scanDocument('front'),
            ),
            const SizedBox(height: 20),
            _buildDocCard(
              "CNIC Back Side",
              cnicBack,
              () => _scanDocument('back'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: (cnicFront != null && cnicBack != null)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProviderFaceVerificationScreen(
                                  profileImageFile: widget.profileImageFile,
                                  name: widget.name,
                                  phone: widget.phone,
                                  email: widget.email,
                                  services: widget.services,
                                  cnicFront: cnicFront!,
                                  cnicBack: cnicBack!,
                                ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  "Next: Face Verification",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(String title, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: file != null ? Colors.green : Colors.grey[300]!,
            width: 2,
          ),
          image: file != null
              ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
              : null,
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40, color: primaryBlue),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              )
            : const Icon(Icons.check_circle, color: Colors.green, size: 40),
      ),
    );
  }
}

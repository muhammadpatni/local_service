import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:local_service/cnic_scanner_screen.dart';
import 'package:local_service/provider_face_verification_screen.dart';

class ProviderDocumentsScreen extends StatefulWidget {
  const ProviderDocumentsScreen({super.key});

  @override
  State<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _ProviderDocumentsScreenState extends State<ProviderDocumentsScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);

  File? _nicFrontFile;
  File? _nicBackFile;
  File? _certificateFile;

  String? _nicFrontCnicNumber;
  bool _isLoading = false;

  // ImgBB API Key — same as user profile
  static const String _imgbbApiKey = 'c4df1e7a32e0eb9b38207de2b70fb210';

  // ─── ImgBB Upload Helper ───
  Future<String> _uploadToImgBB(File imageFile, String filename) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: filename),
    );
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final jsonResp = json.decode(respStr);

    if (jsonResp['status'] == 200) {
      return jsonResp['data']['url'] as String;
    }
    throw Exception(
      'ImgBB upload failed: ${jsonResp['error'] ?? 'Unknown error'}',
    );
  }

  // ─── NIC Front: Scanner se ───
  Future<void> _scanNicFront() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CnicScannerScreen()),
    );
    if (result != null) {
      setState(() {
        _nicFrontFile = result['file'] as File;
        _nicFrontCnicNumber = result['cnicNumber'] as String?;
      });
    }
  }

  // ─── NIC Back: Scanner se ───
  Future<void> _scanNicBack() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CnicScannerScreen()),
    );
    if (result != null) {
      setState(() => _nicBackFile = result['file'] as File);
    }
  }

  // ─── Certificate: Gallery se ───
  Future<void> _pickCertificate() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _certificateFile = File(picked.path));
    }
  }

  Future<void> _onContinue() async {
    if (_nicFrontFile == null) {
      _showSnack("CNIC ka agla hissa (Front) zaroor upload karein");
      return;
    }
    if (_nicBackFile == null) {
      _showSnack("CNIC ka pichla hissa (Back) zaroor upload karein");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // ─── ImgBB pe NIC Front upload ───
      final nicFrontUrl = await _uploadToImgBB(
        _nicFrontFile!,
        'nic_front_${user.uid}.jpg',
      );

      // ─── ImgBB pe NIC Back upload ───
      final nicBackUrl = await _uploadToImgBB(
        _nicBackFile!,
        'nic_back_${user.uid}.jpg',
      );

      // ─── Certificate (optional) upload ───
      String? certificateUrl;
      if (_certificateFile != null) {
        certificateUrl = await _uploadToImgBB(
          _certificateFile!,
          'certificate_${user.uid}.jpg',
        );
      }

      // ─── Firestore update ───
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .update({
            'nicFrontUrl': nicFrontUrl,
            'nicBackUrl': nicBackUrl,
            if (certificateUrl != null) 'certificateUrl': certificateUrl,
            if (_nicFrontCnicNumber != null) 'cnicNumber': _nicFrontCnicNumber,
            'setupStep': 'documents',
          });

      if (!mounted) return;

      // Face verification pe jao, NIC front file saath le jao
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProviderFaceVerificationScreen(nicFrontFile: _nicFrontFile!),
        ),
      );
    } catch (e) {
      _showSnack("Upload fail ho gaya: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.poppins())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Documents Upload",
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                _buildProgressBar(step: 2),
                const SizedBox(height: 6),
                Text(
                  "Step 2 of 3 — Documents",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Identity Verify Karein",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Apna CNIC upload karein. Auto-scan se CNIC number detect ho jata hai.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),

                const SizedBox(height: 28),

                // NIC Front
                _buildDocCard(
                  title: "CNIC — Agla Hissa (Front) *",
                  subtitle: _nicFrontCnicNumber != null
                      ? "Detected: $_nicFrontCnicNumber"
                      : "Zaroor — Auto-scan se detect hoga",
                  icon: Icons.credit_card,
                  file: _nicFrontFile,
                  onTap: _scanNicFront,
                  detectedText: _nicFrontCnicNumber,
                ),

                const SizedBox(height: 14),

                // NIC Back
                _buildDocCard(
                  title: "CNIC — Pichla Hissa (Back) *",
                  subtitle: "Zaroor",
                  icon: Icons.credit_card_outlined,
                  file: _nicBackFile,
                  onTap: _scanNicBack,
                ),

                const SizedBox(height: 14),

                // Certificate
                _buildDocCard(
                  title: "Certificate / Qualification",
                  subtitle: "Optional — Koi bhi relevant certificate",
                  icon: Icons.workspace_premium_outlined,
                  file: _certificateFile,
                  onTap: _pickCertificate,
                  isOptional: true,
                  isGallery: true,
                ),

                const SizedBox(height: 24),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_outlined,
                        color: primaryBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Aapke documents encrypted aur secure hain. Sirf verification ke liye istamal hote hain.",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Face Verification Pe Jao →",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryBlue),
                    const SizedBox(height: 16),
                    Text(
                      "Documents upload ho rahe hain...",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({required int step}) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            height: 5,
            decoration: BoxDecoration(
              color: i < step ? primaryBlue : Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDocCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
    bool isOptional = false,
    bool isGallery = false,
    String? detectedText,
  }) {
    final hasFile = file != null;
    final isDetected = detectedText != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasFile
              ? (isDetected ? const Color(0xFFE8F5E9) : const Color(0xFFF0F9F0))
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasFile
                ? (isDetected ? Colors.green : Colors.green[300]!)
                : Colors.grey[200]!,
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 54,
              decoration: BoxDecoration(
                color: hasFile
                    ? Colors.white
                    : primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: hasFile
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(file!, fit: BoxFit.cover),
                    )
                  : Icon(icon, color: primaryBlue, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (isOptional)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Optional",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasFile
                        ? (isDetected ? subtitle : "Upload successful ✓")
                        : subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: isDetected
                          ? Colors.green[700]
                          : hasFile
                          ? Colors.green[600]
                          : Colors.grey[500],
                      fontWeight: isDetected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              hasFile
                  ? Icons.check_circle
                  : (isGallery
                        ? Icons.photo_library_outlined
                        : Icons.document_scanner_outlined),
              color: hasFile ? Colors.green : primaryBlue,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

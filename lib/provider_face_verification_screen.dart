import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'face_liveness_screen.dart'; // Import video screen
import 'home_page.dart'; // Change this to your Provider Home

class ProviderFaceVerificationScreen extends StatefulWidget {
  final File? profileImageFile;
  final String name, phone, email;
  final List<String> services;
  final File cnicFront, cnicBack;

  const ProviderFaceVerificationScreen({
    super.key,
    required this.profileImageFile,
    required this.name,
    required this.phone,
    required this.email,
    required this.services,
    required this.cnicFront,
    required this.cnicBack,
  });

  @override
  State<ProviderFaceVerificationScreen> createState() =>
      _ProviderFaceVerificationScreenState();
}

class _ProviderFaceVerificationScreenState
    extends State<ProviderFaceVerificationScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  File? livenessVideo;
  bool _isLoading = false;

  Future<void> _startLiveness() async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FaceLivenessScreen()),
    );
    if (result != null) setState(() => livenessVideo = result);
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // DATA SAVING IN 'providers' COLLECTION
      await FirebaseFirestore.instance.collection('providers').doc(uid).set({
        'uid': uid,
        'name': widget.name,
        'phone': widget.phone,
        'email': widget.email,
        'services': widget.services,
        'status': 'pending', // Verification pending
        'createdAt': FieldValue.serverTimestamp(),
        'isProvider': true,
      });

      // Also update role in 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': 'provider',
      });

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Face Verification",
          style: GoogleFonts.poppins(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                      border: Border.all(
                        color: livenessVideo != null
                            ? Colors.green
                            : primaryBlue,
                        width: 3,
                      ),
                    ),
                    child: livenessVideo != null
                        ? const Icon(
                            Icons.videocam,
                            size: 80,
                            color: Colors.green,
                          )
                        : Icon(Icons.face, size: 80, color: primaryBlue),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  livenessVideo != null
                      ? "Video Captured Successfully!"
                      : "Record a short video to verify it's really you",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: _startLiveness,
                    icon: const Icon(Icons.videocam),
                    label: Text(
                      livenessVideo != null
                          ? "Record Again"
                          : "Start Video Verification",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
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
                    onPressed: livenessVideo != null
                        ? _completeRegistration
                        : null,
                    child: Text(
                      "Finish & Submit",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

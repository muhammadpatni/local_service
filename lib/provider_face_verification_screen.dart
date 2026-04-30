// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'face_liveness_screen.dart'; // Import video screen
// import 'home_page.dart'; // Change this to your Provider Home

// class ProviderFaceVerificationScreen extends StatefulWidget {
//   final File? profileImageFile;
//   final String name, phone, email;
//   final List<String> services;
//   final File cnicFront, cnicBack;

//   const ProviderFaceVerificationScreen({
//     super.key,
//     required this.profileImageFile,
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.services,
//     required this.cnicFront,
//     required this.cnicBack,
//   });

//   @override
//   State<ProviderFaceVerificationScreen> createState() =>
//       _ProviderFaceVerificationScreenState();
// }

// class _ProviderFaceVerificationScreenState
//     extends State<ProviderFaceVerificationScreen> {
//   final Color primaryBlue = const Color(0xFF0E6BBB);
//   File? livenessVideo;
//   bool _isLoading = false;

//   Future<void> _startLiveness() async {
//     final File? result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const FaceLivenessScreen()),
//     );
//     if (result != null) setState(() => livenessVideo = result);
//   }

//   Future<void> _completeRegistration() async {
//     setState(() => _isLoading = true);
//     try {
//       String uid = FirebaseAuth.instance.currentUser!.uid;

//       // DATA SAVING IN 'providers' COLLECTION
//       await FirebaseFirestore.instance.collection('providers').doc(uid).set({
//         'uid': uid,
//         'name': widget.name,
//         'phone': widget.phone,
//         'email': widget.email,
//         'services': widget.services,
//         'status': 'pending', // Verification pending
//         'createdAt': FieldValue.serverTimestamp(),
//         'isProvider': true,
//       });

//       // Also update role in 'users' collection
//       await FirebaseFirestore.instance.collection('users').doc(uid).update({
//         'role': 'provider',
//       });

//       if (mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const MyHomePage()),
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           "Face Verification",
//           style: GoogleFonts.poppins(color: Colors.black),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(25),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 Center(
//                   child: Container(
//                     height: 200,
//                     width: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.grey[100],
//                       border: Border.all(
//                         color: livenessVideo != null
//                             ? Colors.green
//                             : primaryBlue,
//                         width: 3,
//                       ),
//                     ),
//                     child: livenessVideo != null
//                         ? const Icon(
//                             Icons.videocam,
//                             size: 80,
//                             color: Colors.green,
//                           )
//                         : Icon(Icons.face, size: 80, color: primaryBlue),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   livenessVideo != null
//                       ? "Video Captured Successfully!"
//                       : "Record a short video to verify it's really you",
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(fontSize: 16),
//                 ),
//                 const SizedBox(height: 40),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: OutlinedButton.icon(
//                     onPressed: _startLiveness,
//                     icon: const Icon(Icons.videocam),
//                     label: Text(
//                       livenessVideo != null
//                           ? "Record Again"
//                           : "Start Video Verification",
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryBlue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     onPressed: livenessVideo != null
//                         ? _completeRegistration
//                         : null,
//                     child: Text(
//                       "Finish & Submit",
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'face_liveness_screen.dart';
import 'provider_home_screen.dart'; // Naya Home Page import

class ProviderFaceVerificationScreen extends StatefulWidget {
  final File? profileImageFile;
  final String name, phone, email, experience;
  final List<String> services;
  final File cnicFront, cnicBack;

  const ProviderFaceVerificationScreen({
    super.key,
    required this.profileImageFile,
    required this.name,
    required this.phone,
    required this.email,
    required this.experience,
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
  File? livenessFaceImage; // Picture captured at the end of liveness
  bool _isVerifyingAPI = false;

  Future<void> _startLiveness() async {
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FaceLivenessScreen()),
    );
    if (result != null) {
      setState(() {
        livenessVideo = result['video'];
        livenessFaceImage = result['image'];
      });
    }
  }

  // API METHOD - Ye actual Grok/Vision API se face match karega
  Future<bool> _verifyFacesWithGrokAPI() async {
    if (livenessFaceImage == null) return false;

    final String apiKey = "api-key";
    final String url = "https://api.groq.com/openai/v1/chat/completions";

    try {
      // Images ko base64 mein convert karna hoga kyunki Groq Vision API base64 leti hai
      List<int> cnicBytes = await widget.cnicFront.readAsBytes();
      List<int> faceBytes = await livenessFaceImage!.readAsBytes();
      String base64Cnic = base64Encode(cnicBytes);
      String base64Face = base64Encode(faceBytes);

      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model":
              "llama-3.2-11b-vision-preview", // Vision model use karna hoga
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text":
                      "Are the faces in these two images of the same person? Respond with only 'true' or 'false'.",
                },
                {
                  "type": "image_url",
                  "image_url": {"url": "data:image/jpeg;base64,$base64Cnic"},
                },
                {
                  "type": "image_url",
                  "image_url": {"url": "data:image/jpeg;base64,$base64Face"},
                },
              ],
            },
          ],
          "temperature": 0.1,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String result = data['choices'][0]['message']['content']
            .toString()
            .toLowerCase();
        return result.contains("true");
      } else {
        debugPrint("Groq Error: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("API Exception: $e");
      return false;
    }
  }

  Future<void> _processVerification() async {
    setState(() => _isVerifyingAPI = true);

    // 1. API Face Verification
    bool isFaceMatched = await _verifyFacesWithGrokAPI();

    if (!isFaceMatched) {
      setState(() => _isVerifyingAPI = false);
      if (mounted) {
        // Verification Fail - Account login rok dena aur wapas CNIC screen pe bhejna
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Verification Failed"),
            content: const Text(
              "Aapka face CNIC se match nahi hua. Barae meharbani details dobara daalain.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to Document Upload screen
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 2. Agar API ne verify kar diya tou data save karo
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('providers').doc(uid).set({
        'uid': uid,
        'name': widget.name,
        'phone': widget.phone,
        'email': widget.email,
        'experience': widget.experience,
        'services': widget.services,
        'status': 'active', // Since auto-verified
        'createdAt': FieldValue.serverTimestamp(),
        'isProvider': true,
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': 'provider',
      });

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isVerifyingAPI = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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
                      ? "Video & Face Captured Successfully!"
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
                        ? _processVerification
                        : null,
                    child: Text(
                      "Verify Details & Submit",
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

          // API Loading UI (White Background with Circular Progress)
          if (_isVerifyingAPI)
            Positioned.fill(
              child: Container(
                color: Colors.white, // Pure white bar as requested
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF0E6BBB)),
                    const SizedBox(height: 20),
                    Text(
                      "Verifying...",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Matching face with CNIC via AI",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
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
}

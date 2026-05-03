// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'cnic_scanner_screen.dart'; // Import scanner
// import 'provider_face_verification_screen.dart';

// class ProviderDocumentScreen extends StatefulWidget {
//   final File? profileImageFile;
//   final String? networkProfileImageUrl;
//   final String name, phone, email;
//   final List<String> services;

//   const ProviderDocumentScreen({
//     super.key,
//     required this.profileImageFile,
//     this.networkProfileImageUrl,
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.services,
//   });

//   @override
//   State<ProviderDocumentScreen> createState() => _ProviderDocumentScreenState();
// }

// class _ProviderDocumentScreenState extends State<ProviderDocumentScreen> {
//   final Color primaryBlue = const Color(0xFF0E6BBB);
//   File? cnicFront;
//   File? cnicBack;

//   // AUTO SCANNER CALL
//   Future<void> _scanDocument(String side) async {
//     final File? result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CnicScannerScreen(side: side)),
//     );

//     if (result != null) {
//       setState(() {
//         if (side == 'front')
//           cnicFront = result;
//         else
//           cnicBack = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           "Identity Verification",
//           style: GoogleFonts.poppins(color: Colors.black),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _buildDocCard(
//               "CNIC Front Side",
//               cnicFront,
//               () => _scanDocument('front'),
//             ),
//             const SizedBox(height: 20),
//             _buildDocCard(
//               "CNIC Back Side",
//               cnicBack,
//               () => _scanDocument('back'),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryBlue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 onPressed: (cnicFront != null && cnicBack != null)
//                     ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 ProviderFaceVerificationScreen(
//                                   profileImageFile: widget.profileImageFile,
//                                   name: widget.name,
//                                   phone: widget.phone,
//                                   email: widget.email,
//                                   services: widget.services,
//                                   cnicFront: cnicFront!,
//                                   cnicBack: cnicBack!,
//                                 ),
//                           ),
//                         );
//                       }
//                     : null,
//                 child: Text(
//                   "Next: Face Verification",
//                   style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDocCard(String title, File? file, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 180,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: file != null ? Colors.green : Colors.grey[300]!,
//             width: 2,
//           ),
//           image: file != null
//               ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
//               : null,
//         ),
//         child: file == null
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.camera_alt, size: 40, color: primaryBlue),
//                   const SizedBox(height: 10),
//                   Text(
//                     title,
//                     style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               )
//             : const Icon(Icons.check_circle, color: Colors.green, size: 40),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'cnic_scanner_screen.dart';
// import 'provider_face_verification_screen.dart';

// class ProviderDocumentScreen extends StatefulWidget {
//   final File? profileImageFile;
//   final String? networkProfileImageUrl;
//   final String name, phone, email, experience;
//   final List<String> services;

//   const ProviderDocumentScreen({
//     super.key,
//     required this.profileImageFile,
//     this.networkProfileImageUrl,
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.experience,
//     required this.services,
//   });

//   @override
//   State<ProviderDocumentScreen> createState() => _ProviderDocumentScreenState();
// }

// class _ProviderDocumentScreenState extends State<ProviderDocumentScreen> {
//   final Color primaryBlue = const Color(0xFF0E6BBB);
//   File? cnicFront;
//   File? cnicBack;

//   Future<void> _scanDocument(String side) async {
//     final File? result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CnicScannerScreen(side: side)),
//     );

//     if (result != null) {
//       setState(() {
//         if (side == 'front') {
//           cnicFront = result;
//         } else {
//           cnicBack = result;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           "Identity Verification",
//           style: GoogleFonts.poppins(color: Colors.black),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _buildDocCard(
//               "CNIC Front Side",
//               cnicFront,
//               () => _scanDocument('front'),
//             ),
//             const SizedBox(height: 20),
//             _buildDocCard(
//               "CNIC Back Side",
//               cnicBack,
//               () => _scanDocument('back'),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryBlue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 onPressed: (cnicFront != null && cnicBack != null)
//                     ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 ProviderFaceVerificationScreen(
//                                   profileImageFile: widget.profileImageFile,
//                                   name: widget.name,
//                                   phone: widget.phone,
//                                   email: widget.email,
//                                   experience: widget.experience,
//                                   services: widget.services,
//                                   cnicFront: cnicFront!,
//                                   cnicBack: cnicBack!,
//                                 ),
//                           ),
//                         );
//                       }
//                     : null,
//                 child: Text(
//                   "Next: Face Verification",
//                   style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDocCard(String title, File? file, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 180,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: file != null ? Colors.green : Colors.grey[300]!,
//             width: 2,
//           ),
//           image: file != null
//               ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
//               : null,
//         ),
//         child: file == null
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.camera_alt, size: 40, color: primaryBlue),
//                   const SizedBox(height: 10),
//                   Text(
//                     title,
//                     style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               )
//             : const Icon(Icons.check_circle, color: Colors.green, size: 40),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'cnic_scanner_screen.dart';
import 'provider_face_verification_screen.dart';

class ProviderDocumentScreen extends StatefulWidget {
  final File? profileImageFile;
  final String? networkProfileImageUrl;
  final String name, phone, email, experience;
  final List<String> services;

  const ProviderDocumentScreen({
    super.key,
    required this.profileImageFile,
    this.networkProfileImageUrl,
    required this.name,
    required this.phone,
    required this.email,
    required this.experience,
    required this.services,
  });

  @override
  State<ProviderDocumentScreen> createState() => _ProviderDocumentScreenState();
}

class _ProviderDocumentScreenState extends State<ProviderDocumentScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  File? cnicFront;
  File? cnicBack;
  bool _isValidating = false;

  Future<void> _scanDocument(String side) async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CnicScannerScreen(side: side)),
    );

    if (result != null) {
      setState(() {
        if (side == 'front') {
          cnicFront = result;
        } else {
          cnicBack = result;
        }
      });
    }
  }

  // Grok API se CNIC validate karo - expiry aur authenticity check
  Future<Map<String, dynamic>> _validateCnicWithGrok(
    File frontImage,
    File backImage,
  ) async {
    const String apiKey = "YOUR_GROQ_API_KEY"; // Apni Groq API key yahan
    const String url = "https://api.groq.com/openai/v1/chat/completions";

    try {
      List<int> frontBytes = await frontImage.readAsBytes();
      List<int> backBytes = await backImage.readAsBytes();
      String base64Front = base64Encode(frontBytes);
      String base64Back = base64Encode(backBytes);

      var response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $apiKey",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "model": "llama-3.2-11b-vision-preview",
              "messages": [
                {
                  "role": "user",
                  "content": [
                    {
                      "type": "text",
                      "text":
                          """Analyze these two CNIC (Pakistani National Identity Card) images carefully.
Check the following:
1. Is this a valid Pakistani CNIC card? (Check for NADRA, Pakistan text, proper format)
2. Is the CNIC expired? (Look for expiry date field - if expiry date has passed compared to current year 2025, mark as expired)
3. Does the front and back belong to the same card? (Check if CNIC numbers match)

Respond ONLY in this exact JSON format, nothing else:
{
  "isValidCnic": true/false,
  "isExpired": true/false,
  "isSameCard": true/false,
  "reason": "brief reason if any check failed, otherwise empty string"
}""",
                    },
                    {
                      "type": "image_url",
                      "image_url": {
                        "url": "data:image/jpeg;base64,$base64Front",
                      },
                    },
                    {
                      "type": "image_url",
                      "image_url": {
                        "url": "data:image/jpeg;base64,$base64Back",
                      },
                    },
                  ],
                },
              ],
              "temperature": 0.1,
              "max_tokens": 200,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content']
            .toString()
            .trim();

        // JSON clean karo (backticks ya extra text ho sakta hai)
        content = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        // JSON parse karo
        Map<String, dynamic> result = jsonDecode(content);
        return result;
      } else {
        debugPrint("Grok API Error: ${response.statusCode} - ${response.body}");
        // API fail hone par default pass karo (taake user block na ho)
        return {
          "isValidCnic": true,
          "isExpired": false,
          "isSameCard": true,
          "reason": "",
        };
      }
    } catch (e) {
      debugPrint("CNIC Validation Exception: $e");
      // Exception par bhi default pass karo
      return {
        "isValidCnic": true,
        "isExpired": false,
        "isSameCard": true,
        "reason": "",
      };
    }
  }

  Future<void> _validateAndProceed() async {
    if (cnicFront == null || cnicBack == null) return;

    setState(() => _isValidating = true);

    Map<String, dynamic> validationResult = await _validateCnicWithGrok(
      cnicFront!,
      cnicBack!,
    );

    setState(() => _isValidating = false);

    bool isValidCnic = validationResult['isValidCnic'] ?? true;
    bool isExpired = validationResult['isExpired'] ?? false;
    bool isSameCard = validationResult['isSameCard'] ?? true;
    String reason = validationResult['reason'] ?? '';

    // Check karo koi violation hai?
    if (!isValidCnic || isExpired || !isSameCard) {
      String errorMessage = "";

      if (!isValidCnic) {
        errorMessage =
            "Yeh valid Pakistani CNIC nahi lagti. Barae meharbani apni asli CNIC scan karein.";
      } else if (isExpired) {
        errorMessage =
            "Aapki CNIC expired hai. Barae meharbani valid (non-expired) CNIC use karein.";
      } else if (!isSameCard) {
        errorMessage =
            "CNIC front aur back same card ke nahi lagte. Barae meharbani ek hi CNIC ke dono sides scan karein.";
      }

      if (reason.isNotEmpty && errorMessage.isEmpty) {
        errorMessage = reason;
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  "CNIC Verification Failed",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            content: Text(
              errorMessage,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // CNIC reset karo dobara scan ke liye
                  setState(() {
                    if (!isValidCnic || isExpired) {
                      cnicFront = null;
                      cnicBack = null;
                    } else if (!isSameCard) {
                      cnicBack = null;
                    }
                  });
                },
                child: Text(
                  "Dobara Scan Karein",
                  style: GoogleFonts.poppins(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Sab theek hai - agle screen par jao
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderFaceVerificationScreen(
            profileImageFile: widget.profileImageFile,
            name: widget.name,
            phone: widget.phone,
            email: widget.email,
            experience: widget.experience,
            services: widget.services,
            cnicFront: cnicFront!,
            cnicBack: cnicBack!,
          ),
        ),
      );
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
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
                        ? _validateAndProceed
                        : null,
                    child: Text(
                      "Verify & Next",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Validation loading overlay
          if (_isValidating)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF0E6BBB)),
                    const SizedBox(height: 20),
                    Text(
                      "Verifying CNIC...",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Checking expiry & authenticity via AI",
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
                  const SizedBox(height: 5),
                  Text(
                    "Tap to scan",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Retake",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

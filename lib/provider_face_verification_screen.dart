import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:local_service/provider_home_screen.dart';

/// Provider Face Verification Screen
/// Selfie leke NIC front se compare karta hai Gemini Vision API ke zariye.
/// Kamyab verification par Firestore update hota hai aur ProviderHomeScreen pe navigate karta hai.
class ProviderFaceVerificationScreen extends StatefulWidget {
  final File nicFrontFile;

  const ProviderFaceVerificationScreen({super.key, required this.nicFrontFile});

  @override
  State<ProviderFaceVerificationScreen> createState() =>
      _ProviderFaceVerificationScreenState();
}

class _ProviderFaceVerificationScreenState
    extends State<ProviderFaceVerificationScreen>
    with WidgetsBindingObserver {
  final Color primaryBlue = const Color(0xFF0E6BBB);

  // ⚠️ Yahan apni actual Gemini API Key lagao
  // Google AI Studio: https://aistudio.google.com/app/apikey
  static const String _geminiApiKey = '';

  CameraController? _cameraCtrl;
  bool _isCameraReady = false;
  File? _selfieFile;
  bool _isProcessing = false;

  _VerificationState _state = _VerificationState.capture;
  String _statusMsg = "Seedha camera ki taraf dekhein aur selfie lein";
  String? _failReason;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraCtrl?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Front camera dhundho (selfie ke liye)
      CameraDescription cam = cameras.first;
      for (final c in cameras) {
        if (c.lensDirection == CameraLensDirection.front) {
          cam = c;
          break;
        }
      }

      _cameraCtrl = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraCtrl!.initialize();
      if (mounted) setState(() => _isCameraReady = true);
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _takeSelfie() async {
    if (_cameraCtrl == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final XFile photo = await _cameraCtrl!.takePicture();
      setState(() {
        _selfieFile = File(photo.path);
        _state = _VerificationState.review;
        _statusMsg = "Apni selfie check karein";
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _statusMsg = "Selfie nahi li ja saki. Dobara try karein.";
        _isProcessing = false;
      });
    }
  }

  Future<void> _verifyWithGemini() async {
    if (_selfieFile == null) return;

    setState(() {
      _isProcessing = true;
      _state = _VerificationState.verifying;
      _statusMsg = "AI se verify ho raha hai...";
    });

    try {
      // Dono images bytes mein parhein
      final selfieBytes = await _selfieFile!.readAsBytes();
      final nicBytes = await widget.nicFrontFile.readAsBytes();

      final selfieB64 = base64Encode(selfieBytes);
      final nicB64 = base64Encode(nicBytes);

      // Gemini 1.5 Flash API call
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey',
      );

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'text':
                          'You are a face verification system for identity validation. '
                          'Compare the two images carefully:\n'
                          '- Image 1: A live selfie taken by the applicant\n'
                          '- Image 2: A CNIC (ID card) which contains a photo of the person\n\n'
                          'Analyze facial features: eyes, nose, face shape, skin tone, jawline, and overall structure. '
                          'Determine if both images show the same person.\n\n'
                          'Rules:\n'
                          '- Reply ONLY with "yes" if the same person appears in both images\n'
                          '- Reply ONLY with "no" if they are different people, image is unclear, or ID card face is not visible\n'
                          '- Do not include any other text, explanation, or punctuation',
                    },
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': selfieB64,
                      },
                    },
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': nicB64,
                      },
                    },
                  ],
                },
              ],
              'generationConfig': {
                'maxOutputTokens': 5,
                'temperature': 0.1,
                'topP': 0.1,
              },
              'safetySettings': [
                {
                  'category': 'HARM_CATEGORY_HARASSMENT',
                  'threshold': 'BLOCK_NONE',
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer =
            (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '')
                .toString()
                .toLowerCase()
                .trim();

        debugPrint("Gemini answer: $answer");

        if (answer.contains('yes')) {
          await _onSuccess();
        } else {
          setState(() {
            _failReason =
                "Aapka chehra CNIC se match nahi karta. Dobara selfy lein ya CNIC check karein.";
            _state = _VerificationState.failed;
            _isProcessing = false;
          });
        }
      } else {
        final errorBody = jsonDecode(response.body);
        final errMsg = errorBody['error']?['message'] ?? response.body;
        throw Exception("API Error ${response.statusCode}: $errMsg");
      }
    } on http.ClientException catch (e) {
      _handleError("Network error: ${e.message}");
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _handleError(String msg) {
    debugPrint("Verification error: $msg");
    setState(() {
      _failReason =
          "Verification mein masla aya. Check karein aur dobara try karein.\n\n$msg";
      _state = _VerificationState.failed;
      _isProcessing = false;
    });
  }

  Future<void> _onSuccess() async {
    setState(() => _state = _VerificationState.success);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Providers collection update
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .update({
            'isVerified': true,
            'verifiedAt': FieldValue.serverTimestamp(),
            'setupStep': 'complete',
          });

      // Users collection mein lastMode = provider
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'lastMode': 'provider'},
      );
    } catch (e) {
      debugPrint("Firestore update error: $e");
    }

    // 2 second baad navigate karo
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
      (route) => false,
    );
  }

  void _retryFromCapture() {
    setState(() {
      _selfieFile = null;
      _failReason = null;
      _state = _VerificationState.capture;
      _statusMsg = "Seedha camera ki taraf dekhein aur selfie lein";
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _state == _VerificationState.success
          ? Colors.white
          : Colors.black,
      appBar:
          _state == _VerificationState.success ||
              _state == _VerificationState.verifying
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: _state == _VerificationState.capture
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Text(
                "Face Verification",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildCurrentState(),
      ),
    );
  }

  Widget _buildCurrentState() {
    switch (_state) {
      case _VerificationState.capture:
        return _buildCaptureView();
      case _VerificationState.review:
        return _buildReviewView();
      case _VerificationState.verifying:
        return _buildVerifyingView();
      case _VerificationState.success:
        return _buildSuccessView();
      case _VerificationState.failed:
        return _buildFailedView();
    }
  }

  // ─── Capture View ───
  Widget _buildCaptureView() {
    return Stack(
      children: [
        if (_isCameraReady)
          Positioned.fill(child: CameraPreview(_cameraCtrl!))
        else
          Center(child: CircularProgressIndicator(color: primaryBlue)),

        // Face frame overlay
        Positioned.fill(child: CustomPaint(painter: _FaceOvalPainter())),

        // Progress (Step 3/3)
        Positioned(
          top: 12,
          left: 24,
          right: 24,
          child: Column(
            children: [
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                "Step 3 of 3 — Face Verification",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),

        // Status message
        Positioned(
          bottom: 175,
          left: 24,
          right: 24,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusMsg,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // Tips
        Positioned(
          bottom: 140,
          left: 24,
          right: 24,
          child: Column(
            children: [
              _tipRow(Icons.wb_sunny_outlined, "Achhi roshni mein raho"),
              const SizedBox(height: 3),
              _tipRow(Icons.face_outlined, "Chehra frame ke andar rakhein"),
            ],
          ),
        ),

        // Capture button
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isProcessing ? null : _takeSelfie,
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.5),
                  color: _isProcessing ? Colors.grey : Colors.white,
                ),
                child: _isProcessing
                    ? Padding(
                        padding: const EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                          color: primaryBlue,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(Icons.camera_alt, color: primaryBlue, size: 34),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Review View ───
  Widget _buildReviewView() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              if (_selfieFile != null)
                Positioned.fill(
                  child: Image.file(_selfieFile!, fit: BoxFit.cover),
                ),
              Positioned.fill(child: CustomPaint(painter: _FaceOvalPainter())),
            ],
          ),
        ),
        Container(
          color: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            children: [
              Text(
                "Selfie check karein",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Chehra saaf nazar aana chahiye aur CNIC wala hi hona chahiye",
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _retryFromCapture,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Dobara Lein",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _verifyWithGemini,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Verify Karein ✓",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Verifying View ───
  Widget _buildVerifyingView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI loading animation
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryBlue.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: primaryBlue.withValues(alpha: 0.1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: primaryBlue,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "AI Verify Kar Raha Hai...",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Selfie aur CNIC compare ho raha hai",
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              "Thoda wait karein...",
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Success View ───
  Widget _buildSuccessView() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (_, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.green[500],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "Verification Kamyab!",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Aapki pehchaan verify ho gayi.\nProvider network mein khush amdeed!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Failed View ───
  Widget _buildFailedView() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.red[700],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 24),
          Text(
            "Verification Fail",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _failReason ?? "Koi masla aaya.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white60,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _retryFromCapture,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "Dobara Try Karein",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

enum _VerificationState { capture, review, verifying, success, failed }

// ─────────────────────────────────────────────────────────
//  Face Oval Frame Painter
// ─────────────────────────────────────────────────────────
class _FaceOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ovalW = size.width * 0.65;
    final ovalH = ovalW * 1.35;
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: ovalW,
      height: ovalH,
    );

    // Dark overlay with oval hole
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.58)
        ..style = PaintingStyle.fill,
    );

    // Blue oval border
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = const Color(0xFF0E6BBB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

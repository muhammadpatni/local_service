import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// CNIC Scanner Screen
/// Camera preview ke saath rectangular frame overlay deta hai.
/// Jab user Scan tap kare, MLKit se CNIC number detect karta hai.
/// Return type: Map {'file': File, 'cnicNumber': String?}
class CnicScannerScreen extends StatefulWidget {
  const CnicScannerScreen({super.key});

  @override
  State<CnicScannerScreen> createState() => _CnicScannerScreenState();
}

class _CnicScannerScreenState extends State<CnicScannerScreen>
    with WidgetsBindingObserver {
  final Color primaryBlue = const Color(0xFF0E6BBB);

  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _statusMessage = "CNIC ko frame ke andar rakhein";

  // CNIC Pakistan format: 12345-1234567-1
  final RegExp _cnicRegex = RegExp(r'\d{5}[\s\-]?\d{7}[\s\-]?\d');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _statusMessage = "Camera available nahi hai");
        return;
      }

      // Back camera prefer karo (CNIC ke liye better)
      CameraDescription camera = cameras.first;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.back) {
          camera = cam;
          break;
        }
      }

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      // Auto-focus enable karo
      await _controller!.setFocusMode(FocusMode.auto);

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _statusMessage = "Camera error: $e");
    }
  }

  Future<void> _captureAndScan() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing)
      return;

    setState(() {
      _isProcessing = true;
      _statusMessage = "Scan ho raha hai...";
    });

    try {
      final XFile photo = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(photo.path);

      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await recognizer.processImage(
        inputImage,
      );
      await recognizer.close();

      // Full text join karo aur CNIC pattern dhundho
      final fullText = recognizedText.blocks
          .map((b) => b.text)
          .join(' ')
          .replaceAll('\n', ' ');

      String? foundCnic;

      // Pehle exact format try karo
      final match = _cnicRegex.firstMatch(fullText.replaceAll(' ', ''));
      if (match != null) {
        // Format normalize karo: XXXXX-XXXXXXX-X
        final raw = match.group(0)!.replaceAll(RegExp(r'[\s]'), '');
        foundCnic = raw.contains('-')
            ? raw
            : '${raw.substring(0, 5)}-${raw.substring(5, 12)}-${raw.substring(12)}';
      }

      if (!mounted) return;

      if (foundCnic != null) {
        setState(() => _statusMessage = "✓ CNIC Detect Ho Gaya!");
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.pop(context, {
            'file': File(photo.path),
            'cnicNumber': foundCnic,
          });
        }
      } else {
        // CNIC nahi mila, phir bhi image return karo (manual entry ke liye)
        _showRetryDialog(photo.path);
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error aaya. Dobara try karein.";
        _isProcessing = false;
      });
    }
  }

  void _showRetryDialog(String imagePath) {
    setState(() => _isProcessing = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "CNIC Detect Nahi Hua",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Auto scan mein CNIC number nahi mila. Kya aap phir bhi is image ko use karna chahte hain?",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _statusMessage = "CNIC ko frame ke andar rakhein");
            },
            child: Text(
              "Dobara Try",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context, {
                'file': File(imagePath),
                'cnicNumber': null, // manual hai
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text("Haan, Use Karo", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "CNIC Scan Karein",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: !_isInitialized
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : Stack(
              children: [
                // Camera Preview
                Positioned.fill(child: CameraPreview(_controller!)),

                // Frame overlay (dark + CNIC frame)
                Positioned.fill(
                  child: CustomPaint(painter: _CnicFramePainter()),
                ),

                // Status message
                Positioned(
                  top: 16,
                  left: 24,
                  right: 24,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_statusMessage),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _statusMessage.contains('✓')
                            ? Colors.green.withValues(alpha: 0.85)
                            : Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusMessage,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // Tips
                Positioned(
                  bottom: 160,
                  left: 24,
                  right: 24,
                  child: Column(
                    children: [
                      _tipRow(
                        Icons.wb_sunny_outlined,
                        "Achhi roshni mein rakhein",
                      ),
                      const SizedBox(height: 4),
                      _tipRow(
                        Icons.straighten,
                        "CNIC seedha aur frame mein hona chahiye",
                      ),
                    ],
                  ),
                ),

                // Capture Button
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isProcessing ? null : _captureAndScan,
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
                            : Icon(
                                Icons.document_scanner,
                                color: primaryBlue,
                                size: 34,
                              ),
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
        Icon(icon, color: Colors.white60, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Custom Painter: CNIC Frame Overlay
// ─────────────────────────────────────────────────────────
class _CnicFramePainter extends CustomPainter {
  final Color frameColor;

  const _CnicFramePainter({this.frameColor = const Color(0xFF0E6BBB)});

  @override
  void paint(Canvas canvas, Size size) {
    // CNIC card ratio (85.6mm x 54mm = 1.585:1)
    final frameW = size.width * 0.87;
    final frameH = frameW / 1.585;
    final frameL = (size.width - frameW) / 2;
    final frameT = (size.height - frameH) / 2;
    final frameRect = Rect.fromLTWH(frameL, frameT, frameW, frameH);
    const radius = Radius.circular(14);

    // Dark overlay with transparent hole
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.62)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // Blue frame border
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, radius),
      Paint()
        ..color = frameColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // White corner accents
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cl = 22.0; // corner length

    void drawCorner(Offset a, Offset b, Offset c) {
      canvas.drawLine(a, b, cornerPaint);
      canvas.drawLine(b, c, cornerPaint);
    }

    // Top-left
    drawCorner(
      Offset(frameL, frameT + cl),
      Offset(frameL, frameT),
      Offset(frameL + cl, frameT),
    );
    // Top-right
    drawCorner(
      Offset(frameL + frameW - cl, frameT),
      Offset(frameL + frameW, frameT),
      Offset(frameL + frameW, frameT + cl),
    );
    // Bottom-left
    drawCorner(
      Offset(frameL, frameT + frameH - cl),
      Offset(frameL, frameT + frameH),
      Offset(frameL + cl, frameT + frameH),
    );
    // Bottom-right
    drawCorner(
      Offset(frameL + frameW - cl, frameT + frameH),
      Offset(frameL + frameW, frameT + frameH),
      Offset(frameL + frameW, frameT + frameH - cl),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

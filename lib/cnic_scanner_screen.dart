// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

// class CnicScannerScreen extends StatefulWidget {
//   final String side;
//   const CnicScannerScreen({super.key, required this.side});

//   @override
//   State<CnicScannerScreen> createState() => _CnicScannerScreenState();
// }

// class _CnicScannerScreenState extends State<CnicScannerScreen> {
//   CameraController? _controller;
//   bool _isBusy = false;
//   bool _isCardDetected = false;
//   final TextRecognizer _textRecognizer = TextRecognizer();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   void _initializeCamera() async {
//     final cameras = await availableCameras();
//     _controller = CameraController(
//       cameras[0],
//       ResolutionPreset.high,
//       enableAudio: false,
//     );
//     await _controller?.initialize();
//     _controller?.startImageStream(_processCameraImage);
//     if (mounted) setState(() {});
//   }

//   void _processCameraImage(CameraImage image) async {
//     if (_isBusy) return;
//     _isBusy = true;

//     try {
//       final WriteBuffer allBytes = WriteBuffer();
//       for (final Plane plane in image.planes) {
//         allBytes.putUint8List(plane.bytes);
//       }
//       final bytes = allBytes.done().buffer.asUint8List();

//       final inputImage = InputImage.fromBytes(
//         bytes: bytes,
//         metadata: InputImageMetadata(
//           size: Size(image.width.toDouble(), image.height.toDouble()),
//           rotation: InputImageRotation.rotation90deg,
//           format:
//               InputImageFormatValue.fromRawValue(image.format.raw) ??
//               InputImageFormat.nv21,
//           bytesPerRow: image.planes[0].bytesPerRow,
//         ),
//       );

//       final RecognizedText recognizedText = await _textRecognizer.processImage(
//         inputImage,
//       );

//       // CNIC Validation: Checking keywords
//       bool hasKeywords =
//           recognizedText.text.contains("PAKISTAN") ||
//           recognizedText.text.contains("IDENTITY") ||
//           recognizedText.text.contains("GOVERNMENT");

//       if (hasKeywords && !_isCardDetected) {
//         setState(() => _isCardDetected = true);
//         await Future.delayed(const Duration(milliseconds: 800));
//         _captureImage();
//       }
//     } catch (e) {
//       debugPrint("Scanner Error: $e");
//     } finally {
//       _isBusy = false;
//     }
//   }

//   void _captureImage() async {
//     if (_controller == null || !_controller!.value.isInitialized) return;
//     try {
//       await _controller?.stopImageStream();
//       final XFile file = await _controller!.takePicture();
//       if (mounted) Navigator.pop(context, File(file.path));
//     } catch (e) {
//       _initializeCamera(); // Retry if fails
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           CameraPreview(_controller!),
//           Center(
//             child: Container(
//               width: 320,
//               height: 210,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: _isCardDetected ? Colors.green : Colors.white,
//                   width: 3,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 60,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 _isCardDetected
//                     ? "Card Detected! Processing..."
//                     : "Align CNIC ${widget.side.toUpperCase()} within the frame",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _textRecognizer.close();
//     super.dispose();
//   }
// }

// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

// class CnicScannerScreen extends StatefulWidget {
//   final String side;
//   const CnicScannerScreen({super.key, required this.side});

//   @override
//   State<CnicScannerScreen> createState() => _CnicScannerScreenState();
// }

// class _CnicScannerScreenState extends State<CnicScannerScreen> {
//   CameraController? _controller;
//   bool _isBusy = false;
//   bool _isCardDetected = false;
//   bool _isCapturing = false;
//   final TextRecognizer _textRecognizer = TextRecognizer();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   void _initializeCamera() async {
//     final cameras = await availableCameras();
//     _controller = CameraController(
//       cameras[0],
//       ResolutionPreset.high,
//       enableAudio: false,
//     );
//     await _controller?.initialize();
//     if (!mounted) return;
//     _controller?.startImageStream(_processCameraImage);
//     setState(() {});
//   }

//   void _processCameraImage(CameraImage image) async {
//     if (_isBusy || _isCapturing) return;
//     _isBusy = true;

//     try {
//       final WriteBuffer allBytes = WriteBuffer();
//       for (final Plane plane in image.planes) {
//         allBytes.putUint8List(plane.bytes);
//       }
//       final bytes = allBytes.done().buffer.asUint8List();

//       final inputImage = InputImage.fromBytes(
//         bytes: bytes,
//         metadata: InputImageMetadata(
//           size: Size(image.width.toDouble(), image.height.toDouble()),
//           rotation: InputImageRotation.rotation90deg,
//           format:
//               InputImageFormatValue.fromRawValue(image.format.raw) ??
//               InputImageFormat.nv21,
//           bytesPerRow: image.planes[0].bytesPerRow,
//         ),
//       );

//       final RecognizedText recognizedText = await _textRecognizer.processImage(
//         inputImage,
//       );
//       String text = recognizedText.text.toUpperCase();

//       // CNIC Validation: Checking keywords case-insensitively
//       bool hasKeywords =
//           text.contains("PAKISTAN") ||
//           text.contains("IDENTITY") ||
//           text.contains("GOVERNMENT");

//       if (hasKeywords && !_isCardDetected && !_isCapturing) {
//         setState(() => _isCardDetected = true);
//         _captureImage();
//       }
//     } catch (e) {
//       debugPrint("Scanner Error: $e");
//     } finally {
//       _isBusy = false;
//     }
//   }

//   void _captureImage() async {
//     if (_isCapturing ||
//         _controller == null ||
//         !_controller!.value.isInitialized) {
//       return;
//     }
//     _isCapturing = true; // Lock capture process

//     try {
//       await Future.delayed(
//         const Duration(milliseconds: 500),
//       ); // Thora wait for focus
//       await _controller?.stopImageStream();
//       final XFile file = await _controller!.takePicture();
//       if (mounted) Navigator.pop(context, File(file.path));
//     } catch (e) {
//       debugPrint("Capture Error: $e");
//       _isCapturing = false;
//       _isCardDetected = false;
//       _initializeCamera(); // Retry if fails
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           CameraPreview(_controller!),
//           Center(
//             child: Container(
//               width: 320,
//               height: 210,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: _isCardDetected ? Colors.green : Colors.white,
//                   width: 3,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 60,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 _isCardDetected
//                     ? "Card Detected! Auto Capturing..."
//                     : "Align CNIC ${widget.side.toUpperCase()} within the frame",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _textRecognizer.close();
//     super.dispose();
//   }
// }

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CnicScannerScreen extends StatefulWidget {
  final String side;
  const CnicScannerScreen({super.key, required this.side});

  @override
  State<CnicScannerScreen> createState() => _CnicScannerScreenState();
}

class _CnicScannerScreenState extends State<CnicScannerScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isBusy = false;
  bool _isCardDetected = false;
  bool _isCapturing = false;
  int _stableFrameCount = 0; // Stability counter - 3 consecutive frames needed
  final int _requiredStableFrames = 3;
  late AnimationController _pulseController;
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted && _controller != null && _controller!.value.isInitialized) {
        _controller!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint("Camera Init Error: $e");
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isBusy || _isCapturing || !mounted) return;
    _isBusy = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation90deg,
          format: InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      String text = recognizedText.text.toUpperCase();

      // Pakistani NIC keyword matching
      bool hasPakistan = text.contains("PAKISTAN");
      bool hasNadra = text.contains("NADRA");
      bool hasNIC =
          text.contains("NATIONAL") ||
          text.contains("IDENTITY") ||
          text.contains("IDENTIT");
      bool hasGovt = text.contains("GOVERNMENT") || text.contains("GOVT");
      bool hasCnic = text.contains("CNIC") || text.contains("CITIZEN");
      // CNIC number pattern: 5 digits - 7 digits - 1 digit
      bool hasCnicNumber = RegExp(r'\d{5}-\d{7}-\d').hasMatch(text) ||
          RegExp(r'\d{13}').hasMatch(text);
      bool hasIslamicRepublic = text.contains("ISLAMIC");

      int matchCount = 0;
      if (hasPakistan) matchCount++;
      if (hasNadra) matchCount++;
      if (hasNIC) matchCount++;
      if (hasGovt) matchCount++;
      if (hasCnic) matchCount++;
      if (hasCnicNumber) matchCount += 2; // CNIC number = strong signal
      if (hasIslamicRepublic) matchCount++;

      if (matchCount >= 2 && !_isCapturing) {
        _stableFrameCount++;

        if (_stableFrameCount >= _requiredStableFrames && !_isCardDetected) {
          if (mounted) setState(() => _isCardDetected = true);
          await _captureImage();
        } else if (mounted && !_isCardDetected) {
          setState(() {}); // Refresh for progress
        }
      } else {
        // Reset if card leaves frame
        if (_stableFrameCount > 0 && !_isCardDetected) {
          _stableFrameCount = 0;
          if (mounted) setState(() {});
        }
      }
    } catch (e) {
      debugPrint("Scanner Error: $e");
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;
    _isCapturing = true;

    try {
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await Future.delayed(const Duration(milliseconds: 700));

      if (_controller == null || !_controller!.value.isInitialized) {
        _isCapturing = false;
        return;
      }

      final XFile file = await _controller!.takePicture();
      if (mounted) Navigator.pop(context, File(file.path));
    } catch (e) {
      debugPrint("Capture Error: $e");
      _isCapturing = false;
      _isCardDetected = false;
      _stableFrameCount = 0;
      _initializeCamera();
    }
  }

  void _manualCapture() async {
    if (_isCapturing) return;
    if (mounted) setState(() => _isCardDetected = true);
    await _captureImage();
  }

  // Pakistani NIC frame dimensions ratio: 85.6mm × 54mm = 1.585:1
  double get _frameWidth {
    final sw = MediaQuery.of(context).size.width;
    return sw * 0.88; // 88% of screen width
  }

  double get _frameHeight => _frameWidth / 1.585; // Exact NIC ratio

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final Color borderColor = _isCardDetected
        ? Colors.green
        : _stableFrameCount > 0
        ? Colors.yellow
        : Colors.white;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen camera
          Positioned.fill(child: CameraPreview(_controller!)),

          // Dark overlay with transparent NIC-shaped hole
          Positioned.fill(
            child: CustomPaint(
              painter: _NicOverlayPainter(
                frameWidth: _frameWidth,
                frameHeight: _frameHeight,
              ),
            ),
          ),

          // Corner bracket frame (like NADRA/EasyPaisa)
          Center(
            child: SizedBox(
              width: _frameWidth,
              height: _frameHeight,
              child: CustomPaint(
                painter: _CornerBracketPainter(color: borderColor),
              ),
            ),
          ),

          // Scan line animation when detecting
          if (!_isCardDetected && _stableFrameCount == 0)
            Center(
              child: SizedBox(
                width: _frameWidth,
                height: _frameHeight,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment(
                        0,
                        -1 + 2 * _pulseController.value,
                      ),
                      child: Container(
                        height: 2,
                        width: _frameWidth,
                        color: Colors.green.withOpacity(0.7),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Top instruction
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  "CNIC ${widget.side.toUpperCase()} Side",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Frame mein card rakhein - auto detect hoga",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Stability progress dots
          if (!_isCardDetected && _stableFrameCount > 0)
            Center(
              child: Transform.translate(
                offset: Offset(0, _frameHeight / 2 + 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_requiredStableFrames, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _stableFrameCount
                            ? Colors.yellow
                            : Colors.white30,
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Bottom status + manual button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isCapturing
                        ? "📸 Processing..."
                        : _isCardDetected
                        ? "✅ Card Detected! Capturing..."
                        : _stableFrameCount > 0
                        ? "🔍 Card mil raha hai..."
                        : "📋 CNIC ko frame mein rakhein",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: _isCardDetected ? Colors.green : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_isCapturing)
                  GestureDetector(
                    onTap: _manualCapture,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "📷  Manually Capture",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textRecognizer.close();
    _controller?.dispose();
    super.dispose();
  }
}

// Dark overlay with NIC-shaped transparent cutout
class _NicOverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  _NicOverlayPainter({required this.frameWidth, required this.frameHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.60);
    final double left = (size.width - frameWidth) / 2;
    final double top = (size.height - frameHeight) / 2;
    final radius = const Radius.circular(12);

    // Draw 4 dark rectangles around the transparent frame
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), paint);
    canvas.drawRect(
        Rect.fromLTWH(0, top + frameHeight, size.width, size.height - top - frameHeight), paint);
    canvas.drawRect(Rect.fromLTWH(0, top, left, frameHeight), paint);
    canvas.drawRect(
        Rect.fromLTWH(left + frameWidth, top, size.width - left - frameWidth, frameHeight), paint);

    // Clear the NIC frame area with rounded corners
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, frameWidth, frameHeight),
        radius,
      ),
      clearPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Corner bracket painter (like professional scanner apps)
class _CornerBracketPainter extends CustomPainter {
  final Color color;
  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double bracketLen = 28.0;
    const double radius = 12.0;

    // TOP LEFT
    canvas.drawLine(
        Offset(radius, 0), Offset(bracketLen, 0), paint);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, radius * 2, radius * 2),
        -3.14159 / 2 * 2, // 180 deg top
        -3.14159 / 2,
        false,
        paint);
    canvas.drawLine(
        Offset(0, radius), Offset(0, bracketLen), paint);

    // TOP RIGHT
    canvas.drawLine(
        Offset(size.width - bracketLen, 0), Offset(size.width - radius, 0), paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
        -3.14159 / 2,
        -3.14159 / 2,
        false,
        paint);
    canvas.drawLine(
        Offset(size.width, radius), Offset(size.width, bracketLen), paint);

    // BOTTOM LEFT
    canvas.drawLine(
        Offset(0, size.height - bracketLen), Offset(0, size.height - radius), paint);
    canvas.drawArc(
        Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
        3.14159,
        -3.14159 / 2,
        false,
        paint);
    canvas.drawLine(
        Offset(radius, size.height), Offset(bracketLen, size.height), paint);

    // BOTTOM RIGHT
    canvas.drawLine(
        Offset(size.width, size.height - bracketLen),
        Offset(size.width, size.height - radius),
        paint);
    canvas.drawArc(
        Rect.fromLTWH(
            size.width - radius * 2, size.height - radius * 2, radius * 2, radius * 2),
        0,
        -3.14159 / 2,
        false,
        paint);
    canvas.drawLine(
        Offset(size.width - bracketLen, size.height),
        Offset(size.width - radius, size.height),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
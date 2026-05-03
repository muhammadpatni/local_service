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

class _CnicScannerScreenState extends State<CnicScannerScreen> {
  CameraController? _controller;
  bool _isBusy = false;
  bool _isCardDetected = false;
  bool _isCapturing = false;
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
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
      // Thoda delay de kar stream shuru karo taake camera stabilize ho jaye
      await Future.delayed(const Duration(milliseconds: 500));
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
          format:
              InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );
      String text = recognizedText.text.toUpperCase();

      // CNIC Validation: multiple keywords check
      bool hasPakistan = text.contains("PAKISTAN");
      bool hasIdentity = text.contains("IDENTITY") || text.contains("IDENTIT");
      bool hasGovt = text.contains("GOVERNMENT") || text.contains("GOVT");
      bool hasNadra = text.contains("NADRA");
      bool hasCnic =
          text.contains("CNIC") ||
          text.contains("NATIONAL") ||
          text.contains("CITIZEN");

      // Kam se kam 2 keywords milein taake false positive na ho
      int matchCount = 0;
      if (hasPakistan) matchCount++;
      if (hasIdentity) matchCount++;
      if (hasGovt) matchCount++;
      if (hasNadra) matchCount++;
      if (hasCnic) matchCount++;

      if (matchCount >= 1 && !_isCardDetected && !_isCapturing) {
        if (mounted) {
          setState(() => _isCardDetected = true);
        }
        await _captureImage();
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
      // Stream band karo pehle
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      // Camera ko focus karne ka waqt do
      await Future.delayed(const Duration(milliseconds: 800));

      if (_controller == null || !_controller!.value.isInitialized) {
        _isCapturing = false;
        return;
      }

      final XFile file = await _controller!.takePicture();

      if (mounted) {
        Navigator.pop(context, File(file.path));
      }
    } catch (e) {
      debugPrint("Capture Error: $e");
      _isCapturing = false;
      if (mounted) {
        setState(() => _isCardDetected = false);
      }
      _initializeCamera();
    }
  }

  // Manual capture button ke liye
  void _manualCapture() async {
    if (_isCapturing) return;
    if (mounted) {
      setState(() => _isCardDetected = true);
    }
    await _captureImage();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen camera preview
          Positioned.fill(child: CameraPreview(_controller!)),

          // Dark overlay except center frame
          Positioned.fill(child: CustomPaint(painter: _OverlayPainter())),

          // CNIC Frame
          Center(
            child: Container(
              width: 320,
              height: 210,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isCardDetected ? Colors.green : Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Top instruction
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Text(
              "Align CNIC ${widget.side.toUpperCase()} within the frame",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Bottom status + manual button
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isCapturing
                        ? "Processing..."
                        : _isCardDetected
                        ? "Card Detected! Auto Capturing..."
                        : "Scanning for CNIC...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Manual capture button
                if (!_isCapturing)
                  GestureDetector(
                    onTap: _manualCapture,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "Capture Manually",
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
    _textRecognizer.close();
    _controller?.dispose();
    super.dispose();
  }
}

// Dark overlay with transparent center hole
class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final frameW = 320.0;
    final frameH = 210.0;
    final left = (size.width - frameW) / 2;
    final top = (size.height - frameH) / 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), paint);
    canvas.drawRect(
      Rect.fromLTWH(0, top + frameH, size.width, size.height - top - frameH),
      paint,
    );
    canvas.drawRect(Rect.fromLTWH(0, top, left, frameH), paint);
    canvas.drawRect(
      Rect.fromLTWH(left + frameW, top, size.width - left - frameW, frameH),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

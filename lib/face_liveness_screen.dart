// import 'dart:async';
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class FaceLivenessScreen extends StatefulWidget {
//   const FaceLivenessScreen({super.key});

//   @override
//   State<FaceLivenessScreen> createState() => _FaceLivenessScreenState();
// }

// class _FaceLivenessScreenState extends State<FaceLivenessScreen> {
//   CameraController? _controller;
//   String instruction = "Position your face in the circle";
//   int step = 0;
//   bool _isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   void _initCamera() async {
//     final cameras = await availableCameras();
//     final front = cameras.firstWhere(
//       (c) => c.lensDirection == CameraLensDirection.front,
//     );
//     _controller = CameraController(front, ResolutionPreset.medium);
//     await _controller!.initialize();
//     if (mounted) setState(() {});
//     _startFlow();
//   }

//   void _startFlow() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (!mounted) return;

//     await _controller!.startVideoRecording();
//     setState(() => _isRecording = true);

//     List<Map<String, dynamic>> steps = [
//       {"text": "Please Smile 😊", "duration": 2},
//       {"text": "Turn your face Left ⬅️", "duration": 2},
//       {"text": "Turn your face Right ➡️", "duration": 2},
//       {"text": "Blink your eyes 👁️", "duration": 2},
//     ];

//     for (var i = 0; i < steps.length; i++) {
//       if (!mounted) return;
//       setState(() {
//         instruction = steps[i]['text'];
//         step = i + 1;
//       });
//       await Future.delayed(Duration(seconds: steps[i]['duration']));
//     }

//     XFile video = await _controller!.stopVideoRecording();
//     if (mounted) Navigator.pop(context, File(video.path));
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           const SizedBox(height: 80),
//           Text(
//             "Liveness Check",
//             style: GoogleFonts.poppins(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 40),
//           Center(
//             child: ClipOval(
//               child: SizedBox(
//                 width: 280,
//                 height: 280,
//                 child: CameraPreview(_controller!),
//               ),
//             ),
//           ),
//           const SizedBox(height: 50),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 40),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0E6BBB).withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Text(
//               instruction,
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 color: const Color(0xFF0E6BBB),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             "Step $step of 4",
//             style: GoogleFonts.poppins(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
// }

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaceLivenessScreen extends StatefulWidget {
  const FaceLivenessScreen({super.key});

  @override
  State<FaceLivenessScreen> createState() => _FaceLivenessScreenState();
}

class _FaceLivenessScreenState extends State<FaceLivenessScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  int _currentStep = 0;
  bool _isProcessing = false;
  bool _stepConfirmed = false;
  bool _cameraReady = false;

  final List<Map<String, dynamic>> _steps = [
    {
      "text": "Smile karein 😊",
      "subtext": "Thoda muskurain aur Confirm dabain",
      "icon": "😊",
    },
    {
      "text": "Face Left karein ⬅️",
      "subtext": "Dheere apna chehra baen taraf ghumaein",
      "icon": "⬅️",
    },
    {
      "text": "Face Right karein ➡️",
      "subtext": "Ab daayen taraf chehra ghumaein",
      "icon": "➡️",
    },
    {
      "text": "Seedha dekhein & Blink karein 👁️",
      "subtext": "Camera ki taraf seedha dekhein aur aankh jhapkaein",
      "icon": "👁️",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _cameraReady = true);

      // Start recording immediately
      await _controller!.startVideoRecording();
    } catch (e) {
      debugPrint("Camera Init Error: $e");
    }
  }

  // User manually confirms they performed the step
  void _onStepConfirmed() async {
    if (_stepConfirmed || _isProcessing) return;

    setState(() => _stepConfirmed = true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _stepConfirmed = false;
      });
    } else {
      // Last step done - finish
      _finishLiveness();
    }
  }

  void _finishLiveness() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      // Stop video recording
      XFile video = await _controller!.stopVideoRecording();

      // Small delay then take final face picture
      await Future.delayed(const Duration(milliseconds: 400));
      XFile faceImage = await _controller!.takePicture();

      if (mounted) {
        Navigator.pop(context, {
          'video': File(video.path),
          'image': File(faceImage.path),
        });
      }
    } catch (e) {
      debugPrint("Finish Error: $e");
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error capturing. Please try again.")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF0E6BBB)),
              SizedBox(height: 16),
              Text("Camera tayyar ho raha hai..."),
            ],
          ),
        ),
      );
    }

    final currentStepData = _steps[_currentStep];
    const primaryBlue = Color(0xFF0E6BBB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Header
            Text(
              "Liveness Verification",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Step ${_currentStep + 1} of ${_steps.length}",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value:
                      (_currentStep + (_stepConfirmed ? 1 : 0)) / _steps.length,
                  backgroundColor: Colors.grey[200],
                  color: _stepConfirmed ? Colors.green : primaryBlue,
                  minHeight: 8,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Camera oval with glow border
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _stepConfirmed ? Colors.green : primaryBlue,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_stepConfirmed ? Colors.green : primaryBlue)
                          .withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(child: CameraPreview(_controller!)),
              ),
            ),

            const SizedBox(height: 28),

            // Step instruction card
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey('step_$_currentStep${_stepConfirmed}'),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _stepConfirmed
                      ? Colors.green.withOpacity(0.08)
                      : primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _stepConfirmed
                        ? Colors.green.withOpacity(0.3)
                        : primaryBlue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _stepConfirmed
                          ? "✅ Done! Agle step par ja rahe hain..."
                          : currentStepData['text'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: _stepConfirmed ? Colors.green : primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!_stepConfirmed) ...[
                      const SizedBox(height: 4),
                      Text(
                        currentStepData['subtext'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  if (!_stepConfirmed && !_isProcessing) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onStepConfirmed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentStep == _steps.length - 1
                              ? "✅  Complete & Submit"
                              : "✅  Ho gaya, Next",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_isProcessing) ...[
                    const CircularProgressIndicator(color: primaryBlue),
                    const SizedBox(height: 12),
                    Text(
                      "Video process ho rahi hai...",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

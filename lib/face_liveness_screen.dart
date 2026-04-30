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

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaceLivenessScreen extends StatefulWidget {
  const FaceLivenessScreen({super.key});

  @override
  State<FaceLivenessScreen> createState() => _FaceLivenessScreenState();
}

class _FaceLivenessScreenState extends State<FaceLivenessScreen> {
  CameraController? _controller;
  String instruction = "Position your face in the circle";
  int step = 0;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(
      front,
      ResolutionPreset.high,
    ); // High for better face verif
    await _controller!.initialize();
    if (mounted) setState(() {});
    _startFlow();
  }

  void _startFlow() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    await _controller!.startVideoRecording();
    setState(() => _isRecording = true);

    List<Map<String, dynamic>> steps = [
      {"text": "Please Smile 😊", "duration": 2},
      {"text": "Turn your face Left ⬅️", "duration": 2},
      {"text": "Turn your face Right ➡️", "duration": 2},
      {"text": "Look Straight & Blink 👁️", "duration": 2},
    ];

    for (var i = 0; i < steps.length; i++) {
      if (!mounted) return;
      setState(() {
        instruction = steps[i]['text'];
        step = i + 1;
      });
      await Future.delayed(Duration(seconds: steps[i]['duration']));
    }

    // Stop video and immediately take a high-res picture for API
    XFile video = await _controller!.stopVideoRecording();

    // Thora delay de kar picture capture karein taake clear straight face aaye
    await Future.delayed(const Duration(milliseconds: 300));
    XFile imageForApi = await _controller!.takePicture();

    if (mounted) {
      Navigator.pop(context, {
        'video': File(video.path),
        'image': File(imageForApi.path),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 80),
          Text(
            "Liveness Check",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: ClipOval(
              child: SizedBox(
                width: 280,
                height: 280,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0E6BBB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              instruction,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xFF0E6BBB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Step $step of 4",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

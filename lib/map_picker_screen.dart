// import 'package:flutter/material.dart';
// import 'package:local_service/location_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// // Apni location_provider file import karein

// class MapPickerScreen extends StatelessWidget {
//   const MapPickerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Provider ka instance lein
//     final locationProv = Provider.of<LocationProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Confirm Location",
//           style: GoogleFonts.poppins(fontSize: 18),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: locationProv.currentPosition,
//               zoom: 16,
//             ),
//             onCameraMove: (position) =>
//                 locationProv.updatePosition(position.target),
//             onCameraIdle: () => locationProv.fetchAddress(),
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             zoomControlsEnabled: false,
//           ),
//           // Center Pin
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 35),
//               child: Icon(
//                 Icons.location_on,
//                 size: 45,
//                 color: const Color(0xFF0E6BBB),
//               ),
//             ),
//           ),
//           // Bottom Info Card
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.map_outlined, color: Color(0xFF0E6BBB)),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           locationProv.addressDisplay,
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             color: locationProv.isFetchingAddress
//                                 ? Colors.grey
//                                 : Colors.black87,
//                           ),
//                           maxLines: 2,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0E6BBB),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed:
//                           (locationProv.isSaving ||
//                               locationProv.isFetchingAddress)
//                           ? null
//                           : () async {
//                               bool success = await locationProv
//                                   .saveToFirebase();
//                               if (success && context.mounted)
//                                 Navigator.pop(context);
//                             },
//                       child: locationProv.isSaving
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               "Confirm & Save",
//                               style: GoogleFonts.poppins(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:local_service/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MapPickerScreen extends StatelessWidget {
  const MapPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProv = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Confirm Location",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationProv.currentPosition,
              zoom: 16,
            ),
            onCameraMove: (position) =>
                locationProv.updatePosition(position.target),
            onCameraIdle: () => locationProv.fetchAddress(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          // Center Pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Icon(
                Icons.location_on,
                size: 45,
                color: const Color(0xFF0E6BBB),
              ),
            ),
          ),
          // Bottom Info Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map_outlined, color: Color(0xFF0E6BBB)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          locationProv.addressDisplay,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: locationProv.isFetchingAddress
                                ? Colors.grey
                                : Colors.black87,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E6BBB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Button ko disable sirf tab karein jab save ho raha ho.
                      // Fetching ke waqt hum click allow karenge lekin function ke andar handle karenge.
                      onPressed: locationProv.isSaving
                          ? null
                          : () async {
                              // User feedback agar address abhi load nahi hua
                              if (locationProv.addressDisplay ==
                                      "Locating..." ||
                                  locationProv.addressDisplay ==
                                      "Move map to pick location") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please wait, fetching address...",
                                    ),
                                  ),
                                );
                                return;
                              }

                              bool success = await locationProv
                                  .saveToFirebase();

                              if (success && context.mounted) {
                                Navigator.pop(context);
                              } else if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Failed to save. check internet or login status.",
                                    ),
                                  ),
                                );
                              }
                            },
                      child: locationProv.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Confirm & Save",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

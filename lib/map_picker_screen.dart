import 'package:flutter/material.dart';
import 'package:local_service/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Color spanishBlue = const Color(0xFF0E6BBB);

  @override
  void initState() {
    super.initState();
    // Screen load hote hi GPS dhoondo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).determinePosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProv = Provider.of<LocationProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationProv.currentPosition,
              zoom: 16,
            ),
            onMapCreated: (controller) =>
                locationProv.mapController = controller,
            onCameraMove: (position) =>
                locationProv.updatePosition(position.target),
            onCameraIdle: () => locationProv.fetchAddress(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // 1. Floating Search Bar
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search location...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: spanishBlue),
                ),
                onSubmitted: (val) => locationProv.searchAddress(val),
              ),
            ),
          ),

          // 2. Custom Center Pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on, size: 50, color: spanishBlue),
            ),
          ),

          // 3. Current Location Button (GPS)
          Positioned(
            right: 20,
            bottom: 230,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () => locationProv.determinePosition(),
              child: Icon(Icons.my_location, color: spanishBlue),
            ),
          ),

          // 4. Bottom Detail Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(25),
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
                      Icon(Icons.location_searching, color: spanishBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          locationProv.addressDisplay,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: spanishBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      // Button ko disable sirf tab karein jab save ho raha ho.
                      // Fetching ke waqt hum click allow karenge lekin function ke andar handle karenge.
                      onPressed: locationProv.isSaving
                          ? null
                          : () async {
                              bool ok = await locationProv.saveToFirebase();
                              if (ok && mounted) Navigator.pop(context);
                            },
                      child: locationProv.isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Confirm & Save",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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

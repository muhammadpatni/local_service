// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LocationProvider with ChangeNotifier {
//   LatLng _currentPosition = const LatLng(24.8607, 67.0011);
//   String _addressDisplay = "Move map to pick location";
//   bool _isSaving = false;
//   bool _isFetchingAddress = false;

//   // Getters
//   LatLng get currentPosition => _currentPosition;
//   String get addressDisplay => _addressDisplay;
//   bool get isSaving => _isSaving;
//   bool get isFetchingAddress => _isFetchingAddress;

//   // Jab camera move ho toh sirf position update karein (Bagair address fetch kiye)
//   void updatePosition(LatLng newPos) {
//     _currentPosition = newPos;
//     notifyListeners();
//   }

//   // Jab camera ruk jaye (onCameraIdle) tab address fetch karein
//   Future<void> fetchAddress() async {
//     _isFetchingAddress = true;
//     _addressDisplay = "Locating...";
//     notifyListeners();

//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         _currentPosition.latitude,
//         _currentPosition.longitude,
//       ).timeout(const Duration(seconds: 5));

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         _addressDisplay =
//             "${place.name}, ${place.subLocality}, ${place.locality}";
//       }
//     } catch (e) {
//       _addressDisplay = "Address not found";
//       debugPrint("Geocoding Error: $e");
//     } finally {
//       _isFetchingAddress = false;
//       notifyListeners();
//     }
//   }

//   // Firebase mein save karne ka logic
//   Future<bool> saveToFirebase() async {
//     if (_isFetchingAddress) return false;

//     _isSaving = true;
//     notifyListeners();

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('addresses')
//             .add({
//               'addressLine': _addressDisplay,
//               'lat': _currentPosition.latitude,
//               'lng': _currentPosition.longitude,
//               'createdAt': FieldValue.serverTimestamp(),
//             });
//         return true;
//       }
//       return false;
//     } catch (e) {
//       debugPrint("Firebase Error: $e");
//       return false;
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationProvider with ChangeNotifier {
  LatLng _currentPosition = const LatLng(24.8607, 67.0011); // Default: Karachi
  String _addressDisplay = "Detecting your location...";
  bool _isSaving = false;
  bool _isFetchingAddress = false;
  GoogleMapController? mapController;

  LatLng get currentPosition => _currentPosition;
  String get addressDisplay => _addressDisplay;
  bool get isSaving => _isSaving;
  bool get isFetchingAddress => _isFetchingAddress;

  // GPS se current location lene ka function
  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _addressDisplay = "Location services are disabled.";
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 16),
    );
    fetchAddress();
    notifyListeners();
  }

  // Search functionality
  Future<void> searchAddress(String query) async {
    if (query.isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        _currentPosition = LatLng(
          locations[0].latitude,
          locations[0].longitude,
        );
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 16),
        );
        fetchAddress();
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    }
  }

  void updatePosition(LatLng newPos) {
    _currentPosition = newPos;
  }

  Future<void> fetchAddress() async {
    // Agar coordinates zero hain toh fetch na karein
    if (_currentPosition.latitude == 0) return;

    _isFetchingAddress = true;
    _addressDisplay = "Locating...";
    notifyListeners();

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      ).timeout(const Duration(seconds: 10)); // Timeout zaroori hai

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Behtar Address Formatting (Building, Street, City)
        String name = place.name ?? "";
        String subLocality = place.subLocality ?? "";
        String locality = place.locality ?? "";

        _addressDisplay = "$name, $subLocality, $locality".replaceAll(
          ", ,",
          ",",
        );

        // Agar formatting ke baad bhi khali ho
        if (_addressDisplay.trim() == "," || _addressDisplay.isEmpty) {
          _addressDisplay =
              "Location found at ${_currentPosition.latitude.toStringAsFixed(4)}";
        }
      } else {
        _addressDisplay = "Address not found";
      }
    } catch (e) {
      debugPrint("Geocoding Error: $e");
      _addressDisplay = "Tap to retry fetching address";
    } finally {
      _isFetchingAddress = false;
      notifyListeners();
    }
  }

  Future<bool> saveToFirebase() async {
    // 1. Address check: Agar address abhi bhi load ho raha hai ya fail hua hai
    if (_isFetchingAddress ||
        _addressDisplay == "Locating..." ||
        _addressDisplay.contains("retry")) {
      await fetchAddress(); // Dobara koshish karein
      if (_addressDisplay.contains("retry")) return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      // 2. Auth Check: Sabse bari wajah save na hone ki
      if (user == null) {
        debugPrint("❌ Firebase Error: No user is currently logged in.");
        return false;
      }

      // 3. Data Map
      Map<String, dynamic> addressData = {
        'addressLine': _addressDisplay,
        'lat': _currentPosition.latitude,
        'lng': _currentPosition.longitude,
        'userId': user.uid, // Safety ke liye userId andar bhi rakh dein
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 4. Firestore Write
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add(addressData);

      debugPrint("✅ Success: Address saved for UID: ${user.uid}");
      return true;
    } catch (e) {
      // 5. Error Logging: Is se aapko Console mein pata chalega masla kya hai
      debugPrint("❌ Firebase Save Error: $e");

      if (e.toString().contains("permission-denied")) {
        debugPrint(
          "Check your Firebase Rules! They might be blocking the write.",
        );
      }

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LocationProvider with ChangeNotifier {
//   LatLng _currentPosition = const LatLng(24.8607, 67.0011);
//   String _addressDisplay = "Move map to pick location";
//   bool _isSaving = false;
//   bool _isFetchingAddress = false;

//   LatLng get currentPosition => _currentPosition;
//   String get addressDisplay => _addressDisplay;
//   bool get isSaving => _isSaving;
//   bool get isFetchingAddress => _isFetchingAddress;

//   void updatePosition(LatLng newPos) {
//     _currentPosition = newPos;
//     // notifyListeners() yahan nahi lagana taaki map lag na kare
//   }

//   Future<void> fetchAddress() async {
//     _isFetchingAddress = true;
//     _addressDisplay = "Locating...";
//     notifyListeners();

//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         _currentPosition.latitude,
//         _currentPosition.longitude,
//       ).timeout(const Duration(seconds: 8)); // Timeout thora barha diya hai

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         // Behtar formatting
//         _addressDisplay =
//             "${place.name}, ${place.subLocality}, ${place.locality}";
//       } else {
//         _addressDisplay = "Unknown Location";
//       }
//     } catch (e) {
//       _addressDisplay = "Tap to retry fetching address";
//       debugPrint("Geocoding Error: $e");
//     } finally {
//       _isFetchingAddress = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> saveToFirebase() async {
//     // Agar address abhi load ho raha hai, toh 1 second intezar karke save karein
//     if (_isFetchingAddress) {
//       await Future.delayed(const Duration(seconds: 1));
//     }

//     _isSaving = true;
//     notifyListeners();

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         debugPrint("Firebase Error: No user logged in");
//         return false;
//       }

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('addresses')
//           .add({
//             'addressLine': _addressDisplay,
//             'lat': _currentPosition.latitude,
//             'lng': _currentPosition.longitude,
//             'createdAt': FieldValue.serverTimestamp(),
//           });

//       debugPrint("Success: Address saved for ${user.uid}");
//       return true;
//     } catch (e) {
//       debugPrint("Firebase Save Error: $e");
//       return false;
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }
// }

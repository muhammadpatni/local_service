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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationProvider with ChangeNotifier {
  LatLng _currentPosition = const LatLng(24.8607, 67.0011);
  String _addressDisplay = "Move map to pick location";
  bool _isSaving = false;
  bool _isFetchingAddress = false;

  LatLng get currentPosition => _currentPosition;
  String get addressDisplay => _addressDisplay;
  bool get isSaving => _isSaving;
  bool get isFetchingAddress => _isFetchingAddress;

  void updatePosition(LatLng newPos) {
    _currentPosition = newPos;
    // notifyListeners() yahan nahi lagana taaki map lag na kare
  }

  Future<void> fetchAddress() async {
    _isFetchingAddress = true;
    _addressDisplay = "Locating...";
    notifyListeners();

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      ).timeout(const Duration(seconds: 8)); // Timeout thora barha diya hai

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Behtar formatting
        _addressDisplay =
            "${place.name}, ${place.subLocality}, ${place.locality}";
      } else {
        _addressDisplay = "Unknown Location";
      }
    } catch (e) {
      _addressDisplay = "Tap to retry fetching address";
      debugPrint("Geocoding Error: $e");
    } finally {
      _isFetchingAddress = false;
      notifyListeners();
    }
  }

  Future<bool> saveToFirebase() async {
    // Agar address abhi load ho raha hai, toh 1 second intezar karke save karein
    if (_isFetchingAddress) {
      await Future.delayed(const Duration(seconds: 1));
    }

    _isSaving = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("Firebase Error: No user logged in");
        return false;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add({
            'addressLine': _addressDisplay,
            'lat': _currentPosition.latitude,
            'lng': _currentPosition.longitude,
            'createdAt': FieldValue.serverTimestamp(),
          });

      debugPrint("Success: Address saved for ${user.uid}");
      return true;
    } catch (e) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

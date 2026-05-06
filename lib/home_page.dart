// // import 'package:flutter/material.dart';
// // import 'package:local_service/user_drawer.dart';

// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({super.key});

// //   @override
// //   State<MyHomePage> createState() => _MyHomePageState();
// // }

// // class _MyHomePageState extends State<MyHomePage> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       drawer: UserDrawer(), // Aapka Drawer widget yahan use hona chahiye
// //       appBar: AppBar(title: const Text("Home Page")),
// //       body: Center(child: Text("Welcome to the Home Page!")),
// //     );
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_service/user_drawer.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//     // Is screen par aate hi lastMode = user save karo
//     _saveLastMode();
//   }

//   Future<void> _saveLastMode() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .update({'lastMode': 'user'});
//       }
//     } catch (e) {
//       debugPrint("lastMode save error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const UserDrawer(),
//       appBar: AppBar(title: const Text("Home Page")),
//       body: const Center(child: Text("Welcome to the Home Page!")),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_service/location_provider.dart';
import 'package:local_service/user_drawer.dart';
import 'package:local_service/services_data.dart'; // <-- apni services list yahan se

// ─────────────────────────────────────────────────────────────────────────────
// services.dart mein yeh structure honi chahiye:
//
// const List<Map<String, dynamic>> serviceCategories = [
//   {'label': 'Plumber',     'icon': Icons.plumbing},
//   {'label': 'Electrician', 'icon': Icons.electrical_services},
//   {'label': 'Painter',     'icon': Icons.format_paint},
//   {'label': 'Carpenter',   'icon': Icons.carpenter},
//   {'label': 'Cleaner',     'icon': Icons.cleaning_services},
//   {'label': 'AC Repair',   'icon': Icons.ac_unit},
//   // ... baaki services
// ];
// ─────────────────────────────────────────────────────────────────────────────

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final FocusNode _searchFocus = FocusNode();

  // ── Search suggestions state ──────────────────────────────────────────────
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounce;

  // ── Service category selection ────────────────────────────────────────────
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _saveLastMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).determinePosition();
    });

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _sheetController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _saveLastMode() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'lastMode': 'user'});
      }
    } catch (e) {
      debugPrint("lastMode save error: $e");
    }
  }

  // ── Search bar mein type karne par suggestions fetch karo ─────────────────
  void _onSearchChanged(String query, LocationProvider loc) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      // LocationProvider mein getSuggestions() method hona chahiye
      // Jo Google Places Autocomplete se results la sake
      final results = await loc.getSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
        });
      }
    });
  }

  // ── Suggestion tap karne par location set karo ────────────────────────────
  void _onSuggestionTap(String suggestion, LocationProvider loc) {
    _searchController.text = suggestion;
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    _searchFocus.unfocus();
    loc.searchAddress(suggestion); // map ko us location par le jao
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const UserDrawer(),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ────────────────────────────────────────────────────────────────
          // LAYER 1 — Full-screen Google Map
          // ────────────────────────────────────────────────────────────────
          Consumer<LocationProvider>(
            builder: (context, loc, _) {
              return GoogleMap(
                onMapCreated: (controller) {
                  loc.mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: loc.currentPosition,
                  zoom: 15.5,
                ),
                onCameraMove: (pos) => loc.updatePosition(pos.target),
                onCameraIdle: () => loc.fetchAddress(),
                // ✅ FIX: Blue GPS dot dikhane ke liye true karo
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // apna custom button use karein
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                mapType: MapType.normal,
              );
            },
          ),

          // ────────────────────────────────────────────────────────────────
          // LAYER 2 — Center pin (map ke center mein)
          // ────────────────────────────────────────────────────────────────
          Positioned.fill(
            bottom: screenHeight * 0.30,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_pin,
                      color: Color(0xFF2563EB),
                      size: 30,
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ────────────────────────────────────────────────────────────────
          // LAYER 3 — Search bar + Menu button
          // ────────────────────────────────────────────────────────────────
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drawer button
                _CircleButton(
                  icon: Icons.menu_rounded,
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 10),

                // Search field + suggestions dropdown
                Expanded(
                  child: Consumer<LocationProvider>(
                    builder: (context, loc, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Search Input ──────────────────────────────
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                _showSuggestions ? 16 : 28,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _searchFocus.hasFocus
                                      ? const Color(
                                          0xFF2563EB,
                                        ).withOpacity(0.22)
                                      : Colors.black.withOpacity(0.15),
                                  blurRadius: _searchFocus.hasFocus ? 16 : 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              onChanged: (v) => _onSearchChanged(v, loc),
                              onSubmitted: (v) {
                                loc.searchAddress(v);
                                setState(() => _showSuggestions = false);
                                _searchFocus.unfocus();
                              },
                              style: const TextStyle(fontSize: 14),
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: "Kahan chahiye service?",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF2563EB),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _suggestions = [];
                                            _showSuggestions = false;
                                          });
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 4,
                                ),
                              ),
                            ),
                          ),

                          // ── InDrive-style Suggestions Dropdown ────────
                          if (_showSuggestions && _suggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  children: _suggestions.asMap().entries.map((
                                    entry,
                                  ) {
                                    final i = entry.key;
                                    final suggestion = entry.value;
                                    return _SuggestionTile(
                                      suggestion: suggestion,
                                      isLast: i == _suggestions.length - 1,
                                      onTap: () =>
                                          _onSuggestionTap(suggestion, loc),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ────────────────────────────────────────────────────────────────
          // LAYER 4 — Current Location FAB (✅ FIXED)
          // ────────────────────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: screenHeight * 0.40,
            child: Consumer<LocationProvider>(
              builder: (context, loc, _) => _CircleButton(
                icon: Icons.my_location_rounded,
                iconColor: const Color(0xFF2563EB),
                onTap: () async {
                  // ✅ FIX: Pehle GPS se current position lo, phir camera animate karo
                  await loc.determinePosition();
                  // determinePosition ke baad currentPosition update hoti hai
                  // LocationProvider mein ensure karo ke mapController available hai
                  loc.mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: loc.currentPosition, zoom: 16.0),
                    ),
                  );
                },
              ),
            ),
          ),

          // ────────────────────────────────────────────────────────────────
          // LAYER 5 — Draggable Bottom Sheet
          // ────────────────────────────────────────────────────────────────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.38,
            minChildSize: 0.22,
            maxChildSize: 0.82,
            snap: true,
            snapSizes: const [0.22, 0.38, 0.82],
            builder: (context, scrollController) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: bottomPadding + 20,
                    ),
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),

                      // ── Sheet Header ──────────────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.home_repair_service_rounded,
                              color: Color(0xFF2563EB),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Book a Service",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                "Fill in details below",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ══════════════════════════════════════════════════
                      // FIELD 1 — Location (map center se auto)
                      // ══════════════════════════════════════════════════
                      _SectionLabel(
                        label: "Your Location",
                        icon: Icons.location_on_rounded,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 6),
                      Consumer<LocationProvider>(
                        builder: (context, loc, _) {
                          return GestureDetector(
                            onTap: () => _sheetController.animateTo(
                              0.22,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: loc.isFetchingAddress
                                        ? Row(
                                            children: [
                                              SizedBox(
                                                width: 14,
                                                height: 14,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.grey[400],
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Detecting location...",
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            loc.addressDisplay,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF334155),
                                              height: 1.4,
                                            ),
                                          ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // ══════════════════════════════════════════════════
                      // FIELD 2 — Service Type (services.dart se)
                      // ══════════════════════════════════════════════════
                      _SectionLabel(
                        label: "Service Type",
                        icon: Icons.handyman_rounded,
                        color: const Color(0xFF2563EB),
                      ),
                      const SizedBox(height: 8),

                      // Horizontal quick-select chips — services.dart se
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: serviceCategories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final cat = serviceCategories[i];
                            final selected = _selectedCategory == cat['label'];
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedCategory = cat['label'] as String;
                                _serviceTypeController.text =
                                    cat['label'] as String;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cat['icon'] as IconData,
                                      size: 14,
                                      color: selected
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      cat['label'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Custom service-type text input
                      TextField(
                        controller: _serviceTypeController,
                        onChanged: (v) =>
                            setState(() => _selectedCategory = null),
                        style: const TextStyle(fontSize: 14),
                        decoration: _inputDeco(
                          hint: "Ya khud type karein...",
                          prefix: const Icon(
                            Icons.edit_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                          focusColor: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ══════════════════════════════════════════════════
                      // FIELD 3 — Problem Description
                      // ══════════════════════════════════════════════════
                      _SectionLabel(
                        label: "Masla Batayein",
                        icon: Icons.description_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        minLines: 3,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        decoration: _inputDeco(
                          hint:
                              "Maslan: 'Bathroom ka tap leak ho raha hai, jaldi fix chahiye...'",
                          focusColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Find Provider Button ──────────────────────────
                      Consumer<LocationProvider>(
                        builder: (context, loc, _) {
                          final bool ready =
                              !loc.isFetchingAddress &&
                              _serviceTypeController.text.trim().isNotEmpty &&
                              _descriptionController.text.trim().isNotEmpty;

                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: ready
                                  ? () {
                                      FocusScope.of(context).unfocus();
                                      // TODO: Navigate to providers list screen
                                      // Navigator.push(context, MaterialPageRoute(
                                      //   builder: (_) => ProvidersListPage(
                                      //     service: _serviceTypeController.text,
                                      //     description: _descriptionController.text,
                                      //     location: loc.currentPosition,
                                      //   ),
                                      // ));
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Nearby providers dhoondh rahe hain...",
                                          ),
                                          backgroundColor: Color(0xFF2563EB),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                disabledBackgroundColor: const Color(
                                  0xFFBFD0F7,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: ready ? 4 : 0,
                                shadowColor: const Color(
                                  0xFF2563EB,
                                ).withOpacity(0.4),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Service Provider Dhoondein",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InDrive-style suggestion tile
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestionTile extends StatelessWidget {
  final String suggestion;
  final bool isLast;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.suggestion,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF2563EB),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.3,
                ),
              ),
            ),
            const Icon(
              Icons.north_west_rounded,
              size: 16,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared InputDecoration helper
// ─────────────────────────────────────────────────────────────────────────────
InputDecoration _inputDeco({
  required String hint,
  Widget? prefix,
  required Color focusColor,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    prefixIcon: prefix,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: focusColor, width: 1.5),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable circle icon button
// ─────────────────────────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    this.iconColor = const Color(0xFF1E293B),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label row
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionLabel({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

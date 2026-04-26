import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:local_service/provider_document_screen.dart'; // Next Screen

class ProviderProfileSettingsScreen extends StatefulWidget {
  final String? emailnumber;
  final bool isSwitching; // Agar user drawer se switch kar raha hai

  const ProviderProfileSettingsScreen({
    super.key,
    this.emailnumber,
    this.isSwitching = false,
  });

  @override
  State<ProviderProfileSettingsScreen> createState() =>
      _ProviderProfileSettingsScreenState();
}

class _ProviderProfileSettingsScreenState
    extends State<ProviderProfileSettingsScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  final Color fieldColor = const Color(0xFFF1F4F8);

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  File? _profileImageFile;
  String? _networkProfileImageUrl; // For existing users

  // Service List
  final List<String> allServices = [
    "Plumber",
    "Electrician",
    "Painter",
    "Carpenter",
    "AC Technician",
    "Home Cleaner",
    "Pest Control",
    "Mason",
    "Welder",
    "Gardener",
    "CCTV Installer",
    "Water Tank Cleaner",
    "RO Plant Technician",
  ];

  List<String> selectedServices = []; // Max 3

  @override
  void initState() {
    super.initState();
    // Default values
    String? value = widget.emailnumber;
    if (value != null && value.startsWith("+92")) {
      phoneController.text = value;
    } else if (value != null) {
      emailController.text = value;
    }

    if (widget.isSwitching) {
      _loadExistingUserData();
    }
  }

  Future<void> _loadExistingUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          var data = doc.data()!;
          setState(() {
            nameController.text = data['name'] ?? '';
            emailController.text = data['email'] ?? user.email ?? '';
            phoneController.text = data['phone'] ?? user.phoneNumber ?? '';
            _networkProfileImageUrl = data['profileImage'];

            // Agar pehle se provider tha toh services load karein
            if (data['services'] != null) {
              selectedServices = List<String>.from(data['services']);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color: primaryBlue),
                title: const Text('Gallery'),
                onTap: () {
                  _pickAndCropImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: primaryBlue),
                title: const Text('Camera'),
                onTap: () {
                  _pickAndCropImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: primaryBlue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _profileImageFile = File(croppedFile.path);
        _networkProfileImageUrl = null; // Purani image hata do
      });
    }
  }

  // Multi-Select Bottom Sheet Logic
  void _showServicesBottomSheet() {
    List<String> filteredList = List.from(allServices);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Services (Max 3)",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search services...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: fieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        filteredList = allServices
                            .where(
                              (s) =>
                                  s.toLowerCase().contains(value.toLowerCase()),
                            )
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        String service = filteredList[index];
                        bool isSelected = selectedServices.contains(service);
                        return CheckboxListTile(
                          activeColor: primaryBlue,
                          title: Text(
                            service,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          value: isSelected,
                          onChanged: (bool? val) {
                            if (val == true) {
                              if (selectedServices.length >= 3) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "You can only select up to 3 services.",
                                    ),
                                  ),
                                );
                                return;
                              }
                              setModalState(
                                () => selectedServices.add(service),
                              );
                              setState(() {}); // Update main screen
                            } else {
                              setModalState(
                                () => selectedServices.remove(service),
                              );
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Done",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _goToNextScreen() {
    if (_profileImageFile == null && _networkProfileImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Picture is mandatory!")),
      );
      return;
    }
    if (nameController.text.trim().isEmpty || selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name and at least 1 Service are mandatory!"),
        ),
      );
      return;
    }

    // Pass data to Document Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderDocumentScreen(
          profileImageFile: _profileImageFile,
          networkProfileImageUrl: _networkProfileImageUrl,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          services: selectedServices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Provider Setup",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        image: _profileImageFile != null
                            ? DecorationImage(
                                image: FileImage(_profileImageFile!),
                                fit: BoxFit.cover,
                              )
                            : (_networkProfileImageUrl != null)
                            ? DecorationImage(
                                image: NetworkImage(_networkProfileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          (_profileImageFile == null &&
                              _networkProfileImageUrl == null)
                          ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel("Full Name *"),
            _buildTextField(nameController, "Ali Khan"),

            _buildLabel("Phone Number"),
            _buildTextField(phoneController, "0300...", isPhone: true),

            _buildLabel("Email Address"),
            _buildTextField(emailController, "ali@gmail.com"),

            _buildLabel("Select Services (Up to 3) *"),
            GestureDetector(
              onTap: _showServicesBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedServices.isEmpty
                            ? "Tap to select services"
                            : selectedServices.join(", "),
                        style: GoogleFonts.poppins(
                          color: selectedServices.isEmpty
                              ? Colors.black38
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _goToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Next Step",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

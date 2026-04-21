import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:local_service/home_page.dart'; // Apna sahi path daliyega

class UserProfileSettingsScreen extends StatefulWidget {
  final String? emailnumber;
  const UserProfileSettingsScreen({super.key, required this.emailnumber});

  @override
  State<UserProfileSettingsScreen> createState() =>
      _UserProfileSettingsScreenState();
}

class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  final Color fieldColor = const Color(0xFFF1F4F8);

  // Naye Controllers Name aur City ke liye add kiye hain
  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isPhoneReadOnly = false;
  bool isEmailReadOnly = false;
  bool _isLoading = false; // Next button ke loader ke liye

  File? _imageFile; // Cropped image ko yahan store karenge

  @override
  void dispose() {
    phoneController.removeListener(_phoneListener);
    nameController.dispose();
    cityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    String? value = widget.emailnumber;

    if (value != null && value.startsWith("+92")) {
      phoneController.text = value;
      isPhoneReadOnly = true;
    } else {
      phoneController.text = "+92";
      phoneController.addListener(_phoneListener);
    }

    if (value != null && !value.startsWith("+92")) {
      emailController.text = value;
      isEmailReadOnly = true;
    }
  }

  void _phoneListener() {
    String text = phoneController.text;
    if (!text.startsWith("+92")) {
      phoneController.value = const TextEditingValue(
        text: "+92",
        selection: TextSelection.collapsed(offset: 3),
      );
    }
  }

  // Bottom sheet to choose Camera or Gallery
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

  // Image Pick & Crop logic
  Future<void> _pickAndCropImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    // Cropping the image into a perfect square
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: primaryBlue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Picture',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  // Save to ImgBB and Firestore, then Navigate
  Future<void> _saveDataAndNavigate() async {
    // Agar validations lagani hain toh yahan laga sakte hain
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name is required!")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = '';

      // 1. Upload Image to ImgBB (agar image select ki hai)
      if (_imageFile != null) {
        Uint8List bytes = await _imageFile!.readAsBytes();
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
            'https://api.imgbb.com/1/upload?key=c4df1e7a32e0eb9b38207de2b70fb210',
          ),
        );
        request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: 'profile.jpg'),
        );
        var response = await request.send();
        var respStr = await response.stream.bytesToString();
        var jsonResp = json.decode(respStr);

        if (jsonResp['status'] == 200) {
          imageUrl = jsonResp['data']['url'];
        }
      }

      // 2. Save Data to Firestore
      final user = FirebaseAuth.instance.currentUser;

      // Agar user login hai to uski UID use karein, warna naya document id generate karein
      String docId =
          user?.uid ?? FirebaseFirestore.instance.collection('users').doc().id;

      await FirebaseFirestore.instance.collection('users').doc(docId).set(
        {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'city': cityController.text.trim(),
          'phone': phoneController.text.trim(),
          'profileImage': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ); // merge: true se existing data overwrite nahi hoga

      // 3. Navigate to HomePage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Profile settings",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // 1. Profile Image Section (Updated with GestureDetector)
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
                                    image: _imageFile != null
                                        ? DecorationImage(
                                            image: FileImage(_imageFile!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _imageFile == null
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
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0E6BBB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 2. Input Fields (Added controllers for Name and City)
                        _buildInputField(
                          label: "Name",
                          hint: "Ahmed",
                          controller: nameController,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Email",
                          hint: "example@mail.com",
                          controller: emailController,
                          readOnly: isEmailReadOnly,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "City",
                          hint: "Karachi",
                          controller: cityController, // Controller mapped
                          readOnly: false,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Phone number",
                          hint: "92**********99",
                          controller: phoneController,
                          readOnly: isPhoneReadOnly,
                          isPhone: true,
                        ),

                        const Spacer(),

                        // 3. Next/Save Button (Updated with logic)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _saveDataAndNavigate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Next",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Reusable Input Field Widget (No major changes here)
  Widget _buildInputField({
    required String label,
    required String hint,
    bool isDropdown = false,
    bool isPhone = false,
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly || isDropdown,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            inputFormatters: isPhone
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
                : [],
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.black38),
              suffixIcon: isDropdown
                  ? const Icon(Icons.chevron_right, color: Colors.black54)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

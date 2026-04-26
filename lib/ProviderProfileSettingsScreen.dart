import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class Providerprofilesettingsscreen extends StatefulWidget {
  final bool isEditMode;
  const Providerprofilesettingsscreen({
    super.key,
    this.isEditMode = false,
    required String emailnumber,
  });

  @override
  State<Providerprofilesettingsscreen> createState() =>
      _ProviderprofilesettingsscreenState();
}

class _ProviderprofilesettingsscreenState
    extends State<Providerprofilesettingsscreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  final Color fieldColor = const Color(0xFFF1F4F8);

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final bool _isLoading = false;

  File? _imageFile;

  final List<String> pakistaniCities = [
    "Karachi",
    "Lahore",
    "Islamabad",
    "Rawalpindi",
    "Faisalabad",
    "Multan",
    "Peshawar",
    "Quetta",
    "Gujranwala",
    "Sialkot",
    "Sakkur",
    "Bhawalpur",
    "Rawalpindi",
    "Hyderabad",
    "Quetta",
  ];

  String? _networkImageUrl;

  @override
  void initState() {
    super.initState();
    phoneController.text = "+92";
    phoneController.addListener(() {
      if (!phoneController.text.startsWith("+92")) {
        phoneController.value = const TextEditingValue(
          text: "+92",
          selection: TextSelection.collapsed(offset: 3),
        );
      }
    });
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
          onPressed: () => Navigator.pop(
            context,
          ), // Yahan se back directly Selection Screen pe le jayega
        ),
        title: Text(
          "Personal Information",
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
                                        : (_networkImageUrl != null &&
                                              _networkImageUrl!.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              _networkImageUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      (_imageFile == null &&
                                          (_networkImageUrl == null ||
                                              _networkImageUrl!.isEmpty))
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
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          label: "City",
                          hint: "Select your city",
                          controller: cityController,
                          isDropdown: true,
                          readOnly: true,
                          onTap: _showCitySearchBottomSheet,
                        ),

                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Phone number",
                          hint: "92**********99",
                          controller: phoneController,
                          isPhone: true,
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {},
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
                                      widget.isEditMode
                                          ? "Update"
                                          : "Next", // Yahan text dynamic ho gaya
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

  // Custom Input Field Builder
  Widget _buildInputField({
    required String label,
    required String hint,
    bool isDropdown = false,
    bool isPhone = false,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              enabled: onTap == null,
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
              inputFormatters: isPhone
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
                  : [],
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(color: Colors.black38),
                suffixIcon: isDropdown
                    ? const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

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

  void _showCitySearchBottomSheet() {
    List<String> filteredCities = List.from(pakistaniCities);

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
                    "Select City",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search your city...",
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
                        filteredCities = pakistaniCities
                            .where(
                              (city) => city.toLowerCase().contains(
                                value.toLowerCase(),
                              ),
                            )
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            filteredCities[index],
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          onTap: () {
                            setState(() {
                              cityController.text = filteredCities[index];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

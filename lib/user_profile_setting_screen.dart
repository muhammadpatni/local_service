// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:image_cropper/image_cropper.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:local_service/home_page.dart'; // Apna sahi path daliyega

// // class UserProfileSettingsScreen extends StatefulWidget {
// //   final String? emailnumber;
// //   const UserProfileSettingsScreen({super.key, required this.emailnumber});

// //   @override
// //   State<UserProfileSettingsScreen> createState() =>
// //       _UserProfileSettingsScreenState();
// // }

// // class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
// //   final Color primaryBlue = const Color(0xFF0E6BBB);
// //   final Color fieldColor = const Color(0xFFF1F4F8);

// //   // Naye Controllers Name aur City ke liye add kiye hain
// //   TextEditingController nameController = TextEditingController();
// //   TextEditingController cityController = TextEditingController();
// //   TextEditingController phoneController = TextEditingController();
// //   TextEditingController emailController = TextEditingController();

// //   bool isPhoneReadOnly = false;
// //   bool isEmailReadOnly = false;
// //   bool _isLoading = false; // Next button ke loader ke liye

// //   File? _imageFile; // Cropped image ko yahan store karenge

// //   @override
// //   void dispose() {
// //     phoneController.removeListener(_phoneListener);
// //     nameController.dispose();
// //     cityController.dispose();
// //     phoneController.dispose();
// //     emailController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   void initState() {
// //     super.initState();

// //     String? value = widget.emailnumber;

// //     if (value != null && value.startsWith("+92")) {
// //       phoneController.text = value;
// //       isPhoneReadOnly = true;
// //     } else {
// //       phoneController.text = "+92";
// //       phoneController.addListener(_phoneListener);
// //     }

// //     if (value != null && !value.startsWith("+92")) {
// //       emailController.text = value;
// //       isEmailReadOnly = true;
// //     }
// //   }

// //   void _phoneListener() {
// //     String text = phoneController.text;
// //     if (!text.startsWith("+92")) {
// //       phoneController.value = const TextEditingValue(
// //         text: "+92",
// //         selection: TextSelection.collapsed(offset: 3),
// //       );
// //     }
// //   }

// //   // Bottom sheet to choose Camera or Gallery
// //   void _showImagePickerOptions() {
// //     showModalBottomSheet(
// //       context: context,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (BuildContext context) {
// //         return SafeArea(
// //           child: Wrap(
// //             children: <Widget>[
// //               ListTile(
// //                 leading: Icon(Icons.photo_library, color: primaryBlue),
// //                 title: const Text('Gallery'),
// //                 onTap: () {
// //                   _pickAndCropImage(ImageSource.gallery);
// //                   Navigator.of(context).pop();
// //                 },
// //               ),
// //               ListTile(
// //                 leading: Icon(Icons.photo_camera, color: primaryBlue),
// //                 title: const Text('Camera'),
// //                 onTap: () {
// //                   _pickAndCropImage(ImageSource.camera);
// //                   Navigator.of(context).pop();
// //                 },
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // Image Pick & Crop logic
// //   Future<void> _pickAndCropImage(ImageSource source) async {
// //     final picker = ImagePicker();
// //     final pickedFile = await picker.pickImage(source: source);
// //     if (pickedFile == null) return;

// //     // Cropping the image into a perfect square
// //     CroppedFile? croppedFile = await ImageCropper().cropImage(
// //       sourcePath: pickedFile.path,
// //       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
// //       compressQuality: 80,
// //       uiSettings: [
// //         AndroidUiSettings(
// //           toolbarTitle: 'Crop Profile Picture',
// //           toolbarColor: primaryBlue,
// //           toolbarWidgetColor: Colors.white,
// //           initAspectRatio: CropAspectRatioPreset.square,
// //           lockAspectRatio: true,
// //         ),
// //         IOSUiSettings(
// //           title: 'Crop Profile Picture',
// //           aspectRatioLockEnabled: true,
// //         ),
// //       ],
// //     );

// //     if (croppedFile != null) {
// //       setState(() {
// //         _imageFile = File(croppedFile.path);
// //       });
// //     }
// //   }

// //   // Save to ImgBB and Firestore, then Navigate
// //   Future<void> _saveDataAndNavigate() async {
// //     // Agar validations lagani hain toh yahan laga sakte hain
// //     if (nameController.text.isEmpty) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text("Name is required!")));
// //       return;
// //     }

// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       String imageUrl = '';

// //       // 1. Upload Image to ImgBB (agar image select ki hai)
// //       if (_imageFile != null) {
// //         Uint8List bytes = await _imageFile!.readAsBytes();
// //         var request = http.MultipartRequest(
// //           'POST',
// //           Uri.parse(
// //             'https://api.imgbb.com/1/upload?key=c4df1e7a32e0eb9b38207de2b70fb210',
// //           ),
// //         );
// //         request.files.add(
// //           http.MultipartFile.fromBytes('image', bytes, filename: 'profile.jpg'),
// //         );
// //         var response = await request.send();
// //         var respStr = await response.stream.bytesToString();
// //         var jsonResp = json.decode(respStr);

// //         if (jsonResp['status'] == 200) {
// //           imageUrl = jsonResp['data']['url'];
// //         }
// //       }

// //       // 2. Save Data to Firestore
// //       final user = FirebaseAuth.instance.currentUser;

// //       // Agar user login hai to uski UID use karein, warna naya document id generate karein
// //       String docId =
// //           user?.uid ?? FirebaseFirestore.instance.collection('users').doc().id;

// //       await FirebaseFirestore.instance.collection('users').doc(docId).set(
// //         {
// //           'name': nameController.text.trim(),
// //           'email': emailController.text.trim(),
// //           'city': cityController.text.trim(),
// //           'phone': phoneController.text.trim(),
// //           'profileImage': imageUrl,
// //           'createdAt': FieldValue.serverTimestamp(),
// //         },
// //         SetOptions(merge: true),
// //       ); // merge: true se existing data overwrite nahi hoga

// //       // 3. Navigate to HomePage
// //       if (mounted) {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => const MyHomePage()),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("Error saving profile: $e"),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: Text(
// //           "Profile settings",
// //           style: GoogleFonts.poppins(
// //             color: Colors.black,
// //             fontSize: 18,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         centerTitle: true,
// //       ),
// //       body: SafeArea(
// //         child: LayoutBuilder(
// //           builder: (context, constraints) {
// //             return SingleChildScrollView(
// //               physics: const BouncingScrollPhysics(),
// //               child: ConstrainedBox(
// //                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
// //                 child: IntrinsicHeight(
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
// //                     child: Column(
// //                       children: [
// //                         const SizedBox(height: 20),

// //                         // 1. Profile Image Section (Updated with GestureDetector)
// //                         Center(
// //                           child: GestureDetector(
// //                             onTap: _showImagePickerOptions,
// //                             child: Stack(
// //                               children: [
// //                                 Container(
// //                                   height: 120,
// //                                   width: 120,
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.grey[200],
// //                                     shape: BoxShape.circle,
// //                                     image: _imageFile != null
// //                                         ? DecorationImage(
// //                                             image: FileImage(_imageFile!),
// //                                             fit: BoxFit.cover,
// //                                           )
// //                                         : null,
// //                                   ),
// //                                   child: _imageFile == null
// //                                       ? const Icon(
// //                                           Icons.person,
// //                                           size: 80,
// //                                           color: Colors.grey,
// //                                         )
// //                                       : null,
// //                                 ),
// //                                 Positioned(
// //                                   bottom: 0,
// //                                   right: 0,
// //                                   child: Container(
// //                                     padding: const EdgeInsets.all(4),
// //                                     decoration: const BoxDecoration(
// //                                       color: Color(0xFF0E6BBB),
// //                                       shape: BoxShape.circle,
// //                                     ),
// //                                     child: const Icon(
// //                                       Icons.add,
// //                                       size: 24,
// //                                       color: Colors.white,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),

// //                         const SizedBox(height: 30),

// //                         // 2. Input Fields (Added controllers for Name and City)
// //                         _buildInputField(
// //                           label: "Name",
// //                           hint: "Ahmed",
// //                           controller: nameController,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildInputField(
// //                           label: "Email",
// //                           hint: "example@mail.com",
// //                           controller: emailController,
// //                           readOnly: isEmailReadOnly,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildInputField(
// //                           label: "City",
// //                           hint: "Karachi",
// //                           controller: cityController, // Controller mapped
// //                           readOnly: false,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildInputField(
// //                           label: "Phone number",
// //                           hint: "92**********99",
// //                           controller: phoneController,
// //                           readOnly: isPhoneReadOnly,
// //                           isPhone: true,
// //                         ),

// //                         const Spacer(),

// //                         // 3. Next/Save Button (Updated with logic)
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 20),
// //                           child: SizedBox(
// //                             width: double.infinity,
// //                             height: 56,
// //                             child: ElevatedButton(
// //                               onPressed: _isLoading
// //                                   ? null
// //                                   : _saveDataAndNavigate,
// //                               style: ElevatedButton.styleFrom(
// //                                 backgroundColor: primaryBlue,
// //                                 elevation: 0,
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius: BorderRadius.circular(16),
// //                                 ),
// //                               ),
// //                               child: _isLoading
// //                                   ? const CircularProgressIndicator(
// //                                       color: Colors.white,
// //                                     )
// //                                   : Text(
// //                                       "Next",
// //                                       style: GoogleFonts.poppins(
// //                                         fontSize: 18,
// //                                         fontWeight: FontWeight.w600,
// //                                         color: Colors.white,
// //                                       ),
// //                                     ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // Reusable Input Field Widget (No major changes here)
// //   Widget _buildInputField({
// //     required String label,
// //     required String hint,
// //     bool isDropdown = false,
// //     bool isPhone = false,
// //     TextEditingController? controller,
// //     bool readOnly = false,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.only(left: 4, bottom: 8),
// //           child: Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               fontSize: 14,
// //               color: Colors.black54,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //         ),
// //         Container(
// //           decoration: BoxDecoration(
// //             color: fieldColor,
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: TextField(
// //             controller: controller,
// //             readOnly: readOnly || isDropdown,
// //             keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
// //             inputFormatters: isPhone
// //                 ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
// //                 : [],
// //             style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
// //             decoration: InputDecoration(
// //               hintText: hint,
// //               hintStyle: GoogleFonts.poppins(color: Colors.black38),
// //               suffixIcon: isDropdown
// //                   ? const Icon(Icons.chevron_right, color: Colors.black54)
// //                   : null,
// //               contentPadding: const EdgeInsets.symmetric(
// //                 horizontal: 16,
// //                 vertical: 16,
// //               ),
// //               border: InputBorder.none,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:http/http.dart' as http;
// import 'package:local_service/home_page.dart'; // Apna sahi path daliyega

// class UserProfileSettingsScreen extends StatefulWidget {
//   final String? emailnumber;
//   const UserProfileSettingsScreen({super.key, required this.emailnumber});

//   @override
//   State<UserProfileSettingsScreen> createState() =>
//       _UserProfileSettingsScreenState();
// }

// class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
//   final Color primaryBlue = const Color(0xFF0E6BBB);
//   final Color fieldColor = const Color(0xFFF1F4F8);

//   TextEditingController nameController = TextEditingController();
//   TextEditingController cityController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();

//   bool isPhoneReadOnly = false;
//   bool isEmailReadOnly = false;
//   bool _isLoading = false;

//   File? _imageFile;

//   // City ki list (Aap ismein mazeed cities add kar sakte hain)
//   final List<String> pakistaniCities = [
//     "Karachi",
//     "Lahore",
//     "Islamabad",
//     "Rawalpindi",
//     "Faisalabad",
//     "Multan",
//     "Peshawar",
//     "Quetta",
//     "Gujranwala",
//     "Sialkot",
//     "Hyderabad",
//     "Sukkur",
//     "Larkana",
//     "Nawabshah",
//     "Mirpur Khas",
//     "Abbottabad",
//     "Bahawalpur",
//     "Sargodha",
//     "Sahiwal",
//     "Jhang",
//   ];

//   @override
//   void dispose() {
//     phoneController.removeListener(_phoneListener);
//     nameController.dispose();
//     cityController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();

//     String? value = widget.emailnumber;

//     if (value != null && value.startsWith("+92")) {
//       phoneController.text = value;
//       isPhoneReadOnly = true;
//     } else {
//       phoneController.text = "+92";
//       phoneController.addListener(_phoneListener);
//     }

//     if (value != null && !value.startsWith("+92")) {
//       emailController.text = value;
//       isEmailReadOnly = true;
//     }
//   }

//   void _phoneListener() {
//     String text = phoneController.text;
//     if (!text.startsWith("+92")) {
//       phoneController.value = const TextEditingValue(
//         text: "+92",
//         selection: TextSelection.collapsed(offset: 3),
//       );
//     }
//   }

//   void _showImagePickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: Icon(Icons.photo_library, color: primaryBlue),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   _pickAndCropImage(ImageSource.gallery);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_camera, color: primaryBlue),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   _pickAndCropImage(ImageSource.camera);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // City Searchable BottomSheet
//   void _showCitySearchBottomSheet() {
//     List<String> filteredCities = List.from(pakistaniCities);

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//                 top: 20,
//                 left: 20,
//                 right: 20,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Select City",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search your city...",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: fieldColor,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       setModalState(() {
//                         filteredCities = pakistaniCities
//                             .where(
//                               (city) => city.toLowerCase().contains(
//                                 value.toLowerCase(),
//                               ),
//                             )
//                             .toList();
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height:
//                         300, // List ki height limit ki hai taake scroll ho sake
//                     child: ListView.builder(
//                       itemCount: filteredCities.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(
//                             filteredCities[index],
//                             style: GoogleFonts.poppins(fontSize: 16),
//                           ),
//                           onTap: () {
//                             setState(() {
//                               cityController.text = filteredCities[index];
//                             });
//                             Navigator.pop(context);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _pickAndCropImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);
//     if (pickedFile == null) return;

//     CroppedFile? croppedFile = await ImageCropper().cropImage(
//       sourcePath: pickedFile.path,
//       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//       compressQuality: 80,
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Crop Profile Picture',
//           toolbarColor: primaryBlue,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.square,
//           lockAspectRatio: true,
//         ),
//         IOSUiSettings(
//           title: 'Crop Profile Picture',
//           aspectRatioLockEnabled: true,
//         ),
//       ],
//     );

//     if (croppedFile != null) {
//       setState(() {
//         _imageFile = File(croppedFile.path);
//       });
//     }
//   }

//   Future<void> _saveDataAndNavigate() async {
//     // 1. Validation Logic: Check if any required field is empty
//     if (nameController.text.trim().isEmpty ||
//         emailController.text.trim().isEmpty ||
//         cityController.text.trim().isEmpty ||
//         phoneController.text.trim().isEmpty ||
//         phoneController.text.trim() == "+92") {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("All fields are required! Please fill them."),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return; // Data save nahi hoga yahan se waapis return ho jayega
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String imageUrl = '';

//       if (_imageFile != null) {
//         Uint8List bytes = await _imageFile!.readAsBytes();
//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse(
//             'https://api.imgbb.com/1/upload?key=c4df1e7a32e0eb9b38207de2b70fb210',
//           ),
//         );
//         request.files.add(
//           http.MultipartFile.fromBytes('image', bytes, filename: 'profile.jpg'),
//         );
//         var response = await request.send();
//         var respStr = await response.stream.bytesToString();
//         var jsonResp = json.decode(respStr);

//         if (jsonResp['status'] == 200) {
//           imageUrl = jsonResp['data']['url'];
//         }
//       }

//       final user = FirebaseAuth.instance.currentUser;
//       String docId =
//           user?.uid ?? FirebaseFirestore.instance.collection('users').doc().id;

//       await FirebaseFirestore.instance.collection('users').doc(docId).set({
//         'name': nameController.text.trim(),
//         'email': emailController.text.trim(),
//         'city': cityController.text.trim(),
//         'phone': phoneController.text.trim(),
//         'profileImage': imageUrl,
//         'createdAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const MyHomePage()),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving profile: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Profile settings",
//           style: GoogleFonts.poppins(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: IntrinsicHeight(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 20),

//                         Center(
//                           child: GestureDetector(
//                             onTap: _showImagePickerOptions,
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   height: 120,
//                                   width: 120,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     shape: BoxShape.circle,
//                                     image: _imageFile != null
//                                         ? DecorationImage(
//                                             image: FileImage(_imageFile!),
//                                             fit: BoxFit.cover,
//                                           )
//                                         : null,
//                                   ),
//                                   child: _imageFile == null
//                                       ? const Icon(
//                                           Icons.person,
//                                           size: 80,
//                                           color: Colors.grey,
//                                         )
//                                       : null,
//                                 ),
//                                 Positioned(
//                                   bottom: 0,
//                                   right: 0,
//                                   child: Container(
//                                     padding: const EdgeInsets.all(4),
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFF0E6BBB),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.add,
//                                       size: 24,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 30),

//                         _buildInputField(
//                           label: "Name",
//                           hint: "Ahmed",
//                           controller: nameController,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           label: "Email",
//                           hint: "example@mail.com",
//                           controller: emailController,
//                           readOnly: isEmailReadOnly,
//                         ),
//                         const SizedBox(height: 16),

//                         // City field with onTap for Search
//                         _buildInputField(
//                           label: "City",
//                           hint: "Select your city",
//                           controller: cityController,
//                           isDropdown: true,
//                           readOnly:
//                               true, // Type nahi kar sakte, list se select karna hoga
//                           onTap: _showCitySearchBottomSheet,
//                         ),

//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           label: "Phone number",
//                           hint: "92**********99",
//                           controller: phoneController,
//                           readOnly: isPhoneReadOnly,
//                           isPhone: true,
//                         ),

//                         const Spacer(),

//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 20),
//                           child: SizedBox(
//                             width: double.infinity,
//                             height: 56,
//                             child: ElevatedButton(
//                               onPressed: _isLoading
//                                   ? null
//                                   : _saveDataAndNavigate,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: primaryBlue,
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                               ),
//                               child: _isLoading
//                                   ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     )
//                                   : Text(
//                                       "Next",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // Reusable Input Field Widget updated with onTap
//   Widget _buildInputField({
//     required String label,
//     required String hint,
//     bool isDropdown = false,
//     bool isPhone = false,
//     TextEditingController? controller,
//     bool readOnly = false,
//     VoidCallback? onTap, // OnTap property add ki gayi hai
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4, bottom: 8),
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black54,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: onTap, // Agar onTap available hai to trigger hoga
//           child: Container(
//             decoration: BoxDecoration(
//               color: fieldColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: TextField(
//               controller: controller,
//               readOnly: readOnly,
//               enabled:
//                   onTap ==
//                   null, // Agar onTap hai to default keyboard disable karein
//               keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
//               inputFormatters: isPhone
//                   ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
//                   : [],
//               style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: GoogleFonts.poppins(color: Colors.black38),
//                 suffixIcon: isDropdown
//                     ? const Icon(
//                         Icons.keyboard_arrow_down,
//                         color: Colors.black54,
//                       )
//                     : null,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:http/http.dart' as http;
// import 'package:local_service/home_page.dart'; // Apna sahi path daliyega

// class UserProfileSettingsScreen extends StatefulWidget {
//   final String? emailnumber;
//   const UserProfileSettingsScreen({super.key, required this.emailnumber});

//   @override
//   State<UserProfileSettingsScreen> createState() =>
//       _UserProfileSettingsScreenState();
// }

// class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
//   final Color primaryBlue = const Color(0xFF0E6BBB);
//   final Color fieldColor = const Color(0xFFF1F4F8);

//   TextEditingController nameController = TextEditingController();
//   TextEditingController cityController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();

//   bool isPhoneReadOnly = false;
//   bool isEmailReadOnly = false;
//   bool _isLoading = false;

//   File? _imageFile;

//   // City ki list (Aap ismein mazeed cities add kar sakte hain)
//   final List<String> pakistaniCities = [
//     "Karachi",
//     "Lahore",
//     "Islamabad",
//     "Rawalpindi",
//     "Faisalabad",
//     "Multan",
//     "Peshawar",
//     "Quetta",
//     "Gujranwala",
//     "Sialkot",
//     "Hyderabad",
//     "Sukkur",
//     "Larkana",
//     "Nawabshah",
//     "Mirpur Khas",
//     "Abbottabad",
//     "Bahawalpur",
//     "Sargodha",
//     "Sahiwal",
//     "Jhang",
//   ];

//   @override
//   void dispose() {
//     phoneController.removeListener(_phoneListener);
//     nameController.dispose();
//     cityController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();

//     String? value = widget.emailnumber;

//     if (value != null && value.startsWith("+92")) {
//       phoneController.text = value;
//       isPhoneReadOnly = true;
//     } else {
//       phoneController.text = "+92";
//       phoneController.addListener(_phoneListener);
//     }

//     if (value != null && !value.startsWith("+92")) {
//       emailController.text = value;
//       isEmailReadOnly = true;
//     }
//   }

//   void _phoneListener() {
//     String text = phoneController.text;
//     if (!text.startsWith("+92")) {
//       phoneController.value = const TextEditingValue(
//         text: "+92",
//         selection: TextSelection.collapsed(offset: 3),
//       );
//     }
//   }

//   void _showImagePickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: Icon(Icons.photo_library, color: primaryBlue),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   _pickAndCropImage(ImageSource.gallery);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_camera, color: primaryBlue),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   _pickAndCropImage(ImageSource.camera);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // City Searchable BottomSheet
//   void _showCitySearchBottomSheet() {
//     List<String> filteredCities = List.from(pakistaniCities);

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//                 top: 20,
//                 left: 20,
//                 right: 20,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Select City",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search your city...",
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: fieldColor,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       setModalState(() {
//                         filteredCities = pakistaniCities
//                             .where(
//                               (city) => city.toLowerCase().contains(
//                                 value.toLowerCase(),
//                               ),
//                             )
//                             .toList();
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height:
//                         300, // List ki height limit ki hai taake scroll ho sake
//                     child: ListView.builder(
//                       itemCount: filteredCities.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(
//                             filteredCities[index],
//                             style: GoogleFonts.poppins(fontSize: 16),
//                           ),
//                           onTap: () {
//                             setState(() {
//                               cityController.text = filteredCities[index];
//                             });
//                             Navigator.pop(context);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _pickAndCropImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);
//     if (pickedFile == null) return;

//     CroppedFile? croppedFile = await ImageCropper().cropImage(
//       sourcePath: pickedFile.path,
//       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//       compressQuality: 80,
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Crop Profile Picture',
//           toolbarColor: primaryBlue,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.square,
//           lockAspectRatio: true,
//         ),
//         IOSUiSettings(
//           title: 'Crop Profile Picture',
//           aspectRatioLockEnabled: true,
//         ),
//       ],
//     );

//     if (croppedFile != null) {
//       setState(() {
//         _imageFile = File(croppedFile.path);
//       });
//     }
//   }

//   Future<void> _saveDataAndNavigate() async {
//     // 1. Validation Logic: Check if any required field is empty
//     if (nameController.text.trim().isEmpty ||
//         emailController.text.trim().isEmpty ||
//         cityController.text.trim().isEmpty ||
//         phoneController.text.trim().isEmpty ||
//         phoneController.text.trim() == "+92") {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("All fields are required! Please fill them."),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return; // Data save nahi hoga yahan se waapis return ho jayega
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String imageUrl = '';

//       if (_imageFile != null) {
//         Uint8List bytes = await _imageFile!.readAsBytes();
//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse(
//             'https://api.imgbb.com/1/upload?key=c4df1e7a32e0eb9b38207de2b70fb210',
//           ),
//         );
//         request.files.add(
//           http.MultipartFile.fromBytes('image', bytes, filename: 'profile.jpg'),
//         );
//         var response = await request.send();
//         var respStr = await response.stream.bytesToString();
//         var jsonResp = json.decode(respStr);

//         if (jsonResp['status'] == 200) {
//           imageUrl = jsonResp['data']['url'];
//         }
//       }

//       final user = FirebaseAuth.instance.currentUser;
//       String docId =
//           user?.uid ?? FirebaseFirestore.instance.collection('users').doc().id;

//       await FirebaseFirestore.instance.collection('users').doc(docId).set({
//         'name': nameController.text.trim(),
//         'email': emailController.text.trim(),
//         'city': cityController.text.trim(),
//         'phone': phoneController.text.trim(),
//         'profileImage': imageUrl,
//         'createdAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const MyHomePage()),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving profile: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Profile settings",
//           style: GoogleFonts.poppins(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: IntrinsicHeight(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 20),

//                         Center(
//                           child: GestureDetector(
//                             onTap: _showImagePickerOptions,
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   height: 120,
//                                   width: 120,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     shape: BoxShape.circle,
//                                     image: _imageFile != null
//                                         ? DecorationImage(
//                                             image: FileImage(_imageFile!),
//                                             fit: BoxFit.cover,
//                                           )
//                                         : null,
//                                   ),
//                                   child: _imageFile == null
//                                       ? const Icon(
//                                           Icons.person,
//                                           size: 80,
//                                           color: Colors.grey,
//                                         )
//                                       : null,
//                                 ),
//                                 Positioned(
//                                   bottom: 0,
//                                   right: 0,
//                                   child: Container(
//                                     padding: const EdgeInsets.all(4),
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFF0E6BBB),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.add,
//                                       size: 24,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 30),

//                         _buildInputField(
//                           label: "Name",
//                           hint: "Ahmed",
//                           controller: nameController,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           label: "Email",
//                           hint: "example@mail.com",
//                           controller: emailController,
//                           readOnly: isEmailReadOnly,
//                         ),
//                         const SizedBox(height: 16),

//                         // City field with onTap for Search
//                         _buildInputField(
//                           label: "City",
//                           hint: "Select your city",
//                           controller: cityController,
//                           isDropdown: true,
//                           readOnly:
//                               true, // Type nahi kar sakte, list se select karna hoga
//                           onTap: _showCitySearchBottomSheet,
//                         ),

//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           label: "Phone number",
//                           hint: "92**********99",
//                           controller: phoneController,
//                           readOnly: isPhoneReadOnly,
//                           isPhone: true,
//                         ),

//                         const Spacer(),

//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 20),
//                           child: SizedBox(
//                             width: double.infinity,
//                             height: 56,
//                             child: ElevatedButton(
//                               onPressed: _isLoading
//                                   ? null
//                                   : _saveDataAndNavigate,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: primaryBlue,
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                               ),
//                               child: _isLoading
//                                   ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     )
//                                   : Text(
//                                       "Next",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // Reusable Input Field Widget updated with onTap
//   Widget _buildInputField({
//     required String label,
//     required String hint,
//     bool isDropdown = false,
//     bool isPhone = false,
//     TextEditingController? controller,
//     bool readOnly = false,
//     VoidCallback? onTap, // OnTap property add ki gayi hai
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4, bottom: 8),
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black54,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: onTap, // Agar onTap available hai to trigger hoga
//           child: Container(
//             decoration: BoxDecoration(
//               color: fieldColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: TextField(
//               controller: controller,
//               readOnly: readOnly,
//               enabled:
//                   onTap ==
//                   null, // Agar onTap hai to default keyboard disable karein
//               keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
//               inputFormatters: isPhone
//                   ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
//                   : [],
//               style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: GoogleFonts.poppins(color: Colors.black38),
//                 suffixIcon: isDropdown
//                     ? const Icon(
//                         Icons.keyboard_arrow_down,
//                         color: Colors.black54,
//                       )
//                     : null,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:local_service/home_page.dart';

class UserProfileSettingsScreen extends StatefulWidget {
  final String? emailnumber;
  final bool isEditMode; // Naya parameter
  const UserProfileSettingsScreen({
    super.key,
    required this.emailnumber,
    this.isEditMode = false, // Default false rakha hai
  });

  @override
  State<UserProfileSettingsScreen> createState() =>
      _UserProfileSettingsScreenState();
}

class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  final Color fieldColor = const Color(0xFFF1F4F8);
  String? _networkImageUrl; // Naya variable purani pic ke liye

  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isPhoneReadOnly = false;
  bool isEmailReadOnly = false;
  bool _isLoading = false;

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
    "Hyderabad",
    "Sukkur",
    "Larkana",
    "Nawabshah",
    "Mirpur Khas",
    "Abbottabad",
    "Bahawalpur",
    "Sargodha",
    "Sahiwal",
    "Jhang",
  ];

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

    // 1. Phone/Email Fields setup logic
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

    // 2. Load Existing Data sirf tab jab Edit Mode ho
    if (widget.isEditMode) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
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
            cityController.text = data['city'] ?? '';
            // Agar database mein email hai toh wahan se lo
            if (data['email'] != null && data['email'] != "") {
              emailController.text = data['email'];
            } else {
              // Warna jo FirebaseAuth mein email hai wo dikhao
              emailController.text = user.email ?? '';
            }
            if (data['phone'] != null && data['phone'] != "") {
              phoneController.text = data['phone'];
            } else {
              // Warna jo FirebaseAuth mein phone hai wo dikhao
              phoneController.text = user.phoneNumber ?? '';
            }
            _networkImageUrl = data['profileImage']; // Purani pic ka URL
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Build method mein Profile Image wala Container update karein:

  void _phoneListener() {
    String text = phoneController.text;
    if (!text.startsWith("+92")) {
      phoneController.value = const TextEditingValue(
        text: "+92",
        selection: TextSelection.collapsed(offset: 3),
      );
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

  Future<void> _saveDataAndNavigate() async {
    // 1. Validation Logic
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        phoneController.text.trim() == "+92") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields are required! Please fill them."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Shuru mein finalUrl ko purani network image ke barabar rakhein
      String finalImageUrl = _networkImageUrl ?? '';

      // 2. Image Upload Logic (Sirf tab chalega jab user nayi pic pick karega)
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
          finalImageUrl =
              jsonResp['data']['url']; // Naya link yahan update ho gaya
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 3. Database Update
      Map<String, dynamic> userData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'city': cityController.text.trim(),
        'phone': phoneController.text.trim(),
        'profileImage':
            finalImageUrl, // Purani image rahegi agar nayi upload nahi hui
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Agar naya user hai (Edit Mode nahi hai), toh createdAt bhi add karein
      if (!widget.isEditMode) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      // 4. Navigation Logic
      if (mounted) {
        if (widget.isEditMode) {
          // Agar edit mode se aaye thay toh wapis drawer/profile par chale jao
          Navigator.pop(context);
        } else {
          // Agar pehli baar setup ho raha hai toh Home par jao
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> _saveDataAndNavigate() async {
  //   // 1. Validation Logic: Check if any required field is empty
  //   if (nameController.text.trim().isEmpty ||
  //       emailController.text.trim().isEmpty ||
  //       cityController.text.trim().isEmpty ||
  //       phoneController.text.trim().isEmpty ||
  //       phoneController.text.trim() == "+92") {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("All fields are required! Please fill them."),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return; // Data save nahi hoga yahan se waapis return ho jayega
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     String imageUrl = '';

  //     if (_imageFile != null) {
  //       Uint8List bytes = await _imageFile!.readAsBytes();
  //       var request = http.MultipartRequest(
  //         'POST',
  //         Uri.parse(
  //           'https://api.imgbb.com/1/upload?key=c4df1e7a32e0eb9b38207de2b70fb210',
  //         ),
  //       );
  //       request.files.add(
  //         http.MultipartFile.fromBytes('image', bytes, filename: 'profile.jpg'),
  //       );
  //       var response = await request.send();
  //       var respStr = await response.stream.bytesToString();
  //       var jsonResp = json.decode(respStr);

  //       if (jsonResp['status'] == 200) {
  //         imageUrl = jsonResp['data']['url'];
  //       }
  //     }

  //     final user = FirebaseAuth.instance.currentUser;
  //     String docId =
  //         user?.uid ?? FirebaseFirestore.instance.collection('users').doc().id;

  //     await FirebaseFirestore.instance.collection('users').doc(docId).set({
  //       'name': nameController.text.trim(),
  //       'email': emailController.text.trim(),
  //       'city': cityController.text.trim(),
  //       'phone': phoneController.text.trim(),
  //       'profileImage': imageUrl,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     }, SetOptions(merge: true));

  //     if (mounted) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const MyHomePage()),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Error saving profile: $e"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

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
                          readOnly: isEmailReadOnly,
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
                          readOnly: isPhoneReadOnly,
                          isPhone: true,
                        ),

                        const Spacer(),

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
}

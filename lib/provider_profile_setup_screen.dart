import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:local_service/provider_documents_screen.dart';
import 'package:local_service/services_data.dart';

class ProviderProfileSetupScreen extends StatefulWidget {
  const ProviderProfileSetupScreen({super.key});

  @override
  State<ProviderProfileSetupScreen> createState() =>
      _ProviderProfileSetupScreenState();
}

class _ProviderProfileSetupScreenState
    extends State<ProviderProfileSetupScreen> {
  final Color primaryBlue = const Color(0xFF0E6BBB);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();

  File? _profileImage;
  String? _existingProfileUrl;
  List<String> _selectedServices = [];

  bool _isLoading = false;
  bool _isDataLoading = true;

  bool _isEmailLogin = false;
  bool _hasPhoneFromAuth = false;

  // ImgBB API Key — same as user profile
  static const String _imgbbApiKey = 'c4df1e7a32e0eb9b38207de2b70fb210';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isDataLoading = false);
      return;
    }

    if (user.email != null && user.email!.isNotEmpty) {
      _isEmailLogin = true;
      _emailController.text = user.email!;
    }
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      _hasPhoneFromAuth = true;
      _phoneController.text = user.phoneNumber!;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        if (_nameController.text.isEmpty) {
          _nameController.text = data['name'] ?? '';
        }
        if (!_isEmailLogin && (data['email'] ?? '').isNotEmpty) {
          _emailController.text = data['email'];
        }
        _existingProfileUrl = data['profileImage'] ?? data['photoUrl'];
      }

      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .get();

      if (providerDoc.exists) {
        final pData = providerDoc.data()!;
        _experienceController.text = pData['experience']?.toString() ?? '';
        if (pData['services'] != null) {
          _selectedServices = List<String>.from(pData['services']);
        }
        if (pData['profilePic'] != null) {
          _existingProfileUrl = pData['profilePic'];
        }
        if (!_isEmailLogin && (pData['email'] ?? '').isNotEmpty) {
          _emailController.text = pData['email'];
        }
      }
    } catch (e) {
      debugPrint('Data load error: $e');
    }

    setState(() => _isDataLoading = false);
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  // ─── ImgBB Upload Helper ───
  Future<String> _uploadToImgBB(File imageFile, String filename) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: filename),
    );
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final jsonResp = json.decode(respStr);

    if (jsonResp['status'] == 200) {
      return jsonResp['data']['url'] as String;
    }
    throw Exception(
      'ImgBB upload failed: ${jsonResp['error'] ?? 'Unknown error'}',
    );
  }

  void _showServicesSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServicesBottomSheet(
        selected: _selectedServices,
        onChanged: (services) => setState(() => _selectedServices = services),
      ),
    );
  }

  Future<void> _onContinue() async {
    if (_profileImage == null && _existingProfileUrl == null) {
      _showSnack("Profile picture upload karna zaroor hai");
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showSnack("Naam zaroor likhein");
      return;
    }
    if (_experienceController.text.trim().isEmpty) {
      _showSnack("Experience likhna zaroor hai");
      return;
    }
    if (_selectedServices.isEmpty) {
      _showSnack("Kam az kam ek service select karein");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      String profileUrl = _existingProfileUrl ?? '';

      // ─── ImgBB pe profile pic upload ───
      if (_profileImage != null) {
        profileUrl = await _uploadToImgBB(
          _profileImage!,
          'provider_profile_${user.uid}.jpg',
        );
      }

      await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'experience': _experienceController.text.trim(),
            'services': _selectedServices,
            'profilePic': profileUrl,
            'isVerified': false,
            'setupStep': 'profile',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProviderDocumentsScreen()),
      );
    } catch (e) {
      _showSnack("Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.poppins())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Provider Setup",
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isDataLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      _buildProgressBar(step: 1),
                      const SizedBox(height: 6),
                      Text(
                        "Step 1 of 3 — Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── Profile Picture ───
                      Center(
                        child: GestureDetector(
                          onTap: _pickProfileImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryBlue,
                                    width: 2.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : _existingProfileUrl != null
                                      ? Image.network(
                                          _existingProfileUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: const Color(0xFFF0F4FF),
                                          child: Icon(
                                            Icons.person,
                                            size: 60,
                                            color: primaryBlue,
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Profile Picture (Zaroor) *",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ─── Personal Info ───
                      _sectionTitle("Personal Information"),
                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _nameController,
                        label: "Full Name *",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _phoneController,
                        label: "Contact Number",
                        icon: Icons.phone_outlined,
                        readOnly: _hasPhoneFromAuth,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _emailController,
                        label: "Email ${_isEmailLogin ? '*' : '(Optional)'}",
                        icon: Icons.email_outlined,
                        readOnly: _isEmailLogin,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 28),

                      // ─── Professional Info ───
                      _sectionTitle("Professional Information"),
                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _experienceController,
                        label: "Years of Experience *",
                        icon: Icons.work_history_outlined,
                        keyboardType: TextInputType.number,
                        hint: "e.g. 5",
                      ),
                      const SizedBox(height: 14),

                      // Services Multi-Select
                      GestureDetector(
                        onTap: _showServicesSelector,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.build_outlined,
                                color: primaryBlue,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Service Types * (Max 3)",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _selectedServices.isEmpty
                                        ? Text(
                                            "Apni services select karein",
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[400],
                                              fontSize: 15,
                                            ),
                                          )
                                        : Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: _selectedServices
                                                .map(
                                                  (s) => Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: primaryBlue
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      s,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: primaryBlue,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Continue →",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),

                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: primaryBlue),
                          const SizedBox(height: 16),
                          Text(
                            "Profile save ho raha hai...",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
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

  Widget _buildProgressBar({required int step}) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            height: 5,
            decoration: BoxDecoration(
              color: i < step ? primaryBlue : Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF2F2F2) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: readOnly ? Colors.grey[600] : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: primaryBlue, fontSize: 13),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: primaryBlue, size: 22),
          border: InputBorder.none,
          suffixIcon: readOnly
              ? Icon(Icons.lock_outline, size: 15, color: Colors.grey[400])
              : null,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Services Bottom Sheet (Searchable Multi-Select)
// ─────────────────────────────────────────────────────────
class _ServicesBottomSheet extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _ServicesBottomSheet({required this.selected, required this.onChanged});

  @override
  State<_ServicesBottomSheet> createState() => _ServicesBottomSheetState();
}

class _ServicesBottomSheetState extends State<_ServicesBottomSheet> {
  final Color primaryBlue = const Color(0xFF0E6BBB);
  late List<String> _selected;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = kAvailableServices
        .where((s) => s.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Services Select Karein",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "${_selected.length}/3 selected",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onChanged(_selected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Done",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search services...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final service = filtered[i];
                final isSelected = _selected.contains(service);
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: isSelected
                      ? primaryBlue.withValues(alpha: 0.07)
                      : null,
                  title: Text(
                    service,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? primaryBlue : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: primaryBlue)
                      : Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey[300],
                        ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(service);
                      } else if (_selected.length < 3) {
                        _selected.add(service);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Maximum 3 services allowed",
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        );
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

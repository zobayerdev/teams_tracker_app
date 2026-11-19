import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/features/employee_part/profile_screen/model/employee_profile_model.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/networks/api_acess.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _designationController;
  late TextEditingController _territoryController;

  File? _selectedImageFile;
  String? _existingImageUrl;
  dynamic _userId;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  StreamSubscription? _profileSub;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _designationController = TextEditingController();
    _territoryController = TextEditingController();

    _loadInitialData();
  }

  void _loadInitialData() {
    // 1. Check if profile data is already available in Rx stream
    if (getEmpProfileRxObj.dataFetcher.hasValue &&
        getEmpProfileRxObj.dataFetcher.value.isNotEmpty) {
      _populateFromData(getEmpProfileRxObj.dataFetcher.value);
    } else {
      // Fallback to local storage values
      _populateFromLocalStorage();
      getEmpProfileRxObj.getEmpProfile();
    }

    // 2. Listen to updates
    _profileSub = getEmpProfileRxObj.fillData.listen((data) {
      if (!mounted) return;
      if (data.isNotEmpty && data['data'] != null) {
        _populateFromData(data);
      }
    });
  }

  void _populateFromLocalStorage() {
    final localId = appData.read(kKeyUserID);
    final localName = appData.read(kKeyUserName)?.toString();
    final localEmail = appData.read(kKeyUserEmail)?.toString();
    final localAvatar = appData.read(kKeyUserAvatar)?.toString();
    final localDesignation = appData.read(kKeyUserDesignation)?.toString();

    setState(() {
      _userId = localId;
      if (localName != null && _nameController.text.isEmpty) {
        _nameController.text = localName;
      }
      if (localEmail != null && _emailController.text.isEmpty) {
        _emailController.text = localEmail;
      }
      if (localDesignation != null && _designationController.text.isEmpty) {
        _designationController.text = localDesignation;
      }
      if (localAvatar != null && _existingImageUrl == null) {
        _existingImageUrl = localAvatar;
      }
    });
  }

  void _populateFromData(dynamic rawData) {
    try {
      final res = EmployeeProfileResponseModel.fromJson(
        Map<String, dynamic>.from(rawData),
      );
      final profile = res.data?.profile;
      if (profile != null) {
        setState(() {
          _userId = profile.id ?? _userId ?? appData.read(kKeyUserID);
          _existingImageUrl =
              profile.profileImageUrl ??
              profile.profileImage ??
              appData.read(kKeyUserAvatar)?.toString();

          if (_nameController.text.isEmpty ||
              _nameController.text == 'Employee') {
            _nameController.text = profile.name ?? '';
          }
          if (_emailController.text.isEmpty) {
            _emailController.text = profile.email ?? 'N/A';
          }
          if (_mobileController.text.isEmpty) {
            _mobileController.text = profile.mobile ?? 'N/A';
          }
          if (_designationController.text.isEmpty) {
            _designationController.text =
                profile.designation ?? 'Sales Representative';
          }
          if (_territoryController.text.isEmpty) {
            _territoryController.text =
                profile.presentAddress?.isNotEmpty == true
                ? profile.presentAddress!
                : (profile.permanentAddress ?? 'Not Assigned');
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _designationController.dispose();
    _territoryController.dispose();
    super.dispose();
  }

  // Pick Image from Gallery or Camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      customToastMessage('Error', 'Failed to pick image: $e');
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Change Profile Photo',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a photo from your gallery or capture a new one',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.camera_alt_rounded,
                                size: 30,
                                color: Color(0xFF059669),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Camera',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF064E3B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.photo_library_rounded,
                                size: 30,
                                color: Color(0xFF059669),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gallery',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF064E3B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSaveProfile() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      customToastMessage('Warning', 'Full Name cannot be empty!');
      return;
    }

    final userId = _userId ?? appData.read(kKeyUserID);
    if (userId == null) {
      customToastMessage('Error', 'User ID not found. Please re-login.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isSuccess = await postUpdateProfileRxObj.updateProfile(
      userId: userId,
      name: name,
      profileImage: _selectedImageFile,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      // Re-fetch profile to sync state across the app
      getEmpProfileRxObj.getEmpProfile();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Pristine Fresh Green & White Gradient Background
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFECFDF5),
                  Color(0xFFF0FDF4),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. Ambient Floating Glowing Orbs
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withOpacity(0.25),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA7F3D0).withOpacity(0.3),
              ),
            ),
          ),

          // 3. Main Form Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Profile',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF064E3B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Scrollable Area
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Profile Avatar Section with Camera Badge
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF34D399),
                                      Color(0xFF059669),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF059669,
                                      ).withOpacity(0.3),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _selectedImageFile != null
                                      ? Image.file(
                                          _selectedImageFile!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : (_existingImageUrl != null &&
                                            _existingImageUrl!.isNotEmpty)
                                      ? Image.network(
                                          _existingImageUrl!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person_rounded,
                                                  size: 55,
                                                  color: Colors.white,
                                                );
                                              },
                                        )
                                      : const Icon(
                                          Icons.person_rounded,
                                          size: 55,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showImagePickerModal,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF064E3B),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _showImagePickerModal,
                          child: Text(
                            'Change Photo',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Form Fields Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 22,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF064E3B,
                                ).withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Name (Editable)
                              _buildField(
                                label: 'Full Name *',
                                controller: _nameController,
                                icon: Icons.person_outline_rounded,
                                hintText: 'Enter your full name',
                              ),
                              const SizedBox(height: 16),

                              // 2. Email (Read-Only)
                              _buildField(
                                label: 'Email Address (Non-Editable)',
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                isReadOnly: true,
                              ),
                              const SizedBox(height: 16),

                              // 3. Mobile
                              _buildField(
                                label: 'Mobile Number (Non-Editable)',
                                controller: _mobileController,
                                icon: Icons.phone_android_rounded,
                                isReadOnly: true,
                              ),
                              const SizedBox(height: 16),

                              // 4. Designation (Company Assigned)
                              _buildField(
                                label: 'Designation (Company Assigned)',
                                controller: _designationController,
                                icon: Icons.badge_outlined,
                                isReadOnly: true,
                              ),
                              const SizedBox(height: 16),

                              // // 5. Territory
                              // _buildField(
                              //   label: 'Assigned Territory / Area',
                              //   controller: _territoryController,
                              //   icon: Icons.location_on_outlined,
                              //   isReadOnly: true,
                              // ),
                              // const SizedBox(height: 26),

                              // Save Changes Button
                              InkWell(
                                onTap: _isLoading ? null : _handleSaveProfile,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF047857),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.35),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Save Changes',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Input Field with ReadOnly style support
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isReadOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isReadOnly ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isReadOnly
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFFE2E8F0),
              width: 1.1,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: keyboardType,
            style: GoogleFonts.outfit(
              color: isReadOnly
                  ? const Color(0xFF64748B)
                  : const Color(0xFF0F172A),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: const Color(0xFF059669),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: isReadOnly
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF059669),
                size: 19,
              ),
              suffixIcon: isReadOnly
                  ? const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

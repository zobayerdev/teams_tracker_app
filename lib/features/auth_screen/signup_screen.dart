import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/helpers/all_routes.dart';
import 'package:location_tracker/helpers/navigation_service.dart';
import 'package:location_tracker/networks/api_acess.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Account & Security Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // 2. Job & Position Controllers
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _supervisorIdController = TextEditingController(
    text: '0',
  );

  // 3. Personal & Identity Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();

  // 4. Address Controllers
  final TextEditingController _presentAddressController =
      TextEditingController();
  final TextEditingController _permanentAddressController =
      TextEditingController();

  // Dropdown States
  String _selectedRole = 'sales_representative';
  String _selectedBloodGroup = 'B+';
  String _selectedReligion = 'Islam';

  bool _isPasswordHidden = true;
  bool _isLoading = false;

  final List<Map<String, String>> _roleOptions = const [
    {'value': 'sales_representative', 'label': 'Sales Representative'},
    {'value': 'employee', 'label': 'Employee'},
    {'value': 'supervisor', 'label': 'Supervisor'},
  ];

  final List<String> _bloodGroups = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _religions = const [
    'Islam',
    'Hinduism',
    'Christianity',
    'Buddhism',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _salaryController.dispose();
    _supervisorIdController.dispose();
    _ageController.dispose();
    _nidController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _educationController.dispose();
    _presentAddressController.dispose();
    _permanentAddressController.dispose();
    super.dispose();
  }

  // Date of Birth Picker with automatic Age calculation
  Future<void> _pickDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year - 24, now.month, now.day);
    final DateTime firstDate = DateTime(1940);
    final DateTime lastDate = now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF059669),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      _dobController.text = formatted;

      // Auto-calculate age
      int calculatedAge = now.year - picked.year;
      if (now.month < picked.month ||
          (now.month == picked.month && now.day < picked.day)) {
        calculatedAge--;
      }
      if (calculatedAge >= 0) {
        _ageController.text = calculatedAge.toString();
      }
      setState(() {});
    }
  }

  // Quick helper to copy present address into permanent address
  void _copyPresentToPermanent() {
    if (_presentAddressController.text.trim().isNotEmpty) {
      setState(() {
        _permanentAddressController.text = _presentAddressController.text
            .trim();
      });
      customToastMessage(
        'Copied',
        'Present address copied to permanent address',
      );
    }
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();
    final designation = _designationController.text.trim();
    final ageText = _ageController.text.trim();
    final nid = _nidController.text.trim();
    final dob = _dobController.text.trim();
    final fatherName = _fatherNameController.text.trim();
    final motherName = _motherNameController.text.trim();
    final education = _educationController.text.trim();
    final presentAddress = _presentAddressController.text.trim();
    final permanentAddress = _permanentAddressController.text.trim();
    final salaryText = _salaryController.text.trim();
    final supervisorIdText = _supervisorIdController.text.trim();

    // 1. Mandatory Validations
    if (name.isEmpty) {
      customToastMessage('Validation Error', 'Full Name is required.');
      return;
    }
    if (phone.isEmpty) {
      customToastMessage('Validation Error', 'Mobile Number is required.');
      return;
    }
    if (phone.length < 11) {
      customToastMessage(
        'Validation Error',
        'Mobile number must be at least 11 digits.',
      );
      return;
    }
    if (password.isEmpty) {
      customToastMessage('Validation Error', 'Password is required.');
      return;
    }
    if (password.length < 6) {
      customToastMessage(
        'Validation Error',
        'Password must be at least 6 characters long.',
      );
      return;
    }

    // 2. Email format validation if provided
    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      customToastMessage(
        'Validation Error',
        'Please enter a valid email address.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final int? age = int.tryParse(ageText);
    final num? salary = num.tryParse(salaryText);
    final int? supervisorId = int.tryParse(supervisorIdText);

    final bool isSuccess = await signupRxObj.postSignup(
      name: name,
      phone: phone,
      password: password,
      email: email.isNotEmpty ? email : null,
      role: _selectedRole,
      designation: designation.isNotEmpty ? designation : null,
      age: age,
      nid: nid.isNotEmpty ? nid : null,
      dob: dob.isNotEmpty ? dob : null,
      fatherName: fatherName.isNotEmpty ? fatherName : null,
      motherName: motherName.isNotEmpty ? motherName : null,
      religion: _selectedReligion,
      bloodGroup: _selectedBloodGroup,
      education: education.isNotEmpty ? education : null,
      presentAddress: presentAddress.isNotEmpty ? presentAddress : null,
      permanentAddress: permanentAddress.isNotEmpty ? permanentAddress : null,
      salary: salary,
      supervisorId: supervisorId ?? 0,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        NavigationService.navigateToReplacement(Routes.logInScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Soft Mint to Crisp White Gradient Background
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

          // 2. Ambient Floating Glowing Orbs (Gloss highlights)
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 90,
                    spreadRadius: 25,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA7F3D0).withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withOpacity(0.2),
                    blurRadius: 110,
                    spreadRadius: 35,
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Form Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    // Back button & Title header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              NavigationService.navigateToReplacement(
                                Routes.logInScreen,
                              );
                            }
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Color(0xFF064E3B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: GoogleFonts.outfit(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF064E3B),
                                ),
                              ),
                              Text(
                                'TeamsLocator field force employee registration',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Frosted Glossy Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 22,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF064E3B,
                                ).withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ============================================
                              // SECTION 1: ACCOUNT & CREDENTIALS
                              // ============================================
                              _buildSectionHeader(
                                title: 'Account & Credentials',
                                icon: Icons.lock_outline_rounded,
                              ),
                              const SizedBox(height: 10),

                              // 1. Full Name
                              _buildInputField(
                                controller: _nameController,
                                label: 'Full Name',
                                hintText: 'e.g. Mohammad Shakil',
                                icon: Icons.person_outline_rounded,
                                isRequired: true,
                              ),
                              const SizedBox(height: 14),

                              // 2. Mobile Number (Phone)
                              _buildInputField(
                                controller: _phoneController,
                                label: 'Mobile Number (Phone)',
                                hintText: 'e.g. 01877665599',
                                icon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                                isRequired: true,
                              ),
                              const SizedBox(height: 14),

                              // 3. Email Address
                              _buildInputField(
                                controller: _emailController,
                                label: 'Email Address',
                                hintText: 'e.g. shakil.dev@gmail.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 14),

                              // 4. Password
                              _buildInputField(
                                controller: _passwordController,
                                label: 'Password',
                                hintText: 'Minimum 6 characters',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                isPasswordHidden: _isPasswordHidden,
                                isRequired: true,
                                onTogglePassword: () {
                                  setState(() {
                                    _isPasswordHidden = !_isPasswordHidden;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // ============================================
                              // SECTION 2: JOB & ROLE DETAILS
                              // ============================================
                              _buildSectionHeader(
                                title: 'Role & Position Details',
                                icon: Icons.badge_outlined,
                              ),
                              const SizedBox(height: 10),

                              // 5. Role Dropdown
                              _buildDropdownField(
                                label: 'Role',
                                value: _selectedRole,
                                icon: Icons.work_outline_rounded,
                                items: _roleOptions.map((role) {
                                  return DropdownMenuItem<String>(
                                    value: role['value'],
                                    child: Text(role['label']!),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedRole = val;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 14),

                              // 6. Designation
                              _buildInputField(
                                controller: _designationController,
                                label: 'Designation',
                                hintText: 'e.g. Sales Executive',
                                icon: Icons.business_center_outlined,
                              ),
                              const SizedBox(height: 14),

                              // 7. Monthly Salary & 8. Supervisor ID in two columns
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _salaryController,
                                      label: 'Monthly Salary',
                                      hintText: 'e.g. 24000',
                                      icon: Icons.payments_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _supervisorIdController,
                                      label: 'Supervisor ID',
                                      hintText: 'e.g. 0',
                                      icon: Icons.supervisor_account_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ============================================
                              // SECTION 3: PERSONAL & IDENTITY
                              // ============================================
                              _buildSectionHeader(
                                title: 'Personal & Identity',
                                icon: Icons.person_pin_outlined,
                              ),
                              const SizedBox(height: 10),

                              // 9. Date of Birth & 10. Age in row
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildDatePickerField(
                                      controller: _dobController,
                                      label: 'Date of Birth (DOB)',
                                      hintText: 'YYYY-MM-DD',
                                      onTap: _pickDateOfBirth,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: _buildInputField(
                                      controller: _ageController,
                                      label: 'Age',
                                      hintText: 'e.g. 26',
                                      icon: Icons.cake_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 11. National ID (NID)
                              _buildInputField(
                                controller: _nidController,
                                label: 'National ID (NID)',
                                hintText: 'e.g. 19982692512345678',
                                icon: Icons.credit_card_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 14),

                              // 12. Blood Group & 13. Religion in row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Blood Group',
                                      value: _selectedBloodGroup,
                                      icon: Icons.bloodtype_outlined,
                                      items: _bloodGroups.map((bg) {
                                        return DropdownMenuItem<String>(
                                          value: bg,
                                          child: Text(bg),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _selectedBloodGroup = val;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Religion',
                                      value: _selectedReligion,
                                      icon: Icons.temple_buddhist_outlined,
                                      items: _religions.map((rel) {
                                        return DropdownMenuItem<String>(
                                          value: rel,
                                          child: Text(rel),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _selectedReligion = val;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 14. Education
                              _buildInputField(
                                controller: _educationController,
                                label: 'Education / Qualification',
                                hintText: 'e.g. BBA in Marketing',
                                icon: Icons.school_outlined,
                              ),
                              const SizedBox(height: 14),

                              // 15. Father's Name & 16. Mother's Name
                              _buildInputField(
                                controller: _fatherNameController,
                                label: "Father's Name",
                                hintText: 'e.g. Abdul Karim',
                                icon: Icons.people_outline_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildInputField(
                                controller: _motherNameController,
                                label: "Mother's Name",
                                hintText: 'e.g. Salma Begum',
                                icon: Icons.people_outline_rounded,
                              ),
                              const SizedBox(height: 20),

                              // ============================================
                              // SECTION 4: ADDRESS DETAILS
                              // ============================================
                              _buildSectionHeader(
                                title: 'Address Details',
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 10),

                              // 17. Present Address
                              _buildInputField(
                                controller: _presentAddressController,
                                label: 'Present Address',
                                hintText:
                                    'House 12, Road 4, Sector 7, Uttara, Dhaka',
                                icon: Icons.home_outlined,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 14),

                              // 18. Permanent Address
                              _buildInputField(
                                controller: _permanentAddressController,
                                label: 'Permanent Address',
                                hintText:
                                    'Vill: Joypur, P.O: Chandpur Sadar, Chandpur',
                                icon: Icons.place_outlined,
                                maxLines: 2,
                                headerTrailing: InkWell(
                                  onTap: _copyPresentToPermanent,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF059669,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF059669,
                                        ).withOpacity(0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.copy_rounded,
                                          size: 11,
                                          color: Color(0xFF059669),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Same as present',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: const Color(0xFF059669),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Submit Emerald Gradient Button
                              InkWell(
                                onTap: _isLoading ? null : _handleRegister,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  height: 52,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981), // Emerald
                                        Color(0xFF047857), // Forest green
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.35),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1,
                                    ),
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
                                            'Complete Registration',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
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

                    const SizedBox(height: 20),

                    // Already have an account -> Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF334155),
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              NavigationService.navigateToReplacement(
                                Routes.logInScreen,
                              );
                            }
                          },
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF059669),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Header with Icon and Title
  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF059669), size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF064E3B),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  // Helper Widget: Reusable Label + Frosted Input Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordHidden = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    int maxLines = 1,
    Widget? headerTrailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
              ],
            ),
            ?headerTrailing,
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && isPasswordHidden,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: const Color(0xFF059669),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 12 : 14,
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF059669), size: 19),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF64748B),
                        size: 19,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown Field matching Frosted Glassmorphism Theme
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF059669), size: 19),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    items: items,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Date of Birth Picker Field
  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required VoidCallback onTap,
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF059669),
                  size: 19,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? hintText : controller.text,
                    style: GoogleFonts.outfit(
                      color: controller.text.isEmpty
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

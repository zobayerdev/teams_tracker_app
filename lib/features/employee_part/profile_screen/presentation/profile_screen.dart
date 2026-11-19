// ignore_for_file: unused_local_variable, prefer_final_fields

import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_tracker/common_widgets/common_import.dart';
import 'package:location_tracker/features/employee_part/profile_screen/model/employee_profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Demo fallback user data (will be populated dynamically from api_profile.php)
  final String _defaultName = "Employee";
  final String _defaultEmail = "employee@example.com";
  final String _defaultMobile = "N/A";
  final String _defaultDesignation = "Field Sales Executive";
  final String _defaultTerritory = "Not Assigned";
  final String _defaultSupervisor = "Not Assigned";
  final String _defaultStatus = "active";

  @override
  void initState() {
    super.initState();
    getEmpProfileRxObj.getEmpProfile();
  }

  void _navigateToEditProfile() async {
    await NavigationService.navigateTo(Routes.editProfileScreen);
    // Refresh profile on return
    getEmpProfileRxObj.getEmpProfile();
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Change Password',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF064E3B),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: GoogleFonts.outfit(
                      color: const Color(0xFF475569),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: GoogleFonts.outfit(
                      color: const Color(0xFF475569),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  customToastMessage(
                    'Success',
                    'Password update request submitted',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Update',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Pristine Fresh Green & White Background
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

          // 2. Glossy Ambient Spheres
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.35),
                    blurRadius: 90,
                    spreadRadius: 25,
                  ),
                ],
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
                color: const Color(0xFFA7F3D0).withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withOpacity(0.2),
                    blurRadius: 110,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Profile View with StreamBuilder
          SafeArea(
            child: StreamBuilder<Map>(
              stream: getEmpProfileRxObj.dataFetcher.stream,
              builder: (context, snapshot) {
                final bool isInitialLoading =
                    snapshot.connectionState == ConnectionState.waiting &&
                    (!snapshot.hasData ||
                        (snapshot.data is Map &&
                            (snapshot.data as Map).isEmpty));

                EmployeeProfileResponseModel? response;
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data is Map &&
                    (snapshot.data as Map).isNotEmpty) {
                  try {
                    response = EmployeeProfileResponseModel.fromJson(
                      Map<String, dynamic>.from(snapshot.data!),
                    );
                  } catch (_) {}
                }

                final profile = response?.data?.profile;
                final supervisor = response?.data?.supervisor;
                final stats = response?.data?.statistics;

                final String displayName = profile?.name?.isNotEmpty == true
                    ? profile!.name!
                    : _defaultName;
                final String displayEmail = profile?.email?.isNotEmpty == true
                    ? profile!.email!
                    : _defaultEmail;
                final String displayMobile = profile?.mobile?.isNotEmpty == true
                    ? profile!.mobile!
                    : _defaultMobile;
                final String displayDesignation =
                    profile?.designation?.isNotEmpty == true
                    ? profile!.designation!
                    : _defaultDesignation;
                final String displayStatus = profile?.status?.isNotEmpty == true
                    ? profile!.status!
                    : _defaultStatus;
                final String displayTerritory =
                    profile?.presentAddress?.isNotEmpty == true
                    ? profile!.presentAddress!
                    : _defaultTerritory;
                final String displaySupervisor = supervisor?.name != null
                    ? "${supervisor!.name}${supervisor.phone != null ? ' (${supervisor.phone})' : ''}"
                    : _defaultSupervisor;
                final String displayRole = profile?.roleType?.isNotEmpty == true
                    ? profile!.roleType!.replaceAll('_', ' ').toUpperCase()
                    : 'SALES REPRESENTATIVE';

                //* ১. API রেসপন্স (stats) থেকে নিরাপদে ডাটা বের করে নেওয়া
                String totalSales = (stats?.totalSales ?? 0).toString();
                String totalOrders = (stats?.totalOrders ?? 0).toString();
                String totalCollected = (stats?.totalCollected ?? 0).toString();

                //* ২. লোকাল স্টোরেজে (GetStorage / appData) সেভ করা
                appData.write(kKeyTotalSales, totalSales);
                appData.write(kKeyTotalOrders, totalOrders);
                appData.write(kKeyTotalCollection, totalCollected);
                if (profile?.id != null) {
                  appData.write(kKeyUserID, profile!.id.toString());
                }

                if (isInitialLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF10B981),
                  backgroundColor: Colors.white,
                  onRefresh: () => getEmpProfileRxObj.getEmpProfile(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Bar Row (Title + Status Badge + Edit Profile Action)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Officer Profile',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF064E3B),
                              ),
                            ),
                            Row(
                              children: [
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              displayStatus.toLowerCase() ==
                                                  'active'
                                              ? const Color(0xFF10B981)
                                              : Colors.amber,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        displayStatus.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF064E3B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Edit Profile Icon Action Button
                                GestureDetector(
                                  onTap: _navigateToEditProfile,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF059669,
                                          ).withOpacity(0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      size: 18,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Profile Main Card (Gloss Frosted)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF064E3B,
                                    ).withOpacity(0.08),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Avatar Icon
                                      Container(
                                        width: 68,
                                        height: 68,
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
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF059669,
                                              ).withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Name & Designation
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName,
                                              style: GoogleFonts.outfit(
                                                fontSize: 18.5,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF064E3B),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              displayDesignation,
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                color: const Color(0xFF059669),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              displayEmail,
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Edit Profile Inline Action Button
                                  InkWell(
                                    onTap: _navigateToEditProfile,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.edit_note_rounded,
                                            size: 19,
                                            color: Color(0xFF064E3B),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Edit Profile Details',
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
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Quick Stats Row
                        Row(
                          children: [
                            _buildStatCard(
                              'Total Sales',
                              stats?.totalSales != null
                                  ? '৳${stats!.totalSales}'
                                  : '৳0',
                              Icons.trending_up_rounded,
                              const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Collected',
                              stats?.totalCollected != null
                                  ? '৳${stats!.totalCollected}'
                                  : '৳0',
                              Icons.account_balance_wallet_rounded,
                              const Color(0xFF047857),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Orders',
                              stats?.totalOrders != null
                                  ? '${stats!.totalOrders} Booked'
                                  : '0 Booked',
                              Icons.shopping_bag_outlined,
                              const Color(0xFF0D9488),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Official Information Card
                        Text(
                          'OFFICIAL INFORMATION',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: const Color(0xFF064E3B).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoTile(
                                    Icons.phone_outlined,
                                    'Contact Mobile',
                                    displayMobile,
                                  ),
                                  const Divider(
                                    height: 18,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  _buildInfoTile(
                                    Icons.location_on_outlined,
                                    'Assigned Territory / Address',
                                    displayTerritory,
                                  ),
                                  const Divider(
                                    height: 18,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  _buildInfoTile(
                                    Icons.supervisor_account_outlined,
                                    'Reporting Supervisor',
                                    displaySupervisor,
                                  ),
                                  const Divider(
                                    height: 18,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  _buildInfoTile(
                                    Icons.verified_user_outlined,
                                    'System Role',
                                    displayRole,
                                  ),
                                  if (profile?.salary != null) ...[
                                    const Divider(
                                      height: 18,
                                      color: Color(0xFFE2E8F0),
                                    ),
                                    _buildInfoTile(
                                      Icons.payments_outlined,
                                      'Base Salary',
                                      '৳${profile!.salary}',
                                    ),
                                  ],
                                  if (profile?.memberSince != null &&
                                      profile!.memberSince!.isNotEmpty) ...[
                                    const Divider(
                                      height: 18,
                                      color: Color(0xFFE2E8F0),
                                    ),
                                    _buildInfoTile(
                                      Icons.calendar_today_outlined,
                                      'Member Since',
                                      profile.memberSince!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Personal & Biographical Information (If Available)
                        if (profile != null &&
                            (profile.nid?.isNotEmpty == true ||
                                profile.bloodGroup?.isNotEmpty == true ||
                                profile.education?.isNotEmpty == true)) ...[
                          const SizedBox(height: 22),
                          Text(
                            'PERSONAL & IDENTITY DETAILS',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: const Color(0xFF064E3B).withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    if (profile.bloodGroup?.isNotEmpty ==
                                        true) ...[
                                      _buildInfoTile(
                                        Icons.bloodtype_outlined,
                                        'Blood Group',
                                        profile.bloodGroup!,
                                      ),
                                      const Divider(
                                        height: 18,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ],
                                    if (profile.nid?.isNotEmpty == true) ...[
                                      _buildInfoTile(
                                        Icons.badge_outlined,
                                        'National ID (NID)',
                                        profile.nid!,
                                      ),
                                      const Divider(
                                        height: 18,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ],
                                    if (profile.education?.isNotEmpty ==
                                        true) ...[
                                      _buildInfoTile(
                                        Icons.school_outlined,
                                        'Education',
                                        profile.education!,
                                      ),
                                      const Divider(
                                        height: 18,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ],
                                    if (profile.permanentAddress?.isNotEmpty ==
                                        true) ...[
                                      _buildInfoTile(
                                        Icons.home_outlined,
                                        'Permanent Address',
                                        profile.permanentAddress!,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // Security Actions & Preferences
                        Text(
                          'SECURITY & PREFERENCES',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: const Color(0xFF064E3B).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Change Password Button
                        InkWell(
                          onTap: _showChangePasswordDialog,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lock_reset_rounded,
                                        size: 20,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      'Change Password',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                  color: Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Logout Button (integrated with logoutRxObj API)
                        InkWell(
                          onTap: () async {
                            final bool? shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text(
                                  'Confirm Logout',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to end your duty session and log out?',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDC2626),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      'Logout',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              await logoutRxObj.postLogout();
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5).withOpacity(0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout_rounded,
                                  size: 19,
                                  color: Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Logout Duty Session',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Column(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF064E3B),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Info Tile Widget
  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: const Color(0xFF059669)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

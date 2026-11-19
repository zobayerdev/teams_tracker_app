// ignore_for_file: unnecessary_import, unused_import

import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker/common_widgets/common_import.dart';
import 'package:location_tracker/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  //* Officer Information
  final String _officerName = appData.read(kKeyUserName) ?? 'Field Officer';
  final String _designation =
      appData.read(kKeyUserDesignation) ?? 'Sales Representative';

  //* Real-time Device Tracking States
  final LocationHelper _locationHelper = LocationHelper.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  double? _latitude;
  double? _longitude;
  String _currentAddress = "Detecting live location...";
  bool _isLocationLoading = true;
  String? _locationErrorMessage;
  bool _isPermanentlyDenied = false;
  bool _isGpsDisabled = false;
  Position? _lastGeocodedPosition;

  // Attendance Toggle States
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  String _inTime = "--:--";
  String _outTime = "--:--";
  String _workingHours = "0h 0m";
  bool _isAttendanceLoading = false;

  // Today's Performance Metrics
  // final int _todayOrders = appData.read(kKeyTotalOrders);
  // final double _todaySales = 18450.0;
  // final double _todayCollection = 9200.0;

  String _todaySales = (appData.read(kKeyTotalSales) ?? '0').toString();
  String _todayOrders = (appData.read(kKeyTotalOrders) ?? '0').toString();
  String _todayCollection = (appData.read(kKeyTotalCollection) ?? '0')
      .toString();

  // Real-time Battery States
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  int _batteryLevel = 100;
  bool _isCharging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initBatteryLevel();
    _loadSavedAttendanceState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLiveLocation();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSavedAttendanceState();
      // ইউজার সেটিংস থেকে পারমিশন অন করে অ্যাপে ফিরে এলে অটোমেটিক রিলোড হবে
      if (_locationErrorMessage != null) {
        _initLiveLocation();
      }
    }
  }

  /// Load attendance state from Hive (date-wise reset handled inside)
  Future<void> _loadSavedAttendanceState() async {
    final state = await AttendanceHiveHelper.getAttendanceState();
    if (mounted) {
      setState(() {
        _isCheckedIn = state.isCheckedIn;
        _isCheckedOut = state.isCheckedOut;
        _inTime = state.inTime;
        _outTime = state.outTime;
        _workingHours = state.workingHours;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    _batteryStateSubscription?.cancel();
    super.dispose();
  }

  //* Fetch real device battery level and listen for charging state changes
  Future<void> _initBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }

      _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
        state,
      ) async {
        final updatedLevel = await _battery.batteryLevel;
        if (mounted) {
          setState(() {
            _batteryLevel = updatedLevel;
            _isCharging =
                state == BatteryState.charging || state == BatteryState.full;
          });
        }
      });
    } catch (e) {
      log('Battery level error: $e');
    }
  }

  //* Initialize and request location permissions, then start live GPS tracking
  Future<void> _initLiveLocation() async {
    if (!mounted) return;
    setState(() {
      _isLocationLoading = true;
      _locationErrorMessage = null;
      _isPermanentlyDenied = false;
      _isGpsDisabled = false;
    });

    final permissionResult = await _locationHelper.checkAndRequestPermission();

    if (!mounted) return;

    if (!permissionResult.isSuccess) {
      setState(() {
        _isLocationLoading = false;
        _locationErrorMessage = permissionResult.errorMessage;
        _isPermanentlyDenied = permissionResult.isPermanentlyDenied;
        _isGpsDisabled = permissionResult.isServiceDisabled;
        _currentAddress = "Location permission not granted";
      });
      return;
    }

    // Permission granted! Fetch initial accurate position
    final position = await _locationHelper.getCurrentPosition();
    if (!mounted) return;

    if (position != null) {
      _updateLocation(position, updateAddress: true);
    } else {
      setState(() {
        _isLocationLoading = false;
        _currentAddress = "Acquiring GPS signal...";
      });
    }

    // Listen to real-time live GPS stream
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = _locationHelper.getLivePositionStream().listen(
      (newPosition) {
        if (!mounted) return;
        bool shouldUpdateAddress = false;
        if (_lastGeocodedPosition == null) {
          shouldUpdateAddress = true;
        } else {
          final distance = Geolocator.distanceBetween(
            _lastGeocodedPosition!.latitude,
            _lastGeocodedPosition!.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );
          // Only reverse geocode if moved more than 25 meters to save resources
          if (distance > 25) {
            shouldUpdateAddress = true;
          }
        }
        _updateLocation(newPosition, updateAddress: shouldUpdateAddress);
      },
      onError: (error) {
        log('Live GPS stream error: $error');
      },
    );
  }

  void _updateLocation(Position position, {bool updateAddress = false}) async {
    if (!mounted) return;
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _isLocationLoading = false;
      _locationErrorMessage = null;
      _isPermanentlyDenied = false;
      _isGpsDisabled = false;
    });

    if (updateAddress) {
      _lastGeocodedPosition = position;
      final address = await _locationHelper.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (mounted && address != null && address.trim().isNotEmpty) {
        setState(() {
          _currentAddress = address;
        });
      }
    }
  }

  Future<void> _handlePermissionAction() async {
    if (_isPermanentlyDenied) {
      await _locationHelper.openAppSettings();
    } else if (_isGpsDisabled) {
      await _locationHelper.openLocationSettings();
    } else {
      await _initLiveLocation();
    }
  }

  // Check-In / Check-Out Action
  void _handleAttendanceToggle() async {
    if (_isCheckedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ajker diner duty check-out already complete hoyeche!',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 1. Check or fetch live location
    double? lat = _latitude;
    double? lng = _longitude;
    String address = _currentAddress;

    if (lat == null || lng == null) {
      setState(() {
        _isAttendanceLoading = true;
      });

      final pos = await _locationHelper.getCurrentPosition();
      if (pos != null) {
        lat = pos.latitude;
        lng = pos.longitude;
        _latitude = lat;
        _longitude = lng;
        final revAddress = await _locationHelper.getAddressFromCoordinates(
          lat,
          lng,
        );
        if (revAddress != null && revAddress.isNotEmpty) {
          address = revAddress;
          _currentAddress = address;
        }
      } else {
        setState(() {
          _isAttendanceLoading = false;
        });
        customToastMessage(
          'Error',
          'Accurate GPS location is required to submit attendance.',
        );
        return;
      }
    }

    setState(() {
      _isAttendanceLoading = true;
    });

    final now = DateTime.now();
    // Time format: "05:20:00" as specified: "time": "05:20:00"
    final apiTime = DateFormat('HH:mm:ss').format(now);
    // Display format: "05:20 PM"
    final displayTime = DateFormat('hh:mm a').format(now);

    final payload = {
      "latitude": lat,
      "longitude": lng,
      "address": address,
      "time": apiTime,
    };

    final isSuccess = await postAttendanceRxObj.postAttendance(payload);

    if (!mounted) return;

    setState(() {
      _isAttendanceLoading = false;
    });

    if (isSuccess) {
      if (!_isCheckedIn) {
        // --- 1. Check-In Success ---
        await AttendanceHiveHelper.saveCheckIn(
          displayTime: displayTime,
          checkInDateTime: now,
        );

        if (!mounted) return;

        setState(() {
          _isCheckedIn = true;
          _inTime = displayTime;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Duty Started! Successfully Checked-In at $_inTime',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        // --- 2. Check-Out Success ---
        final checkInTime = AttendanceHiveHelper.getRawCheckInTime() ?? now;
        final diff = now.difference(checkInTime);
        final hours = diff.inHours;
        final minutes = diff.inMinutes.remainder(60);
        final workingHoursStr = "${hours}h ${minutes}m";

        await AttendanceHiveHelper.saveCheckOut(
          displayTime: displayTime,
          workingHours: workingHoursStr,
        );

        if (!mounted) return;

        setState(() {
          _isCheckedOut = true;
          _outTime = displayTime;
          _workingHours = workingHoursStr;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Duty Closed! Successfully Checked-Out at $_outTime ($workingHoursStr)',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // Add Customer / New Shop Modal
  void _showAddCustomerModal() {
    final shopNameController = TextEditingController();
    final ownerNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController(
      text: _latitude != null ? _currentAddress : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add New Customer / Shop',
                      style: GoogleFonts.outfit(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF064E3B),
                      ),
                    ),
                    Text(
                      'Register shop with realtime pinpoint GPS location',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Shop Name
                    _buildModalTextField(
                      'Shop Name',
                      'e.g. Bismillah General Store',
                      Icons.store_rounded,
                      shopNameController,
                    ),
                    const SizedBox(height: 12),

                    // Owner Name
                    _buildModalTextField(
                      'Owner Name',
                      'e.g. Haji Mohammad Ali',
                      Icons.person_outline_rounded,
                      ownerNameController,
                    ),
                    const SizedBox(height: 12),

                    // Phone Number
                    _buildModalTextField(
                      'Mobile Number',
                      'e.g. 017XXXXXXXX',
                      Icons.phone_android_rounded,
                      phoneController,
                      isPhone: true,
                    ),
                    const SizedBox(height: 12),

                    // Address with current GPS coordinates badge
                    _buildModalTextField(
                      'Shop Address / Area',
                      'Road, Market details',
                      Icons.location_on_outlined,
                      addressController,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _latitude != null && _longitude != null
                          ? 'Auto GPS: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                          : 'Auto GPS: Detecting location...',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (shopNameController.text.trim().isEmpty ||
                            phoneController.text.trim().isEmpty) {
                          return;
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'New Customer Added Successfully!',
                              style: GoogleFonts.outfit(),
                            ),
                            backgroundColor: const Color(0xFF059669),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Save Shop Profile',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalTextField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                fontSize: 12.5,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF059669)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
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
            top: -60,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withOpacity(0.32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 340,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA7F3D0).withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withOpacity(0.18),
                    blurRadius: 110,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Dashboard Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(),
                  const SizedBox(height: 18),
                  _buildLiveTrackingCard(),
                  const SizedBox(height: 16),
                  _buildAttendanceActionCard(),
                  const SizedBox(height: 22),
                  _buildTodayPerformanceCard(),
                  const SizedBox(height: 24),

                  // Operational Services
                  Text(
                    'OPERATIONAL SERVICES',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: const Color(0xFF064E3B).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOperationalServicesGrid(),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Top Header Profile Greeting
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34D399), Color(0xFF059669)],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _officerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF064E3B),
                      ),
                    ),
                    Text(
                      _designation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            NavigationService.navigateTo(Routes.notificationScreen);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: Color(0xFF064E3B),
            ),
          ),
        ),
      ],
    );
  }

  // 2. Real-Time GPS Tracking Card (Zero Overflow & Clean Error Handling)
  Widget _buildLiveTrackingCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF064E3B).withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            size: 18,
                            color: Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Live GPS Tracker',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _latitude != null
                                ? const Color(0xFF10B981).withOpacity(0.15)
                                : const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _latitude != null
                                ? 'LIVE'
                                : (_isLocationLoading
                                      ? 'SEARCHING'
                                      : 'OFFLINE'),
                            style: GoogleFonts.outfit(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: _latitude != null
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _isLocationLoading
                            ? null
                            : _initLiveLocation,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Refresh GPS',
                        icon: _isLocationLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF059669),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                size: 17,
                                color: Color(0xFF059669),
                              ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCharging
                                  ? Icons.battery_charging_full_rounded
                                  : (_batteryLevel > 20
                                        ? Icons.battery_std_rounded
                                        : Icons.battery_alert_rounded),
                              size: 15,
                              color: _batteryLevel > 20
                                  ? const Color(0xFF059669)
                                  : Colors.redAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_batteryLevel%',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 17,
                    color: _latitude != null
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _currentAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              if (_locationErrorMessage != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: _handlePermissionAction,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isGpsDisabled
                              ? Icons.location_off_rounded
                              : (_isPermanentlyDenied
                                    ? Icons.settings_rounded
                                    : Icons.lock_open_rounded),
                          size: 15,
                          color: const Color(0xFFB45309),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _locationErrorMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Color(0xFF92400E),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _latitude != null
                          ? 'Lat: ${_latitude!.toStringAsFixed(6)}'
                          : (_isLocationLoading
                                ? 'Lat: Locating...'
                                : 'Lat: --'),
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: _latitude != null
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 14,
                      color: const Color(0xFFCBD5E1),
                    ),
                    Text(
                      _longitude != null
                          ? 'Lng: ${_longitude!.toStringAsFixed(6)}'
                          : (_isLocationLoading
                                ? 'Lng: Locating...'
                                : 'Lng: --'),
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: _longitude != null
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Attendance Action Card
  Widget _buildAttendanceActionCard() {
    String buttonText = "Start Duty (Check-In)";
    Color buttonGradientStart = const Color(0xFF10B981);
    Color buttonGradientEnd = const Color(0xFF047857);

    if (_isCheckedIn && !_isCheckedOut) {
      buttonText = "End Duty (Check-Out)";
      buttonGradientStart = const Color(0xFFEF4444);
      buttonGradientEnd = const Color(0xFFB91C1C);
    } else if (_isCheckedOut) {
      buttonText = "Duty Completed";
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF064E3B).withOpacity(0.07),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDutyTimeBlock('IN TIME', _inTime, Icons.login_rounded),
                  Container(
                    width: 1,
                    height: 35,
                    color: const Color(0xFFE2E8F0),
                  ),
                  _buildDutyTimeBlock(
                    'OUT TIME',
                    _outTime,
                    Icons.logout_rounded,
                  ),
                  Container(
                    width: 1,
                    height: 35,
                    color: const Color(0xFFE2E8F0),
                  ),
                  _buildDutyTimeBlock(
                    'WORKING',
                    _workingHours,
                    Icons.hourglass_bottom_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: (_isAttendanceLoading || _isCheckedOut)
                    ? null
                    : _handleAttendanceToggle,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _isCheckedOut
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade600,
                            ],
                          )
                        : LinearGradient(
                            colors: [buttonGradientStart, buttonGradientEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: _isCheckedOut
                            ? Colors.black12
                            : buttonGradientStart.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: _isAttendanceLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isCheckedIn && !_isCheckedOut
                                    ? Icons.stop_circle_outlined
                                    : Icons.play_circle_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                buttonText,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDutyTimeBlock(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: const Color(0xFF059669)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF064E3B),
          ),
        ),
      ],
    );
  }

  // 4. Today's Performance Card
  Widget _buildTodayPerformanceCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF064E3B).withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TODAY'S FIELD SUMMARY",
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: const Color(0xFF064E3B).withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Realtime Sync',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildMetricItem(
                    'Orders Booked',
                    _todayOrders.toString(),
                    Icons.shopping_cart_outlined,
                    const Color(0xFF059669),
                  ),
                  _buildMetricItem(
                    'Today Sales',
                    '৳${_todaySales.toString()}',
                    Icons.trending_up_rounded,
                    const Color(0xFF0D9488),
                  ),
                  _buildMetricItem(
                    'Collected',
                    '৳${_todayCollection.toString()}',
                    Icons.payments_outlined,
                    const Color(0xFF047857),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String title,
    String val,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 15,
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
    );
  }

  // 5. Operational Services Action Grid
  Widget _buildOperationalServicesGrid() {
    final List services = [
      {
        'title': 'Add Customer',
        'subtitle': 'Register new shop',
        'icon': Icons.person_add_alt_1_rounded,
        'color': const Color(0xFF059669),
        'action': 'add_customer',
      },
      {
        'title': 'Take Order',
        'subtitle': 'Book new shop order',
        'icon': Icons.add_shopping_cart_rounded,
        'color': const Color(0xFF10B981),
        'action': 'take_order',
      },
      {
        'title': 'Collect Due',
        'subtitle': 'Cash & payment log',
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFF0D9488),
        'action': 'collect_due',
      },
      {
        'title': 'Catalog',
        'subtitle': 'Stock & box prices',
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFF047857),
        'action': 'catalog',
      },
      {
        'title': 'Tour Plan',
        'subtitle': 'Submit market route',
        'icon': Icons.map_outlined,
        'color': const Color(0xFF0E7490),
        'action': 'tour_plan',
      },
      {
        'title': 'Leave Apply',
        'subtitle': 'Apply for leave',
        'icon': Icons.event_note_outlined,
        'color': const Color(0xFF15803D),
        'action': 'leave_app',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = services[index];
        return InkWell(
          onTap: () {
            if (item['action'] == 'add_customer') {
              _showAddCustomerModal();
            } else if (item['action'] == 'take_order') {
              NavigationService.navigateTo(Routes.takeOrder);
            } else if (item['action'] == 'collect_due') {
              NavigationService.navigateTo(Routes.collectDue);
            } else if (item['action'] == 'catalog') {
              NavigationService.navigateTo(Routes.catalogScreen);
            } else if (item['action'] == 'tour_plan') {
              NavigationService.navigateTo(Routes.tourPlanScreen);
            } else if (item['action'] == 'leave_app') {
              NavigationService.navigateTo(Routes.leaveScreen);
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 1.6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF064E3B).withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: item['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF064E3B),
                      ),
                    ),
                    Text(
                      item['subtitle'] as String,
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
      },
    );
  }
}

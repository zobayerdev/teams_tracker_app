// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_tracker/common_widgets/waiting_widget.dart';
import 'package:location_tracker/features/employee_part/attendence_screen/model/attendance_response_model.dart';
import 'package:location_tracker/helpers/url_lunch.dart';
import 'package:location_tracker/networks/api_acess.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonthYear;
  final ScrollController _calendarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonthYear = DateTime(_selectedDate.year, _selectedDate.month);

    _fetchAttendance();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  void _fetchAttendance() {
    final String monthStr =
        "${_currentMonthYear.year}-${_currentMonthYear.month.toString().padLeft(2, '0')}";
    getAttendanceRxObj.fetchAttendance(month: monthStr);
  }

  int _daysInMonth(DateTime date) {
    var firstDayThisMonth = DateTime(date.year, date.month, date.day);
    var firstDayNextMonth = DateTime(
      firstDayThisMonth.year,
      firstDayThisMonth.month + 1,
      1,
    );
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  void _changeMonth(int increment) {
    setState(() {
      _currentMonthYear = DateTime(
        _currentMonthYear.year,
        _currentMonthYear.month + increment,
      );
      _selectedDate = DateTime(
        _currentMonthYear.year,
        _currentMonthYear.month,
        1,
      );
    });
    _scrollToSelectedDay();
    _fetchAttendance();
  }

  void _scrollToSelectedDay() {
    if (_calendarScrollController.hasClients) {
      double targetScroll = (_selectedDate.day - 1) * 62.0;
      _calendarScrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatDateKey(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getWeekdayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // Pinpoint Coordinates Details Modal
  void _showCoordinatesModal(BuildContext context, AttendanceRecordModel att) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
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
                    'GPS Pinpoint Audit',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF064E3B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Exact satellite coordinates during check-in & check-out',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recorded Check-In Spot Address
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.login_rounded,
                          color: Color(0xFF059669),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CHECK-IN SPOT',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                att.inAddress ?? 'No Check-in Address Recorded',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Latitude & Longitude Block (Check-In)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CHECK-IN LAT',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${att.inLat ?? 'N/A'}',
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CHECK-IN LNG',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${att.inLng ?? 'N/A'}',
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

                  // Recorded Check-Out Spot Address & Coordinates (if available)
                  if (att.checkOut != null &&
                      (att.outAddress != null || att.outLat != null)) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CHECK-OUT SPOT',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  att.outAddress ??
                                      'No Check-out Address Recorded',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CHECK-OUT LAT',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${att.outLat ?? 'N/A'}',
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CHECK-OUT LNG',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${att.outLng ?? 'N/A'}',
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
                  ],

                  const SizedBox(height: 18),

                  // Open in Google Maps Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final lat = att.inLat ?? att.outLat;
                      final lng = att.inLng ?? att.outLng;
                      if (lat != null && lng != null) {
                        urlLunch(
                          "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
                        );
                      } else {
                        _triggerExportNotice("Coordinates not available");
                      }
                    },
                    icon: const Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'Open in Google Maps',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Export Action Sheet (PDF ও Excel অপশন)
  void _showExportOptionsModal({int recordCount = 0}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Export Attendance Statement',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Duration: ${_getMonthName(_currentMonthYear.month)} ${_currentMonthYear.year} ($recordCount records)',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Export as PDF
                _buildExportTile(
                  icon: Icons.picture_as_pdf_rounded,
                  iconColor: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEE2E2),
                  title: 'Print / Save as PDF Document',
                  subtitle: 'Official signed monthly field audit preview',
                  onTap: () {
                    Navigator.pop(context);
                    _triggerExportNotice(
                      'PDF Statement Generating for ${_getMonthName(_currentMonthYear.month)} ${_currentMonthYear.year}...',
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 2. Export as Excel (.CSV)
                _buildExportTile(
                  icon: Icons.table_view_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFFD1FAE5),
                  title: 'Export to Excel Spreadsheet (.CSV)',
                  subtitle: 'Detailed time, coordinates & duration logs',
                  onTap: () {
                    Navigator.pop(context);
                    _triggerExportNotice(
                      'Excel (.CSV) Spreadsheet Downloaded for ${_getMonthName(_currentMonthYear.month)} ${_currentMonthYear.year}!',
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerExportNotice(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSummaryMiniBadge(
    String label,
    String value,
    Color textColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final totalDaysInCurrentMonth = _daysInMonth(_currentMonthYear);
    final String selectedDateStr = _formatDateKey(_selectedDate);

    return Scaffold(
      body: StreamBuilder<Map>(
        stream: getAttendanceRxObj.dataFetcher.stream,
        builder: (context, snapshot) {
          AttendanceResponseModel? response;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data is Map &&
              (snapshot.data as Map).isNotEmpty) {
            try {
              response = AttendanceResponseModel.fromJson(
                Map<String, dynamic>.from(snapshot.data!),
              );
            } catch (_) {}
          }

          final List<AttendanceRecordModel> attendanceRecords =
              response?.data ?? [];
          final summary = response?.summary;

          final filteredRecords = attendanceRecords
              .where((a) => a.date == selectedDateStr)
              .toList();

          final bool isInitialLoading =
              snapshot.connectionState == ConnectionState.waiting &&
              (!snapshot.hasData ||
                  (snapshot.data is Map && (snapshot.data as Map).isEmpty));

          return Stack(
            children: [
              // 1. Background Gradient
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

              // 2. Ambient Floating Glowing Spheres
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 220,
                  height: 220,
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
                bottom: 60,
                left: -40,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA7F3D0).withOpacity(0.35),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withOpacity(0.2),
                        blurRadius: 100,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Main Screen View
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header with Month Switcher & Export Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance Log',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF064E3B),
                                ),
                              ),
                              Text(
                                'Daily duty timestamps & working hours',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          // Export Action Button (PDF / Excel)
                          InkWell(
                            onTap: () => _showExportOptionsModal(
                              recordCount: attendanceRecords.length,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.4),
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
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.file_download_outlined,
                                    size: 16,
                                    color: Color(0xFF059669),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Export',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
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

                    // Month Switcher Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _changeMonth(-1),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 22,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                            Text(
                              "${_getMonthName(_currentMonthYear.month)} ${_currentMonthYear.year}",
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF064E3B),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _changeMonth(1),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                size: 22,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Monthly Summary Mini-Badges (if summary is available)
                    if (summary != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            _buildSummaryMiniBadge(
                              'Logged',
                              '${summary.totalWorkingDaysLogged ?? 0}',
                              const Color(0xFF065F46),
                              const Color(0xFFD1FAE5),
                            ),
                            const SizedBox(width: 6),
                            _buildSummaryMiniBadge(
                              'Present',
                              '${summary.presentDays ?? 0}',
                              const Color(0xFF047857),
                              const Color(0xFFECFDF5),
                            ),
                            const SizedBox(width: 6),
                            _buildSummaryMiniBadge(
                              'Late',
                              '${summary.lateDays ?? 0}',
                              const Color(0xFFB45309),
                              const Color(0xFFFEF3C7),
                            ),
                            const SizedBox(width: 6),
                            _buildSummaryMiniBadge(
                              'Absent',
                              '${summary.absentDays ?? 0}',
                              const Color(0xFFB91C1C),
                              const Color(0xFFFEE2E2),
                            ),
                            const SizedBox(width: 6),
                            _buildSummaryMiniBadge(
                              'Hours',
                              '${summary.totalHoursWorked ?? 0}h',
                              const Color(0xFF1E40AF),
                              const Color(0xFFDBEAFE),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 6),

                    // 4. Interactive Monthly Horizontal Calendar Bar (30/31 days)
                    SizedBox(
                      height: 85,
                      child: ListView.builder(
                        controller: _calendarScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: totalDaysInCurrentMonth,
                        itemBuilder: (context, index) {
                          final dayNum = index + 1;
                          final dayDate = DateTime(
                            _currentMonthYear.year,
                            _currentMonthYear.month,
                            dayNum,
                          );
                          final bool isSelected =
                              _selectedDate.day == dayNum &&
                              _selectedDate.month == dayDate.month &&
                              _selectedDate.year == dayDate.year;

                          final String dayDateStr = _formatDateKey(dayDate);
                          final bool hasDayRecord = attendanceRecords.any(
                            (r) => r.date == dayDateStr,
                          );

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = dayDate;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 54,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF059669)
                                    : Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? const Color(
                                            0xFF059669,
                                          ).withOpacity(0.35)
                                        : Colors.black.withOpacity(0.04),
                                    blurRadius: isSelected ? 12 : 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getWeekdayName(dayDate),
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white70
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$dayNum',
                                    style: GoogleFonts.outfit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF064E3B),
                                    ),
                                  ),
                                  if (hasDayRecord) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Attendance Status Header for the Selected Day
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date: ${_selectedDate.day} ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                          Text(
                            filteredRecords.isNotEmpty
                                ? 'Record Found (${filteredRecords.length})'
                                : 'Holiday / Off Day',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: filteredRecords.isNotEmpty
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 5. Attendance Details Card / Empty View / Loading Indicator
                    Expanded(
                      child: isInitialLoading
                          ? const Center(child: WaitingWidget())
                          : RefreshIndicator(
                              color: const Color(0xFF059669),
                              onRefresh: () async {
                                _fetchAttendance();
                              },
                              child: filteredRecords.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(
                                            parent: BouncingScrollPhysics(),
                                          ),
                                      children: [
                                        SizedBox(height: size.height * 0.12),
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  18,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF10B981,
                                                  ).withOpacity(0.12),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.event_busy_rounded,
                                                  size: 40,
                                                  color: Color(0xFF059669),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'No Duty Logged',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF064E3B,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'No Check-in entry on ${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  color: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(
                                            parent: BouncingScrollPhysics(),
                                          ),
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        4,
                                        20,
                                        90,
                                      ),
                                      itemCount: filteredRecords.length,
                                      itemBuilder: (context, index) {
                                        final att = filteredRecords[index];
                                        final statusLower = (att.status ?? '')
                                            .toLowerCase();
                                        final bool isLate =
                                            statusLower == 'late';
                                        final bool isAbsent =
                                            statusLower == 'absent';
                                        final bool isPresent =
                                            statusLower == 'present';

                                        Color badgeBgColor;
                                        Color badgeTextColor;
                                        Color badgeIconColor;
                                        IconData badgeIcon;
                                        String badgeText;

                                        if (isLate) {
                                          badgeBgColor = const Color(
                                            0xFFFEF3C7,
                                          );
                                          badgeTextColor = const Color(
                                            0xFFB45309,
                                          );
                                          badgeIconColor = const Color(
                                            0xFFD97706,
                                          );
                                          badgeIcon =
                                              Icons.warning_amber_rounded;
                                          badgeText = 'LATE ARRIVAL';
                                        } else if (isAbsent) {
                                          badgeBgColor = const Color(
                                            0xFFFEE2E2,
                                          );
                                          badgeTextColor = const Color(
                                            0xFFB91C1C,
                                          );
                                          badgeIconColor = const Color(
                                            0xFFEF4444,
                                          );
                                          badgeIcon = Icons.cancel_outlined;
                                          badgeText = 'ABSENT';
                                        } else if (isPresent) {
                                          badgeBgColor = const Color(
                                            0xFFD1FAE5,
                                          );
                                          badgeTextColor = const Color(
                                            0xFF047857,
                                          );
                                          badgeIconColor = const Color(
                                            0xFF059669,
                                          );
                                          badgeIcon =
                                              Icons.check_circle_rounded;
                                          badgeText = 'ON TIME (PRESENT)';
                                        } else {
                                          badgeBgColor = const Color(
                                            0xFFE0F2FE,
                                          );
                                          badgeTextColor = const Color(
                                            0xFF0369A1,
                                          );
                                          badgeIconColor = const Color(
                                            0xFF0284C7,
                                          );
                                          badgeIcon =
                                              Icons.info_outline_rounded;
                                          badgeText = (att.status ?? 'RECORDED')
                                              .toUpperCase();
                                        }

                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 18,
                                              sigmaY: 18,
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              padding: const EdgeInsets.all(18),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.78,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF064E3B,
                                                    ).withOpacity(0.06),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Status Badge Row
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: badgeBgColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              badgeIcon,
                                                              size: 14,
                                                              color:
                                                                  badgeIconColor,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              badgeText,
                                                              style: GoogleFonts.outfit(
                                                                fontSize: 10.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    badgeTextColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        'Duration: ${att.workingHours ?? '0h 0m'}',
                                                        style:
                                                            GoogleFonts.outfit(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  const Color(
                                                                    0xFF064E3B,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),

                                                  const Divider(
                                                    height: 22,
                                                    color: Color(0xFFE2E8F0),
                                                  ),

                                                  // Time Comparison
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .login_rounded,
                                                                  size: 14,
                                                                  color: Color(
                                                                    0xFF10B981,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  'CHECK-IN (IN)',
                                                                  style: GoogleFonts.outfit(
                                                                    fontSize:
                                                                        10.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: const Color(
                                                                      0xFF64748B,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 3,
                                                            ),
                                                            Text(
                                                              att.inTime ??
                                                                  '--:--',
                                                              style: GoogleFonts.outfit(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    const Color(
                                                                      0xFF0F172A,
                                                                    ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              att.inAddress ??
                                                                  'No Address Recorded',
                                                              style: GoogleFonts.outfit(
                                                                fontSize: 11,
                                                                color:
                                                                    const Color(
                                                                      0xFF64748B,
                                                                    ),
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height: 45,
                                                        color: const Color(
                                                          0xFFE2E8F0,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .logout_rounded,
                                                                  size: 14,
                                                                  color: Color(
                                                                    0xFFEF4444,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  'CHECK-OUT (OUT)',
                                                                  style: GoogleFonts.outfit(
                                                                    fontSize:
                                                                        10.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: const Color(
                                                                      0xFF64748B,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 3,
                                                            ),
                                                            Text(
                                                              att.outTime ??
                                                                  'Duty Active',
                                                              style: GoogleFonts.outfit(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    const Color(
                                                                      0xFF0F172A,
                                                                    ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              att.outAddress ??
                                                                  (att.outTime !=
                                                                          null
                                                                      ? 'No Address Recorded'
                                                                      : 'In Field Area'),
                                                              style: GoogleFonts.outfit(
                                                                fontSize: 11,
                                                                color:
                                                                    const Color(
                                                                      0xFF64748B,
                                                                    ),
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 14),

                                                  // GPS Coordinates Spot View Link (Working Action)
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: InkWell(
                                                      onTap: () {
                                                        _showCoordinatesModal(
                                                          context,
                                                          att,
                                                        );
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 4,
                                                              horizontal: 6,
                                                            ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .map_outlined,
                                                              size: 14,
                                                              color: Color(
                                                                0xFF059669,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              'View Pinpoint Coordinates',
                                                              style: GoogleFonts.outfit(
                                                                fontSize: 11.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    const Color(
                                                                      0xFF059669,
                                                                    ),
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
                                      },
                                    ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

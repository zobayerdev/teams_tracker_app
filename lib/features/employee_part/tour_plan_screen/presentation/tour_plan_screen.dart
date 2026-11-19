import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/features/employee_part/tour_plan_screen/model/tour_model.dart';
import 'package:location_tracker/networks/api_acess.dart';

class TourPlanScreen extends StatefulWidget {
  const TourPlanScreen({super.key});

  @override
  State<TourPlanScreen> createState() => _TourPlanScreenState();
}

class _TourPlanScreenState extends State<TourPlanScreen> {
  int _selectedTab = 0; // 0: Upcoming / Active, 1: History / Completed

  List<TourModel> _tours = [];
  TourSummaryModel? _summary;
  bool _isLoading = true;
  StreamSubscription? _tourSub;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    getMyToursRxObj.fetchMyTours();

    _tourSub = getMyToursRxObj.fillData.listen((data) {
      if (!mounted) return;
      if (data.isNotEmpty && data['data'] != null) {
        try {
          final res = TourHistoryResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          setState(() {
            _tours = res.data;
            _summary = res.summary;
            _isLoading = false;
          });
        } catch (_) {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _tourSub?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  // Open Create Tour Modal
  void _showCreateTourModal() {
    final titleController = TextEditingController();
    final destinationController = TextEditingController();
    final purposeController = TextEditingController();
    final transportController = TextEditingController();
    final daController = TextEditingController();
    final hotelController = TextEditingController();
    final otherController = TextEditingController();

    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 4));
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            final double estTransport =
                double.tryParse(transportController.text.trim()) ?? 0;
            final double estDa =
                double.tryParse(daController.text.trim()) ?? 0;
            final double estHotel =
                double.tryParse(hotelController.text.trim()) ?? 0;
            final double estOther =
                double.tryParse(otherController.text.trim()) ?? 0;
            final double totalEstBudget =
                estTransport + estDa + estHotel + estOther;

            final int daysCount =
                endDate.difference(startDate).inDays + 1;

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.88,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.97),
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
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Submit Tour Plan',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF064E3B),
                                  ),
                                ),
                                Text(
                                  'Send visiting route & estimated expenses',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$daysCount Days',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tour Title
                        _buildModalTextField(
                          'Tour / Route Title',
                          'e.g. Chittagong Territory Market Visit',
                          Icons.route_outlined,
                          titleController,
                        ),
                        const SizedBox(height: 12),

                        // Destination
                        _buildModalTextField(
                          'Destination / Territory Area',
                          'e.g. Agrabad & GEC Circle, Chattogram',
                          Icons.location_on_outlined,
                          destinationController,
                        ),
                        const SizedBox(height: 12),

                        // Date Range Pickers (Start Date & End Date)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: startDate,
                                        firstDate: DateTime.now().subtract(
                                          const Duration(days: 30),
                                        ),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 120),
                                        ),
                                      );
                                      if (picked != null) {
                                        setModalState(() {
                                          startDate = picked;
                                          if (endDate.isBefore(startDate)) {
                                            endDate = startDate;
                                          }
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(startDate),
                                            style: GoogleFonts.outfit(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 15,
                                            color: Color(0xFF059669),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Date',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: endDate,
                                        firstDate: startDate,
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 120),
                                        ),
                                      );
                                      if (picked != null) {
                                        setModalState(() {
                                          endDate = picked;
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(endDate),
                                            style: GoogleFonts.outfit(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 15,
                                            color: Color(0xFF059669),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Purpose / Objective
                        _buildModalTextField(
                          'Purpose / Objectives',
                          'e.g. Expanding retail dealer network and onboarding 20 new shops.',
                          Icons.assignment_outlined,
                          purposeController,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Section Title: Estimated Expenses
                        Text(
                          'ESTIMATED EXPENSES (BUDGET)',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: const Color(0xFF064E3B).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: _buildModalTextField(
                                'Transport (TA)',
                                '৳ 2500',
                                Icons.directions_bus_outlined,
                                transportController,
                                isNumber: true,
                                onChanged: (v) => setModalState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildModalTextField(
                                'Daily Allowance (DA)',
                                '৳ 2000',
                                Icons.fastfood_outlined,
                                daController,
                                isNumber: true,
                                onChanged: (v) => setModalState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _buildModalTextField(
                                'Hotel / Night Stay',
                                '৳ 3500',
                                Icons.hotel_outlined,
                                hotelController,
                                isNumber: true,
                                onChanged: (v) => setModalState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildModalTextField(
                                'Other Expenses',
                                '৳ 800',
                                Icons.more_horiz_rounded,
                                otherController,
                                isNumber: true,
                                onChanged: (v) => setModalState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Total Estimated Budget Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Estimated Budget:',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF064E3B),
                                ),
                              ),
                              Text(
                                '৳${totalEstBudget.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final title = titleController.text.trim();
                                  final destination =
                                      destinationController.text.trim();
                                  final purpose =
                                      purposeController.text.trim();

                                  if (title.isEmpty) {
                                    customToastMessage(
                                      'Warning',
                                      'Please enter tour title',
                                    );
                                    return;
                                  }
                                  if (destination.isEmpty) {
                                    customToastMessage(
                                      'Warning',
                                      'Please enter destination',
                                    );
                                    return;
                                  }

                                  setModalState(() {
                                    isSubmitting = true;
                                  });

                                  final isSuccess =
                                      await postApplyTourRxObj.postApplyTour(
                                    title: title,
                                    destination: destination,
                                    startDate: _formatDate(startDate),
                                    endDate: _formatDate(endDate),
                                    purpose: purpose.isNotEmpty
                                        ? purpose
                                        : 'Market expansion visit',
                                    estTransport: estTransport,
                                    estDa: estDa,
                                    estHotel: estHotel,
                                    estOther: estOther,
                                  );

                                  if (builderContext.mounted) {
                                    setModalState(() {
                                      isSubmitting = false;
                                    });

                                    if (isSuccess) {
                                      getMyToursRxObj.fetchMyTours();
                                      Navigator.pop(builderContext);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            disabledBackgroundColor: const Color(
                              0xFF059669,
                            ).withOpacity(0.6),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit for Approval',
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
      },
    );
  }

  Widget _buildModalTextField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
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
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
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

    final filteredTours = _tours.where((t) {
      final status = t.status.toLowerCase();
      if (_selectedTab == 0) {
        return status == 'pending' || status == 'approved';
      } else {
        return status == 'completed' || status == 'rejected';
      }
    }).toList();

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
            bottom: 80,
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
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
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
                          const SizedBox(width: 6),
                          Text(
                            'Tour Plans',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                        ],
                      ),

                      // Add Tour Button
                      InkWell(
                        onTap: _showCreateTourModal,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF047857)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'New Plan',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Summary Stats Card (if summary available)
                if (_summary != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF064E3B).withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'Total Tours',
                            '${_summary!.totalTours}',
                            const Color(0xFF064E3B),
                          ),
                          _buildSummaryItem(
                            'Pending',
                            '${_summary!.pending}',
                            const Color(0xFFF59E0B),
                          ),
                          _buildSummaryItem(
                            'Approved',
                            '${_summary!.approved}',
                            const Color(0xFF10B981),
                          ),
                          _buildSummaryItem(
                            'Rejected',
                            '${_summary!.rejected}',
                            const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Tab Switcher (Active vs History)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(0, 'Active & Pending'),
                        _buildTabButton(1, 'History & Completed'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tour Plans List / Empty View
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF059669),
                          ),
                        )
                      : filteredTours.isEmpty
                          ? RefreshIndicator(
                              color: const Color(0xFF059669),
                              onRefresh: () =>
                                  getMyToursRxObj.fetchMyTours(),
                              child: ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                children: [
                                  SizedBox(
                                    height: size.height * 0.25,
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981)
                                                .withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.map_outlined,
                                            size: 40,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No Tour Plans Found',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF064E3B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedTab == 0
                                              ? 'Submit your field route by tapping + New Plan'
                                              : 'Completed or rejected tours will appear here',
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
                            )
                          : RefreshIndicator(
                              color: const Color(0xFF059669),
                              onRefresh: () =>
                                  getMyToursRxObj.fetchMyTours(),
                              child: ListView.separated(
                                physics:
                                    const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(18, 4, 18, 24),
                                itemCount: filteredTours.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = filteredTours[index];
                                  final status =
                                      item.status.toLowerCase();

                                  Color statusColor;
                                  String statusLabel;

                                  if (status == 'approved') {
                                    statusColor = const Color(0xFF10B981);
                                    statusLabel = 'APPROVED';
                                  } else if (status == 'pending') {
                                    statusColor = const Color(0xFFF59E0B);
                                    statusLabel = 'PENDING APPROVAL';
                                  } else if (status == 'rejected') {
                                    statusColor = const Color(0xFFEF4444);
                                    statusLabel = 'REJECTED';
                                  } else {
                                    statusColor = const Color(0xFF0D9488);
                                    statusLabel = 'COMPLETED';
                                  }

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 16,
                                        sigmaY: 16,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(0.76),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                      0xFF064E3B)
                                                  .withOpacity(0.05),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Top Row: Title & Status Badge
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.title,
                                                    style:
                                                        GoogleFonts.outfit(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                          0xFF0F172A),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration:
                                                      BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.14),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                  ),
                                                  child: Text(
                                                    statusLabel,
                                                    style:
                                                        GoogleFonts.outfit(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),

                                            // Destination Area
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .location_on_outlined,
                                                  size: 14,
                                                  color:
                                                      Color(0xFF059669),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    item.destination,
                                                    style:
                                                        GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      color: const Color(
                                                          0xFF475569),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Purpose
                                            if (item.purpose
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 2,
                                                    ),
                                                    child: Icon(
                                                      Icons.flag_outlined,
                                                      size: 14,
                                                      color: Color(
                                                          0xFF64748B),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      item.purpose,
                                                      style:
                                                          GoogleFonts.outfit(
                                                        fontSize: 12,
                                                        color: const Color(
                                                            0xFF64748B),
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],

                                            const Divider(
                                              height: 16,
                                              color: Color(0xFFE2E8F0),
                                            ),

                                            // Expense Breakdown Chips
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _buildExpenseChip(
                                                  'TA',
                                                  '৳${item.expenseBreakdown.transportTa}',
                                                ),
                                                _buildExpenseChip(
                                                  'DA',
                                                  '৳${item.expenseBreakdown.dailyAllowanceDa}',
                                                ),
                                                _buildExpenseChip(
                                                  'Hotel',
                                                  '৳${item.expenseBreakdown.hotel}',
                                                ),
                                                _buildExpenseChip(
                                                  'Other',
                                                  '৳${item.expenseBreakdown.other}',
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),

                                            // Bottom Metadata: Date range & Estimated Budget
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      size: 12,
                                                      color: Color(
                                                          0xFF059669),
                                                    ),
                                                    const SizedBox(
                                                        width: 4),
                                                    Text(
                                                      '${item.startDate} to ${item.endDate} (${item.totalDays}d)',
                                                      style: GoogleFonts
                                                          .outfit(
                                                        fontSize: 11.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color(
                                                            0xFF064E3B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  'Est: ৳${item.totalEstimatedBudget}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: const Color(
                                                        0xFF047857),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Supervisor Remarks (if any)
                                            if (item.reviewDetails
                                                    ?.remarks !=
                                                null &&
                                                item.reviewDetails!.remarks!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(
                                                        8),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                      0xFFECFDF5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                  border: Border.all(
                                                    color: const Color(
                                                            0xFF10B981)
                                                        .withOpacity(
                                                            0.25),
                                                  ),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .chat_bubble_outline_rounded,
                                                      size: 14,
                                                      color: Color(
                                                          0xFF059669),
                                                    ),
                                                    const SizedBox(
                                                        width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        'Supervisor: ${item.reviewDetails!.remarks}',
                                                        style: GoogleFonts
                                                            .outfit(
                                                          fontSize: 11,
                                                          color: const Color(
                                                              0xFF047857),
                                                          fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10.5,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseChip(String label, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $amount',
        style: GoogleFonts.outfit(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final bool isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF059669) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/features/employee_part/leave_screen/model/leave_model.dart';
import 'package:location_tracker/networks/api_acess.dart';

class LeaveApplyScreen extends StatefulWidget {
  const LeaveApplyScreen({super.key});

  @override
  State<LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends State<LeaveApplyScreen> {
  List<LeaveModel> _leaves = [];
  LeaveSummaryModel? _summary;
  bool _isLoading = true;
  StreamSubscription? _leaveSub;

  final Map<String, String> _categoryOptions = {
    'Sick Leave': 'sick',
    'Casual Leave': 'casual',
    'Annual Leave': 'annual',
    'Emergency Leave': 'emergency',
  };

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    getMyLeavesRxObj.fetchMyLeaves();

    _leaveSub = getMyLeavesRxObj.fillData.listen((data) {
      if (!mounted) return;
      if (data.isNotEmpty && data['data'] != null) {
        try {
          final res = LeaveHistoryResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          setState(() {
            _leaves = res.data;
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
    _leaveSub?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _formatCategoryName(String? raw) {
    if (raw == null || raw.isEmpty) return 'Leave';
    final lower = raw.toLowerCase().trim();
    if (lower == 'sick' || lower == 'sick leave') return 'Sick Leave';
    if (lower == 'casual' || lower == 'casual leave') return 'Casual Leave';
    if (lower == 'annual' || lower == 'annual leave') return 'Annual Leave';
    if (lower == 'emergency' || lower == 'emergency leave') {
      return 'Emergency Leave';
    }
    return raw
        .split('_')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  // Open Leave Application Modal
  void _showApplyLeaveModal() {
    String selectedType = 'Sick Leave';
    DateTime fromDate = DateTime.now().add(const Duration(days: 1));
    DateTime toDate = DateTime.now().add(const Duration(days: 1));
    final reasonController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            final int totalDays = toDate.difference(fromDate).inDays + 1;
            final keyboardPadding =
                MediaQuery.of(builderContext).viewInsets.bottom;
            final maxHeight =
                MediaQuery.of(builderContext).size.height * 0.85;

            return Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
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
                child: Padding(
                  padding: EdgeInsets.only(bottom: keyboardPadding),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                        Text(
                          'Apply for Leave',
                          style: GoogleFonts.outfit(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF064E3B),
                          ),
                        ),
                        Text(
                          'Official leave request requires supervisor verification',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Leave Type Selection
                        Text(
                          'Select Leave Category',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF064E3B),
                              ),
                              value: selectedType,
                              items: _categoryOptions.keys.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    t,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedType = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Date Pickers Row (From Date & To Date)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'From Date',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: builderContext,
                                        initialDate: fromDate,
                                        firstDate: DateTime.now().subtract(
                                          const Duration(days: 30),
                                        ),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 120),
                                        ),
                                      );
                                      if (picked != null) {
                                        setModalState(() {
                                          fromDate = picked;
                                          if (toDate.isBefore(fromDate)) {
                                            toDate = fromDate;
                                          }
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _formatDate(fromDate),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
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
                                    'To Date',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: builderContext,
                                        initialDate: toDate.isBefore(fromDate)
                                            ? fromDate
                                            : toDate,
                                        firstDate: fromDate,
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 120),
                                        ),
                                      );
                                      if (picked != null) {
                                        setModalState(() {
                                          toDate = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _formatDate(toDate),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
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
                        const SizedBox(height: 8),

                        // Calculated Total Days Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Total Duration: $totalDays Day${totalDays > 1 ? 's' : ''}',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Reason / Purpose
                        Text(
                          'Detailed Reason for Leave',
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
                            controller: reasonController,
                            maxLines: 3,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Explain the reason for taking leave...',
                              hintStyle: GoogleFonts.outfit(
                                fontSize: 12.5,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit Application Button
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final reason = reasonController.text.trim();
                                  if (reason.isEmpty) {
                                    customToastMessage(
                                      'Warning',
                                      'Please enter reason for leave',
                                    );
                                    return;
                                  }

                                  setModalState(() {
                                    isSubmitting = true;
                                  });

                                  final categoryKey =
                                      _categoryOptions[selectedType] ?? 'sick';

                                  final isSuccess =
                                      await postApplyLeaveRxObj.postApplyLeave(
                                    leaveType: categoryKey,
                                    startDate: _formatDate(fromDate),
                                    endDate: _formatDate(toDate),
                                    reason: reason,
                                  );

                                  if (builderContext.mounted) {
                                    setModalState(() {
                                      isSubmitting = false;
                                    });

                                    if (isSuccess) {
                                      getMyLeavesRxObj.fetchMyLeaves();
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
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit Leave Request',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fresh Gradient Background
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
                color: const Color(0xFF34D399).withOpacity(0.25),
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
                color: const Color(0xFFA7F3D0).withOpacity(0.25),
              ),
            ),
          ),

          // 3. Main Screen View
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar - Completely Responsive
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
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Leave Applications',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF064E3B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Apply Leave Button
                      InkWell(
                        onTap: _showApplyLeaveModal,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF047857)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Apply Leave',
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

                // Leave History Summary Cards (from API summary)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      _buildQuotaCard(
                        'Approved',
                        '${_summary?.approved ?? 0}',
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      _buildQuotaCard(
                        'Pending',
                        '${_summary?.pending ?? 0}',
                        const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 6),
                      _buildQuotaCard(
                        'Rejected',
                        '${_summary?.rejected ?? 0}',
                        const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 6),
                      _buildQuotaCard(
                        'Total',
                        '${_summary?.totalApplied ?? 0}',
                        const Color(0xFF0D9488),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'MY LEAVE REQUEST HISTORY',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: const Color(0xFF064E3B).withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Leaves History List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF059669),
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF059669),
                          onRefresh: () async {
                            await getMyLeavesRxObj.fetchMyLeaves();
                          },
                          child: _leaves.isEmpty
                              ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(18),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF10B981,
                                                  ).withOpacity(0.12),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.event_note_outlined,
                                                  size: 40,
                                                  color: Color(0xFF059669),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'No Leave Requests',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFF064E3B),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Submit a leave request by tapping Apply Leave above',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  color:
                                                      const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : ListView.separated(
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    24,
                                  ),
                                  itemCount: _leaves.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = _leaves[index];
                                    final status =
                                        (item.finalStatus ?? 'pending')
                                            .toLowerCase();

                                    Color statusColor;
                                    String statusLabel;

                                    if (status == 'approved') {
                                      statusColor = const Color(0xFF10B981);
                                      statusLabel = 'APPROVED';
                                    } else if (status == 'pending') {
                                      statusColor = const Color(0xFFF59E0B);
                                      statusLabel = 'PENDING';
                                    } else {
                                      statusColor = const Color(0xFFEF4444);
                                      statusLabel = 'REJECTED';
                                    }

                                    return Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF064E3B)
                                                .withOpacity(0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Type & Status
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _formatCategoryName(
                                                    item.leaveType,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: const Color(
                                                      0xFF0F172A,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: statusColor
                                                      .withOpacity(0.14),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  statusLabel,
                                                  style: GoogleFonts.outfit(
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

                                          // Dates & Duration
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.date_range_outlined,
                                                size: 14,
                                                color: Color(0xFF059669),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${item.startDate ?? ""} to ${item.endDate ?? ""}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: const Color(
                                                      0xFF064E3B,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF1F5F9),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${item.totalDays ?? 1} Day${(item.totalDays ?? 1) > 1 ? "s" : ""}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 10.5,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: const Color(
                                                      0xFF475569,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),

                                          // Reason
                                          Text(
                                            item.reason ?? '',
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              color: const Color(0xFF64748B),
                                              height: 1.35,
                                            ),
                                          ),

                                          // Approvals Row (Supervisor & Admin)
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 6,
                                            children: [
                                              _buildApprovalBadge(
                                                'Supervisor',
                                                item.supervisorApproval
                                                        ?.status ??
                                                    'pending',
                                              ),
                                              _buildApprovalBadge(
                                                'Admin',
                                                item.adminApproval
                                                        ?.status ??
                                                    'pending',
                                              ),
                                            ],
                                          ),

                                          // Remarks (if any)
                                          if ((item.supervisorApproval
                                                          ?.remarks !=
                                                      null &&
                                                  item
                                                      .supervisorApproval!
                                                      .remarks!
                                                      .isNotEmpty) ||
                                              (item.adminApproval
                                                          ?.remarks !=
                                                      null &&
                                                  item
                                                      .adminApproval!
                                                      .remarks!
                                                      .isNotEmpty)) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFECFDF5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF10B981,
                                                  ).withOpacity(0.25),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.comment_outlined,
                                                    size: 13,
                                                    color: Color(0xFF059669),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      item
                                                              .supervisorApproval
                                                              ?.remarks ??
                                                          item
                                                              .adminApproval
                                                              ?.remarks ??
                                                          '',
                                                      style:
                                                          GoogleFonts.outfit(
                                                        fontSize: 11,
                                                        color: const Color(
                                                          0xFF047857,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],

                                          // Applied at timestamp
                                          if (item.appliedAt != null &&
                                              item.appliedAt!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  size: 11,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Applied: ${item.appliedAt}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 10.5,
                                                    color: const Color(
                                                      0xFF94A3B8,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
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

  // Approval step mini badge
  Widget _buildApprovalBadge(String role, String status) {
    Color col;
    final st = status.toLowerCase();
    if (st == 'approved') {
      col = const Color(0xFF10B981);
    } else if (st == 'pending') {
      col = const Color(0xFFF59E0B);
    } else {
      col = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: col.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: col.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$role: ${st.toUpperCase()}',
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: col,
            ),
          ),
        ],
      ),
    );
  }

  // Quota / Summary Card Widget - Resilient to Small Screens
  Widget _buildQuotaCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

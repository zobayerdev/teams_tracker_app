import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_tracker/features/employee_part/order_screen/model/get_order_model.dart';
import 'package:location_tracker/networks/api_acess.dart';
import 'order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonthYear;
  final ScrollController _calendarScrollController = ScrollController();

  List<MyOrderModel> _allOrders = [];
  OrderSummaryModel? _summary;
  bool _isLoading = true;
  StreamSubscription? _orderSub;
  bool _showAllOrders = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonthYear = DateTime(_selectedDate.year, _selectedDate.month);

    _initData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  void _initData() {
    getOrderRxObj.fetchOrders();

    _orderSub = getOrderRxObj.fillData.listen((data) {
      if (!mounted) return;
      if (data.isNotEmpty && data['data'] != null) {
        try {
          final res = GetOrderResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          setState(() {
            _allOrders = res.data;
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
    _orderSub?.cancel();
    _calendarScrollController.dispose();
    super.dispose();
  }

  // Calculate days in selected month (28, 29, 30, or 31)
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
      _showAllOrders = false;
    });
    _scrollToSelectedDay();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final totalDaysInCurrentMonth = _daysInMonth(_currentMonthYear);
    final String selectedDateStr = _formatDateKey(_selectedDate);

    // Selected date or all orders filter
    final filteredOrders = _showAllOrders
        ? _allOrders
        : _allOrders
            .where((o) => o.orderDate == selectedDateStr)
            .toList();

    final double dayTotalSales = filteredOrders.fold(
      0.0,
      (sum, o) => sum + o.totalAmount.toDouble(),
    );

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

          // 3. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
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
                            'Field Orders',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                          Text(
                            _summary != null && _summary!.totalOrders > 0
                                ? 'Total: ${_summary!.totalOrders} Orders • ৳${_summary!.totalSales}'
                                : 'Daily shop bookings & delivery logs',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      // Month Selector with Prev & Next arrows
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _changeMonth(-1),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 20,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${_getMonthName(_currentMonthYear.month)} ${_currentMonthYear.year}",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF064E3B),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _changeMonth(1),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 4. Interactive Monthly Horizontal Calendar Bar
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
                      final String dayKey = _formatDateKey(dayDate);
                      final bool isSelected = !_showAllOrders &&
                          _selectedDate.day == dayNum &&
                          _selectedDate.month == dayDate.month &&
                          _selectedDate.year == dayDate.year;
                      final bool hasOrders =
                          _allOrders.any((o) => o.orderDate == dayKey);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = dayDate;
                            _showAllOrders = false;
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
                                    ? const Color(0xFF059669).withOpacity(0.35)
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF064E3B),
                                ),
                              ),
                              if (hasOrders) ...[
                                const SizedBox(height: 2),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF10B981),
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

                const SizedBox(height: 12),

                // Selected Day Summary (Count + Sales Value + All toggle)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            _showAllOrders
                                ? 'All Orders (${filteredOrders.length})'
                                : 'Orders (${filteredOrders.length})',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                          if (_allOrders.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _showAllOrders = !_showAllOrders;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _showAllOrders
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF10B981)
                                          .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _showAllOrders ? 'Filtered' : 'View All',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _showAllOrders
                                        ? Colors.white
                                        : const Color(0xFF047857),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'Total: ৳${dayTotalSales.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 5. Orders List / Empty View
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF059669),
                          ),
                        )
                      : filteredOrders.isEmpty
                          ? RefreshIndicator(
                              color: const Color(0xFF059669),
                              onRefresh: () => getOrderRxObj.fetchOrders(),
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
                                            Icons
                                                .remove_shopping_cart_outlined,
                                            size: 40,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No Orders Found',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF064E3B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'No shop orders booked on ${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                        if (_allOrders.isNotEmpty &&
                                            !_showAllOrders) ...[
                                          const SizedBox(height: 12),
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _showAllOrders = true;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 16,
                                              color: Color(0xFF059669),
                                            ),
                                            label: Text(
                                              'View All (${_allOrders.length}) Orders',
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    const Color(0xFF059669),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: const Color(0xFF059669),
                              onRefresh: () => getOrderRxObj.fetchOrders(),
                              child: ListView.separated(
                                physics:
                                    const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 90),
                                itemCount: filteredOrders.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final o = filteredOrders[index];
                                  final bool isPaid =
                                      o.paymentStatus.toLowerCase() ==
                                          'paid';

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderDetailsScreen(
                                            order: o.toJson(),
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 16,
                                          sigmaY: 16,
                                        ),
                                        child: Container(
                                          padding:
                                              const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withOpacity(0.75),
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
                                                    .withOpacity(0.06),
                                                blurRadius: 18,
                                                offset:
                                                    const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Top Row: Shop Name & Paid/Due Badge
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      o.shopName,
                                                      style:
                                                          GoogleFonts.outfit(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: const Color(
                                                            0xFF0F172A),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration:
                                                        BoxDecoration(
                                                      color: isPaid
                                                          ? const Color(
                                                                  0xFF10B981)
                                                              .withOpacity(
                                                                  0.16)
                                                          : const Color(
                                                                  0xFFEF4444)
                                                              .withOpacity(
                                                                  0.14),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8),
                                                    ),
                                                    child: Text(
                                                      isPaid
                                                          ? 'PAID'
                                                          : 'DUE',
                                                      style:
                                                          GoogleFonts.outfit(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isPaid
                                                            ? const Color(
                                                                0xFF047857)
                                                            : const Color(
                                                                0xFFDC2626),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),

                                              // Mobile & Area
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone_outlined,
                                                    size: 13,
                                                    color: Color(
                                                        0xFF64748B),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    o.shopPhone,
                                                    style:
                                                        GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      color: const Color(
                                                          0xFF64748B),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Icon(
                                                    Icons.tag_rounded,
                                                    size: 13,
                                                    color: Color(
                                                        0xFF64748B),
                                                  ),
                                                  Text(
                                                    '#ORD-${o.orderId}',
                                                    style:
                                                        GoogleFonts.outfit(
                                                      fontSize: 11.5,
                                                      color: const Color(
                                                          0xFF64748B),
                                                    ),
                                                  ),
                                                  if (o.createdTime
                                                      .isNotEmpty) ...[
                                                    const SizedBox(
                                                        width: 8),
                                                    Text(
                                                      '• ${o.createdTime}',
                                                      style: GoogleFonts
                                                          .outfit(
                                                        fontSize: 11.5,
                                                        color: const Color(
                                                            0xFF94A3B8),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),

                                              const Divider(
                                                height: 16,
                                                color: Color(0xFFE2E8F0),
                                              ),

                                              // Bottom Row: Total Amount & View Details Arrow
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Total: ',
                                                        style: GoogleFonts
                                                            .outfit(
                                                          fontSize: 12,
                                                          color: const Color(
                                                              0xFF64748B),
                                                        ),
                                                      ),
                                                      Text(
                                                        '৳${o.totalAmount}',
                                                        style: GoogleFonts
                                                            .outfit(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                          color: const Color(
                                                              0xFF064E3B),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'View Details (${o.itemsCount} items)',
                                                        style: GoogleFonts
                                                            .outfit(
                                                          fontSize: 11.5,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                          color: const Color(
                                                              0xFF059669),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 2),
                                                      const Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        size: 11,
                                                        color: Color(
                                                            0xFF059669),
                                                      ),
                                                    ],
                                                  ),
                                                ],
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

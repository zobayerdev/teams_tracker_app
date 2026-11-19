import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/features/employee_part/catalog_screen/model/product_response_model.dart';
import 'package:location_tracker/features/employee_part/home_screen/model/customer_response_model.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/networks/api_acess.dart';

class OrderProductItem {
  final ProductModel product;
  int qty;

  OrderProductItem({
    required this.product,
    this.qty = 0,
  });
}

class TakeOrderScreen extends StatefulWidget {
  const TakeOrderScreen({super.key});

  @override
  State<TakeOrderScreen> createState() => _TakeOrderScreenState();
}

class _TakeOrderScreenState extends State<TakeOrderScreen> {
  CustomerModel? _selectedCustomer;
  List<CustomerModel> _customers = [];
  List<OrderProductItem> _orderProducts = [];

  bool _isLoadingCustomers = true;
  bool _isLoadingProducts = true;
  bool _isSubmitting = false;

  StreamSubscription? _customerSub;
  StreamSubscription? _productSub;

  String _paymentStatus = 'due'; // 'paid', 'due', 'partial'
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    getCustomerRxObj.fetchCustomers();
    getProductRxObj.fetchProduct();

    _customerSub = getCustomerRxObj.fillData.listen((data) {
      if (!mounted) return;
      if (data.isNotEmpty && data['data'] != null) {
        try {
          final res = CustomerResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          setState(() {
            _customers = res.data;
            if (_selectedCustomer == null && _customers.isNotEmpty) {
              _selectedCustomer = _customers.first;
            }
            _isLoadingCustomers = false;
          });
        } catch (_) {
          setState(() => _isLoadingCustomers = false);
        }
      } else {
        setState(() => _isLoadingCustomers = false);
      }
    });

    _productSub = getProductRxObj.fillData.listen((data) {
      if (!mounted) return;
      if (data.isNotEmpty && data['data'] != null) {
        try {
          final res = ProductResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          setState(() {
            final currentQuantities = {
              for (var item in _orderProducts) item.product.id: item.qty,
            };

            _orderProducts = res.data.map((p) {
              return OrderProductItem(
                product: p,
                qty: currentQuantities[p.id] ?? 0,
              );
            }).toList();
            _isLoadingProducts = false;
          });
        } catch (_) {
          setState(() => _isLoadingProducts = false);
        }
      } else {
        setState(() => _isLoadingProducts = false);
      }
    });
  }

  @override
  void dispose() {
    _customerSub?.cancel();
    _productSub?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    double total = 0.0;
    for (var p in _orderProducts) {
      final price = p.product.shopPrice > 0
          ? p.product.shopPrice.toDouble()
          : p.product.customerPrice.toDouble();
      total += p.qty * price;
    }
    return total;
  }

  int get _totalItemsCount {
    int count = 0;
    for (var p in _orderProducts) {
      count += p.qty;
    }
    return count;
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      int current = _orderProducts[index].qty;
      int maxStock = _orderProducts[index].product.stockQuantity;
      int next = current + change;

      if (next >= 0 && (maxStock == 0 || next <= maxStock)) {
        _orderProducts[index].qty = next;
      }
    });
  }

  void _handleConfirmOrder() async {
    if (_selectedCustomer == null) {
      customToastMessage('Warning', 'Please select a retailer / customer.');
      return;
    }

    final selectedItems = _orderProducts.where((p) => p.qty > 0).toList();
    if (selectedItems.isEmpty || _totalAmount <= 0) {
      customToastMessage(
        'Warning',
        'Kono product select kora hoyni! Onnotomo 1 ti item jog korun.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final int employeeId =
        int.tryParse(appData.read(kKeyUserID)?.toString() ?? '') ?? 1;

    final itemsPayload = selectedItems
        .map((p) => {
              "product_id": p.product.id,
              "quantity": p.qty,
            })
        .toList();

    final bool isSuccess = await postCreateOrderRxObj.postCreateOrder(
      shopName: _selectedCustomer!.shopName,
      shopPhone: _selectedCustomer!.phone,
      phone: _selectedCustomer!.phone,
      ownerName: _selectedCustomer!.ownerName,
      address: _selectedCustomer!.address,
      latitude: _selectedCustomer!.latitude,
      longitude: _selectedCustomer!.longitude,
      createdBy: employeeId,
      paymentStatus: _paymentStatus,
      note: _noteController.text.trim(),
      items: itemsPayload,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (isSuccess) {
      getOrderRxObj.fetchOrders();
      Navigator.pop(context);
    }
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

          // 3. Main Screen Form View
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
                            'Take New Order',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF064E3B),
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
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Live Booking',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Products & Shop List
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shop Selector Card
                        _buildShopSelectorCard(),
                        const SizedBox(height: 18),

                        // Section Title: Products
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PRODUCT CATALOG',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: const Color(0xFF064E3B).withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${_orderProducts.length} Items Available',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: const Color(0xFF059669),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Product Items List
                        if (_isLoadingProducts)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(
                                color: Color(0xFF059669),
                              ),
                            ),
                          )
                        else if (_orderProducts.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'No products available currently.',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _orderProducts.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _orderProducts[index];
                              final int qty = item.qty;
                              final price = item.product.shopPrice > 0
                                  ? item.product.shopPrice
                                  : item.product.customerPrice;

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 14,
                                    sigmaY: 14,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.76),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: qty > 0
                                            ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.5)
                                            : Colors.white,
                                        width: qty > 0 ? 1.6 : 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF064E3B,
                                          ).withOpacity(0.04),
                                          blurRadius: 14,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Product Image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: (item.product.imageUrl !=
                                                      null &&
                                                  item.product.imageUrl!
                                                      .isNotEmpty)
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      item.product.imageUrl!,
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    width: 48,
                                                    height: 48,
                                                    color:
                                                        const Color(0xFF10B981)
                                                            .withOpacity(0.12),
                                                    child: const Center(
                                                      child: SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color:
                                                              Color(0xFF059669),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Container(
                                                    width: 48,
                                                    height: 48,
                                                    color:
                                                        const Color(0xFF10B981)
                                                            .withOpacity(0.12),
                                                    child: const Icon(
                                                      Icons.inventory_2_outlined,
                                                      color: Color(0xFF059669),
                                                      size: 22,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF10B981)
                                                            .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.inventory_2_outlined,
                                                    color: Color(0xFF059669),
                                                    size: 22,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.product.productName,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFF0F172A),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Price: ৳$price  •  Stock: ${item.product.stockQuantity}${item.product.piecePerBox > 0 ? ' (${item.product.piecePerBox}/box)' : ''}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  color:
                                                      const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Stepper Counter (+ / -)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () =>
                                                    _updateQuantity(index, -1),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                    color: Color(0xFF064E3B),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 32,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '$qty',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: qty > 0
                                                        ? const Color(
                                                            0xFF059669)
                                                        : const Color(
                                                            0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () =>
                                                    _updateQuantity(index, 1),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: Color(0xFF064E3B),
                                                  ),
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
                            },
                          ),

                        const SizedBox(height: 18),

                        // Payment Status Selection
                        _buildPaymentMethodSection(),

                        const SizedBox(height: 14),

                        // Special Delivery Instructions / Note
                        _buildOrderNoteInput(),

                        const SizedBox(height: 110), // Bottom sheet gap
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating Bottom Action Calculation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF064E3B).withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Total Breakdown
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL ORDER VALUE',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '৳${_totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF064E3B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_totalItemsCount pcs',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF047857),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Confirm Order Button
                      InkWell(
                        onTap: _isSubmitting ? null : _handleConfirmOrder,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF10B981,
                                ).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Confirm Order',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shop Selector Widget
  Widget _buildShopSelectorCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF064E3B).withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        size: 18,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Target Shop / Retailer',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF064E3B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Change',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isLoadingCustomers)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                )
              else if (_customers.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    'No shops found. Please add a shop first.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CustomerModel>(
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF064E3B),
                      ),
                      value: _selectedCustomer,
                      items: _customers.map((cust) {
                        return DropdownMenuItem<CustomerModel>(
                          value: cust,
                          child: Text(
                            cust.shopName,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCustomer = val;
                        });
                      },
                    ),
                  ),
                ),
              if (_selectedCustomer != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCustomer!.ownerName,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.phone_outlined,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCustomer!.phone,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (_selectedCustomer!.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _selectedCustomer!.address,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Payment Selection Widget
  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT TERMS',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: const Color(0xFF064E3B).withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPaymentTypeChip('Full Due', 'due', const Color(0xFFEF4444)),
            const SizedBox(width: 10),
            _buildPaymentTypeChip('Cash Paid', 'paid', const Color(0xFF10B981)),
            const SizedBox(width: 10),
            _buildPaymentTypeChip(
              'Partial',
              'partial',
              const Color(0xFFF59E0B),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentTypeChip(String title, String val, Color activeColor) {
    final bool isSelected = _paymentStatus == val;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _paymentStatus = val;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(0.14)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  // Order Note Input Widget
  Widget _buildOrderNoteInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _noteController,
        style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF0F172A)),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintText: 'Add special delivery instruction or note...',
          hintStyle: GoogleFonts.outfit(
            fontSize: 12.5,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.note_alt_outlined,
            color: Color(0xFF059669),
            size: 18,
          ),
        ),
      ),
    );
  }
}

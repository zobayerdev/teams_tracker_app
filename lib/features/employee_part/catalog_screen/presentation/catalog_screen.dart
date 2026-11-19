import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_tracker/features/employee_part/catalog_screen/model/product_response_model.dart';
import 'package:location_tracker/helpers/all_routes.dart';
import 'package:location_tracker/helpers/navigation_service.dart';
import 'package:location_tracker/networks/api_acess.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];
  bool _isLoading = true;
  StreamSubscription? _productSub;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    getProductRxObj.fetchProduct();

    _productSub = getProductRxObj.fillData.listen((data) {
      if (!mounted) return;
      if (data.isNotEmpty && data['data'] != null) {
        try {
          final res = ProductResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          setState(() {
            _allProducts = res.data;
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
    _productSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Filtered Products according to search query
  List<ProductModel> get _filteredProducts {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _allProducts;
    return _allProducts.where((p) {
      return p.productName.toLowerCase().contains(query) ||
          p.productCode.toLowerCase().contains(query);
    }).toList();
  }

  // Quick Product Detail / Stock Preview Modal
  void _showProductDetailsModal(ProductModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        final bool inStock = item.stockQuantity > 0;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        item.productCode.isNotEmpty
                            ? item.productCode.toUpperCase()
                            : 'CODE',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: inStock
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        inStock
                            ? 'IN STOCK (${item.stockQuantity} pcs / ${item.stockBoxes} bxs)'
                            : 'STOCK OUT',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: inStock
                              ? const Color(0xFF047857)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: const Color(0xFFECFDF5),
                        child: (item.imageUrl != null &&
                                item.imageUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF059669),
                                  size: 26,
                                ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                color: Color(0xFF059669),
                                size: 26,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Boxes: ${item.stockBoxes}  •  Loose: ${item.stockLoosePcs} pcs  •  ${item.piecePerBox} pcs/box',
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

                // Multi-Tier Price Grid
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEPO PRICE',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '৳${item.depoPrice}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF064E3B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SHOP PRICE',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '৳${item.shopPrice}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CUSTOMER MRP',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '৳${item.customerPrice}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Book Order Button
                ElevatedButton.icon(
                  onPressed: inStock
                      ? () {
                          Navigator.pop(context);
                          NavigationService.navigateTo(Routes.takeOrder);
                        }
                      : null,
                  icon: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    'Book for Shop Order',
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final products = _filteredProducts;

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

          // 3. Main Catalog View
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
                            'Product Catalog',
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
                          '${_allProducts.length} Products',
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

                // Search Bar (Glossy Frosted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF064E3B).withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() {}),
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        hintText: 'Search products by name or code...',
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF059669),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Product Items List / Empty View
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF059669),
                          ),
                        )
                      : products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 40,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No Products Found',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF064E3B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try searching with another keyword or code',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: const Color(0xFF059669),
                              onRefresh: () =>
                                  getProductRxObj.fetchProduct(),
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(18, 4, 18, 24),
                                itemCount: products.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = products[index];
                                  final bool inStock = item.stockQuantity > 0;

                                  return InkWell(
                                    onTap: () =>
                                        _showProductDetailsModal(item),
                                    borderRadius: BorderRadius.circular(20),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 16,
                                          sigmaY: 16,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.76),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF064E3B,
                                                ).withOpacity(0.05),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Product Image
                                                  Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFECFDF5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFF10B981,
                                                        ).withOpacity(0.25),
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13),
                                                      child: (item.imageUrl !=
                                                                  null &&
                                                              item.imageUrl!
                                                                  .isNotEmpty)
                                                          ? CachedNetworkImage(
                                                              imageUrl: item
                                                                  .imageUrl!,
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  (context,
                                                                          url) =>
                                                                      const Center(
                                                                child: SizedBox(
                                                                  width: 18,
                                                                  height: 18,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    color: Color(
                                                                        0xFF059669),
                                                                  ),
                                                                ),
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(
                                                                Icons
                                                                    .image_outlined,
                                                                size: 24,
                                                                color: Color(
                                                                    0xFF059669),
                                                              ),
                                                            )
                                                          : const Icon(
                                                              Icons
                                                                  .image_outlined,
                                                              size: 24,
                                                              color: Color(
                                                                  0xFF059669),
                                                            ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),

                                                  // Product Title & SKU
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.productName,
                                                          style: GoogleFonts
                                                              .outfit(
                                                            fontSize: 14.5,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: const Color(
                                                                0xFF0F172A),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          'Code: ${item.productCode}  •  ${item.piecePerBox} pcs/box',
                                                          style: GoogleFonts
                                                              .outfit(
                                                            fontSize: 11.5,
                                                            color: const Color(
                                                                0xFF64748B),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Stock Badge
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: inStock
                                                          ? const Color(
                                                                  0xFF10B981)
                                                              .withOpacity(0.15)
                                                          : const Color(
                                                                  0xFFEF4444)
                                                              .withOpacity(
                                                                  0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      inStock
                                                          ? '${item.stockQuantity} In Stock'
                                                          : 'Out of Stock',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: inStock
                                                            ? const Color(
                                                                0xFF047857)
                                                            : const Color(
                                                                0xFFDC2626),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const Divider(
                                                height: 18,
                                                color: Color(0xFFE2E8F0),
                                              ),

                                              // Pricing Multi-Tier Row
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'SHOP PRICE',
                                                        style:
                                                            GoogleFonts.outfit(
                                                          fontSize: 9.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF64748B),
                                                        ),
                                                      ),
                                                      Text(
                                                        '৳${item.shopPrice}',
                                                        style:
                                                            GoogleFonts.outfit(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF064E3B),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'DEPO PRICE',
                                                        style:
                                                            GoogleFonts.outfit(
                                                          fontSize: 9.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF64748B),
                                                        ),
                                                      ),
                                                      Text(
                                                        '৳${item.depoPrice}',
                                                        style:
                                                            GoogleFonts.outfit(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color(
                                                              0xFF475569),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'CUSTOMER MRP',
                                                        style:
                                                            GoogleFonts.outfit(
                                                          fontSize: 9.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF047857),
                                                        ),
                                                      ),
                                                      Text(
                                                        '৳${item.customerPrice}',
                                                        style:
                                                            GoogleFonts.outfit(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF047857),
                                                        ),
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

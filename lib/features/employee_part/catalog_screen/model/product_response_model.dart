import 'dart:convert';

ProductResponseModel productResponseModelFromJson(String str) =>
    ProductResponseModel.fromJson(json.decode(str));

String productResponseModelToJson(ProductResponseModel data) =>
    json.encode(data.toJson());

class ProductResponseModel {
  final bool? status;
  final String? message;
  final int? totalCount;
  final List<ProductModel> data;

  ProductResponseModel({
    this.status,
    this.message,
    this.totalCount,
    this.data = const [],
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) =>
      ProductResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        totalCount: int.tryParse(json["total_count"]?.toString() ?? ''),
        data: json["data"] == null
            ? []
            : List<ProductModel>.from(
                (json["data"] as List).map(
                  (x) => ProductModel.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "total_count": totalCount,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ProductModel {
  final int id;
  final String productName;
  final String productCode;
  final int piecePerBox;
  final int stockQuantity;
  final int stockBoxes;
  final int stockLoosePcs;
  final num depoPrice;
  final num shopPrice;
  final num customerPrice;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.productName,
    required this.productCode,
    this.piecePerBox = 0,
    this.stockQuantity = 0,
    this.stockBoxes = 0,
    this.stockLoosePcs = 0,
    this.depoPrice = 0,
    this.shopPrice = 0,
    this.customerPrice = 0,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: int.tryParse(json["id"]?.toString() ?? '') ?? 0,
    productName: json["product_name"]?.toString() ?? '',
    productCode: json["product_code"]?.toString() ?? '',
    piecePerBox: int.tryParse(json["piece_per_box"]?.toString() ?? '') ?? 0,
    stockQuantity: int.tryParse(json["stock_quantity"]?.toString() ?? '') ?? 0,
    stockBoxes: int.tryParse(json["stock_boxes"]?.toString() ?? '') ?? 0,
    stockLoosePcs: int.tryParse(json["stock_loose_pcs"]?.toString() ?? '') ?? 0,
    depoPrice: num.tryParse(json["depo_price"]?.toString() ?? '') ?? 0,
    shopPrice: num.tryParse(json["shop_price"]?.toString() ?? '') ?? 0,
    customerPrice: num.tryParse(json["customer_price"]?.toString() ?? '') ?? 0,
    imageUrl: json["image_url"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_name": productName,
    "product_code": productCode,
    "piece_per_box": piecePerBox,
    "stock_quantity": stockQuantity,
    "stock_boxes": stockBoxes,
    "stock_loose_pcs": stockLoosePcs,
    "depo_price": depoPrice,
    "shop_price": shopPrice,
    "customer_price": customerPrice,
    "image_url": imageUrl,
  };
}

import 'dart:convert';

GetOrderResponseModel getOrderResponseModelFromJson(String str) =>
    GetOrderResponseModel.fromJson(json.decode(str));

String getOrderResponseModelToJson(GetOrderResponseModel data) =>
    json.encode(data.toJson());

class GetOrderResponseModel {
  final bool? status;
  final String? message;
  final OrderSummaryModel? summary;
  final List<MyOrderModel> data;

  GetOrderResponseModel({
    this.status,
    this.message,
    this.summary,
    this.data = const [],
  });

  factory GetOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      GetOrderResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        summary: json["summary"] != null && json["summary"] is Map
            ? OrderSummaryModel.fromJson(Map<String, dynamic>.from(json["summary"]))
            : null,
        data: json["data"] == null
            ? []
            : List<MyOrderModel>.from(
                (json["data"] as List).map(
                  (x) => MyOrderModel.fromJson(
                    x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x),
                  ),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "summary": summary?.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class OrderSummaryModel {
  final int totalOrders;
  final num totalSales;
  final num totalCollected;
  final num totalDue;

  OrderSummaryModel({
    this.totalOrders = 0,
    this.totalSales = 0,
    this.totalCollected = 0,
    this.totalDue = 0,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) =>
      OrderSummaryModel(
        totalOrders: int.tryParse(json["total_orders"]?.toString() ?? '') ?? 0,
        totalSales: num.tryParse(json["total_sales"]?.toString() ?? '') ?? 0,
        totalCollected:
            num.tryParse(json["total_collected"]?.toString() ?? '') ?? 0,
        totalDue: num.tryParse(json["total_due"]?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "total_orders": totalOrders,
    "total_sales": totalSales,
    "total_collected": totalCollected,
    "total_due": totalDue,
  };
}

class MyOrderModel {
  final int orderId;
  final String shopName;
  final String shopPhone;
  final String shopAddress;
  final num latitude;
  final num longitude;
  final num totalAmount;
  final num paidAmount;
  final num dueAmount;
  final String paymentStatus;
  final String orderStatus;
  final String orderDate;
  final String createdTime;
  final int itemsCount;
  final List<MyOrderItemModel> items;

  MyOrderModel({
    required this.orderId,
    required this.shopName,
    required this.shopPhone,
    this.shopAddress = '',
    this.latitude = 0,
    this.longitude = 0,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.dueAmount = 0,
    this.paymentStatus = 'due',
    this.orderStatus = 'confirmed',
    this.orderDate = '',
    this.createdTime = '',
    this.itemsCount = 0,
    this.items = const [],
  });

  factory MyOrderModel.fromJson(Map<String, dynamic> json) => MyOrderModel(
    orderId: int.tryParse(json["order_id"]?.toString() ?? '') ?? 0,
    shopName: json["shop_name"]?.toString() ?? '',
    shopPhone: json["shop_phone"]?.toString() ?? '',
    shopAddress: json["shop_address"]?.toString() ?? '',
    latitude: num.tryParse(json["latitude"]?.toString() ?? '') ?? 0,
    longitude: num.tryParse(json["longitude"]?.toString() ?? '') ?? 0,
    totalAmount: num.tryParse(json["total_amount"]?.toString() ?? '') ?? 0,
    paidAmount: num.tryParse(json["paid_amount"]?.toString() ?? '') ?? 0,
    dueAmount: num.tryParse(json["due_amount"]?.toString() ?? '') ?? 0,
    paymentStatus: json["payment_status"]?.toString() ?? 'due',
    orderStatus: json["order_status"]?.toString() ?? 'confirmed',
    orderDate: json["order_date"]?.toString() ?? '',
    createdTime: json["created_time"]?.toString() ?? '',
    itemsCount: int.tryParse(json["items_count"]?.toString() ?? '') ?? 0,
    items: json["items"] == null
        ? []
        : List<MyOrderItemModel>.from(
            (json["items"] as List).map(
              (x) => MyOrderItemModel.fromJson(
                x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x),
              ),
            ),
          ),
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "shop_name": shopName,
    "shop_phone": shopPhone,
    "shop_address": shopAddress,
    "latitude": latitude,
    "longitude": longitude,
    "total_amount": totalAmount,
    "paid_amount": paidAmount,
    "due_amount": dueAmount,
    "payment_status": paymentStatus,
    "order_status": orderStatus,
    "order_date": orderDate,
    "created_time": createdTime,
    "items_count": itemsCount,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class MyOrderItemModel {
  final int productId;
  final String productName;
  final String productCode;
  final int quantity;
  final num unitPrice;
  final num subtotal;

  MyOrderItemModel({
    required this.productId,
    required this.productName,
    this.productCode = '',
    this.quantity = 0,
    this.unitPrice = 0,
    this.subtotal = 0,
  });

  factory MyOrderItemModel.fromJson(Map<String, dynamic> json) =>
      MyOrderItemModel(
        productId: int.tryParse(json["product_id"]?.toString() ?? '') ?? 0,
        productName: json["product_name"]?.toString() ?? '',
        productCode: json["product_code"]?.toString() ?? '',
        quantity: int.tryParse(json["quantity"]?.toString() ?? '') ?? 0,
        unitPrice: num.tryParse(json["unit_price"]?.toString() ?? '') ?? 0,
        subtotal: num.tryParse(json["subtotal"]?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "product_name": productName,
    "product_code": productCode,
    "quantity": quantity,
    "unit_price": unitPrice,
    "subtotal": subtotal,
  };
}

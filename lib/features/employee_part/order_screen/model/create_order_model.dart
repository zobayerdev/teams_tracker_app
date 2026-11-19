import 'dart:convert';

CreateOrderResponseModel createOrderResponseModelFromJson(String str) =>
    CreateOrderResponseModel.fromJson(json.decode(str));

String createOrderResponseModelToJson(CreateOrderResponseModel data) =>
    json.encode(data.toJson());

class CreateOrderItemRequestModel {
  final int productId;
  final int quantity;

  CreateOrderItemRequestModel({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "quantity": quantity,
  };

  factory CreateOrderItemRequestModel.fromJson(Map<String, dynamic> json) =>
      CreateOrderItemRequestModel(
        productId: int.tryParse(json["product_id"]?.toString() ?? '') ?? 0,
        quantity: int.tryParse(json["quantity"]?.toString() ?? '') ?? 0,
      );
}

class CreateOrderRequestModel {
  final String shopName;
  final String shopPhone;
  final String? phone;
  final String? ownerName;
  final String? address;
  final num? latitude;
  final num? longitude;
  final int createdBy;
  final String paymentStatus;
  final String? note;
  final List<CreateOrderItemRequestModel> items;

  CreateOrderRequestModel({
    required this.shopName,
    required this.shopPhone,
    this.phone,
    this.ownerName,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdBy,
    this.paymentStatus = 'due',
    this.note,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    "shop_name": shopName,
    "shop_phone": shopPhone,
    "phone": phone ?? shopPhone,
    if (ownerName != null) "owner_name": ownerName,
    if (address != null) "address": address,
    "latitude": ?latitude,
    "longitude": ?longitude,
    "created_by": createdBy,
    "payment_status": paymentStatus,
    if (note != null && note!.isNotEmpty) "note": note,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class CreateOrderResponseModel {
  final bool? status;
  final String? message;
  final OrderDataModel? data;

  CreateOrderResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateOrderResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? OrderDataModel.fromJson(json["data"])
            : (json["data"] != null && json["data"] is Map
                ? OrderDataModel.fromJson(Map<String, dynamic>.from(json["data"]))
                : null),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class OrderDataModel {
  final int orderId;
  final String? employeeName;
  final String shopName;
  final String shopPhone;
  final num totalAmount;
  final String paymentStatus;
  final int totalItems;
  final List<OrderItemModel> items;
  final String? orderDate;

  OrderDataModel({
    required this.orderId,
    this.employeeName,
    required this.shopName,
    required this.shopPhone,
    required this.totalAmount,
    required this.paymentStatus,
    required this.totalItems,
    this.items = const [],
    this.orderDate,
  });

  factory OrderDataModel.fromJson(Map<String, dynamic> json) => OrderDataModel(
    orderId: int.tryParse(json["order_id"]?.toString() ?? '') ?? 0,
    employeeName: json["employee_name"]?.toString(),
    shopName: json["shop_name"]?.toString() ?? '',
    shopPhone: json["shop_phone"]?.toString() ?? '',
    totalAmount: num.tryParse(json["total_amount"]?.toString() ?? '') ?? 0,
    paymentStatus: json["payment_status"]?.toString() ?? 'due',
    totalItems: int.tryParse(json["total_items"]?.toString() ?? '') ?? 0,
    items: json["items"] == null
        ? []
        : List<OrderItemModel>.from(
            (json["items"] as List).map(
              (x) => OrderItemModel.fromJson(
                x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x),
              ),
            ),
          ),
    orderDate: json["order_date"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "employee_name": employeeName,
    "shop_name": shopName,
    "shop_phone": shopPhone,
    "total_amount": totalAmount,
    "payment_status": paymentStatus,
    "total_items": totalItems,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "order_date": orderDate,
  };
}

class OrderItemModel {
  final int productId;
  final String productName;
  final int quantity;
  final num unitPrice;
  final num subtotal;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    productId: int.tryParse(json["product_id"]?.toString() ?? '') ?? 0,
    productName: json["product_name"]?.toString() ?? '',
    quantity: int.tryParse(json["quantity"]?.toString() ?? '') ?? 0,
    unitPrice: num.tryParse(json["unit_price"]?.toString() ?? '') ?? 0,
    subtotal: num.tryParse(json["subtotal"]?.toString() ?? '') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "product_name": productName,
    "quantity": quantity,
    "unit_price": unitPrice,
    "subtotal": subtotal,
  };
}

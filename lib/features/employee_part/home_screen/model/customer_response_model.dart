import 'dart:convert';

CustomerResponseModel customerResponseModelFromJson(String str) =>
    CustomerResponseModel.fromJson(json.decode(str));

String customerResponseModelToJson(CustomerResponseModel data) =>
    json.encode(data.toJson());

class CustomerResponseModel {
  final bool? status;
  final String? message;
  final int? total;
  final List<CustomerModel> data;

  CustomerResponseModel({
    this.status,
    this.message,
    this.total,
    this.data = const [],
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) =>
      CustomerResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        total: int.tryParse(json["total"]?.toString() ?? ''),
        data: json["data"] == null
            ? []
            : List<CustomerModel>.from(
                (json["data"] as List).map(
                  (x) => CustomerModel.fromJson(
                    x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x),
                  ),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "total": total,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CustomerModel {
  final int id;
  final String shopName;
  final String ownerName;
  final String phone;
  final String address;
  final num latitude;
  final num longitude;
  final String status;
  final int createdBy;
  final String? createdAt;
  final String? createdByName;

  CustomerModel({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.status = 'active',
    this.createdBy = 0,
    this.createdAt,
    this.createdByName,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: int.tryParse(json["id"]?.toString() ?? '') ?? 0,
    shopName: json["shop_name"]?.toString() ?? '',
    ownerName: json["owner_name"]?.toString() ?? '',
    phone: json["phone"]?.toString() ?? '',
    address: json["address"]?.toString() ?? '',
    latitude: num.tryParse(json["latitude"]?.toString() ?? '') ?? 0.0,
    longitude: num.tryParse(json["longitude"]?.toString() ?? '') ?? 0.0,
    status: json["status"]?.toString() ?? 'active',
    createdBy: int.tryParse(json["created_by"]?.toString() ?? '') ?? 0,
    createdAt: json["created_at"]?.toString(),
    createdByName: json["created_by_name"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "shop_name": shopName,
    "owner_name": ownerName,
    "phone": phone,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "status": status,
    "created_by": createdBy,
    "created_at": createdAt,
    "created_by_name": createdByName,
  };
}

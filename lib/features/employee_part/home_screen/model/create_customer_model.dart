import 'dart:convert';

CreateCustomerResponseModel createCustomerResponseModelFromJson(String str) =>
    CreateCustomerResponseModel.fromJson(json.decode(str));

String createCustomerResponseModelToJson(CreateCustomerResponseModel data) =>
    json.encode(data.toJson());

class CreateCustomerRequestModel {
  final String shopName;
  final String ownerName;
  final String phone;
  final String address;
  final num latitude;
  final num longitude;
  final int createdBy;

  CreateCustomerRequestModel({
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
    "shop_name": shopName,
    "owner_name": ownerName,
    "phone": phone,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "created_by": createdBy,
  };

  factory CreateCustomerRequestModel.fromJson(Map<String, dynamic> json) =>
      CreateCustomerRequestModel(
        shopName: json["shop_name"]?.toString() ?? '',
        ownerName: json["owner_name"]?.toString() ?? '',
        phone: json["phone"]?.toString() ?? '',
        address: json["address"]?.toString() ?? '',
        latitude: num.tryParse(json["latitude"]?.toString() ?? '') ?? 0.0,
        longitude: num.tryParse(json["longitude"]?.toString() ?? '') ?? 0.0,
        createdBy: int.tryParse(json["created_by"]?.toString() ?? '') ?? 0,
      );
}

class CreateCustomerResponseModel {
  final bool? status;
  final String? message;
  final dynamic data;

  CreateCustomerResponseModel({this.status, this.message, this.data});

  factory CreateCustomerResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateCustomerResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };
}

import 'dart:convert';

ChangePasswordResponseModel changePasswordResponseModelFromJson(String str) =>
    ChangePasswordResponseModel.fromJson(json.decode(str));

String changePasswordResponseModelToJson(ChangePasswordResponseModel data) =>
    json.encode(data.toJson());

class ChangePasswordRequestModel {
  final dynamic userId;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequestModel({
    required this.userId,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "new_password": newPassword,
    "confirm_password": confirmPassword,
  };
}

class ChangePasswordResponseModel {
  final bool? status;
  final String? message;

  ChangePasswordResponseModel({this.status, this.message});

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      ChangePasswordResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}

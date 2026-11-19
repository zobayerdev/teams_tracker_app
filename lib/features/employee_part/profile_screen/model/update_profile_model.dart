import 'dart:convert';

UpdateProfileResponseModel updateProfileResponseModelFromJson(String str) =>
    UpdateProfileResponseModel.fromJson(json.decode(str));

String updateProfileResponseModelToJson(UpdateProfileResponseModel data) =>
    json.encode(data.toJson());

class UpdateProfileResponseModel {
  final bool? status;
  final String? message;
  final UpdateProfileData? data;

  UpdateProfileResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      UpdateProfileResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        data: json["data"] != null && json["data"] is Map
            ? UpdateProfileData.fromJson(Map<String, dynamic>.from(json["data"]))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class UpdateProfileData {
  final int? id;
  final String? name;
  final String? profileImage;
  final String? profileImageUrl;

  UpdateProfileData({
    this.id,
    this.name,
    this.profileImage,
    this.profileImageUrl,
  });

  factory UpdateProfileData.fromJson(Map<String, dynamic> json) =>
      UpdateProfileData(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"]?.toString() ?? ''),
        name: json["name"]?.toString(),
        profileImage: json["profile_image"]?.toString(),
        profileImageUrl: json["profile_image_url"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profile_image": profileImage,
        "profile_image_url": profileImageUrl,
      };
}

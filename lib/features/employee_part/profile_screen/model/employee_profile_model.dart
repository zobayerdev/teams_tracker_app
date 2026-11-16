import 'dart:convert';

EmployeeProfileResponseModel employeeProfileResponseModelFromJson(String str) =>
    EmployeeProfileResponseModel.fromJson(json.decode(str));

String employeeProfileResponseModelToJson(EmployeeProfileResponseModel data) =>
    json.encode(data.toJson());

class EmployeeProfileResponseModel {
  bool? status;
  String? message;
  EmployeeProfileData? data;

  EmployeeProfileResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory EmployeeProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      EmployeeProfileResponseModel(
        status: json["status"] is bool ? json["status"] : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? EmployeeProfileData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class EmployeeProfileData {
  ProfileModel? profile;
  SupervisorModel? supervisor;
  StatisticsModel? statistics;

  EmployeeProfileData({
    this.profile,
    this.supervisor,
    this.statistics,
  });

  factory EmployeeProfileData.fromJson(Map<String, dynamic> json) =>
      EmployeeProfileData(
        profile: json["profile"] != null && json["profile"] is Map<String, dynamic>
            ? ProfileModel.fromJson(json["profile"])
            : null,
        supervisor: json["supervisor"] != null && json["supervisor"] is Map<String, dynamic>
            ? SupervisorModel.fromJson(json["supervisor"])
            : null,
        statistics: json["statistics"] != null && json["statistics"] is Map<String, dynamic>
            ? StatisticsModel.fromJson(json["statistics"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "profile": profile?.toJson(),
        "supervisor": supervisor?.toJson(),
        "statistics": statistics?.toJson(),
      };
}

class ProfileModel {
  int? id;
  String? name;
  String? email;
  String? mobile;
  String? designation;
  String? roleType;
  String? status;
  int? age;
  String? nid;
  String? dob;
  String? fatherName;
  String? motherName;
  String? religion;
  String? bloodGroup;
  String? education;
  String? presentAddress;
  String? permanentAddress;
  num? salary;
  String? memberSince;

  ProfileModel({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.designation,
    this.roleType,
    this.status,
    this.age,
    this.nid,
    this.dob,
    this.fatherName,
    this.motherName,
    this.religion,
    this.bloodGroup,
    this.education,
    this.presentAddress,
    this.permanentAddress,
    this.salary,
    this.memberSince,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
        name: json["name"]?.toString(),
        email: json["email"]?.toString(),
        mobile: json["mobile"]?.toString(),
        designation: json["designation"]?.toString(),
        roleType: json["role_type"]?.toString(),
        status: json["status"]?.toString(),
        age: json["age"] is int ? json["age"] : int.tryParse(json["age"]?.toString() ?? ''),
        nid: json["nid"]?.toString(),
        dob: json["dob"]?.toString(),
        fatherName: json["father_name"]?.toString(),
        motherName: json["mother_name"]?.toString(),
        religion: json["religion"]?.toString(),
        bloodGroup: json["blood_group"]?.toString(),
        education: json["education"]?.toString(),
        presentAddress: json["present_address"]?.toString(),
        permanentAddress: json["permanent_address"]?.toString(),
        salary: json["salary"] is num ? json["salary"] : num.tryParse(json["salary"]?.toString() ?? ''),
        memberSince: json["member_since"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "designation": designation,
        "role_type": roleType,
        "status": status,
        "age": age,
        "nid": nid,
        "dob": dob,
        "father_name": fatherName,
        "mother_name": motherName,
        "religion": religion,
        "blood_group": bloodGroup,
        "education": education,
        "present_address": presentAddress,
        "permanent_address": permanentAddress,
        "salary": salary,
        "member_since": memberSince,
      };
}

class SupervisorModel {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? designation;

  SupervisorModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.designation,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) =>
      SupervisorModel(
        id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
        name: json["name"]?.toString(),
        phone: json["phone"]?.toString(),
        email: json["email"]?.toString(),
        designation: json["designation"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "designation": designation,
      };
}

class StatisticsModel {
  num? totalOrders;
  num? totalSales;
  num? totalCollected;
  num? pendingLeaves;
  num? approvedTours;

  StatisticsModel({
    this.totalOrders,
    this.totalSales,
    this.totalCollected,
    this.pendingLeaves,
    this.approvedTours,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) =>
      StatisticsModel(
        totalOrders: json["total_orders"] is num
            ? json["total_orders"]
            : num.tryParse(json["total_orders"]?.toString() ?? ''),
        totalSales: json["total_sales"] is num
            ? json["total_sales"]
            : num.tryParse(json["total_sales"]?.toString() ?? ''),
        totalCollected: json["total_collected"] is num
            ? json["total_collected"]
            : num.tryParse(json["total_collected"]?.toString() ?? ''),
        pendingLeaves: json["pending_leaves"] is num
            ? json["pending_leaves"]
            : num.tryParse(json["pending_leaves"]?.toString() ?? ''),
        approvedTours: json["approved_tours"] is num
            ? json["approved_tours"]
            : num.tryParse(json["approved_tours"]?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        "total_orders": totalOrders,
        "total_sales": totalSales,
        "total_collected": totalCollected,
        "pending_leaves": pendingLeaves,
        "approved_tours": approvedTours,
      };
}

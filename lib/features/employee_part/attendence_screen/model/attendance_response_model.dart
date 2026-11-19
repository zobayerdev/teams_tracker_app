import 'dart:convert';

AttendanceResponseModel attendanceResponseModelFromJson(String str) =>
    AttendanceResponseModel.fromJson(json.decode(str));

String attendanceResponseModelToJson(AttendanceResponseModel data) =>
    json.encode(data.toJson());

class AttendanceResponseModel {
  final bool? status;
  final String? message;
  final String? month;
  final AttendanceEmployee? employee;
  final AttendanceSummary? summary;
  final List<AttendanceRecordModel>? data;

  AttendanceResponseModel({
    this.status,
    this.message,
    this.month,
    this.employee,
    this.summary,
    this.data,
  });

  factory AttendanceResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => AttendanceResponseModel(
    status: json["status"] is bool
        ? json["status"]
        : (json["status"] == 1 || json["status"] == "true"),
    message: json["message"]?.toString(),
    month: json["month"]?.toString(),
    employee:
        json["employee"] != null && json["employee"] is Map<String, dynamic>
        ? AttendanceEmployee.fromJson(
            Map<String, dynamic>.from(json["employee"]),
          )
        : null,
    summary: json["summary"] != null && json["summary"] is Map<String, dynamic>
        ? AttendanceSummary.fromJson(Map<String, dynamic>.from(json["summary"]))
        : null,
    data: json["data"] != null && json["data"] is List
        ? List<AttendanceRecordModel>.from(
            (json["data"] as List).whereType<Map>().map(
              (x) =>
                  AttendanceRecordModel.fromJson(Map<String, dynamic>.from(x)),
            ),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "month": month,
    "employee": employee?.toJson(),
    "summary": summary?.toJson(),
    "data": data != null
        ? List<dynamic>.from(data!.map((x) => x.toJson()))
        : null,
  };
}

class AttendanceEmployee {
  final int? id;
  final String? name;
  final String? mobile;
  final String? designation;
  final String? role;

  AttendanceEmployee({
    this.id,
    this.name,
    this.mobile,
    this.designation,
    this.role,
  });

  factory AttendanceEmployee.fromJson(Map<String, dynamic> json) =>
      AttendanceEmployee(
        id:
            int.tryParse(json["id"]?.toString() ?? '') ??
            (json["id"] is int ? json["id"] : null),
        name: json["name"]?.toString(),
        mobile: json["mobile"]?.toString(),
        designation: json["designation"]?.toString(),
        role: json["role"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile": mobile,
    "designation": designation,
    "role": role,
  };
}

class AttendanceSummary {
  final int? totalWorkingDaysLogged;
  final int? presentDays;
  final int? lateDays;
  final int? absentDays;
  final num? totalHoursWorked;

  AttendanceSummary({
    this.totalWorkingDaysLogged,
    this.presentDays,
    this.lateDays,
    this.absentDays,
    this.totalHoursWorked,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      AttendanceSummary(
        totalWorkingDaysLogged:
            int.tryParse(json["total_working_days_logged"]?.toString() ?? '') ??
            (json["total_working_days_logged"] is int
                ? json["total_working_days_logged"]
                : null),
        presentDays:
            int.tryParse(json["present_days"]?.toString() ?? '') ??
            (json["present_days"] is int ? json["present_days"] : null),
        lateDays:
            int.tryParse(json["late_days"]?.toString() ?? '') ??
            (json["late_days"] is int ? json["late_days"] : null),
        absentDays:
            int.tryParse(json["absent_days"]?.toString() ?? '') ??
            (json["absent_days"] is int ? json["absent_days"] : null),
        totalHoursWorked: num.tryParse(
          json["total_hours_worked"]?.toString() ?? '',
        ),
      );

  Map<String, dynamic> toJson() => {
    "total_working_days_logged": totalWorkingDaysLogged,
    "present_days": presentDays,
    "late_days": lateDays,
    "absent_days": absentDays,
    "total_hours_worked": totalHoursWorked,
  };
}

class AttendanceRecordModel {
  final int? id;
  final String? date;
  final String? dayName;
  final String? inTime;
  final String? outTime;
  final String? workingHours;
  final num? decimalHours;
  final String? status;
  final AttendanceLocation? checkIn;
  final AttendanceLocation? checkOut;

  AttendanceRecordModel({
    this.id,
    this.date,
    this.dayName,
    this.inTime,
    this.outTime,
    this.workingHours,
    this.decimalHours,
    this.status,
    this.checkIn,
    this.checkOut,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) =>
      AttendanceRecordModel(
        id:
            int.tryParse(json["id"]?.toString() ?? '') ??
            (json["id"] is int ? json["id"] : null),
        date: json["date"]?.toString(),
        dayName: json["day_name"]?.toString(),
        inTime: json["in_time"]?.toString(),
        outTime: json["out_time"]?.toString(),
        workingHours: json["working_hours"]?.toString(),
        decimalHours: num.tryParse(json["decimal_hours"]?.toString() ?? ''),
        status: json["status"]?.toString(),
        checkIn:
            json["check_in"] != null && json["check_in"] is Map<String, dynamic>
            ? AttendanceLocation.fromJson(
                Map<String, dynamic>.from(json["check_in"]),
              )
            : null,
        checkOut:
            json["check_out"] != null &&
                json["check_out"] is Map<String, dynamic>
            ? AttendanceLocation.fromJson(
                Map<String, dynamic>.from(json["check_out"]),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "day_name": dayName,
    "in_time": inTime,
    "out_time": outTime,
    "working_hours": workingHours,
    "decimal_hours": decimalHours,
    "status": status,
    "check_in": checkIn?.toJson(),
    "check_out": checkOut?.toJson(),
  };

  String? get inAddress => checkIn?.address;
  String? get outAddress => checkOut?.address;
  num? get inLat => checkIn?.latitude;
  num? get inLng => checkIn?.longitude;
  num? get outLat => checkOut?.latitude;
  num? get outLng => checkOut?.longitude;
}

class AttendanceLocation {
  final num? latitude;
  final num? longitude;
  final String? address;

  AttendanceLocation({this.latitude, this.longitude, this.address});

  factory AttendanceLocation.fromJson(Map<String, dynamic> json) =>
      AttendanceLocation(
        latitude: num.tryParse(json["latitude"]?.toString() ?? ''),
        longitude: num.tryParse(json["longitude"]?.toString() ?? ''),
        address: json["address"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
    "address": address,
  };
}

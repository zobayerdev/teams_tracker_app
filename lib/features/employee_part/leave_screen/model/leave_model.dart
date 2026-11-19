import 'dart:convert';

LeaveHistoryResponseModel leaveHistoryResponseModelFromJson(String str) =>
    LeaveHistoryResponseModel.fromJson(json.decode(str));

String leaveHistoryResponseModelToJson(LeaveHistoryResponseModel data) =>
    json.encode(data.toJson());

class CreateLeaveRequestModel {
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;

  CreateLeaveRequestModel({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    "leave_type": leaveType,
    "start_date": startDate,
    "end_date": endDate,
    "reason": reason,
  };
}

class CreateLeaveResponseModel {
  final bool? status;
  final String? message;
  final dynamic data;

  CreateLeaveResponseModel({this.status, this.message, this.data});

  factory CreateLeaveResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateLeaveResponseModel(
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

class LeaveHistoryResponseModel {
  final bool? status;
  final String? message;
  final LeaveSummaryModel? summary;
  final List<LeaveModel> data;

  LeaveHistoryResponseModel({
    this.status,
    this.message,
    this.summary,
    this.data = const [],
  });

  factory LeaveHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      LeaveHistoryResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        summary: json["summary"] != null && json["summary"] is Map
            ? LeaveSummaryModel.fromJson(Map<String, dynamic>.from(json["summary"]))
            : null,
        data: json["data"] == null
            ? []
            : List<LeaveModel>.from(
                (json["data"] as List).map(
                  (x) => LeaveModel.fromJson(
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

class LeaveSummaryModel {
  final int totalApplied;
  final int approved;
  final int pending;
  final int rejected;

  LeaveSummaryModel({
    this.totalApplied = 0,
    this.approved = 0,
    this.pending = 0,
    this.rejected = 0,
  });

  factory LeaveSummaryModel.fromJson(Map<String, dynamic> json) =>
      LeaveSummaryModel(
        totalApplied: _parseInt(json["total_applied"]),
        approved: _parseInt(json["approved"]),
        pending: _parseInt(json["pending"]),
        rejected: _parseInt(json["rejected"]),
      );

  Map<String, dynamic> toJson() => {
    "total_applied": totalApplied,
    "approved": approved,
    "pending": pending,
    "rejected": rejected,
  };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class LeaveModel {
  final int? leaveId;
  final String? leaveType;
  final String? startDate;
  final String? endDate;
  final int? totalDays;
  final String? reason;
  final LeaveApprovalModel? supervisorApproval;
  final LeaveApprovalModel? adminApproval;
  final String? finalStatus;
  final String? appliedAt;

  LeaveModel({
    this.leaveId,
    this.leaveType,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.reason,
    this.supervisorApproval,
    this.adminApproval,
    this.finalStatus,
    this.appliedAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
    leaveId: _parseIntNullable(json["leave_id"]),
    leaveType: json["leave_type"]?.toString(),
    startDate: json["start_date"]?.toString(),
    endDate: json["end_date"]?.toString(),
    totalDays: _parseIntNullable(json["total_days"]),
    reason: json["reason"]?.toString(),
    supervisorApproval:
        json["supervisor_approval"] != null &&
            json["supervisor_approval"] is Map
        ? LeaveApprovalModel.fromJson(
            Map<String, dynamic>.from(json["supervisor_approval"]),
          )
        : null,
    adminApproval:
        json["admin_approval"] != null && json["admin_approval"] is Map
        ? LeaveApprovalModel.fromJson(
            Map<String, dynamic>.from(json["admin_approval"]),
          )
        : null,
    finalStatus: json["final_status"]?.toString(),
    appliedAt: json["applied_at"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "leave_id": leaveId,
    "leave_type": leaveType,
    "start_date": startDate,
    "end_date": endDate,
    "total_days": totalDays,
    "reason": reason,
    "supervisor_approval": supervisorApproval?.toJson(),
    "admin_approval": adminApproval?.toJson(),
    "final_status": finalStatus,
    "applied_at": appliedAt,
  };

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class LeaveApprovalModel {
  final String? status;
  final dynamic reviewedBy;
  final String? remarks;
  final String? actionAt;

  LeaveApprovalModel({
    this.status,
    this.reviewedBy,
    this.remarks,
    this.actionAt,
  });

  factory LeaveApprovalModel.fromJson(Map<String, dynamic> json) =>
      LeaveApprovalModel(
        status: json["status"]?.toString(),
        reviewedBy: json["reviewed_by"],
        remarks: json["remarks"]?.toString(),
        actionAt: json["action_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "reviewed_by": reviewedBy,
    "remarks": remarks,
    "action_at": actionAt,
  };
}

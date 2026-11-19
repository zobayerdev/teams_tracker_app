import 'dart:convert';

TourHistoryResponseModel tourHistoryResponseModelFromJson(String str) =>
    TourHistoryResponseModel.fromJson(json.decode(str));

String tourHistoryResponseModelToJson(TourHistoryResponseModel data) =>
    json.encode(data.toJson());

class CreateTourRequestModel {
  final String title;
  final String destination;
  final String startDate;
  final String endDate;
  final String purpose;
  final num estTransport;
  final num estDa;
  final num estHotel;
  final num estOther;

  CreateTourRequestModel({
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.purpose,
    this.estTransport = 0.0,
    this.estDa = 0.0,
    this.estHotel = 0.0,
    this.estOther = 0.0,
  });

  Map<String, dynamic> toJson() => {
    "title": title,
    "destination": destination,
    "start_date": startDate,
    "end_date": endDate,
    "purpose": purpose,
    "est_transport": estTransport,
    "est_da": estDa,
    "est_hotel": estHotel,
    "est_other": estOther,
  };
}

class CreateTourResponseModel {
  final bool? status;
  final String? message;
  final dynamic data;

  CreateTourResponseModel({this.status, this.message, this.data});

  factory CreateTourResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateTourResponseModel(
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

class TourHistoryResponseModel {
  final bool? status;
  final String? message;
  final TourSummaryModel? summary;
  final List<TourModel> data;

  TourHistoryResponseModel({
    this.status,
    this.message,
    this.summary,
    this.data = const [],
  });

  factory TourHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      TourHistoryResponseModel(
        status: json["status"] is bool
            ? json["status"]
            : (json["status"] == 1 || json["status"] == "true"),
        message: json["message"]?.toString(),
        summary: json["summary"] != null && json["summary"] is Map
            ? TourSummaryModel.fromJson(Map<String, dynamic>.from(json["summary"]))
            : null,
        data: json["data"] == null
            ? []
            : List<TourModel>.from(
                (json["data"] as List).map(
                  (x) => TourModel.fromJson(
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

class TourSummaryModel {
  final int totalTours;
  final int approved;
  final int pending;
  final int rejected;
  final num totalApprovedBudget;

  TourSummaryModel({
    this.totalTours = 0,
    this.approved = 0,
    this.pending = 0,
    this.rejected = 0,
    this.totalApprovedBudget = 0,
  });

  factory TourSummaryModel.fromJson(Map<String, dynamic> json) =>
      TourSummaryModel(
        totalTours: int.tryParse(json["total_tours"]?.toString() ?? '') ?? 0,
        approved: int.tryParse(json["approved"]?.toString() ?? '') ?? 0,
        pending: int.tryParse(json["pending"]?.toString() ?? '') ?? 0,
        rejected: int.tryParse(json["rejected"]?.toString() ?? '') ?? 0,
        totalApprovedBudget:
            num.tryParse(json["total_approved_budget"]?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "total_tours": totalTours,
    "approved": approved,
    "pending": pending,
    "rejected": rejected,
    "total_approved_budget": totalApprovedBudget,
  };
}

class TourModel {
  final int tourId;
  final String title;
  final String destination;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String purpose;
  final ExpenseBreakdownModel expenseBreakdown;
  final num totalEstimatedBudget;
  final String status;
  final num? approvedBudget;
  final TourReviewDetailsModel? reviewDetails;
  final String? submittedAt;

  TourModel({
    required this.tourId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.totalDays = 0,
    this.purpose = '',
    required this.expenseBreakdown,
    this.totalEstimatedBudget = 0,
    this.status = 'pending',
    this.approvedBudget,
    this.reviewDetails,
    this.submittedAt,
  });

  factory TourModel.fromJson(Map<String, dynamic> json) => TourModel(
    tourId: int.tryParse(json["tour_id"]?.toString() ?? '') ?? 0,
    title: json["title"]?.toString() ?? '',
    destination: json["destination"]?.toString() ?? '',
    startDate: json["start_date"]?.toString() ?? '',
    endDate: json["end_date"]?.toString() ?? '',
    totalDays: int.tryParse(json["total_days"]?.toString() ?? '') ?? 0,
    purpose: json["purpose"]?.toString() ?? '',
    expenseBreakdown: json["expense_breakdown"] != null &&
            json["expense_breakdown"] is Map
        ? ExpenseBreakdownModel.fromJson(
            Map<String, dynamic>.from(json["expense_breakdown"]),
          )
        : ExpenseBreakdownModel(),
    totalEstimatedBudget:
        num.tryParse(json["total_estimated_budget"]?.toString() ?? '') ?? 0,
    status: json["status"]?.toString() ?? 'pending',
    approvedBudget: num.tryParse(json["approved_budget"]?.toString() ?? ''),
    reviewDetails: json["review_details"] != null &&
            json["review_details"] is Map
        ? TourReviewDetailsModel.fromJson(
            Map<String, dynamic>.from(json["review_details"]),
          )
        : null,
    submittedAt: json["submitted_at"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "tour_id": tourId,
    "title": title,
    "destination": destination,
    "start_date": startDate,
    "end_date": endDate,
    "total_days": totalDays,
    "purpose": purpose,
    "expense_breakdown": expenseBreakdown.toJson(),
    "total_estimated_budget": totalEstimatedBudget,
    "status": status,
    "approved_budget": approvedBudget,
    "review_details": reviewDetails?.toJson(),
    "submitted_at": submittedAt,
  };
}

class ExpenseBreakdownModel {
  final num transportTa;
  final num dailyAllowanceDa;
  final num hotel;
  final num other;

  ExpenseBreakdownModel({
    this.transportTa = 0,
    this.dailyAllowanceDa = 0,
    this.hotel = 0,
    this.other = 0,
  });

  factory ExpenseBreakdownModel.fromJson(Map<String, dynamic> json) =>
      ExpenseBreakdownModel(
        transportTa:
            num.tryParse(json["transport_ta"]?.toString() ?? '') ?? 0,
        dailyAllowanceDa:
            num.tryParse(json["daily_allowance_da"]?.toString() ?? '') ?? 0,
        hotel: num.tryParse(json["hotel"]?.toString() ?? '') ?? 0,
        other: num.tryParse(json["other"]?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "transport_ta": transportTa,
    "daily_allowance_da": dailyAllowanceDa,
    "hotel": hotel,
    "other": other,
  };
}

class TourReviewDetailsModel {
  final String? reviewedBy;
  final String? remarks;
  final String? actionAt;

  TourReviewDetailsModel({
    this.reviewedBy,
    this.remarks,
    this.actionAt,
  });

  factory TourReviewDetailsModel.fromJson(Map<String, dynamic> json) =>
      TourReviewDetailsModel(
        reviewedBy: json["reviewed_by"]?.toString(),
        remarks: json["remarks"]?.toString(),
        actionAt: json["action_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "reviewed_by": reviewedBy,
    "remarks": remarks,
    "action_at": actionAt,
  };
}

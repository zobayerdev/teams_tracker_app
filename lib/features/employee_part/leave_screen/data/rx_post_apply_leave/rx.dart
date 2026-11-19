import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';
import 'api.dart';

final class PostApplyLeaveRx extends RxResponseInt<Map> {
  final api = PostApplyLeaveApi.instance;

  String message = "Something went wrong";

  PostApplyLeaveRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> postApplyLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      Map<String, dynamic> data = {
        "leave_type": leaveType,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
      };

      Map resdata = await api.postApplyLeave(data);
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    message =
        data["message"]?.toString() ?? "Leave application submitted successfully.";
    customToastMessage('Success', message);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Failed to submit leave application';
    log(error.toString());

    if (error is DioException) {
      final res = error.response?.data;
      if (res is Map && res["message"] != null) {
        message = res["message"].toString();
      } else if (res is String && res.isNotEmpty) {
        message = res;
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        message = "Check Your Network Connection";
      }
    }

    customToastMessage('Error', message);
    return false;
  }
}

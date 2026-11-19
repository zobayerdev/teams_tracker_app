import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';
import 'api.dart';

final class PostCreateCustomerRx extends RxResponseInt<Map> {
  final api = PostCreateCustomerApi.instance;

  String message = "Something went wrong";

  PostCreateCustomerRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> postCreateCustomer({
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required num latitude,
    required num longitude,
    required int createdBy,
  }) async {
    try {
      Map<String, dynamic> data = {
        "shop_name": shopName,
        "owner_name": ownerName,
        "phone": phone,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "created_by": createdBy,
      };

      Map resdata = await api.postCreateCustomer(data);
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    message = data["message"]?.toString() ?? "Customer created successfully.";
    customToastMessage('Success', message);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Failed to create customer';
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

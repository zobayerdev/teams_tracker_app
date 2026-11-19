import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';
import 'api.dart';

final class PostCreateOrderRx extends RxResponseInt<Map> {
  final api = PostCreateOrderApi.instance;

  String message = "Something went wrong";

  PostCreateOrderRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> postCreateOrder({
    required String shopName,
    required String shopPhone,
    String? phone,
    String? ownerName,
    String? address,
    num? latitude,
    num? longitude,
    required int createdBy,
    String paymentStatus = 'due',
    String? note,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      Map<String, dynamic> data = {
        "shop_name": shopName,
        "shop_phone": shopPhone,
        "phone": phone ?? shopPhone,
        if (ownerName != null && ownerName.isNotEmpty) "owner_name": ownerName,
        if (address != null && address.isNotEmpty) "address": address,
        "latitude": ?latitude,
        "longitude": ?longitude,
        "created_by": createdBy,
        "payment_status": paymentStatus,
        if (note != null && note.isNotEmpty) "note": note,
        "items": items,
      };

      Map resdata = await api.postCreateOrder(data);
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    message = data["message"]?.toString() ?? "Order created successfully.";
    customToastMessage('Success', message);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Failed to create order';
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

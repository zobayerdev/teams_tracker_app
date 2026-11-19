import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';
import 'api.dart';

final class GetProductRx extends RxResponseInt<Map> {
  final api = GetProductApi.instance;

  String message = "Something went wrong";

  GetProductRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> fetchProduct() async {
    try {
      Map resdata = await api.getProduct();
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Failed to fetch products';
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

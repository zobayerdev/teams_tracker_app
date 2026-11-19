import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/features/auth_screen/data/signup_data.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';

final class SignupRx extends RxResponseInt<Map> {
  final api = SignupApi.instance;

  String message = "Something went wrong";

  SignupRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> postSignup({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? role,
    String? designation,
    int? age,
    String? nid,
    String? dob,
    String? fatherName,
    String? motherName,
    String? religion,
    String? bloodGroup,
    String? education,
    String? presentAddress,
    String? permanentAddress,
    num? salary,
    int? supervisorId,
  }) async {
    try {
      Map<String, dynamic> data = {
        "name": name,
        "phone": phone,
        "mobile": phone,
        "password": password,
        if (email != null && email.trim().isNotEmpty) "email": email.trim(),
        if (role != null && role.trim().isNotEmpty) ...{
          "role": role.trim(),
          "role_type": role.trim(),
        },
        if (designation != null && designation.trim().isNotEmpty)
          "designation": designation.trim(),
        "age": ?age,
        if (nid != null && nid.trim().isNotEmpty) "nid": nid.trim(),
        if (dob != null && dob.trim().isNotEmpty) "dob": dob.trim(),
        if (fatherName != null && fatherName.trim().isNotEmpty)
          "father_name": fatherName.trim(),
        if (motherName != null && motherName.trim().isNotEmpty)
          "mother_name": motherName.trim(),
        if (religion != null && religion.trim().isNotEmpty)
          "religion": religion.trim(),
        if (bloodGroup != null && bloodGroup.trim().isNotEmpty)
          "blood_group": bloodGroup.trim(),
        if (education != null && education.trim().isNotEmpty)
          "education": education.trim(),
        if (presentAddress != null && presentAddress.trim().isNotEmpty)
          "present_address": presentAddress.trim(),
        if (permanentAddress != null && permanentAddress.trim().isNotEmpty)
          "permanent_address": permanentAddress.trim(),
        "salary": ?salary,
        "supervisor_id": ?supervisorId,
      };

      Map resdata = await api.postSignup(data);
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    message =
        data["message"]?.toString() ??
        "Registration successful! You can now log in.";
    customToastMessage('Success', message);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Something went wrong';
    log(error.toString());

    if (error is DioException) {
      final res = error.response?.data;
      if (res is Map && res["message"] != null) {
        message = res["message"].toString();
      } else if (res is String && res.isNotEmpty) {
        message = res;
      } else {
        message =
            error.response?.statusMessage ??
            "Registration failed. Please check your inputs.";
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

typedef PostSignupRx = SignupRx;
typedef RegisterRx = SignupRx;

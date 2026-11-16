import 'package:flutter_test/flutter_test.dart';
import 'package:location_tracker/features/employee_part/profile_screen/model/employee_profile_model.dart';
import 'package:location_tracker/helpers/default_response_model.dart';

void main() {
  test('DefaultResponse parses API JSON correctly', () {
    final Map<String, dynamic> mockJson = {
      "status": true,
      "code": 200,
      "message": "Operation successful",
    };

    final response = DefaultResponse.fromJson(mockJson);

    expect(response.success, true);
    expect(response.code, 200);
    expect(response.message, "Operation successful");

    final serialized = response.toJson();
    expect(serialized["status"], true);
    expect(serialized["code"], 200);
    expect(serialized["message"], "Operation successful");
  });

  test('EmployeeProfileResponseModel parses API JSON correctly', () {
    final Map<String, dynamic> mockJson = {
      "status": true,
      "message": "Profile data fetched successfully.",
      "data": {
        "profile": {
          "id": 13,
          "name": "Md. Zobayer Hasan Nayem",
          "email": "wiwygu@mailinator.com",
          "mobile": "+1 (761) 408-2145",
          "designation": "Sales Representative.",
          "role_type": "sales_representative",
          "status": "active",
          "age": 26,
          "nid": "6465216122",
          "dob": "2007-02-28",
          "father_name": "M. A Hasan",
          "mother_name": "Khadija Hasan",
          "religion": "Islam",
          "blood_group": "O+",
          "education": "Bsc In Computer Science and Engineering",
          "present_address": "52 Kazi Garden, North Road, Dhanmondi, Dhaka",
          "permanent_address": "52 Kazi Garden, North Road, Dhanmondi, Dhaka",
          "salary": 35000,
          "member_since": "17 Nov, 2026"
        },
        "supervisor": {
          "id": 2,
          "name": "nayem office",
          "phone": "01615257555",
          "email": "nayem.bdcit@gmail.com",
          "designation": "Supervisor"
        },
        "statistics": {
          "total_orders": 12,
          "total_sales": 50000,
          "total_collected": 35000,
          "pending_leaves": 1,
          "approved_tours": 3
        }
      }
    };

    final response = EmployeeProfileResponseModel.fromJson(mockJson);

    expect(response.status, true);
    expect(response.message, "Profile data fetched successfully.");
    expect(response.data?.profile?.id, 13);
    expect(response.data?.profile?.name, "Md. Zobayer Hasan Nayem");
    expect(response.data?.profile?.salary, 35000);
    expect(response.data?.profile?.bloodGroup, "O+");
    expect(response.data?.supervisor?.name, "nayem office");
    expect(response.data?.statistics?.totalSales, 50000);
    expect(response.data?.statistics?.approvedTours, 3);
  });
}

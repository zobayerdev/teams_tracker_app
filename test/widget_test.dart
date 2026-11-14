import 'package:flutter_test/flutter_test.dart';
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
}

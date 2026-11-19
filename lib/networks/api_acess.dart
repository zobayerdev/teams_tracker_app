import 'package:location_tracker/features/auth_screen/data/login_rx.dart';
import 'package:location_tracker/features/auth_screen/data/logout_rx.dart';
import 'package:location_tracker/features/auth_screen/data/signup_rx.dart';
import 'package:location_tracker/features/employee_part/attendence_screen/data/rx_get_attendance/rx.dart';
import 'package:location_tracker/features/employee_part/catalog_screen/data/rx_get_product/rx.dart';
import 'package:location_tracker/features/employee_part/home_screen/data/rx_get_customers/rx.dart';
import 'package:location_tracker/features/employee_part/home_screen/data/rx_post_attendance/rx.dart';
import 'package:location_tracker/features/employee_part/home_screen/data/rx_post_create_customer/rx.dart';
import 'package:location_tracker/features/employee_part/leave_screen/data/rx_get_my_leaves/rx.dart';
import 'package:location_tracker/features/employee_part/leave_screen/data/rx_post_apply_leave/rx.dart';
import 'package:location_tracker/features/employee_part/order_screen/data/rx_get_order/rx.dart';
import 'package:location_tracker/features/employee_part/order_screen/data/rx_post_create_order/rx.dart';
import 'package:location_tracker/features/employee_part/profile_screen/data/get_emp_profile_rx.dart';
import 'package:location_tracker/features/employee_part/profile_screen/data/rx_post_change_password/rx.dart';
import 'package:location_tracker/features/employee_part/profile_screen/data/rx_post_update_profile/rx.dart';
import 'package:location_tracker/features/employee_part/tour_plan_screen/data/rx_get_my_tours/rx.dart';
import 'package:location_tracker/features/employee_part/tour_plan_screen/data/rx_post_apply_tour/rx.dart';
import 'package:rxdart/subjects.dart';

LoginRx loginRxObj = LoginRx(empty: {}, dataFetcher: BehaviorSubject<Map>());

PostLoginRx postLoginRxObj = loginRxObj;

SignupRx signupRxObj = SignupRx(empty: {}, dataFetcher: BehaviorSubject<Map>());

PostSignupRx postSignupRxObj = signupRxObj;

LogoutRx logoutRxObj = LogoutRx(empty: {}, dataFetcher: BehaviorSubject<Map>());

GetEmpProfileRx getEmpProfileRxObj = GetEmpProfileRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

PostAttendanceRx postAttendanceRxObj = PostAttendanceRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

GetAttendanceRx getAttendanceRxObj = GetAttendanceRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

PostCreateCustomerRx postCreateCustomerRxObj = PostCreateCustomerRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

GetProductRx getProductRxObj = GetProductRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

GetCustomerRx getCustomerRxObj = GetCustomerRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

PostCreateOrderRx postCreateOrderRxObj = PostCreateOrderRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

GetOrderRx getOrderRxObj = GetOrderRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

PostApplyTourRx postApplyTourRxObj = PostApplyTourRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

GetMyToursRx getMyToursRxObj = GetMyToursRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

PostApplyLeaveRx postApplyLeaveRxObj = PostApplyLeaveRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

GetMyLeavesRx getMyLeavesRxObj = GetMyLeavesRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

PostUpdateProfileRx postUpdateProfileRxObj = PostUpdateProfileRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);

PostChangePasswordRx postChangePasswordRxObj = PostChangePasswordRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map>(),
);




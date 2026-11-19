import 'package:location_tracker/features/auth_screen/data/login_rx.dart';
import 'package:location_tracker/features/auth_screen/data/logout_rx.dart';
import 'package:location_tracker/features/auth_screen/data/signup_rx.dart';
import 'package:location_tracker/features/employee_part/home_screen/data/rx_post_attendance/rx.dart';
import 'package:location_tracker/features/employee_part/profile_screen/data/get_emp_profile_rx.dart';
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

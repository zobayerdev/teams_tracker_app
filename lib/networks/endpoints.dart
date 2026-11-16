// ignore_for_file: unused_import, constant_identifier_names

import 'dart:io';
import 'package:flutter/foundation.dart';

const String baseUrl = "https://location.zobayer.xyz/user";

final class NetworkConstants {
  NetworkConstants._();
  static const ACCEPT = "Accept";
  static const APP_KEY = "App-Key";
  static const ACCEPT_LANGUAGE = "Accept-Language";
  static const ACCEPT_LANGUAGE_VALUE = "en";
  static const APP_KEY_VALUE = String.fromEnvironment("APP_KEY_VALUE");
  static const ACCEPT_TYPE = "application/json";
  static const AUTHORIZATION = "Authorization";
  static const CONTENT_TYPE = "content-Type";
}

final class Endpoints {
  Endpoints._();

  // * Auth API ENDPOINT
  static String logIn() => "/api_login.php";
  static String signUpUrl() => "/api_register.php";
  static String logOut() => "/api_logout.php";

  // * Employee API
  static String getEmployeeProfile() => "/api_profile.php";
}

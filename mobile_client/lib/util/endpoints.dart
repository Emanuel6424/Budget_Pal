import 'dart:io';

class Endpoints {
  static String getBaseUrl() {
    // Use the environment variable if available, otherwise default to localhost.
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }

  static String createUserUrl() {
    return '${getBaseUrl()}/user/new';
  }

  static String loginUserUrl() {
    return '${getBaseUrl()}/user/post/login';
  }

  static String getUserByEmailUrl(String email) {
    return '${getBaseUrl()}/user/get/email/$email';
  }
}

import 'dart:io';

class Endpoints {
  static const String _productionUrl =
      'https://budgetpal-production.up.railway.app/api';

  static String getBaseUrl() {
    // Returns production URL when not running on a local emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api'; // local emulator
    } else {
      return _productionUrl; // production
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

  static String createAccountUrl() {
    return '${getBaseUrl()}/account/new';
  }

  static String getAccountUrl(int accountId) {
    return '${getBaseUrl()}/account/$accountId';
  }

  static String createTransactionUrl() {
    return '${getBaseUrl()}/transaction/new';
  }

  static String getTransactionsUrl(int accountId) {
    return '${getBaseUrl()}/transaction/account/$accountId';
  }

  // In util/endpoints.dart
  static String getBudgetStatusUrl(int budgetId) {
    return '${getBaseUrl()}/budget/$budgetId/status';
  }

  static String getRecentTransactionsUrl(int userId) {
    return '${getBaseUrl()}/transaction/recent/$userId';
  }

  // In util/endpoints.dart
  static String createBudgetUrl() {
    return '${getBaseUrl()}/budget/new';
  }
}

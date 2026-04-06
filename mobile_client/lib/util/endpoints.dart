import 'dart:io';

import 'package:flutter/foundation.dart';

class Endpoints {
  static const String _productionUrl =
      'https://budgetpal-production.up.railway.app/api';

  static String getBaseUrl() {
    if (kIsWeb) {
      return _productionUrl; // ✅ always use production on web
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api'; // local android emulator
    } else {
      return _productionUrl;
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

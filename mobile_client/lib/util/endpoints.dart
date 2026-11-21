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

  static String createAccountUrl() {
    return '${getBaseUrl()}/account/new';
  }

  static String getAccountUrl(int accountId) {
    return '${getBaseUrl()}/account/$accountId';
  }

  static String updateAccountUrl(int accountId) {
    return '${getBaseUrl()}/account/$accountId';
  }

  static String deleteAccountUrl(int accountId, int userId) {
    return '${getBaseUrl()}/account/$accountId?userId=$userId';
  }

  static String createTransactionUrl() {
    return '${getBaseUrl()}/transaction/new';
  }

  static String getTransactionsUrl(int accountId) {
    return '${getBaseUrl()}/transaction/account/$accountId';
  }

  static String updateTransactionUrl(int transactionId) {
    return '${getBaseUrl()}/transaction/$transactionId';
  }

  static String deleteTransactionUrl(int transactionId, int userId) {
    return '${getBaseUrl()}/transaction/$transactionId?userId=$userId';
  }

  // In util/endpoints.dart
  static String getBudgetStatusUrl(int budgetId) {
    return '${getBaseUrl()}/budget/$budgetId/status';
  }

  static String getBudgetTransactionsUrl(int budgetId) {
    return '${getBaseUrl()}/budget/$budgetId/transactions';
  }

  static String getRecentTransactionsUrl(int userId) {
    return '${getBaseUrl()}/transaction/recent/$userId';
  }

  // In util/endpoints.dart
  static String createBudgetUrl() {
    return '${getBaseUrl()}/budget/new';
  }

  static String updateBudgetUrl(int budgetId) {
    return '${getBaseUrl()}/budget/$budgetId';
  }

  static String deleteBudgetUrl(int budgetId, int userId) {
    return '${getBaseUrl()}/budget/$budgetId?userId=$userId';
  }

  static String getNotificationsUrl(int userId) {
    return '${getBaseUrl()}/notification/$userId';
  }

  static String markNotificationReadUrl(int notificationId, int userId) {
    return '${getBaseUrl()}/notification/$notificationId/read?userId=$userId';
  }
}

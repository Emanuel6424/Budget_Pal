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

  static String getAccountUrl(String email) {
    return '${getBaseUrl()}/account/get/email/$email';
  }

  static String getTasksUrl(int accountId) {
    return '${getBaseUrl()}/account/get/$accountId/tasks';
  }

  static String createTaskUrl() {
    return '${getBaseUrl()}/account/task/new';
  }

  static String updateTaskUrl(int accountId, int taskId) {
    return '${getBaseUrl()}/account/$accountId/task/put/$taskId';
  }

  static String deleteTaskUrl(int accountId, int taskId) {
    return '${getBaseUrl()}/account/$accountId/task/delete/$taskId';
  }

  static String updatePreferencesUrl(int accountId) {
    return '${getBaseUrl()}/account/put/$accountId/preferences';
  }
}

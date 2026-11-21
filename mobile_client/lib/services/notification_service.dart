// services/notification_service.dart
import 'dart:convert';

import 'package:budget_pal/models/notification.dart';
import 'package:budget_pal/util/endpoints.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final headers = {'Content-Type': 'application/json'};

  Future<List<BudgetNotification>> getNotifications(int userId) async {
    try {
      var url = Uri.parse(Endpoints.getNotificationsUrl(userId));
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> fetched = jsonDecode(utf8.decode(response.bodyBytes));
        return fetched.map((json) => BudgetNotification.fromJson(json)).toList();
      } else {
        print('Failed to fetch notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<bool> markRead(int notificationId, int userId) async {
    try {
      var url = Uri.parse(Endpoints.markNotificationReadUrl(notificationId, userId));
      final response = await http.post(url, headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification read: $e');
      return false;
    }
  }
}

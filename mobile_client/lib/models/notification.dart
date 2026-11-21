// models/notification.dart
class BudgetNotification {
  final int id;
  final int budgetId;
  final String type;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  BudgetNotification({
    required this.id,
    required this.budgetId,
    required this.type,
    required this.title,
    required this.body,
    required this.readAt,
    required this.createdAt,
  });

  bool get isUnread => readAt == null;

  factory BudgetNotification.fromJson(Map<String, dynamic> json) {
    return BudgetNotification(
      id: json['id'],
      budgetId: json['budgetId'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

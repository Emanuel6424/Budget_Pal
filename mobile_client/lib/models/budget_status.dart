// models/budget_status.dart
class BudgetStatus {
  final int id;
  final String name;
  final double limit;
  final double spent;
  final double remaining;
  final double percentUsed;
  final String startDate;
  final String endDate;

  BudgetStatus({
    required this.id,
    required this.name,
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    required this.startDate,
    required this.endDate,
  });

  factory BudgetStatus.fromJson(Map<String, dynamic> json) {
    return BudgetStatus(
      id: json['id'],
      name: json['name'],
      limit: json['limit'].toDouble(),
      spent: json['spent'].toDouble(),
      remaining: json['remaining'].toDouble(),
      percentUsed: json['percentUsed'].toDouble(),
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }
}

class Budget {
  final int id;
  final String name;
  final double limitAmount;
  final String period;
  final String startDate;
  final String endDate;
  final bool active;
  final int categoryId;

  Budget({
    required this.id,
    required this.name,
    required this.limitAmount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.active,
    required this.categoryId,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      limitAmount: json['limitAmount'].toDouble(),
      period: json['period'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      active: json['isActive'] ?? true,
      categoryId: json['categoryId'] ?? 0, // Default to 0 if null
    );
  }
}

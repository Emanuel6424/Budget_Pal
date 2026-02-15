class Transaction {
  final int id;
  final int accountId;
  final DateTime date;
  final String description;
  final String merchant;
  final double amount;
  final String type;
  final int categoryId;

  Transaction({
    required this.id,
    required this.accountId,
    required this.date,
    required this.description,
    required this.merchant,
    required this.amount,
    required this.type,
    required this.categoryId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      accountId: json['accountId'],
      date: DateTime.parse(json['date']), // Parse the string to DateTime
      description: json['description'],
      merchant: json['merchant'],
      amount: json['amount'].toDouble(), // Also ensure amount is double
      type: json['type'],
      categoryId: json['categoryId'],
    );
  }
}

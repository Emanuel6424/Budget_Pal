class Account {
  final int id;
  final String name;
  final String type;
  final String accountNumber;
  final double balance;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.accountNumber,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      accountNumber: json['accountNumber'],
      balance: json['balance'],
    );
  }
}

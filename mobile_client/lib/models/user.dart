import 'package:budget_pal/models/account.dart';

class User {
  late final int id;
  String firstname;
  String lastname;
  String email;
  List<Account> accounts;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.accounts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    User newUser = User(
      id: json['id'],
      firstname: json['firstName'],
      lastname: json['lastName'],
      email: json['email'],
      accounts: (json['accounts'] as List)
          .map((accountJson) => Account.fromJson(accountJson))
          .toList(),
    );
    return newUser;
  }

  double get totalBalance {
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }
}

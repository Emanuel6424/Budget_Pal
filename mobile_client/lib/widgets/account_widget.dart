import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountWidget extends StatelessWidget {
  final String name;
  final String type;
  final String accountNumber;
  final double balance;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  AccountWidget({
    super.key,
    required this.name,
    required this.type,
    required this.accountNumber,
    required this.balance,
  });

  Map<String, IconData> accountTypeIcons = {
    "Checking": Icons.account_balance_wallet,
    "Savings": Icons.savings,
    "Retirement": Icons.beach_access,
    "Credit Card": Icons.credit_card,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(accountTypeIcons[type], size: 30, color: Colors.black),
                Text(accountNumber),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(type + " Account"),
                ),
                Text(
                  currencyFormat.format(balance),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

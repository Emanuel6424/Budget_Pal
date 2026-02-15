import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountHeaderWidget extends StatelessWidget {
  final String name;
  final String type;
  final String accountNumber;
  final double balance;
  final currencyFormat = NumberFormat.currency(locale: "en_US", symbol: '\$');

  AccountHeaderWidget({
    super.key,
    required this.name,
    required this.type,
    required this.accountNumber,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(type + " Account * " + accountNumber),
            ),
            Text(
              currencyFormat.format(balance),
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

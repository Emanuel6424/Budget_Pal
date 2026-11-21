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
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(name, style: textTheme.titleMedium),
              subtitle: Text(
                "$type Account • $accountNumber",
                style: textTheme.bodySmall,
              ),
            ),
            Text(
              currencyFormat.format(balance),
              style: textTheme.titleLarge?.copyWith(fontSize: 34),
            ),
          ],
        ),
      ),
    );
  }
}
